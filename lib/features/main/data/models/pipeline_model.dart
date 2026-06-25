import 'candidate_model.dart';
import 'employer_vacancy_model.dart';

/// GET /mobile/employer/pipeline javobi (PROMPT_MOS_NOMZODLAR_MOBILE.md §4.1):
/// vakansiyalar (requirements) + har vakansiya bo'yicha mos nomzodlar +
/// biriktirishlar (bosqichlar). Ustunlar mahalliy hisoblanadi.
class PipelineModel {
  final List<EmployerVacancyModel> requirements;
  final List<PipelineReqCandidates> candidatesByReq;
  final List<PipelineAssignment> assignments;

  const PipelineModel({
    this.requirements = const [],
    this.candidatesByReq = const [],
    this.assignments = const [],
  });

  factory PipelineModel.fromJson(Map<String, dynamic> json) {
    List<T> parse<T>(dynamic raw, T Function(Map<String, dynamic>) f) =>
        raw is List
            ? raw.map((e) => f(e as Map<String, dynamic>)).toList()
            : <T>[];

    return PipelineModel(
      requirements: parse(json['requirements'], EmployerVacancyModel.fromJson),
      candidatesByReq:
          parse(json['candidatesByReq'], PipelineReqCandidates.fromJson),
      assignments: parse(json['assignments'], PipelineAssignment.fromJson),
    );
  }

  /// Berilgan vakansiya uchun mos nomzodlar pool'i.
  List<CandidateModel> candidatesOf(int reqId) {
    for (final c in candidatesByReq) {
      if (c.requirementId == reqId) return c.candidates;
    }
    return const [];
  }

  /// Nomzod (anketa) bo'yicha biriktirish — har anketa uchun bittadan.
  PipelineAssignment? assignmentFor(int reqId, int anketaId) {
    for (final a in assignments) {
      if (a.employerRequirementId == reqId && a.anketaId == anketaId) return a;
    }
    return null;
  }

  /// Bitta vakansiya uchun bosqich → kartalar ro'yxati.
  /// matched ('') = biriktirilmagan mos nomzodlar; qolganlar = status bo'yicha
  /// biriktirishlar.
  Map<String, List<PipelineColumnItem>> columnsFor(int reqId) {
    final pool = candidatesOf(reqId);
    final reqAssignments =
        assignments.where((a) => a.employerRequirementId == reqId).toList();
    final assignedIds = reqAssignments.map((a) => a.anketaId).toSet();

    final matched = <PipelineColumnItem>[];
    for (final c in pool) {
      if (!assignedIds.contains(c.id)) {
        matched.add(PipelineColumnItem(candidate: c));
      }
    }

    final byStatus = <String, List<PipelineColumnItem>>{'': matched};
    for (final a in reqAssignments) {
      // Karta ma'lumoti: avval pool'dagi to'liq nomzod (match_score bilan),
      // bo'lmasa biriktirishdagi anketa.
      final candidate = pool.firstWhere(
        (c) => c.id == a.anketaId,
        orElse: () => a.anketa ?? CandidateModel(id: a.anketaId),
      );
      byStatus
          .putIfAbsent(a.status, () => <PipelineColumnItem>[])
          .add(PipelineColumnItem(candidate: candidate, assignment: a));
    }
    return byStatus;
  }
}

/// candidatesByReq[] elementi.
class PipelineReqCandidates {
  final int requirementId;
  final int? jobTypeId;
  final List<CandidateModel> candidates;

  const PipelineReqCandidates({
    required this.requirementId,
    this.jobTypeId,
    this.candidates = const [],
  });

  factory PipelineReqCandidates.fromJson(Map<String, dynamic> json) {
    final raw = json['candidates'];
    return PipelineReqCandidates(
      requirementId: json['requirement_id'] as int? ?? 0,
      jobTypeId: json['job_type_id'] as int?,
      candidates: raw is List
          ? raw
              .map((e) => CandidateModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : const [],
    );
  }
}

/// anketa_assignment yozuvi (bosqich + suhbat holati).
class PipelineAssignment {
  final int id;
  final int anketaId;
  final int employerRequirementId;
  final String status; // suhbatga_yozildi | suhbatga_bordi | bormadi | ...
  final String? interviewDatetime;
  final String? comment;
  final CandidateModel? anketa;
  final int? interviewId;
  final String candidateResponse; // pending | accepted | declined
  final String? candidateRespondedAt;
  final String travelStatus; // idle | on_way | arrived | stopped

  const PipelineAssignment({
    required this.id,
    required this.anketaId,
    required this.employerRequirementId,
    required this.status,
    this.interviewDatetime,
    this.comment,
    this.anketa,
    this.interviewId,
    this.candidateResponse = 'pending',
    this.candidateRespondedAt,
    this.travelStatus = 'idle',
  });

  factory PipelineAssignment.fromJson(Map<String, dynamic> json) {
    final anketaJson = json['anketa'] as Map<String, dynamic>?;
    return PipelineAssignment(
      id: json['id'] as int? ?? 0,
      anketaId: json['anketa_id'] as int? ?? 0,
      employerRequirementId: json['employer_requirement_id'] as int? ?? 0,
      status: json['status'] as String? ?? '',
      interviewDatetime: json['interview_datetime'] as String?,
      comment: json['comment'] as String?,
      anketa:
          anketaJson != null ? CandidateModel.fromJson(anketaJson) : null,
      interviewId: json['interview_id'] as int?,
      candidateResponse: json['candidate_response'] as String? ?? 'pending',
      candidateRespondedAt: json['candidate_responded_at'] as String?,
      travelStatus: json['travel_status'] as String? ?? 'idle',
    );
  }

  /// `interview_datetime` → `23.06.2026 09:00` (yoki '—').
  String get interviewDisplay {
    final raw = interviewDatetime;
    if (raw == null) return '—';
    final d = DateTime.tryParse(raw)?.toLocal();
    if (d == null) return '—';
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}.${two(d.month)}.${d.year} ${two(d.hour)}:${two(d.minute)}';
  }
}

/// Ustundagi bitta karta — nomzod (+ ixtiyoriy biriktirish).
class PipelineColumnItem {
  final CandidateModel candidate;
  final PipelineAssignment? assignment;

  const PipelineColumnItem({required this.candidate, this.assignment});
}
