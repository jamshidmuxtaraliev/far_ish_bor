class SavedVacancyModel {
  final int id;
  final int vacancyId;
  final int mobileUserId;
  final DateTime? savedAt;
  final int? salary;
  final String? deadline;
  final String? comment;
  final String? status;
  final int? minAge;
  final int? maxAge;

  SavedVacancyModel({
    required this.id,
    required this.vacancyId,
    required this.mobileUserId,
    this.savedAt,
    this.salary,
    this.deadline,
    this.comment,
    this.status,
    this.minAge,
    this.maxAge,
  });

  factory SavedVacancyModel.fromJson(Map<String, dynamic> json) {
    final vacancy = json['vacancy'] as Map<String, dynamic>? ?? {};

    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      try {
        return DateTime.parse(v as String).toLocal();
      } catch (_) {
        return null;
      }
    }

    return SavedVacancyModel(
      id: json['id'] as int? ?? 0,
      vacancyId: json['vacancy_id'] as int? ?? 0,
      mobileUserId: json['mobile_user_id'] as int? ?? 0,
      savedAt: parseDate(json['saved_at'] ?? json['createdAt']),
      salary: vacancy['salary'] as int?,
      deadline: vacancy['deadline'] as String?,
      comment: vacancy['comment'] as String?,
      status: vacancy['status'] as String?,
      minAge: vacancy['min_age'] as int?,
      maxAge: vacancy['max_age'] as int?,
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

  String get ageDisplay {
    if (minAge == null && maxAge == null) return '';
    if (minAge != null && maxAge != null) return '$minAge–$maxAge yosh';
    if (minAge != null) return '$minAge+ yosh';
    return '${maxAge!} yoshgacha';
  }
}
