class SavedVacancyModel {
  final int id;
  final int vacancyId;
  final int mobileUserId;
  final DateTime? savedAt;
  final String? jobTypeName;
  final int? salary;
  final String? regionName;
  final String? companyName;
  final String? deadline;

  SavedVacancyModel({
    required this.id,
    required this.vacancyId,
    required this.mobileUserId,
    this.savedAt,
    this.jobTypeName,
    this.salary,
    this.regionName,
    this.companyName,
    this.deadline,
  });

  factory SavedVacancyModel.fromJson(Map<String, dynamic> json) {
    final vacancy = json['vacancy'] as Map<String, dynamic>? ?? {};
    final jobType = vacancy['job_type'] as Map<String, dynamic>? ?? {};
    final employer = vacancy['employer'] as Map<String, dynamic>? ?? {};
    final region = vacancy['region'] as Map<String, dynamic>? ??
        employer['region'] as Map<String, dynamic>? ?? {};

    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      try { return DateTime.parse(v as String); } catch (_) { return null; }
    }

    return SavedVacancyModel(
      id: json['id'] as int? ?? 0,
      vacancyId: json['vacancy_id'] as int? ?? 0,
      mobileUserId: json['mobile_user_id'] as int? ?? 0,
      savedAt: parseDate(json['saved_at'] ?? json['createdAt']),
      jobTypeName: jobType['name_uz'] as String? ?? vacancy['profession_text'] as String?,
      salary: vacancy['salary'] as int?,
      regionName: region['name_uz'] as String?,
      companyName: employer['name'] as String?,
      deadline: vacancy['deadline'] as String?,
    );
  }

  String get salaryDisplay {
    if (salary == null || salary == 0) return 'Kelishiladi';
    final s = salary!;
    if (s >= 1000000) return '${(s / 1000000).toStringAsFixed(1)} mln so\'m';
    return '$s so\'m';
  }

  String get savedAtDisplay {
    if (savedAt == null) return '';
    return '${savedAt!.day.toString().padLeft(2, '0')}.${savedAt!.month.toString().padLeft(2, '0')}.${savedAt!.year}';
  }
}
