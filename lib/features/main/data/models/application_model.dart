class ApplicationModel {
  final int id;
  final String status;
  final String? jobTypeName;
  final String? companyName;
  final String? regionName;
  final String? districtName;
  final int? salary;
  final DateTime? createdAt;
  final DateTime? interviewDatetime;
  final String? coverMessage;

  ApplicationModel({
    required this.id,
    required this.status,
    this.jobTypeName,
    this.companyName,
    this.regionName,
    this.districtName,
    this.salary,
    this.createdAt,
    this.interviewDatetime,
    this.coverMessage,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    final req = json['requirement'] as Map<String, dynamic>? ?? {};
    final employer = json['employer'] as Map<String, dynamic>? ?? {};
    final region = req['region'] as Map<String, dynamic>? ?? {};
    final district = req['district'] as Map<String, dynamic>? ?? {};

    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      try { return DateTime.parse(v as String); } catch (_) { return null; }
    }

    return ApplicationModel(
      id: json['id'] as int? ?? 0,
      status: json['status'] as String? ?? 'pending',
      jobTypeName: req['job_type_name'] as String?,
      companyName: employer['name'] as String?,
      regionName: region['name_uz'] as String?,
      districtName: district['name_uz'] as String?,
      salary: req['salary'] as int?,
      createdAt: parseDate(json['created_at']),
      interviewDatetime: parseDate(json['interview_datetime']),
      coverMessage: json['cover_message'] as String?,
    );
  }

  bool get isActive => !['rejected', 'missed'].contains(status);

  String get statusLabel {
    switch (status) {
      case 'pending': return 'Kutilmoqda';
      case 'viewed': return "Ko'rildi";
      case 'invited': return 'Taklif qilindi';
      case 'scheduled': return 'Suhbat belgilandi';
      case 'confirmed': return 'Tasdiqlandi';
      case 'on_way': return "Yo'ldaman";
      case 'arrived': return 'Keldi';
      case 'hired': return 'Ishga olindi';
      case 'missed': return 'Kelmadi';
      case 'rejected': return 'Rad etildi';
      default: return status;
    }
  }

  // Can seeker update this status to 'confirmed'?
  bool get canConfirm => status == 'scheduled' || status == 'invited';
  // Can seeker update this status to 'on_way'?
  bool get canGoOnWay => status == 'scheduled' || status == 'confirmed';

  String get locationDisplay {
    final parts = [regionName, districtName].where((v) => v != null && v.isNotEmpty).toList();
    return parts.join(', ');
  }

  String get createdAtDisplay {
    if (createdAt == null) return '';
    return '${createdAt!.year}-${createdAt!.month.toString().padLeft(2, '0')}-${createdAt!.day.toString().padLeft(2, '0')}';
  }

  String get interviewDisplay {
    if (interviewDatetime == null) return '';
    final d = interviewDatetime!;
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} - ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}
