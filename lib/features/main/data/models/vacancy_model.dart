class VacancyModel {
  final int id;
  final int? jobTypeId;
  final String? jobTypeName;
  final int? salary;
  final int? minAge;
  final int? maxAge;
  final String? status;
  final double? matchScore;
  final String? companyName;
  final String? companyPhone;
  final String? companyAddress;

  VacancyModel({
    required this.id,
    this.jobTypeId,
    this.jobTypeName,
    this.salary,
    this.minAge,
    this.maxAge,
    this.status,
    this.matchScore,
    this.companyName,
    this.companyPhone,
    this.companyAddress,
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
      companyName: employer?['name'] as String?,
      companyPhone: employer?['phone'] as String?,
      companyAddress: employer?['address'] as String?,
    );
  }

  String get salaryDisplay {
    if (salary == null) return "Ko'rsatilmagan";
    final n = salary!;
    if (n >= 1000000) return "${(n / 1000000).toStringAsFixed(1)} mln so'm";
    return "$n so'm";
  }

  int get matchPercent => (matchScore ?? 0).round();
}
