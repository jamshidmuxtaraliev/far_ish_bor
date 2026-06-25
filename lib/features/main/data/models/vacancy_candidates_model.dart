import 'candidate_model.dart';
import 'employer_vacancy_model.dart';

/// GET /mobile/employer/vacancies/:id/candidates javobi (§4.2):
/// bitta vakansiya uchun operator tavsiyalari + mos nomzodlar.
class VacancyCandidatesModel {
  final EmployerVacancyModel vacancy;
  final List<CandidateModel> recommended;
  final List<CandidateModel> mos;

  const VacancyCandidatesModel({
    required this.vacancy,
    this.recommended = const [],
    this.mos = const [],
  });

  factory VacancyCandidatesModel.fromJson(Map<String, dynamic> json) {
    List<CandidateModel> parse(dynamic raw) => raw is List
        ? raw
            .map((e) => CandidateModel.fromJson(e as Map<String, dynamic>))
            .toList()
        : <CandidateModel>[];

    return VacancyCandidatesModel(
      vacancy: EmployerVacancyModel.fromJson(
          (json['vacancy'] as Map<String, dynamic>?) ?? const {}),
      recommended: parse(json['recommended']),
      mos: parse(json['mos']),
    );
  }

  bool get isEmpty => recommended.isEmpty && mos.isEmpty;
}
