/// E'LON BERISH RUXSATI — `GET mobile/employer/vacancy-access`.
///
/// Qoida serverda ikki bosqichli (backend: services/employerVacancy.service):
///   1. Operator kompaniya ma'lumotlarini TASDIQLAMAGUNCHA ish beruvchi
///      umuman e'lon bera olmaydi (ilovada ham, saytda ham, botda ham).
///   2. Tasdiqlangach `limit` tagacha e'lon bera oladi.
///
/// ⚠️ Bu model faqat UI uchun — tugmani ochish/yopish va sababni ko'rsatish.
/// Server `POST mobile/employer/vacancies` da baribir o'zi tekshiradi
/// (403 tasdiqlanmagan · 402 tarif faol emas · 409 limit to'ldi).
class VacancyAccessModel {
  /// Operator kompaniyani tasdiqlaganmi (`submission_status='tasdiqlangan'`).
  final bool approved;

  /// Hozir yangi e'lon bera oladimi.
  final bool canCreate;

  /// `canCreate == false` bo'lsa sabab kodi:
  /// `pending_review` · `rejected` · `tariff_inactive` · `limit_reached` ·
  /// `no_employer`.
  final String? reasonCode;

  /// Foydalanuvchiga ko'rsatiladigan tayyor matn (serverdan keladi —
  /// ilovada takrorlab yozilmasin, operator matnni bir joydan o'zgartiradi).
  final String? reason;

  /// Nechta e'lon mumkin. `null` = cheksiz.
  final int? limit;

  /// Hozir nechta e'loni bor.
  final int used;

  /// Yana nechta bera oladi. `null` = cheksiz.
  final int? remaining;

  const VacancyAccessModel({
    required this.approved,
    required this.canCreate,
    this.reasonCode,
    this.reason,
    this.limit,
    this.used = 0,
    this.remaining,
  });

  /// Eski backend (endpoint yo'q) yoki tarmoq xatosi — tugma OCHIQ qoladi.
  /// Ilova serverdan oldin yangilansa foydalanuvchi qamalib qolmasin;
  /// haqiqiy to'siq baribir POST javobida ishlaydi.
  static const VacancyAccessModel unknown =
      VacancyAccessModel(approved: true, canCreate: true);

  factory VacancyAccessModel.fromJson(Map<String, dynamic> json) {
    int? asInt(dynamic v) => v == null ? null : int.tryParse(v.toString());
    return VacancyAccessModel(
      approved: json['approved'] == true,
      canCreate: json['can_create'] == true,
      reasonCode: json['reason_code'] as String?,
      reason: json['reason'] as String?,
      limit: asInt(json['limit']),
      used: asInt(json['used']) ?? 0,
      remaining: asInt(json['remaining']),
    );
  }
}
