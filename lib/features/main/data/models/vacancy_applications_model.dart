import 'application_stats_model.dart';
import 'candidate_model.dart';
import 'contact_unlock_model.dart';
import 'employer_vacancy_model.dart';

/// `2026-08-18T14:31:00.000Z` → `18.08.2026 19:31` (mahalliy vaqt).
String formatDateTime(DateTime? d, {bool withTime = true}) {
  if (d == null) return '';
  final l = d.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  final date = '${two(l.day)}.${two(l.month)}.${l.year}';
  return withTime ? '$date ${two(l.hour)}:${two(l.minute)}' : date;
}

DateTime? parseIsoDate(dynamic value) {
  if (value is! String || value.isEmpty) return null;
  try {
    return DateTime.parse(value);
  } catch (_) {
    return null;
  }
}

/// GET /mobile/employer/vacancies/:id/applications → `items[]` (§4.2).
///
/// ⚠️ `id` — `mobile_applications.id`; tarix aynan shu id bilan olinadi.
class VacancyApplicationModel {
  final int id;
  final int? anketaId;
  final int? requirementId;
  final String status;

  /// Serverdan tayyor o'zbekcha matn — ilovada tarjima qilinmaydi (§6.2).
  final String? statusLabel;
  final String? coverMessage;
  final DateTime? interviewDatetime;
  final DateTime? statusChangedAt;
  final DateTime? appliedAt;
  final CandidateModel? candidate;

  /// Telefon/chat ochiqmi — eng ishonchli bayroq (§4.2).
  final bool contactOpen;
  final ContactCapabilitiesModel? capabilities;

  const VacancyApplicationModel({
    required this.id,
    this.anketaId,
    this.requirementId,
    this.status = 'pending',
    this.statusLabel,
    this.coverMessage,
    this.interviewDatetime,
    this.statusChangedAt,
    this.appliedAt,
    this.candidate,
    this.contactOpen = false,
    this.capabilities,
  });

  factory VacancyApplicationModel.fromJson(Map<String, dynamic> json) {
    final candidateJson = json['candidate'];
    final capsJson = json['capabilities'];
    return VacancyApplicationModel(
      id: json['id'] as int? ?? 0,
      anketaId: json['anketa_id'] as int?,
      requirementId: json['employer_requirement_id'] as int?,
      status: json['status'] as String? ?? 'pending',
      statusLabel: json['status_label'] as String?,
      coverMessage: json['cover_message'] as String?,
      interviewDatetime: parseIsoDate(json['interview_datetime']),
      statusChangedAt: parseIsoDate(json['status_changed_at']),
      appliedAt: parseIsoDate(json['applied_at'] ?? json['createdAt']),
      candidate: candidateJson is Map<String, dynamic>
          ? CandidateModel.fromJson(candidateJson)
          : null,
      contactOpen: json['contact_open'] as bool? ?? false,
      capabilities: capsJson is Map
          ? ContactCapabilitiesModel.fromJson(
              Map<String, dynamic>.from(capsJson))
          : null,
    );
  }

  String get appliedDisplay => formatDateTime(appliedAt);

  String get interviewDisplay => formatDateTime(interviewDatetime);

  String get candidateName => candidate?.fullname ?? 'Nomzod';
}

/// GET /mobile/employer/vacancies/:id/applications javobi (§4.2).
class VacancyApplicationsModel {
  final EmployerVacancyModel? vacancy;
  final ApplicationStatsModel stats;
  final ContactPolicyModel? contactPolicy;
  final int total;
  final int limit;
  final int offset;
  final List<VacancyApplicationModel> items;

  const VacancyApplicationsModel({
    this.vacancy,
    this.stats = ApplicationStatsModel.empty,
    this.contactPolicy,
    this.total = 0,
    this.limit = 100,
    this.offset = 0,
    this.items = const [],
  });

  factory VacancyApplicationsModel.fromJson(Map<String, dynamic> json) {
    final vacancyJson = json['vacancy'];
    final statsJson = json['stats'];
    final policyJson = json['contact_policy'];
    final rawItems = json['items'];
    return VacancyApplicationsModel(
      vacancy: vacancyJson is Map<String, dynamic>
          ? EmployerVacancyModel.fromJson(vacancyJson)
          : null,
      stats: statsJson is Map<String, dynamic>
          ? ApplicationStatsModel.fromJson(statsJson)
          : ApplicationStatsModel.empty,
      contactPolicy: policyJson is Map<String, dynamic>
          ? ContactPolicyModel.fromJson(policyJson)
          : null,
      total: (json['total'] as num?)?.toInt() ?? 0,
      limit: (json['limit'] as num?)?.toInt() ?? 100,
      offset: (json['offset'] as num?)?.toInt() ?? 0,
      items: rawItems is List
          ? rawItems
              .map((e) =>
                  VacancyApplicationModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : const [],
    );
  }
}
