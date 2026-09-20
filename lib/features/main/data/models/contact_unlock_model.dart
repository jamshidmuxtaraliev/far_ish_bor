/// PROMPT_OTKLIK_MOBILE.md §2 — ish beruvchining kontakt rejimi.
///
/// `tarifli`  → kontaktlar bepul, "Ochish" tugmasi umuman chizilmaydi.
/// `otklik`   → har bir nomzod `fee` evaziga ochiladi.
/// `tarifsiz` → otklik bilan bir xil ishlaydi (operator CRM'da rejimni yoqmagan).
enum AccessMode { tarifli, otklik, tarifsiz }

AccessMode accessModeFrom(String? raw) => switch (raw) {
      'tarifli' => AccessMode.tarifli,
      'tarifsiz' => AccessMode.tarifsiz,
      _ => AccessMode.otklik,
    };

class ContactAccessModel {
  final bool freeContacts;
  final AccessMode mode;

  /// Bitta nomzodni ochish narxi (so'm). Tarifli rejimda `0`.
  /// ⚠️ Hech qachon hardcode qilinmasin — admin CRM'da o'zgartiradi (§2).
  final int fee;

  /// Joriy balans (so'm); eski backend javobida bo'lmasligi mumkin.
  final int? balance;

  /// Nomzodlar bazasini ko'rish huquqi — odatda hammaga ochiq.
  final bool canSearchCandidates;

  // ── 30 KUNLIK OTKLIK KVOTASI (obuna yoki bir martalik paket) ──────────────
  // ⚠ Kontakt ochishda to'lov tartibi: 1) bepul → 2) KVOTA → 3) balansdan
  // `fee`. Ya'ni kvotasi bor ish beruvchidan pul YECHILMAYDI va balansi
  // bo'sh bo'lsa ham bloklanmasligi kerak.
  final int otklikAvailable;
  final int otklikTotal;
  final int otklikUsed;
  final String? otklikExpiresAt;

  /// Server hisoblab beradi: `free` | `quota` | `balance`.
  final String nextCharge;

  /// Joriy tarif/paket — bosh sahifadagi karta uchun.
  /// ⚠ Ish beruvchiga PUL QOLDIG'I ko'rsatilmaydi (balans kartasi olib
  /// tashlandi) — o'rniga aynan shu blok chiqadi.
  final EmployerPlan plan;

  const ContactAccessModel({
    required this.freeContacts,
    required this.mode,
    required this.fee,
    this.balance,
    this.canSearchCandidates = true,
    this.otklikAvailable = 0,
    this.otklikTotal = 0,
    this.otklikUsed = 0,
    this.otklikExpiresAt,
    this.nextCharge = 'balance',
    this.plan = const EmployerPlan(),
  });

  /// Qulf UI'si (yopiq karta + "Ochish" tugmasi) ko'rsatiladimi.
  bool get isOtklik => !freeContacts && mode != AccessMode.tarifli;

  /// Keyingi ochish kvotadan yechiladimi — shunda balans tekshirilmaydi.
  ///
  /// ⚠ `nextCharge` server javobi olingan PAYTDAGI holat: oxirgi kvota
  /// ishlatilgach u hamon `quota` bo'lib qoladi. Shuning uchun kvota sonlari
  /// ma'lum bo'lsa QOLDIQ hal qiladi; `otklik_*` yubormaydigan eski backendda
  /// esa `next_charge` ga tushamiz.
  bool get paysFromQuota =>
      hasQuotaPlan ? otklikAvailable > 0 : nextCharge == 'quota';

  /// Kvota (paket/obuna) umuman sotib olinganmi.
  bool get hasQuotaPlan => otklikTotal > 0;

  bool canAfford(int price) =>
      freeContacts || paysFromQuota || balance == null || balance! >= price;

