import 'package:flutter/material.dart';

import 'application_access.dart';
import '../../../../core/theme/jb_palette.dart';

class ApplicationModel {
  final int id;
  final String status;

  /// Ariza yuborilgan vakansiya (requirement) id'si — vakansiya ekranida
  /// "bu vakansiyaga arizam qabul qilinganmi?" degan tekshiruv uchun.
  final int? requirementId;
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
    this.requirementId,
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
      requirementId: (req['id'] ?? json['requirement_id']) as int?,
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

  /// Ish beruvchi arizani qabul qilganmi — korxona telefoni va chat shu
  /// shartga bog'liq.
  bool get isAccepted => isApplicationAccepted(status);

  /// Ish izlovchiga ko'rinadigan status matni. Backenddagi BARCHA qiymatlar shu
  /// yerda tarjima qilinadi; noma'lum qiymat ham inglizcha chiqib qolmasligi
  /// uchun umumiy "Jarayonda" ga tushadi.
  String get statusLabel => switch (status) {
        'pending' => 'Kutilmoqda',
        'viewed' => "Ko'rildi",
        'invited' => 'Taklif qilindi',
        'scheduled' => 'Suhbatga chaqirildi',
        'confirmed' => 'Tasdiqlandi',
        'on_way' => "Yo'ldaman",
        'arrived' => 'Keldi',
        'accepted' => 'Maqul keldingiz',
        'probation' => 'Sinov davrida',
        'hired' => 'Ishga olindingiz',
        'missed' => 'Kelmadingiz',
        'rejected' => 'Rad etildi',
        // Biriktirish (assignment) statuslari — ba'zi javoblarda shular keladi.
        'suhbatga_yozildi' => 'Suhbat vaqti belgilandi',
        'suhbatga_bordi' => 'Suhbatga bordingiz',
        'bormadi' => 'Bormadingiz',
        'qabul_qilindi' => 'Qabul qilindingiz',
        'mos_kelmadi' => 'Mos kelmadi',
        _ => 'Jarayonda',
      };

  Color get statusColor => switch (status) {
        'pending' => jb.amber,
        'viewed' => jb.violet,
        'invited' => jb.violet,
        'scheduled' || 'confirmed' || 'arrived' => jb.green,
        'on_way' || 'probation' || 'suhbatga_yozildi' || 'suhbatga_bordi' => jb.cyan,
        'accepted' || 'hired' || 'qabul_qilindi' => jb.green,
        'rejected' => jb.red,
        _ => jb.gray,
      };

  Color get statusBgColor => switch (status) {
        'pending' => jb.amberBg,
        'viewed' => jb.blueTint,
        'invited' => jb.violetBg,
        'scheduled' || 'confirmed' || 'arrived' => jb.greenBg,
        'on_way' || 'probation' || 'suhbatga_yozildi' || 'suhbatga_bordi' => jb.blueTint,
        'accepted' || 'hired' || 'qabul_qilindi' => jb.greenBg,
        'rejected' => jb.redBg,
        _ => jb.cardAlt,
      };

  IconData get statusIcon => switch (status) {
        'pending' => Icons.timelapse_rounded,
        'viewed' => Icons.check_circle_outline_rounded,
        'invited' => Icons.mail_outline_rounded,
        'scheduled' || 'suhbatga_yozildi' => Icons.calendar_month_rounded,
        'confirmed' => Icons.check_circle_rounded,
        'on_way' => Icons.directions_walk_rounded,
        'arrived' || 'suhbatga_bordi' => Icons.location_on_rounded,
        'accepted' || 'qabul_qilindi' => Icons.thumb_up_outlined,
        'probation' => Icons.hourglass_bottom_rounded,
        'hired' => Icons.handshake_outlined,
        'missed' || 'bormadi' => Icons.event_busy_rounded,
        'rejected' || 'mos_kelmadi' => Icons.cancel_outlined,
        _ => Icons.info_outline,
      };

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
