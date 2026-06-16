part of 'vacancy_bloc.dart';

@immutable
abstract class VacancyEvent {}

class LoadSeekerVacanciesEvent extends VacancyEvent {
  final int? jobTypeId;
  final int? regionId;
  LoadSeekerVacanciesEvent({this.jobTypeId, this.regionId});
}

class LoadEmployerVacanciesEvent extends VacancyEvent {}

class ApplyVacancyEvent extends VacancyEvent {
  final int vacancyId;
  final String? coverMessage;
  ApplyVacancyEvent(this.vacancyId, {this.coverMessage});
}

class CreateVacancyEvent extends VacancyEvent {
  final CreateVacancyRequest request;
  CreateVacancyEvent(this.request);
}

class UpdateVacancyEvent extends VacancyEvent {
  final CreateVacancyRequest request;
  UpdateVacancyEvent(this.request);
}

class DeleteVacancyEvent extends VacancyEvent {
  final int id;
  DeleteVacancyEvent(this.id);
}

class LoadCandidatesEvent extends VacancyEvent {}

class LoadMyApplicationsEvent extends VacancyEvent {}

class UpdateApplicationStatusEvent extends VacancyEvent {
  final int applicationId;
  final String status;
  UpdateApplicationStatusEvent(this.applicationId, this.status);
}

// Saved vacancies
class LoadSavedVacanciesEvent extends VacancyEvent {
  final int mobileUserId;
  LoadSavedVacanciesEvent(this.mobileUserId);
}

class SaveVacancyEvent extends VacancyEvent {
  final int mobileUserId;
  final int vacancyId;
  SaveVacancyEvent(this.mobileUserId, this.vacancyId);
}

class UnsaveVacancyEvent extends VacancyEvent {
  final int mobileUserId;
  final int vacancyId;
  UnsaveVacancyEvent(this.mobileUserId, this.vacancyId);
}

// Employer applications
class LoadEmployerApplicationsEvent extends VacancyEvent {}

// Contact unlock
class LoadRecommendedCandidatesEvent extends VacancyEvent {}

class LoadContactAccessEvent extends VacancyEvent {}

class UnlockContactEvent extends VacancyEvent {
  final int anketaId;
  final int? vacancyId;
  final String trigger;
  UnlockContactEvent({required this.anketaId, this.vacancyId, this.trigger = 'phone_view'});
}

class LoadUnlockHistoryEvent extends VacancyEvent {}

class LoadCandidateDetailEvent extends VacancyEvent {
  final int id;
  LoadCandidateDetailEvent(this.id);
}

class UpdateEmployerApplicationStatusEvent extends VacancyEvent {
  final int applicationId;
  final String status;
  final String? interviewDatetime;
  final String? type;
  UpdateEmployerApplicationStatusEvent(
    this.applicationId,
    this.status, {
    this.interviewDatetime,
    this.type,
  });
}
