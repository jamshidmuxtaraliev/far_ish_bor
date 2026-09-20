import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_alice/alice.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:jobUp24/generated/l10n/l10n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/locale/locale_cubit.dart';
import 'core/services/connection_service.dart';
import 'core/services/get_it.dart';
import 'core/services/push_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/jb_palette.dart';
import 'core/theme/theme_cubit.dart';
import 'features/auth/presentation/logic/auth_bloc.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/billing/presentation/logic/billing_bloc.dart';
import 'features/chat/presentation/logic/chat_bloc.dart';
import 'features/faq/presentation/logic/faq_bloc.dart';
import 'features/main/presentation/logic/interview_bloc.dart';
import 'features/main/presentation/logic/vacancy_bloc.dart';
import 'features/notifications/presentation/logic/notification_bloc.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  await setupDI(alice: MyApp.alice);

  // FCM push. Firebase ishga tushmasa (masalan google-services.json yo'q
  // bo'lsa) ILOVA TO'XTAMASLIGI kerak — push bezak, kirish emas.
  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);
    await PushService.instance.init();
    // Kirgan foydalanuvchi bo'lsa token darhol serverga ketadi.
    await PushService.instance.syncToken();
  } catch (e) {
    debugPrint('[push] Firebase ishga tushmadi: $e');
  }
  WidgetsBinding.instance.addPostFrameCallback((_) {
    getIt<InternetCheckerService>().start();
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  static final alice = Alice(
    showNotification: kDebugMode,
    showInspectorOnShake: kDebugMode,
    navigatorKey: rootNavigatorKey,
  );

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>.value(value: getIt<ThemeCubit>()),
        BlocProvider<LocaleCubit>.value(value: getIt<LocaleCubit>()),
        BlocProvider<AuthBloc>.value(value: getIt<AuthBloc>()),
        BlocProvider<VacancyBloc>.value(value: getIt<VacancyBloc>()),
        BlocProvider<InterviewBloc>.value(value: getIt<InterviewBloc>()),
        BlocProvider<BillingBloc>.value(value: getIt<BillingBloc>()),
        BlocProvider<ChatBloc>.value(value: getIt<ChatBloc>()),
        BlocProvider<NotificationBloc>.value(value: getIt<NotificationBloc>()),
        BlocProvider<FaqBloc>.value(value: getIt<FaqBloc>()),
      ],
      child: BlocBuilder<LocaleCubit, Locale>(
        builder:
            (context, locale) => BlocBuilder<ThemeCubit, ThemeMode>(
              builder:
                  (context, themeMode) => MaterialApp(
                    title: 'Jobup24',
                    debugShowCheckedModeBanner: false,
                    theme: lightTheme(),
                    darkTheme: darkTheme(),
                    themeMode: themeMode,
                    locale: locale,
                    supportedLocales: S.delegate.supportedLocales,
                    localizationsDelegates: const [
                      S.delegate,
                      GlobalMaterialLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                    ],
                    navigatorKey: MyApp.alice.getNavigatorKey(),
                    home: const SplashScreen(),
                    builder: (context, child) {
                      // MaterialApp qaysi mavzuni tanlagan bo'lsa (light/dark/
                      // system), global palitrani o'shanga moslaymiz — pastdagi
                      // widget'lar qurilishidan oldin ishlaydi.
                      syncJbPalette(Theme.of(context).brightness);
                      return MediaQuery(
                        data: MediaQuery.of(
                          context,
                        ).copyWith(textScaler: const TextScaler.linear(1.0)),
                        child: Stack(
                          children: [
                            child!,
                            if (false)
                              Positioned(
                                bottom: 100,
                                right: 16,
                                child: FloatingActionButton.small(
                                  heroTag: 'alice_inspector_btn',
                                  onPressed: () => MyApp.alice.showInspector(),
                                  backgroundColor: Colors.red,
                                  child: const Icon(
                                    Icons.bug_report,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
            ),
      ),
    );
  }
}
