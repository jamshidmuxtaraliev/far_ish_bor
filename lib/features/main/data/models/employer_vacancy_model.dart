import 'application_stats_model.dart';

class EmployerVacancyModel {
  final int id;
  final int? jobTypeId;
  final String? jobTypeName;
  final int? anketaCount;
  final int? salary;
  final String? deadline;
  final int? minAge;
  final int? maxAge;
  final String? status;
  /// `status == 'paused'` bo'lgan payt — "qachondan beri to'xtatilgan".
  final String? pausedAt;
  final String? comment;
  final String? createdAt;
  final int? applicationsCount;
  /// Otklik (ariza) statistikasi — PROMPT_VAKANSIYA_OTKLIKLARI §3.1.
  final ApplicationStatsModel applications;
  // Vakansiya-markazli oqim uchun badge sonlar (§4.1)
  final int mosCount;
  final int recommendedCount;

  EmployerVacancyModel({
    required this.id,
    this.jobTypeId,
    this.jobTypeName,
    this.anketaCount,
    this.salary,
    this.deadline,
    this.minAge,
    this.maxAge,
    this.status,
    this.pausedAt,
    this.comment,
    this.createdAt,
    this.applicationsCount,
    this.applications = ApplicationStatsModel.empty,
    this.mosCount = 0,
    this.recommendedCount = 0,
  });

  factory EmployerVacancyModel.fromJson(Map<String, dynamic> json) {
    final jobType = json['job_type'] as Map<String, dynamic>?;
    return EmployerVacancyModel(
      id: json['id'] as int? ?? 0,
      jobTypeId: json['job_type_id'] as int?,
      // Backend tanlangan tilda { id, name } qaytaradi; eski name_uz ga fallback
      jobTypeName: jobType?['name'] as String? ??
          jobType?['name_uz'] as String? ??
          jobType?['name_ru'] as String?,
      anketaCount: json['anketa_count'] as int?,
      salary: json['salary'] as int?,
      deadline: json['deadline'] as String?,
      minAge: json['min_age'] as int?,
      maxAge: json['max_age'] as int?,
      status: json['status'] as String?,
      pausedAt: json['paused_at'] as String?,
      comment: json['comment'] as String?,
      // Sequelize `createdAt` deb yuboradi (model `underscored` emas) —
      // faqat `created_at` o'qilsa kartadagi "N kun oldin" hech qachon chiqmaydi.
      createdAt: json['created_at'] as String? ?? json['createdAt'] as String?,
      applicationsCount: json['applications_count'] as int?,
      applications: ApplicationStatsModel.fromVacancyJson(json),
      mosCount: json['mos_count'] as int? ?? 0,
      recommendedCount: json['recommended_count'] as int? ?? 0,
    );
  }

  String get salaryDisplay {
    if (salary == null) return "Ko'rsatilmagan";
    final n = salary!;
    if (n >= 1000000) return "${(n / 1000000).toStringAsFixed(1)} mln so'm";
    return "$n so'm";
  }

  bool get isActive => status == 'active';

  /// Ish beruvchi vakansiyani vaqtincha to'xtatib turgan — sayt/ilovada
  /// ko'rinmaydi va yangi otklik qabul qilinmaydi (yozuvi saqlanadi).
  bool get isPaused => status == 'paused';

  /// Play/Pause tugmasi faqat shu holatlarda ma'noli — to'ldirilgan yoki
  /// bekor qilingan vakansiyani to'xtatib bo'lmaydi (backend 409 qaytaradi).
  bool get canTogglePause => status == 'active' || status == 'paused';

  /// Kerakli xodim topilgan (backend: `status == 'filled'`).
  bool get isFilled => status == 'filled';

  /// Bekor qilingan.
  bool get isCancelled => status == 'cancelled';

  /// Moderatsiya/tasdiq kutayotgan.
  bool get isPending => status == 'pending';

  /// `deadline` — Sequelize DATEONLY, ya'ni odatda 'YYYY-MM-DD' matni; ba'zi
  /// javoblarda to'liq ISO ham kelishi mumkin. Shuning uchun UTC bo'lsa
  /// mahalliy vaqtga o'tkazamiz va FAQAT sana qismini olamiz — aks holda
  /// +05:00 mintaqada muddat bir kun oldin "o'tib ketgan" bo'lib ko'rinadi.
  DateTime? get deadlineDate {
    final raw = deadline;
    if (raw == null || raw.isEmpty) return null;
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return null;
    final local = parsed.isUtc ? parsed.toLocal() : parsed;
    return DateTime(local.year, local.month, local.day);
  }

  /// Muddati o'tgan — `deadline` bugundan OLDIN. Bugungi sana hali o'tmagan.
  bool get isExpired {
    final d = deadlineDate;
    if (d == null) return false;
    final now = DateTime.now();
    return d.isBefore(DateTime(now.year, now.month, now.day));
  }
}
