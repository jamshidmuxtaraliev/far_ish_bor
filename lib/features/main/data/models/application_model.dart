class ApplicationModel {
  final int id;
  final String status;
  final String? jobTypeName;
  final String? companyName;
  final String? companyPhone;
  final int? salary;
  final String? deadline;
  final int? minAge;
  final int? maxAge;
  final String? requirementComment;
  final DateTime? createdAt;
  final DateTime? interviewDatetime;
  final String? coverMessage;

  ApplicationModel({
    required this.id,
    required this.status,
    this.jobTypeName,
    this.companyName,
    this.companyPhone,
    this.salary,
    this.deadline,
    this.minAge,
    this.maxAge,
    this.requirementComment,
    this.createdAt,
    this.interviewDatetime,
    this.coverMessage,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    final req = json['requirement'] as Map<String, dynamic>? ?? {};
    final jobType = req['job_type'] as Map<String, dynamic>?;
    final employer = json['employer'] as Map<String, dynamic>? ?? {};

    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      try {
        return DateTime.parse(v as String).toLocal();
      } catch (_) {
        return null;
      }
    }

    return ApplicationModel(
      id: json['id'] as int? ?? 0,
      status: json['status'] as String? ?? 'pending',
      jobTypeName: jobType?['name_uz'] as String? ?? jobType?['name'] as String?,
      companyName: employer['name'] as String?,
      companyPhone: employer['phone'] as String?,
      salary: req['salary'] as int?,
      deadline: req['deadline'] as String?,
      minAge: req['min_age'] as int?,
      maxAge: req['max_age'] as int?,
      requirementComment: req['comment'] as String?,
      createdAt: parseDate(json['createdAt']),
      interviewDatetime: parseDate(json['interview_datetime']),
      coverMessage: json['cover_message'] as String?,
    );
  }

  bool get isActive => !['rejected', 'missed'].contains(status);

  String get statusLabel {
    switch (status) {
      case 'pending':    return 'Kutilmoqda';
      case 'viewed':     return "Ko'rildi";
      case 'invited':    return 'Taklif qilindi';
      case 'scheduled':  return 'Suhbatga chaqirildi';
      case 'confirmed':  return 'Tasdiqlandi';
      case 'on_way':     return "Yo'ldaman";
      case 'arrived':    return 'Keldi';
      case 'hired':      return 'Ishga olindi';
      case 'missed':     return 'Kelmadi';
      case 'rejected':   return 'Rad etildi';
      default:           return status;
    }
  }

  bool get canConfirm  => status == 'scheduled' || status == 'invited';
  bool get canGoOnWay  => status == 'confirmed';

  String get salaryDisplay {
    if (salary == null) return '';
    final n = salary!;
    if (n >= 1000000) return "${(n / 1000000).toStringAsFixed(1)} mln so'm";
    return "$n so'm";
  }

  String get createdAtDisplay {
    if (createdAt == null) return '';
    final d = createdAt!;
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  String get interviewDisplay {
    if (interviewDatetime == null) return '';
    final d = interviewDatetime!;
    final date =
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    final time =
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    return '$date • $time';
  }
}
