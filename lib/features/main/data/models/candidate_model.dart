class CandidateModel {
  final int id;
  final double? matchScore;
  final String? fullname;
  final String? jobTypeName;
  final int? jobTypeId;
  final int? experienceYear;
  final int? expectedSalary;
  final String? phone;
  final String? workStatus;
  final String? workSchedule;
  final String? gender;
  final String? birthday;
  final List<String> languages;

  CandidateModel({
    required this.id,
    this.matchScore,
    this.fullname,
    this.jobTypeName,
    this.jobTypeId,
    this.experienceYear,
    this.expectedSalary,
    this.phone,
    this.workStatus,
    this.workSchedule,
    this.gender,
    this.birthday,
    this.languages = const [],
  });

  factory CandidateModel.fromJson(Map<String, dynamic> json) {
    final anketa = json['anketa'] as Map<String, dynamic>? ?? {};
    final jobType = anketa['job_type'] as Map<String, dynamic>?;
    final rawLangs = anketa['languages'];
    final langs = rawLangs is List ? rawLangs.map((e) => e.toString()).toList() : <String>[];
    return CandidateModel(
      id: json['id'] as int? ?? anketa['id'] as int? ?? 0,
      matchScore: (json['match_score'] as num?)?.toDouble(),
      fullname: anketa['fullname'] as String?,
      jobTypeName: jobType?['name_uz'] as String?,
      jobTypeId: anketa['job_type_id'] as int?,
      experienceYear: anketa['experience_year'] as int?,
      expectedSalary: anketa['expected_salary'] as int?,
      phone: anketa['phone'] as String?,
      workStatus: anketa['work_status'] as String?,
      workSchedule: anketa['work_schedule'] as String?,
      gender: anketa['gender'] as String?,
      birthday: anketa['birthday'] as String?,
      languages: langs,
    );
  }

  int get matchPercent => (matchScore ?? 0).round();

  String get salaryDisplay {
    if (expectedSalary == null) return '';
    final n = expectedSalary!;
    if (n >= 1000000) return "${(n / 1000000).toStringAsFixed(1)} mln so'm";
    return "$n so'm";
  }

  String get initials {
    if (fullname == null || fullname!.isEmpty) return '?';
    final parts = fullname!.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts[0][0].toUpperCase();
  }
}
