import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:meta/meta.dart';

import '../../../../core/error/error_model.dart';
import '../../data/datasource/remote/vacancy_remote_data_source.dart';
import '../../data/models/application_model.dart';
import '../../data/models/candidate_model.dart';
import '../../data/models/create_vacancy_request.dart';
import '../../data/models/employer_application_model.dart';
import '../../data/models/employer_vacancy_model.dart';
import '../../data/models/saved_vacancy_model.dart';
import '../../data/models/vacancy_model.dart';

part 'vacancy_event.dart';
part 'vacancy_state.dart';

class VacancyBloc extends Bloc<VacancyEvent, VacancyState> {
  final VacancyRemoteDataSource dataSource;

  VacancyBloc(this.dataSource) : super(const VacancyState()) {
    on<LoadSeekerVacanciesEvent>(_onLoadSeekerVacancies);
    on<LoadEmployerVacanciesEvent>(_onLoadEmployerVacancies);
    on<ApplyVacancyEvent>(_onApply);
    on<CreateVacancyEvent>(_onCreateVacancy);
    on<UpdateVacancyEvent>(_onUpdateVacancy);
    on<DeleteVacancyEvent>(_onDeleteVacancy);
    on<LoadCandidatesEvent>(_onLoadCandidates);
    on<LoadMyApplicationsEvent>(_onLoadMyApplications);
    on<UpdateApplicationStatusEvent>(_onUpdateApplicationStatus);
    on<LoadSavedVacanciesEvent>(_onLoadSaved);
    on<SaveVacancyEvent>(_onSave);
    on<UnsaveVacancyEvent>(_onUnsave);
    on<LoadEmployerApplicationsEvent>(_onLoadEmployerApplications);
    on<UpdateEmployerApplicationStatusEvent>(_onUpdateEmployerAppStatus);
  }

  Future<void> _onLoadSeekerVacancies(LoadSeekerVacanciesEvent event, Emitter<VacancyState> emit) async {
    emit(state.copyWith(vacanciesStatus: FormzSubmissionStatus.inProgress));
    final result = await dataSource.getSeekerVacancies(jobTypeId: event.jobTypeId, regionId: event.regionId);
    result.fold(
      (failure) => emit(state.copyWith(vacanciesStatus: FormzSubmissionStatus.failure, error: failure)),
      (list) => emit(state.copyWith(vacanciesStatus: FormzSubmissionStatus.success, seekerVacancies: list)),
    );
  }

  Future<void> _onLoadEmployerVacancies(LoadEmployerVacanciesEvent event, Emitter<VacancyState> emit) async {
    emit(state.copyWith(vacanciesStatus: FormzSubmissionStatus.inProgress));
    final result = await dataSource.getEmployerVacancies();
    result.fold(
      (failure) => emit(state.copyWith(vacanciesStatus: FormzSubmissionStatus.failure, error: failure)),
      (list) => emit(state.copyWith(vacanciesStatus: FormzSubmissionStatus.success, employerVacancies: list)),
    );
  }

  Future<void> _onApply(ApplyVacancyEvent event, Emitter<VacancyState> emit) async {
    emit(state.copyWith(applyStatus: FormzSubmissionStatus.inProgress));
    final result = await dataSource.applyVacancy(event.vacancyId, coverMessage: event.coverMessage);
    result.fold(
      (failure) => emit(state.copyWith(applyStatus: FormzSubmissionStatus.failure, error: failure)),
      (_) => emit(state.copyWith(applyStatus: FormzSubmissionStatus.success)),
    );
    emit(state.copyWith(applyStatus: FormzSubmissionStatus.initial));
  }

  Future<void> _onCreateVacancy(CreateVacancyEvent event, Emitter<VacancyState> emit) async {
    emit(state.copyWith(manageVacancyStatus: FormzSubmissionStatus.inProgress));
    final result = await dataSource.createOrUpdateVacancy(event.request);
    result.fold(
      (failure) => emit(state.copyWith(manageVacancyStatus: FormzSubmissionStatus.failure, error: failure)),
      (_) async {
        emit(state.copyWith(manageVacancyStatus: FormzSubmissionStatus.success));
        final refresh = await dataSource.getEmployerVacancies();
        refresh.fold((_) {}, (list) => emit(state.copyWith(employerVacancies: list)));
      },
    );
    emit(state.copyWith(manageVacancyStatus: FormzSubmissionStatus.initial));
  }

  Future<void> _onUpdateVacancy(UpdateVacancyEvent event, Emitter<VacancyState> emit) async {
    emit(state.copyWith(manageVacancyStatus: FormzSubmissionStatus.inProgress));
    final result = await dataSource.createOrUpdateVacancy(event.request);
    result.fold(
      (failure) => emit(state.copyWith(manageVacancyStatus: FormzSubmissionStatus.failure, error: failure)),
      (_) async {
        emit(state.copyWith(manageVacancyStatus: FormzSubmissionStatus.success));
        final refresh = await dataSource.getEmployerVacancies();
        refresh.fold((_) {}, (list) => emit(state.copyWith(employerVacancies: list)));
      },
    );
    emit(state.copyWith(manageVacancyStatus: FormzSubmissionStatus.initial));
  }

