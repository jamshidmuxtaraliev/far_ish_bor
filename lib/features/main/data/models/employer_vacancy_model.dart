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
  final String? comment;
  final String? createdAt;
  final int? applicationsCount;

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
    this.comment,
    this.createdAt,
    this.applicationsCount,
  });

  factory EmployerVacancyModel.fromJson(Map<String, dynamic> json) {
    final jobType = json['job_type'] as Map<String, dynamic>?;
    return EmployerVacancyModel(
      id: json['id'] as int? ?? 0,
      jobTypeId: json['job_type_id'] as int?,
      jobTypeName: jobType?['name_uz'] as String?,
      anketaCount: json['anketa_count'] as int?,
      salary: json['salary'] as int?,
      deadline: json['deadline'] as String?,
      minAge: json['min_age'] as int?,
      maxAge: json['max_age'] as int?,
      status: json['status'] as String?,
      comment: json['comment'] as String?,
      createdAt: json['created_at'] as String?,
      applicationsCount: json['applications_count'] as int?,
    );
  }

  String get salaryDisplay {
    if (salary == null) return "Ko'rsatilmagan";
    final n = salary!;
    if (n >= 1000000) return "${(n / 1000000).toStringAsFixed(1)} mln so'm";
    return "$n so'm";
  }

  bool get isActive => status == 'active';
}