  factory ContactAccessModel.fromJson(Map<String, dynamic> json) {
    final free = json['free_contacts'] as bool? ?? false;
    final available = (json['otklik_available'] as num?)?.toInt() ?? 0;
    return ContactAccessModel(
      freeContacts: free,
      mode: json['mode'] != null
          ? accessModeFrom(json['mode'] as String?)
          : (free ? AccessMode.tarifli : AccessMode.otklik),
      fee: (json['fee'] as num?)?.toInt() ?? 30000,
      balance: (json['balance'] as num?)?.toInt(),
      canSearchCandidates: json['can_search_candidates'] as bool? ?? true,
      otklikAvailable: available,
      otklikTotal: (json['otklik_total'] as num?)?.toInt() ?? 0,
      otklikUsed: (json['otklik_used'] as num?)?.toInt() ?? 0,
      otklikExpiresAt: json['otklik_expires_at'] as String?,
      // Eski backend `next_charge` yubormasa mavjud sonlardan tiklanadi.
      nextCharge: json['next_charge'] as String? ??
          (free ? 'free' : (available > 0 ? 'quota' : 'balance')),
      plan: EmployerPlan.fromJson(json['plan'] as Map<String, dynamic>?),
    );
  }

  ContactAccessModel copyWith({int? balance, int? otklikAvailable}) {
    final available = otklikAvailable ?? this.otklikAvailable;
    return ContactAccessModel(
      freeContacts: freeContacts,
      mode: mode,
      fee: fee,
      balance: balance ?? this.balance,
      canSearchCandidates: canSearchCandidates,
      otklikAvailable: available,
      otklikTotal: otklikTotal,
      otklikUsed: otklikUsed,
      otklikExpiresAt: otklikExpiresAt,
      plan: plan,
      // Kvota yechilgach "keyingi ochish" ham o'zgaradi — eski qiymat
      // qolib ketsa mijozga "otklikdan" deb ko'rsatib, so'ng 402 qaytardi.
      nextCharge: freeContacts
          ? 'free'
          : (hasQuotaPlan ? (available > 0 ? 'quota' : 'balance') : nextCharge),
    );
  }
}

/// Ish beruvchining JORIY TARIFI — `contact-access` javobidagi `plan` bloki.
///
/// ⚠ Ikki muddat ARALASHTIRILMASIN:
///   • [expiresAt]      — butun obuna/paket muddati (12 oylik ham bo'ladi);
///   • [cycleEndsAt]    — joriy 30 kunlik KALIT oynasi (qoldiq keyingi oyga
///     o'tmaydi, shuning uchun kalit qoldig'i yonida aynan shu ko'rsatiladi).
class EmployerPlan {
  /// `subscription` — obuna tarifi · `package` — bir martalik kalit paketi.
  final String? kind;

  /// Obuna nomi (masalan "Premium"). Paketda server nom yubormaydi —
  /// hamyon jadvalida nom ustuni yo'q, shuning uchun [label] uni o'zi qo'yadi.
  final String? name;
  final String? code;
  final String? expiresAt;
  final int? daysLeft;
  final String? cycleEndsAt;
  final int? cycleDaysLeft;
  final int? periodMonths;

  const EmployerPlan({
    this.kind,
    this.name,
    this.code,
    this.expiresAt,
    this.daysLeft,
    this.cycleEndsAt,
    this.cycleDaysLeft,
    this.periodMonths,
  });

  bool get hasPlan => kind != null;
  bool get isSubscription => kind == 'subscription';

  /// Kartada ko'rinadigan nom.
  String get label => (name?.isNotEmpty ?? false)
      ? name!
      : (kind == 'package' ? 'Kalit paketi' : 'Tarif tanlanmagan');

  factory EmployerPlan.fromJson(Map<String, dynamic>? json) {
    if (json == null || json['has_plan'] != true) return const EmployerPlan();
    return EmployerPlan(
      kind: json['kind'] as String?,
      name: json['name'] as String?,
      code: json['code'] as String?,
      expiresAt: json['expires_at'] as String?,
      daysLeft: (json['days_left'] as num?)?.toInt(),
      cycleEndsAt: json['cycle_ends_at'] as String?,
      cycleDaysLeft: (json['cycle_days_left'] as num?)?.toInt(),
      periodMonths: (json['period_months'] as num?)?.toInt(),
    );
  }
}

