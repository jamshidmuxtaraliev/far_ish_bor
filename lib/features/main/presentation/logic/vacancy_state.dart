part of 'vacancy_bloc.dart';

@immutable
class VacancyState extends Equatable {
  final FormzSubmissionStatus vacanciesStatus;
  final FormzSubmissionStatus candidatesStatus;
  final FormzSubmissionStatus vacancyCandidatesStatus;
  final VacancyCandidatesModel? vacancyCandidates;
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

  final List<CandidateModel> recommendedCandidates;
  final FormzSubmissionStatus recommendedStatus;
  final ContactAccessModel? contactAccess;
  final FormzSubmissionStatus contactAccessStatus;
  final ContactUnlockResultModel? unlockResult;
  final FormzSubmissionStatus unlockStatus;
  final List<ContactUnlockHistoryModel> unlockHistory;
  final FormzSubmissionStatus unlockHistoryStatus;
  final Set<int> unlockedAnketaIds;
  // anketa_id → phone (from in-session unlocks, so list cards refresh without reload)
  final Map<int, String> unlockedPhones;

  final CandidateModel? candidateDetail;
  final FormzSubmissionStatus candidateDetailStatus;

  // Mos nomzodlar pipeline (Kanban)
  final PipelineModel? pipeline;
  final FormzSubmissionStatus pipelineStatus;
  // create/update/delete biriktirish — bitta umumiy holat (one-shot)
  final FormzSubmissionStatus assignmentActionStatus;

  final ErrorModel? error;

  const VacancyState({
    this.vacanciesStatus = FormzSubmissionStatus.initial,
    this.candidatesStatus = FormzSubmissionStatus.initial,
    this.vacancyCandidatesStatus = FormzSubmissionStatus.initial,
    this.vacancyCandidates,
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
    this.recommendedCandidates = const [],
    this.recommendedStatus = FormzSubmissionStatus.initial,
    this.contactAccess,
    this.contactAccessStatus = FormzSubmissionStatus.initial,
    this.unlockResult,
    this.unlockStatus = FormzSubmissionStatus.initial,
    this.unlockHistory = const [],
    this.unlockHistoryStatus = FormzSubmissionStatus.initial,
    this.unlockedAnketaIds = const {},
    this.unlockedPhones = const {},
    this.candidateDetail,
    this.candidateDetailStatus = FormzSubmissionStatus.initial,
    this.pipeline,
    this.pipelineStatus = FormzSubmissionStatus.initial,
    this.assignmentActionStatus = FormzSubmissionStatus.initial,
    this.error,
  });

  VacancyState copyWith({
    FormzSubmissionStatus? vacanciesStatus,
    FormzSubmissionStatus? candidatesStatus,
    FormzSubmissionStatus? vacancyCandidatesStatus,
    VacancyCandidatesModel? vacancyCandidates,
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
    List<CandidateModel>? recommendedCandidates,
    FormzSubmissionStatus? recommendedStatus,
    ContactAccessModel? contactAccess,
    FormzSubmissionStatus? contactAccessStatus,
    ContactUnlockResultModel? unlockResult,
    FormzSubmissionStatus? unlockStatus,
    List<ContactUnlockHistoryModel>? unlockHistory,
    FormzSubmissionStatus? unlockHistoryStatus,
    Set<int>? unlockedAnketaIds,
    Map<int, String>? unlockedPhones,
    CandidateModel? candidateDetail,
    FormzSubmissionStatus? candidateDetailStatus,
    PipelineModel? pipeline,
    FormzSubmissionStatus? pipelineStatus,
    FormzSubmissionStatus? assignmentActionStatus,
    ErrorModel? error,
  }) {
    return VacancyState(
      vacanciesStatus: vacanciesStatus ?? this.vacanciesStatus,
      candidatesStatus: candidatesStatus ?? this.candidatesStatus,
      vacancyCandidatesStatus: vacancyCandidatesStatus ?? this.vacancyCandidatesStatus,
      vacancyCandidates: vacancyCandidates ?? this.vacancyCandidates,
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
      recommendedCandidates: recommendedCandidates ?? this.recommendedCandidates,
      recommendedStatus: recommendedStatus ?? this.recommendedStatus,
      contactAccess: contactAccess ?? this.contactAccess,
      contactAccessStatus: contactAccessStatus ?? this.contactAccessStatus,
      unlockResult: unlockResult ?? this.unlockResult,
      unlockStatus: unlockStatus ?? this.unlockStatus,
      unlockHistory: unlockHistory ?? this.unlockHistory,
      unlockHistoryStatus: unlockHistoryStatus ?? this.unlockHistoryStatus,
      unlockedAnketaIds: unlockedAnketaIds ?? this.unlockedAnketaIds,
      unlockedPhones: unlockedPhones ?? this.unlockedPhones,
      candidateDetail: candidateDetail ?? this.candidateDetail,
      candidateDetailStatus:
          candidateDetailStatus ?? this.candidateDetailStatus,
      pipeline: pipeline ?? this.pipeline,
      pipelineStatus: pipelineStatus ?? this.pipelineStatus,
      assignmentActionStatus:
          assignmentActionStatus ?? this.assignmentActionStatus,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        vacanciesStatus, candidatesStatus, vacancyCandidatesStatus, vacancyCandidates,
        applyStatus, manageVacancyStatus,
        applicationsStatus, updateAppStatus, savedStatus, employerAppsStatus, updateEmpAppStatus,
        seekerVacancies, employerVacancies, candidates, myApplications,
        savedVacancies, employerApplications,
        recommendedCandidates, recommendedStatus,
        contactAccess, contactAccessStatus,
        unlockResult, unlockStatus,
        unlockHistory, unlockHistoryStatus, unlockedAnketaIds,
        unlockedPhones,
        candidateDetail, candidateDetailStatus,
        pipeline, pipelineStatus, assignmentActionStatus,
        error,
      ];
}
