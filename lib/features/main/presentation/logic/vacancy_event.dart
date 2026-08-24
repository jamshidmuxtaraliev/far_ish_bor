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

// Vakansiya-markazli oqim: bitta vakansiya ichidagi tavsiya + mos nomzodlar
class LoadVacancyCandidatesEvent extends VacancyEvent {
  final int vacancyId;
  LoadVacancyCandidatesEvent(this.vacancyId);
}

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

/// Bitta vakansiyaning otkliklari + statistika + kontakt siyosati (§4).
class LoadVacancyApplicationsEvent extends VacancyEvent {
  final int vacancyId;
  final String? status;
  LoadVacancyApplicationsEvent(this.vacancyId, {this.status});
}

/// Otklik tarixi (§5) — `asEmployer` yo'lni tanlaydi.
class LoadApplicationHistoryEvent extends VacancyEvent {
  final int applicationId;
  final bool asEmployer;
  LoadApplicationHistoryEvent(this.applicationId, {this.asEmployer = true});
}

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

/// Socket `balance:updated` — to'lov webhook'idan keyin yangi balans (§5.3).
class BalanceUpdatedEvent extends VacancyEvent {
  final int balance;
  BalanceUpdatedEvent(this.balance);
}

/// Socket `contact:unlocked` — nomzod ochildi (§7.3).
class ContactUnlockedRemotelyEvent extends VacancyEvent {
  final int anketaId;
  ContactUnlockedRemotelyEvent(this.anketaId);
}

class LoadCandidateDetailEvent extends VacancyEvent {
  final int id;
  LoadCandidateDetailEvent(this.id);
}

// Mos nomzodlar pipeline (Kanban) + bosqich biriktirishlari
class LoadPipelineEvent extends VacancyEvent {}

class CreateAssignmentEvent extends VacancyEvent {
  final int anketaId;
  final int requirementId;
  final String status;
  final String? interviewDatetime;
  CreateAssignmentEvent({
    required this.anketaId,
    required this.requirementId,
    this.status = 'suhbatga_yozildi',
    this.interviewDatetime,
  });
}

class UpdateAssignmentEvent extends VacancyEvent {
  final int id;
  final String? status;
  final String? interviewDatetime;
  final String? comment;
  UpdateAssignmentEvent({
    required this.id,
    this.status,
    this.interviewDatetime,
    this.comment,
  });
}

class DeleteAssignmentEvent extends VacancyEvent {
  final int id;
  DeleteAssignmentEvent(this.id);
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
