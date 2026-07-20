class VacancyModel {
  final int id;
  final int? jobTypeId;
  final String? jobTypeName;
  final int? salary;
  final int? minAge;
  final int? maxAge;
  final String? status;
  final double? matchScore;
  final int? companyId;
  final String? companyName;
  final String? companyPhone;
  final String? companyAddress;
  final String? companyLogo;
  // Korxona profili — mavjud bo'lsa ko'rsatiladi, aks holda yashiriladi.
  final String? companyCategory;
  final String? companyAbout;
  final String? companyContact;
  // Employer joylashuvi — xaritada marker sifatida ko'rsatish uchun.
  final double? latitude;
  final double? longitude;

  VacancyModel({
    required this.id,
    this.jobTypeId,
    this.jobTypeName,
    this.salary,
    this.minAge,
    this.maxAge,
    this.status,
    this.matchScore,
    this.companyId,
    this.companyName,
    this.companyPhone,
    this.companyAddress,
    this.companyLogo,
    this.companyCategory,
    this.companyAbout,
    this.companyContact,
    this.latitude,
    this.longitude,
  });

  factory VacancyModel.fromJson(Map<String, dynamic> json) {
    final employer = json['employer'] as Map<String, dynamic>?;
    final jobType = json['job_type'] as Map<String, dynamic>?;
    return VacancyModel(
      id: json['id'] as int? ?? 0,
      jobTypeId: json['job_type_id'] as int?,
      jobTypeName: jobType?['name_uz'] as String?,
      salary: json['salary'] as int?,
      minAge: json['min_age'] as int?,
      maxAge: json['max_age'] as int?,
      status: json['status'] as String?,
      matchScore: (json['match_score'] as num?)?.toDouble(),
      companyId: employer?['id'] as int?,
      companyName: employer?['name'] as String?,
      companyPhone: employer?['phone'] as String?,
      companyAddress: employer?['address'] as String?,
      companyLogo: employer?['logo'] as String?,
      companyCategory: (employer?['category'] ?? employer?['field'] ?? employer?['activity_field']) as String?,
      companyAbout: (employer?['about'] ?? employer?['description']) as String?,
      companyContact: (employer?['contact_person'] ?? employer?['responsible_person'] ?? employer?['contact']) as String?,
      latitude: (employer?['latitude'] as num?)?.toDouble(),
      longitude: (employer?['longitude'] as num?)?.toDouble(),
    );
  }

  /// Korxona bosh harfi (avatar uchun).
  String get companyInitial =>
      (companyName?.trim().isNotEmpty == true) ? companyName!.trim()[0].toUpperCase() : '?';

  /// True agar vakansiyani xaritada ko'rsatish uchun koordinatalar mavjud bo'lsa.
  bool get hasCoords => latitude != null && longitude != null;

  String get salaryDisplay {
    if (salary == null) return "Ko'rsatilmagan";
    final n = salary!;
    if (n >= 1000000) return "${(n / 1000000).toStringAsFixed(1)} mln so'm";
    return "$n so'm";
  }

  int get matchPercent => (matchScore ?? 0).round();
}
