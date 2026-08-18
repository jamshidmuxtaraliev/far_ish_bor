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

  const ContactAccessModel({
    required this.freeContacts,
    required this.mode,
    required this.fee,
    this.balance,
    this.canSearchCandidates = true,
  });

  /// Qulf UI'si (yopiq karta + "Ochish" tugmasi) ko'rsatiladimi.
  bool get isOtklik => !freeContacts && mode != AccessMode.tarifli;

  bool canAfford(int price) => balance == null || balance! >= price;

  factory ContactAccessModel.fromJson(Map<String, dynamic> json) {
    final free = json['free_contacts'] as bool? ?? false;
    return ContactAccessModel(
      freeContacts: free,
      mode: json['mode'] != null
          ? accessModeFrom(json['mode'] as String?)
          : (free ? AccessMode.tarifli : AccessMode.otklik),
      fee: (json['fee'] as num?)?.toInt() ?? 30000,
      balance: (json['balance'] as num?)?.toInt(),
      canSearchCandidates: json['can_search_candidates'] as bool? ?? true,
    );
  }

  ContactAccessModel copyWith({int? balance}) => ContactAccessModel(
        freeContacts: freeContacts,
        mode: mode,
        fee: fee,
        balance: balance ?? this.balance,
        canSearchCandidates: canSearchCandidates,
      );
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

  const ContactUnlockResultModel({
    this.anketaId = 0,
    required this.charged,
    required this.free,
    required this.fee,
    this.balance,
    required this.phone,
    this.additionalContact,
    this.capabilities,
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
