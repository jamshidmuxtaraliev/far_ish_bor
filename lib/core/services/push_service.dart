import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../features/auth/data/datasource/local/user_local_data_source.dart';
import '../../features/auth/domain/auth_repository/auth_repository.dart';
import 'get_it.dart';

/// FCM push — qurilma tomoni.
///
/// Backend tayyor edi, mobil tomoni YO'Q edi: `firebase_messaging` paketi
/// umuman qo'shilmagan, `google-services.json` esa ishlatilmay yotardi
/// (`push-check.js` → "Ro'yxatdan o'tgan qurilmalar: 0"). Bu fayl o'sha
/// bo'shliqni yopadi.
///
/// Zanjir: Firebase token → `POST /push/register` → `mobile_users.fcm_token`
/// → `notifier.fire(...)` → `fcm.channel.js` → qurilma.
///
/// ⚠ Token faqat foydalanuvchi KIRGANDAN keyin yuboriladi — `/push/register`
/// mobil auth talab qiladi va tokensiz 401 qaytaradi.
class PushService {
  PushService._();

  static final PushService instance = PushService._();

  final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();

  /// Bildirishnoma bosilganda ochiladigan yo'l (backend `route` maydoni).
  /// Ilova hali qurilmaganda kelgan bosishni ushlab turadi.
  static final ValueNotifier<String?> pendingRoute = ValueNotifier<String?>(null);

  bool _inited = false;
  String? _lastSentToken;

  /// Backend `templates.js → CH` bilan BIR XIL bo'lishi shart — Android'da
  /// mavjud bo'lmagan kanalga kelgan push standart kanalga tushib, ovoz va
  /// muhimlik sozlamalari yo'qoladi.
  static const _channels = <(String, String, String)>[
    ('jobup24_default', 'Umumiy', 'Umumiy bildirishnomalar'),
    ('jobup24_job', 'Ish va vakansiya', 'Yangi vakansiya va mos nomzodlar'),
    ('jobup24_app', 'Arizalar', 'Ariza va suhbat bosqichlari'),
    ('jobup24_chat', 'Xabarlar', 'Chat xabarlari'),
    ('jobup24_payment', "To'lov", "To'lov, balans va tarif"),
    ('jobup24_urgent', 'Muhim', 'Eslatma va ogohlantirishlar'),
  ];

  /// `main()` da Firebase ishga tushgach chaqiriladi.
  Future<void> init() async {
    if (_inited) return;
    _inited = true;

    await _initLocalNotifications();
    await _requestPermission();

    // Ilova OCHIQ turganda Android push'ni o'zi ko'rsatmaydi — banner'ni
    // biz chizamiz. iOS da esa tizimga ko'rsatishni ruxsat beramiz.
    FirebaseMessaging.onMessage.listen(_showForeground);

    // Bildirishnoma bosilib ilova OCHILDI (fonda edi).
    FirebaseMessaging.onMessageOpenedApp.listen((m) => _handleTap(m.data));

    // Ilova BUTUNLAY yopiq edi va push bilan ochildi.
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) _handleTap(initial.data);

    // Token aylanishi (qayta o'rnatish, tozalash) — serverdagisi eskirmasin.
    FirebaseMessaging.instance.onTokenRefresh.listen((t) {
      _lastSentToken = null;
      syncToken(force: true);
    });
  }

  Future<void> _initLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _local.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (details) {
        final payload = details.payload;
        if (payload == null || payload.isEmpty) return;
        try {
          _handleTap(Map<String, dynamic>.from(jsonDecode(payload) as Map));
        } catch (_) {/* buzuq payload — e'tiborsiz qoldiramiz */}
      },
    );

    if (!Platform.isAndroid) return;
    final android8 = _local.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    for (final (id, name, desc) in _channels) {
      await android8?.createNotificationChannel(
        AndroidNotificationChannel(id, name, description: desc, importance: Importance.high),
      );
    }
  }

  Future<void> _requestPermission() async {
    // Android 13+ da ham shu chaqiruv POST_NOTIFICATIONS so'raydi.
    await FirebaseMessaging.instance.requestPermission(alert: true, badge: true, sound: true);
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  /// Qurilma tokenini serverga yuboradi. Kirgandan keyin va ilova har
  /// ochilganda chaqiriladi — takror yuborish zararsiz (server `update`).
  ///
  /// [force] — token o'zgarganda keshni chetlab o'tish.
  Future<void> syncToken({bool force = false}) async {
    final authToken = getIt<UserLocalDatasource>().getToken();
    if (authToken.isEmpty) return; // kirmagan — /push/register 401 beradi

    String? token;
    try {
      token = await FirebaseMessaging.instance.getToken();
    } catch (e) {
      debugPrint('[push] token olinmadi: $e');
      return;
    }
    if (token == null || token.isEmpty) return;
    if (!force && token == _lastSentToken) return;

    final platform = Platform.isIOS ? 'ios' : 'android';
    final result = await getIt<AuthRepository>().registerPushToken(token, platform);
    result.fold(
      (e) => debugPrint('[push] register xatosi: ${e.errorMessage}'),
      (_) {
        _lastSentToken = token;
        debugPrint('[push] token saqlandi ($platform)');
      },
    );
  }

  /// Chiqishda chaqiriladi — tokenni serverdan ham, qurilmadan ham uzadi.
  /// ⚠ Buni o'tkazib yuborsangiz, telefonda boshqa hisobga kirilgandan keyin
  /// ham eski foydalanuvchining push'lari kelaverardi.
  Future<void> clear() async {
    _lastSentToken = null;
    try {
      await getIt<AuthRepository>().unregisterPushToken();
    } catch (_) {/* chiqish push tufayli to'xtab qolmasin */}
    try {
      await FirebaseMessaging.instance.deleteToken();
    } catch (_) {/* o'sha sabab */}
  }

  Future<void> _showForeground(RemoteMessage message) async {
    final n = message.notification;
    if (n == null) return;

    final channelId = message.data['channel_id']?.toString() ?? 'jobup24_default';
    await _local.show(
      message.hashCode,
      n.title,
      n.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          _channelName(channelId),
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: jsonEncode(message.data),
    );
  }

  static String _channelName(String id) {
    for (final (cid, name, _) in _channels) {
      if (cid == id) return name;
    }
    return 'Umumiy';
  }

  /// Bosilgan bildirishnomani yo'lga aylantiradi. Yo'lni o'qish va ekranga
  /// o'tkazish [pendingRoute] ni kuzatayotgan tomonda (`MyApp`) bo'ladi.
  void _handleTap(Map<String, dynamic> data) {
    final route = data['route']?.toString();
    if (route == null || route.isEmpty) return;
    pendingRoute.value = route;
  }
}

/// Fon (ilova yopiq) xabar ishlovchisi — TOP-LEVEL bo'lishi SHART, aks holda
/// Flutter uni alohida izolyatda topolmaydi va push jimgina yo'qoladi.
@pragma('vm:entry-point')
Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
  // Fonda Android bildirishnomani o'zi chizadi — bu yerda qo'shimcha ish
  // shart emas. Handler ro'yxatdan o'tgani `data` xabarlari yo'qolmasligi
  // uchun kerak.
}