/// §6 — nomzod ochilgach ochiladigan uchta imkoniyat.
class ContactCapabilitiesModel {
  final String? phone;

  /// Ish beruvchi ↔ nomzod chat kaliti: `direct:e<employer_id>:a<anketa_id>`.
  final String? chatSessionKey;
  final bool interview;

  const ContactCapabilitiesModel({
    this.phone,
    this.chatSessionKey,
    this.interview = false,
  });

  bool get hasChat => (chatSessionKey ?? '').isNotEmpty;

  factory ContactCapabilitiesModel.fromJson(Map<String, dynamic> json) {
    final chat = json['chat'];
    return ContactCapabilitiesModel(
      phone: json['phone'] as String?,
      chatSessionKey:
          chat is Map ? chat['session_key'] as String? : chat as String?,
      interview: json['interview'] as bool? ?? true,
    );
  }
}

class ContactUnlockResultModel {
  final int anketaId;
  final bool charged;
  final bool free;
  final int fee;
  final int? balance;
  final String phone;
  final String? additionalContact;
  final ContactCapabilitiesModel? capabilities;

  /// Kvotadan yechildimi (`pay_source='wallet'`) — pul yechilmagan.
  final bool quotaCharged;

  /// Yechilgandan keyingi otklik qoldig'i (faqat kvota yo'lida keladi).
  final int? otklikRemaining;

  const ContactUnlockResultModel({
    this.anketaId = 0,
    required this.charged,
    required this.free,
    required this.fee,
    this.balance,
    required this.phone,
    this.additionalContact,
    this.capabilities,
    this.quotaCharged = false,
    this.otklikRemaining,
  });

  factory ContactUnlockResultModel.fromJson(Map<String, dynamic> json) {
    final unlock = json['unlock'];
    final caps = json['capabilities'];
    final phone = json['phone'] as String? ??
        (caps is Map ? caps['phone'] as String? : null) ??
        '';
    return ContactUnlockResultModel(
      anketaId: unlock is Map ? (unlock['anketa_id'] as num?)?.toInt() ?? 0 : 0,
      charged: json['charged'] as bool? ?? false,
      free: json['free'] as bool? ?? false,
      fee: (json['fee'] as num?)?.toInt() ?? 0,
      balance: (json['balance'] as num?)?.toInt(),
      phone: phone,
      additionalContact: json['additional_contact'] as String?,
      quotaCharged: json['quota_charged'] as bool? ??
          json['pay_source'] == 'wallet',
      otklikRemaining: (json['otklik_remaining'] as num?)?.toInt(),
      capabilities: caps is Map
          ? ContactCapabilitiesModel.fromJson(Map<String, dynamic>.from(caps))
          : (phone.isNotEmpty
              ? ContactCapabilitiesModel(phone: phone, interview: true)
              : null),
    );
  }
}

class ContactUnlockHistoryModel {
  final int id;
  final int anketaId;
  final int? vacancyId;
  final String trigger;
  final int amount;
  final String unlockedAt;

  const ContactUnlockHistoryModel({
    required this.id,
    required this.anketaId,
    this.vacancyId,
    required this.trigger,
    required this.amount,
    required this.unlockedAt,
  });

  factory ContactUnlockHistoryModel.fromJson(Map<String, dynamic> json) =>
      ContactUnlockHistoryModel(
        id: json['id'] as int,
        anketaId: json['anketa_id'] as int,
        vacancyId: json['vacancy_id'] as int?,
        trigger: json['trigger'] as String? ?? 'phone_view',
        amount: json['amount'] as int? ?? 0,
        unlockedAt: json['unlocked_at'] as String? ?? '',
      );

  bool get isFree => amount == 0;
}
