import 'vacancy_applications_model.dart' show formatDateTime, parseIsoDate;

/// PROMPT_VAKANSIYA_OTKLIKLARI_MOBILE.md §5.2 — bitta status o'zgarishi.
class ApplicationTimelineEntryModel {
  final int id;
  final String? fromStatus;
  final String? fromLabel;
  final String toStatus;
  final String? toLabel;

  /// Masalan rad etish sababi.
  final String? comment;

  /// `staff` | `mobile` | `system`.
  final String actorType;
  final String? actorLabel;
  final DateTime? at;

  const ApplicationTimelineEntryModel({
    required this.id,
    this.fromStatus,
    this.fromLabel,
    this.toStatus = 'pending',
    this.toLabel,
    this.comment,
    this.actorType = 'system',
    this.actorLabel,
    this.at,
  });

  factory ApplicationTimelineEntryModel.fromJson(Map<String, dynamic> json) =>
      ApplicationTimelineEntryModel(
        id: json['id'] as int? ?? 0,
        fromStatus: json['from_status'] as String?,
        fromLabel: json['from_label'] as String?,
        toStatus: json['to_status'] as String? ?? 'pending',
        toLabel: json['to_label'] as String?,
        comment: json['comment'] as String?,
        actorType: json['actor_type'] as String? ?? 'system',
        actorLabel: json['actor_label'] as String?,
        at: parseIsoDate(json['at']),
      );

  /// §5.2: `staff` → operator login'i, `mobile` → "Foydalanuvchi",
  /// `system` → "Tizim".
  String get actorDisplay => switch (actorType) {
        'system' => 'Tizim',
        'mobile' => actorLabel ?? 'Foydalanuvchi',
        _ => actorLabel ?? 'Operator',
      };

  String get atDisplay => formatDateTime(at);

  /// "Yuborildi → Ko'rildi" (birinchi yozuvda `from` bo'lmaydi).
  String get transitionDisplay {
    final from = fromLabel ?? fromStatus;
    final to = toLabel ?? toStatus;
    if (from == null || from.isEmpty) return to;
    return '$from → $to';
  }
}

/// Tarix javobidagi ariza sarlavhasi — rolga qarab `candidate` yoki
/// `employer` to'ladi.
class ApplicationHistoryRefModel {
  final int id;
  final String status;
  final String? statusLabel;
  final String? coverMessage;
  final DateTime? interviewDatetime;
  final DateTime? appliedAt;
  final String? candidateName;
  final String? vacancyTitle;
  final int? vacancyId;
  final String? employerName;

  const ApplicationHistoryRefModel({
    required this.id,
    this.status = 'pending',
    this.statusLabel,
    this.coverMessage,
    this.interviewDatetime,
    this.appliedAt,
    this.candidateName,
    this.vacancyTitle,
    this.vacancyId,
    this.employerName,
  });

  factory ApplicationHistoryRefModel.fromJson(Map<String, dynamic> json) {
    final candidate = json['candidate'];
    final vacancy = json['vacancy'];
    final employer = json['employer'];
    final jobType = vacancy is Map ? vacancy['job_type'] : null;
    return ApplicationHistoryRefModel(
      id: json['id'] as int? ?? 0,
      status: json['status'] as String? ?? 'pending',
      statusLabel: json['status_label'] as String?,
      coverMessage: json['cover_message'] as String?,
      interviewDatetime: parseIsoDate(json['interview_datetime']),
      appliedAt: parseIsoDate(json['applied_at'] ?? json['createdAt']),
      candidateName: candidate is Map ? candidate['fullname'] as String? : null,
      vacancyTitle: jobType is Map
          ? (jobType['name'] ?? jobType['name_uz']) as String?
          : null,
      vacancyId: vacancy is Map ? vacancy['id'] as int? : null,
      employerName: employer is Map ? employer['name'] as String? : null,
    );
  }

  String get appliedDisplay => formatDateTime(appliedAt);
}

/// GET /mobile/{employer/}applications/:id/history javobi — ikkala rol uchun
/// bir xil tuzilma (§5.2).
class ApplicationHistoryModel {
  final ApplicationHistoryRefModel? application;

  /// Eskidan yangiga tartiblangan; hech qachon bo'sh bo'lmaydi (`null → pending`
  /// yozuvi ham shu yerda).
  final List<ApplicationTimelineEntryModel> timeline;

  const ApplicationHistoryModel({this.application, this.timeline = const []});

  factory ApplicationHistoryModel.fromJson(Map<String, dynamic> json) {
    final app = json['application'];
    final raw = json['timeline'];
    return ApplicationHistoryModel(
      application: app is Map<String, dynamic>
          ? ApplicationHistoryRefModel.fromJson(app)
          : null,
      timeline: raw is List
          ? raw
              .map((e) => ApplicationTimelineEntryModel.fromJson(
                  e as Map<String, dynamic>))
              .toList()
          : const [],
    );
  }
}
