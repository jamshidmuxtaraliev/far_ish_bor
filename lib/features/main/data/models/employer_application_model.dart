class EmployerApplicationModel {
  final int id;
  final String status;
  final DateTime? interviewDatetime;
  final String? anketaFullname;
  final String? anketaPhone;
  final String? anketaJobType;
  final String? anketaRegion;
  final int? anketaId;
  final String? requirementJobTypeName;
  final int? requirementSalary;
  final int? requirementId;

  EmployerApplicationModel({
    required this.id,
    required this.status,
    this.interviewDatetime,
    this.anketaFullname,
    this.anketaPhone,
    this.anketaJobType,
    this.anketaRegion,
    this.anketaId,
    this.requirementJobTypeName,
    this.requirementSalary,
    this.requirementId,
  });

  factory EmployerApplicationModel.fromJson(Map<String, dynamic> json) {
    final anketa = json['anketa'] as Map<String, dynamic>? ?? {};
    final req = json['requirement'] as Map<String, dynamic>? ?? {};
    final jobType = anketa['job_type'] as Map<String, dynamic>? ?? {};
    final region = anketa['region'] as Map<String, dynamic>? ?? {};
    final reqJobType = req['job_type'] as Map<String, dynamic>? ?? {};

    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      try { return DateTime.parse(v as String); } catch (_) { return null; }
    }

    return EmployerApplicationModel(
      id: json['id'] as int? ?? 0,
      status: json['status'] as String? ?? 'pending',
      interviewDatetime: parseDate(json['interview_datetime']),
      anketaFullname: anketa['fullname'] as String?,
      anketaPhone: anketa['phone_number'] as String?,
      anketaJobType: jobType['name_uz'] as String? ?? anketa['profession_text'] as String?,
      anketaRegion: region['name_uz'] as String?,
      anketaId: anketa['id'] as int?,
      requirementJobTypeName: reqJobType['name_uz'] as String? ?? req['profession_text'] as String?,
      requirementSalary: req['salary'] as int?,
      requirementId: req['id'] as int?,
    );
  }

  String get statusLabel {
    switch (status) {
      case 'pending': return 'Kutilmoqda';
      case 'viewed': return "Ko'rildi";
      case 'invited': return 'Taklif qilindi';
      case 'scheduled': return 'Suhbat belgilandi';
      case 'confirmed': return 'Tasdiqlandi';
      case 'on_way': return "Yo'lda";
      case 'arrived': return 'Keldi';
      case 'accepted': return 'Maqul keldi';
      case 'probation': return 'Sinov davrida';
      case 'hired': return 'Ishga kirdi';
      case 'missed': return 'Kelmadi';
      case 'rejected': return 'Rad etildi';
      default: return status;
    }
  }

  String get interviewDisplay {
    if (interviewDatetime == null) return '';
    final d = interviewDatetime!;
    return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  String get salaryDisplay {
    if (requirementSalary == null || requirementSalary == 0) return 'Kelishiladi';
    final s = requirementSalary!;
    if (s >= 1000000) return '${(s / 1000000).toStringAsFixed(1)} mln so\'m';
    if (s >= 1000) return '${(s / 1000).toStringAsFixed(0)} ming so\'m';
    return '$s so\'m';
  }
}
