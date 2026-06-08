part of 'vacancy_bloc.dart';

@immutable
class VacancyState extends Equatable {
  final FormzSubmissionStatus vacanciesStatus;
  final FormzSubmissionStatus candidatesStatus;
  final FormzSubmissionStatus applyStatus;
  final FormzSubmissionStatus manageVacancyStatus;
  final FormzSubmissionStatus applicationsStatus;
  final FormzSubmissionStatus updateAppStatus;
  final FormzSubmissionStatus savedStatus;
  final FormzSubmissionStatus employerAppsStatus;
  final FormzSubmissionStatus updateEmpAppStatus;
  final List<VacancyModel> seekerVacancies;
  final List<EmployerVacancyModel> employerVacancies;
  final List<CandidateModel> candidates;
  final List<ApplicationModel> myApplications;
  final List<SavedVacancyModel> savedVacancies;
  final List<EmployerApplicationModel> employerApplications;
  final ErrorModel? error;

  const VacancyState({
    this.vacanciesStatus = FormzSubmissionStatus.initial,
    this.candidatesStatus = FormzSubmissionStatus.initial,
    this.applyStatus = FormzSubmissionStatus.initial,
    this.manageVacancyStatus = FormzSubmissionStatus.initial,
    this.applicationsStatus = FormzSubmissionStatus.initial,
    this.updateAppStatus = FormzSubmissionStatus.initial,
    this.savedStatus = FormzSubmissionStatus.initial,
    this.employerAppsStatus = FormzSubmissionStatus.initial,
    this.updateEmpAppStatus = FormzSubmissionStatus.initial,
    this.seekerVacancies = const [],
    this.employerVacancies = const [],
    this.candidates = const [],
    this.myApplications = const [],
    this.savedVacancies = const [],
    this.employerApplications = const [],
    this.error,
  });

  VacancyState copyWith({
    FormzSubmissionStatus? vacanciesStatus,
    FormzSubmissionStatus? candidatesStatus,
    FormzSubmissionStatus? applyStatus,
    FormzSubmissionStatus? manageVacancyStatus,
    FormzSubmissionStatus? applicationsStatus,
    FormzSubmissionStatus? updateAppStatus,
    FormzSubmissionStatus? savedStatus,
    FormzSubmissionStatus? employerAppsStatus,
    FormzSubmissionStatus? updateEmpAppStatus,
    List<VacancyModel>? seekerVacancies,
    List<EmployerVacancyModel>? employerVacancies,
    List<CandidateModel>? candidates,
    List<ApplicationModel>? myApplications,
    List<SavedVacancyModel>? savedVacancies,
    List<EmployerApplicationModel>? employerApplications,
    ErrorModel? error,
  }) {
    return VacancyState(
      vacanciesStatus: vacanciesStatus ?? this.vacanciesStatus,
      candidatesStatus: candidatesStatus ?? this.candidatesStatus,
      applyStatus: applyStatus ?? this.applyStatus,
      manageVacancyStatus: manageVacancyStatus ?? this.manageVacancyStatus,
      applicationsStatus: applicationsStatus ?? this.applicationsStatus,
      updateAppStatus: updateAppStatus ?? this.updateAppStatus,
      savedStatus: savedStatus ?? this.savedStatus,
      employerAppsStatus: employerAppsStatus ?? this.employerAppsStatus,
      updateEmpAppStatus: updateEmpAppStatus ?? this.updateEmpAppStatus,
      seekerVacancies: seekerVacancies ?? this.seekerVacancies,
      employerVacancies: employerVacancies ?? this.employerVacancies,
      candidates: candidates ?? this.candidates,
      myApplications: myApplications ?? this.myApplications,
      savedVacancies: savedVacancies ?? this.savedVacancies,
      employerApplications: employerApplications ?? this.employerApplications,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        vacanciesStatus, candidatesStatus, applyStatus, manageVacancyStatus,
        applicationsStatus, updateAppStatus, savedStatus, employerAppsStatus, updateEmpAppStatus,
        seekerVacancies, employerVacancies, candidates, myApplications,
        savedVacancies, employerApplications, error,
      ];
}