  Future<void> _onLoadCandidates(LoadCandidatesEvent event, Emitter<VacancyState> emit) async {
    emit(state.copyWith(candidatesStatus: FormzSubmissionStatus.inProgress));
    final result = await dataSource.getCandidates();
    result.fold(
      (failure) => emit(state.copyWith(candidatesStatus: FormzSubmissionStatus.failure, error: failure)),
      (list) => emit(state.copyWith(candidatesStatus: FormzSubmissionStatus.success, candidates: list)),
    );
  }

  Future<void> _onLoadMyApplications(LoadMyApplicationsEvent event, Emitter<VacancyState> emit) async {
    emit(state.copyWith(applicationsStatus: FormzSubmissionStatus.inProgress));
    final result = await dataSource.getMyApplications();
    result.fold(
      (failure) => emit(state.copyWith(applicationsStatus: FormzSubmissionStatus.failure, error: failure)),
      (list) => emit(state.copyWith(applicationsStatus: FormzSubmissionStatus.success, myApplications: list)),
    );
  }

  Future<void> _onUpdateApplicationStatus(UpdateApplicationStatusEvent event, Emitter<VacancyState> emit) async {
    emit(state.copyWith(updateAppStatus: FormzSubmissionStatus.inProgress));
    final result = await dataSource.updateApplicationStatus(event.applicationId, event.status);
    result.fold(
      (failure) => emit(state.copyWith(updateAppStatus: FormzSubmissionStatus.failure, error: failure)),
      (_) async {
        emit(state.copyWith(updateAppStatus: FormzSubmissionStatus.success));
        final refresh = await dataSource.getMyApplications();
        refresh.fold((_) {}, (list) => emit(state.copyWith(myApplications: list)));
      },
    );
    emit(state.copyWith(updateAppStatus: FormzSubmissionStatus.initial));
  }

  Future<void> _onDeleteVacancy(DeleteVacancyEvent event, Emitter<VacancyState> emit) async {
    emit(state.copyWith(manageVacancyStatus: FormzSubmissionStatus.inProgress));
    final result = await dataSource.deleteVacancy(event.id);
    result.fold(
      (failure) => emit(state.copyWith(manageVacancyStatus: FormzSubmissionStatus.failure, error: failure)),
      (_) {
        final updated = state.employerVacancies.where((v) => v.id != event.id).toList();
        emit(state.copyWith(manageVacancyStatus: FormzSubmissionStatus.success, employerVacancies: updated));
      },
    );
    emit(state.copyWith(manageVacancyStatus: FormzSubmissionStatus.initial));
  }

  Future<void> _onLoadSaved(LoadSavedVacanciesEvent event, Emitter<VacancyState> emit) async {
    emit(state.copyWith(savedStatus: FormzSubmissionStatus.inProgress));
    final result = await dataSource.getSavedVacancies(event.mobileUserId);
    result.fold(
      (failure) => emit(state.copyWith(savedStatus: FormzSubmissionStatus.failure, error: failure)),
      (list) => emit(state.copyWith(savedStatus: FormzSubmissionStatus.success, savedVacancies: list)),
    );
  }

  Future<void> _onSave(SaveVacancyEvent event, Emitter<VacancyState> emit) async {
    final result = await dataSource.saveVacancy(event.mobileUserId, event.vacancyId);
    if (result.isRight()) {
      final refresh = await dataSource.getSavedVacancies(event.mobileUserId);
      refresh.fold((_) {}, (list) => emit(state.copyWith(savedVacancies: list)));
    }
  }

  Future<void> _onUnsave(UnsaveVacancyEvent event, Emitter<VacancyState> emit) async {
    final result = await dataSource.unsaveVacancy(event.mobileUserId, event.vacancyId);
    result.fold(
      (_) {},
      (_) {
        final updated = state.savedVacancies.where((s) => s.vacancyId != event.vacancyId).toList();
        emit(state.copyWith(savedVacancies: updated));
      },
    );
  }

  Future<void> _onLoadEmployerApplications(LoadEmployerApplicationsEvent event, Emitter<VacancyState> emit) async {
    emit(state.copyWith(employerAppsStatus: FormzSubmissionStatus.inProgress));
    final result = await dataSource.getEmployerApplications();
    result.fold(
      (failure) => emit(state.copyWith(employerAppsStatus: FormzSubmissionStatus.failure, error: failure)),
      (list) => emit(state.copyWith(employerAppsStatus: FormzSubmissionStatus.success, employerApplications: list)),
    );
  }

  Future<void> _onUpdateEmployerAppStatus(UpdateEmployerApplicationStatusEvent event, Emitter<VacancyState> emit) async {
    emit(state.copyWith(updateEmpAppStatus: FormzSubmissionStatus.inProgress));
    final result = await dataSource.updateEmployerApplicationStatus(
      event.applicationId,
      event.status,
      interviewDatetime: event.interviewDatetime,
      type: event.type,
    );
    result.fold(
      (failure) => emit(state.copyWith(updateEmpAppStatus: FormzSubmissionStatus.failure, error: failure)),
      (_) async {
        emit(state.copyWith(updateEmpAppStatus: FormzSubmissionStatus.success));
        final refresh = await dataSource.getEmployerApplications();
        refresh.fold((_) {}, (list) => emit(state.copyWith(employerApplications: list)));
      },
    );
    emit(state.copyWith(updateEmpAppStatus: FormzSubmissionStatus.initial));
  }
}
