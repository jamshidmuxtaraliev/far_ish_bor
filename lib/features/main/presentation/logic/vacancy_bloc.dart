import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:meta/meta.dart';

import '../../../../core/error/error_model.dart';
import '../../../chat/data/datasource/chat_realtime_datasource.dart';
import '../../data/datasource/remote/vacancy_remote_data_source.dart';
import '../../data/models/ad_campaign_model.dart';
import '../../data/models/application_history_model.dart';
import '../../data/models/application_model.dart';
import '../../data/models/candidate_model.dart';
import '../../data/models/contact_unlock_model.dart';
import '../../data/models/create_vacancy_request.dart';
import '../../data/models/employer_application_model.dart';
import '../../data/models/employer_vacancy_model.dart';
import '../../data/models/pipeline_model.dart';
import '../../data/models/saved_vacancy_model.dart';
import '../../data/models/story_model.dart';
import '../../data/models/vacancy_applications_model.dart';
import '../../data/models/vacancy_candidates_model.dart';
import '../../data/models/vacancy_model.dart';

part 'vacancy_event.dart';
part 'vacancy_state.dart';

class VacancyBloc extends Bloc<VacancyEvent, VacancyState> {
  final VacancyRemoteDataSource dataSource;

  /// Socket (chat bilan umumiy): `balance:updated` va `contact:unlocked`
  /// eventlari otklik oqimini real vaqtda yangilaydi (PROMPT_OTKLIK §5.3, §7.3).
  final ChatRealtimeDatasource realtime;

  StreamSubscription<int>? _balanceSub;
  StreamSubscription<int>? _unlockedSub;

  VacancyBloc(this.dataSource, this.realtime) : super(const VacancyState()) {
    on<LoadStoriesEvent>(_onLoadStories);
    on<MarkStoryViewedEvent>(_onMarkStoryViewed);
    on<LoadPublicAdsEvent>(_onLoadPublicAds);
    on<LoadSeekerVacanciesEvent>(_onLoadSeekerVacancies);
    on<LoadEmployerVacanciesEvent>(_onLoadEmployerVacancies);
    on<ApplyVacancyEvent>(_onApply);
    on<CreateVacancyEvent>(_onCreateVacancy);
    on<UpdateVacancyEvent>(_onUpdateVacancy);
    on<DeleteVacancyEvent>(_onDeleteVacancy);
    on<SetVacancyPausedEvent>(_onSetVacancyPaused);
    on<LoadCandidatesEvent>(_onLoadCandidates);
    on<LoadVacancyCandidatesEvent>(_onLoadVacancyCandidates);
    on<LoadMyApplicationsEvent>(_onLoadMyApplications);
    on<UpdateApplicationStatusEvent>(_onUpdateApplicationStatus);
    on<LoadSavedVacanciesEvent>(_onLoadSaved);
    on<SaveVacancyEvent>(_onSave);
    on<UnsaveVacancyEvent>(_onUnsave);
    on<LoadEmployerApplicationsEvent>(_onLoadEmployerApplications);
    on<LoadVacancyApplicationsEvent>(_onLoadVacancyApplications);
    on<LoadApplicationHistoryEvent>(_onLoadApplicationHistory);
    on<UpdateEmployerApplicationStatusEvent>(_onUpdateEmployerAppStatus);
    on<LoadRecommendedCandidatesEvent>(_onLoadRecommended);
    on<LoadContactAccessEvent>(_onLoadContactAccess);
    on<UnlockContactEvent>(_onUnlockContact);
    on<LoadUnlockHistoryEvent>(_onLoadUnlockHistory);
    on<LoadCandidateDetailEvent>(_onLoadCandidateDetail);
    on<LoadPipelineEvent>(_onLoadPipeline);
    on<CreateAssignmentEvent>(_onCreateAssignment);
    on<UpdateAssignmentEvent>(_onUpdateAssignment);
    on<DeleteAssignmentEvent>(_onDeleteAssignment);
    on<BalanceUpdatedEvent>(_onBalanceUpdated);
    on<ContactUnlockedRemotelyEvent>(_onContactUnlockedRemotely);

    _balanceSub = realtime.onBalanceUpdated.listen(
      (balance) => add(BalanceUpdatedEvent(balance)),
    );
    _unlockedSub = realtime.onContactUnlocked.listen(
      (anketaId) => add(ContactUnlockedRemotelyEvent(anketaId)),
    );
  }

  @override
  Future<void> close() async {
    await _balanceSub?.cancel();
    await _unlockedSub?.cancel();
    return super.close();
  }

  /// Story lentasi. Reklama bilan bir xil qoida — xatolik `state.error` ga
  /// yozilmaydi, lenta shunchaki chizilmaydi.
  Future<void> _onLoadStories(LoadStoriesEvent event, Emitter<VacancyState> emit) async {
    if (!event.force && state.stories.isNotEmpty) return;
    emit(state.copyWith(storiesStatus: FormzSubmissionStatus.inProgress));
    final result = await dataSource.getStories();
    result.fold(
      (_) => emit(state.copyWith(storiesStatus: FormzSubmissionStatus.failure)),
      (list) => emit(state.copyWith(storiesStatus: FormzSubmissionStatus.success, stories: list)),
    );
  }

  /// Ko'rilgan storylar — server hisoblagichi + ilovada doira rangi.
  /// ⚠ Faqat shu sessiya uchun: qayta ochilganda hammasi yana "yangi"
  /// bo'ladi (mahalliy saqlash hozircha qo'shilmagan).
  Future<void> _onMarkStoryViewed(MarkStoryViewedEvent event, Emitter<VacancyState> emit) async {
    if (state.viewedStoryIds.contains(event.id)) return;
    emit(state.copyWith(viewedStoryIds: {...state.viewedStoryIds, event.id}));
    await dataSource.markStoryViewed(event.id);
  }

  /// Bosh ekrandagi reklama lentasi. Bezak bo'lgani uchun xatolik
  /// `state.error` ga YOZILMAYDI — reklama kelmagani foydalanuvchiga
  /// ko'rsatiladigan xato emas, blok shunchaki chizilmaydi.
  Future<void> _onLoadPublicAds(LoadPublicAdsEvent event, Emitter<VacancyState> emit) async {
    if (!event.force && state.ads.isNotEmpty) return;
    emit(state.copyWith(adsStatus: FormzSubmissionStatus.inProgress));
    final result = await dataSource.getPublicAds();
    result.fold(
      (_) => emit(state.copyWith(adsStatus: FormzSubmissionStatus.failure)),
      (list) => emit(state.copyWith(adsStatus: FormzSubmissionStatus.success, ads: list)),
    );
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
    await result.fold(
      (failure) async => emit(state.copyWith(manageVacancyStatus: FormzSubmissionStatus.failure, error: failure)),
      (_) async {
        emit(state.copyWith(manageVacancyStatus: FormzSubmissionStatus.success));
        await _refreshVacancySources(emit);
      },
    );
    emit(state.copyWith(manageVacancyStatus: FormzSubmissionStatus.initial));
  }

  Future<void> _onUpdateVacancy(UpdateVacancyEvent event, Emitter<VacancyState> emit) async {
    emit(state.copyWith(manageVacancyStatus: FormzSubmissionStatus.inProgress));
    final result = await dataSource.createOrUpdateVacancy(event.request);
    await result.fold(
      (failure) async => emit(state.copyWith(manageVacancyStatus: FormzSubmissionStatus.failure, error: failure)),
      (_) async {
        emit(state.copyWith(manageVacancyStatus: FormzSubmissionStatus.success));
        await _refreshVacancySources(emit);
      },
    );
    emit(state.copyWith(manageVacancyStatus: FormzSubmissionStatus.initial));
  }

  Future<void> _onLoadCandidates(LoadCandidatesEvent event, Emitter<VacancyState> emit) async {
    emit(state.copyWith(candidatesStatus: FormzSubmissionStatus.inProgress));
    final result = await dataSource.getCandidates();
    result.fold(
      (failure) => emit(state.copyWith(candidatesStatus: FormzSubmissionStatus.failure, error: failure)),
      (list) => emit(state.copyWith(
        candidatesStatus: FormzSubmissionStatus.success,
        candidates: list,
        unlockedCapabilities: _mergeCapabilities(list),
      )),
    );
  }

  Future<void> _onLoadVacancyCandidates(LoadVacancyCandidatesEvent event, Emitter<VacancyState> emit) async {
    emit(state.copyWith(vacancyCandidatesStatus: FormzSubmissionStatus.inProgress));
    final result = await dataSource.getVacancyCandidates(event.vacancyId);
    result.fold(
      (failure) => emit(state.copyWith(vacancyCandidatesStatus: FormzSubmissionStatus.failure, error: failure)),
      (data) => emit(state.copyWith(vacancyCandidatesStatus: FormzSubmissionStatus.success, vacancyCandidates: data)),
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
    await result.fold(
      (failure) async => emit(state.copyWith(updateAppStatus: FormzSubmissionStatus.failure, error: failure)),
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
    await result.fold(
      (failure) async => emit(state.copyWith(manageVacancyStatus: FormzSubmissionStatus.failure, error: failure)),
      (_) async {
        final updated = state.employerVacancies.where((v) => v.id != event.id).toList();
        emit(state.copyWith(manageVacancyStatus: FormzSubmissionStatus.success, employerVacancies: updated));
        // O'chirilgan vakansiyaning nomzodlari "Mos nomzodlar"da qolib
        // ketmasin — pipeline serverdan qayta o'qiladi.
        await _refreshVacancySources(emit);
      },
    );
    emit(state.copyWith(manageVacancyStatus: FormzSubmissionStatus.initial));
  }

  /// Play/Pause — vakansiyani vaqtincha to'xtatish yoki qayta yoqish.
  /// Muvaffaqiyatdan keyin ro'yxat serverdan qayta o'qiladi (yaratish/tahrirlash
  /// bilan bir xil naqsh) — status va boshqa maydonlar server bilan mos qolsin.
  Future<void> _onSetVacancyPaused(SetVacancyPausedEvent event, Emitter<VacancyState> emit) async {
    emit(state.copyWith(manageVacancyStatus: FormzSubmissionStatus.inProgress));
    final result = await dataSource.setVacancyPaused(event.id, event.paused);
    await result.fold(
      (failure) async => emit(state.copyWith(manageVacancyStatus: FormzSubmissionStatus.failure, error: failure)),
      (_) async {
        emit(state.copyWith(manageVacancyStatus: FormzSubmissionStatus.success));
        await _refreshVacancySources(emit);
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

  Future<void> _onLoadRecommended(LoadRecommendedCandidatesEvent event, Emitter<VacancyState> emit) async {
    emit(state.copyWith(recommendedStatus: FormzSubmissionStatus.inProgress));
    final result = await dataSource.getRecommendedCandidates();
    result.fold(
      (failure) => emit(state.copyWith(recommendedStatus: FormzSubmissionStatus.failure, error: failure)),
      (list) => emit(state.copyWith(
        recommendedStatus: FormzSubmissionStatus.success,
        recommendedCandidates: list,
        unlockedCapabilities: _mergeCapabilities(list),
      )),
    );
  }

  /// Ro'yxat javoblaridagi ochiq nomzodlarning `capabilities`ini yig'ib boradi
  /// (§6: `candidates`, `recommended`, `pipeline` — ochilganlarida keladi).
  Map<int, ContactCapabilitiesModel> _mergeCapabilities(
      Iterable<CandidateModel> list) {
    final caps =
        Map<int, ContactCapabilitiesModel>.from(state.unlockedCapabilities);
    for (final c in list) {
      if (c.capabilities != null) caps[c.id] = c.capabilities!;
    }
    return caps;
  }

  Future<void> _onLoadContactAccess(LoadContactAccessEvent event, Emitter<VacancyState> emit) async {
    emit(state.copyWith(contactAccessStatus: FormzSubmissionStatus.inProgress));
    final result = await dataSource.getContactAccess();
    result.fold(
      (failure) => emit(state.copyWith(contactAccessStatus: FormzSubmissionStatus.failure, error: failure)),
      (access) => emit(state.copyWith(contactAccessStatus: FormzSubmissionStatus.success, contactAccess: access)),
    );
  }

  Future<void> _onUnlockContact(UnlockContactEvent event, Emitter<VacancyState> emit) async {
    emit(state.copyWith(
      unlockStatus: FormzSubmissionStatus.inProgress,
      lastUnlockAttemptId: event.anketaId,
    ));
    final result = await dataSource.unlockContact(
      anketaId: event.anketaId,
      vacancyId: event.vacancyId,
      trigger: event.trigger,
    );
    result.fold(
      (failure) {
        // §10 — nomzod o'chirilgan (404): kartani ro'yxatlardan olib tashlaymiz.
        if (failure.errorCode == 404) {
          emit(state.copyWith(
            unlockStatus: FormzSubmissionStatus.failure,
            error: failure,
            candidates:
                state.candidates.where((c) => c.id != event.anketaId).toList(),
            recommendedCandidates: state.recommendedCandidates
                .where((c) => c.id != event.anketaId)
                .toList(),
          ));
          return;
        }
        emit(state.copyWith(
            unlockStatus: FormzSubmissionStatus.failure, error: failure));
      },
      (unlockResult) {
        final newUnlocked = Set<int>.from(state.unlockedAnketaIds)..add(event.anketaId);
        final newPhones = Map<int, String>.from(state.unlockedPhones)
          ..[event.anketaId] = unlockResult.phone;
        // §6 — ochilgach uchta imkoniyat (telefon · chat · suhbat) shu yerda
        // saqlanadi; ro'yxatni qayta yuklashni kutmasdan karta ochiq bo'ladi.
        final caps = Map<int, ContactCapabilitiesModel>.from(
            state.unlockedCapabilities);
        if (unlockResult.capabilities != null) {
          caps[event.anketaId] = unlockResult.capabilities!;
        }
        emit(state.copyWith(
          unlockStatus: FormzSubmissionStatus.success,
          unlockResult: unlockResult,
          unlockedAnketaIds: newUnlocked,
          unlockedPhones: newPhones,
          unlockedCapabilities: caps,
          // Balans YOKI otklik qoldig'i — qaysi yo'l bilan ochilgan bo'lsa
          // o'shani darhol yangilaymiz (kartalar qayta so'rovsiz to'g'ri
          // ko'rsatsin).
          contactAccess: (unlockResult.balance != null ||
                  unlockResult.otklikRemaining != null)
              ? state.contactAccess?.copyWith(
                  balance: unlockResult.balance,
                  otklikAvailable: unlockResult.otklikRemaining,
                )
              : null,
        ));
      },
    );
    emit(state.copyWith(unlockStatus: FormzSubmissionStatus.initial));
  }

  /// `balance:updated` — to'lov webhook'i kelgach serverdan yangi balans.
  void _onBalanceUpdated(BalanceUpdatedEvent event, Emitter<VacancyState> emit) {
    final access = state.contactAccess;
    if (access == null) return;
    emit(state.copyWith(contactAccess: access.copyWith(balance: event.balance)));
  }

  /// `contact:unlocked` — nomzod boshqa qurilmada/to'lovdan keyin ochildi.
  void _onContactUnlockedRemotely(
      ContactUnlockedRemotelyEvent event, Emitter<VacancyState> emit) {
    if (state.unlockedAnketaIds.contains(event.anketaId)) return;
    emit(state.copyWith(
      unlockedAnketaIds: Set<int>.from(state.unlockedAnketaIds)
        ..add(event.anketaId),
    ));
  }

  Future<void> _onLoadCandidateDetail(LoadCandidateDetailEvent event, Emitter<VacancyState> emit) async {
    emit(state.copyWith(candidateDetailStatus: FormzSubmissionStatus.inProgress));
    final result = await dataSource.getCandidateDetail(event.id);
    result.fold(
      (failure) => emit(state.copyWith(
        candidateDetailStatus: FormzSubmissionStatus.failure,
        error: failure,
      )),
      (detail) {
        // Ochilgan nomzodda detal javobi `capabilities` bilan keladi (§6).
        final caps = Map<int, ContactCapabilitiesModel>.from(
            state.unlockedCapabilities);
        if (detail.capabilities != null) caps[detail.id] = detail.capabilities!;
        final unlocked = Set<int>.from(state.unlockedAnketaIds);
        if (detail.isUnlocked || (!detail.locked && detail.phoneRaw != null)) {
          unlocked.add(detail.id);
        }
        emit(state.copyWith(
          candidateDetailStatus: FormzSubmissionStatus.success,
          candidateDetail: detail,
          unlockedCapabilities: caps,
          unlockedAnketaIds: unlocked,
        ));
      },
    );
  }

  Future<void> _onLoadUnlockHistory(LoadUnlockHistoryEvent event, Emitter<VacancyState> emit) async {
    emit(state.copyWith(unlockHistoryStatus: FormzSubmissionStatus.inProgress));
    final result = await dataSource.getUnlockHistory();
    result.fold(
      (failure) => emit(state.copyWith(unlockHistoryStatus: FormzSubmissionStatus.failure, error: failure)),
      (list) {
        final ids = list.map((h) => h.anketaId).toSet();
        emit(state.copyWith(
          unlockHistoryStatus: FormzSubmissionStatus.success,
          unlockHistory: list,
          unlockedAnketaIds: ids,
        ));
      },
    );
  }

  Future<void> _onLoadPipeline(LoadPipelineEvent event, Emitter<VacancyState> emit) async {
    emit(state.copyWith(pipelineStatus: FormzSubmissionStatus.inProgress));
    final result = await dataSource.getPipeline();
    result.fold(
      (failure) => emit(state.copyWith(pipelineStatus: FormzSubmissionStatus.failure, error: failure)),
      (data) => emit(state.copyWith(
        pipelineStatus: FormzSubmissionStatus.success,
        pipeline: data,
        unlockedCapabilities: _mergeCapabilities(
            data.candidatesByReq.expand((g) => g.candidates)),
      )),
    );
  }

  /// Vakansiya ro'yxati o'zgargach — dropdown BILAN BIRGA "Mos nomzodlar"
  /// manbasi ham yangilanadi.
  ///
  /// ⚠ Ilgari bu yerda faqat `getEmployerVacancies()` chaqirilardi: yangi
  /// vakansiya dropdownda darhol paydo bo'lardi, lekin `pipeline` eski holida
  /// qolib "Mos nomzodlar" tabi BO'SH ko'rinardi (Yangi/Jarayonda/Suhbat — 0),
  /// holbuki server o'nlab mos nomzod qaytarardi. `LoadPipelineEvent` faqat
  /// [CandidatesScreen.initState] da yuboriladi, ekran esa `IndexedStack` da
  /// tirik saqlanadi — ya'ni bir marta ochilgach o'zi qayta yuklanmaydi.
  Future<void> _refreshVacancySources(Emitter<VacancyState> emit) async {
    final vacancies = await dataSource.getEmployerVacancies();
    vacancies.fold(
        (_) {}, (list) => emit(state.copyWith(employerVacancies: list)));
    final pipeline = await dataSource.getPipeline();
    pipeline.fold(
      (_) {},
      (data) => emit(state.copyWith(
        pipelineStatus: FormzSubmissionStatus.success,
        pipeline: data,
        unlockedCapabilities: _mergeCapabilities(
            data.candidatesByReq.expand((g) => g.candidates)),
      )),
    );
  }

  /// Biriktirish o'zgargach pipeline + tavsiyalarni qayta yuklaymiz (§7).
  Future<void> _refreshAfterAssignment(Emitter<VacancyState> emit) async {
    final pipeline = await dataSource.getPipeline();
    pipeline.fold((_) {}, (data) => emit(state.copyWith(pipeline: data)));
    final recommended = await dataSource.getRecommendedCandidates();
    recommended.fold((_) {}, (list) => emit(state.copyWith(recommendedCandidates: list)));
  }

  Future<void> _onCreateAssignment(CreateAssignmentEvent event, Emitter<VacancyState> emit) async {
    emit(state.copyWith(assignmentActionStatus: FormzSubmissionStatus.inProgress));
    final result = await dataSource.createAssignment(
      anketaId: event.anketaId,
      employerRequirementId: event.requirementId,
      status: event.status,
      interviewDatetime: event.interviewDatetime,
    );
    await result.fold(
      (failure) async => emit(state.copyWith(assignmentActionStatus: FormzSubmissionStatus.failure, error: failure)),
      (_) async {
        emit(state.copyWith(assignmentActionStatus: FormzSubmissionStatus.success));
        await _refreshAfterAssignment(emit);
      },
    );
    emit(state.copyWith(assignmentActionStatus: FormzSubmissionStatus.initial));
  }

  Future<void> _onUpdateAssignment(UpdateAssignmentEvent event, Emitter<VacancyState> emit) async {
    emit(state.copyWith(assignmentActionStatus: FormzSubmissionStatus.inProgress));
    final result = await dataSource.updateAssignment(
      event.id,
      status: event.status,
      interviewDatetime: event.interviewDatetime,
      comment: event.comment,
    );
    await result.fold(
      (failure) async => emit(state.copyWith(assignmentActionStatus: FormzSubmissionStatus.failure, error: failure)),
      (_) async {
        emit(state.copyWith(assignmentActionStatus: FormzSubmissionStatus.success));
        await _refreshAfterAssignment(emit);
      },
    );
    emit(state.copyWith(assignmentActionStatus: FormzSubmissionStatus.initial));
  }

  Future<void> _onDeleteAssignment(DeleteAssignmentEvent event, Emitter<VacancyState> emit) async {
    emit(state.copyWith(assignmentActionStatus: FormzSubmissionStatus.inProgress));
    final result = await dataSource.deleteAssignment(event.id);
    await result.fold(
      (failure) async => emit(state.copyWith(assignmentActionStatus: FormzSubmissionStatus.failure, error: failure)),
      (_) async {
        emit(state.copyWith(assignmentActionStatus: FormzSubmissionStatus.success));
        await _refreshAfterAssignment(emit);
      },
    );
    emit(state.copyWith(assignmentActionStatus: FormzSubmissionStatus.initial));
  }

  Future<void> _onLoadVacancyApplications(
      LoadVacancyApplicationsEvent event, Emitter<VacancyState> emit) async {
    emit(state.copyWith(
        vacancyApplicationsStatus: FormzSubmissionStatus.inProgress));
    final result = await dataSource.getVacancyApplications(
      event.vacancyId,
      status: event.status,
    );
    result.fold(
      (failure) => emit(state.copyWith(
          vacancyApplicationsStatus: FormzSubmissionStatus.failure,
          error: failure)),
      (data) => emit(state.copyWith(
          vacancyApplicationsStatus: FormzSubmissionStatus.success,
          vacancyApplications: data)),
    );
  }

  Future<void> _onLoadApplicationHistory(
      LoadApplicationHistoryEvent event, Emitter<VacancyState> emit) async {
    emit(state.copyWith(
        applicationHistoryStatus: FormzSubmissionStatus.inProgress));
    final result = await dataSource.getApplicationHistory(
      event.applicationId,
      asEmployer: event.asEmployer,
    );
    result.fold(
      (failure) => emit(state.copyWith(
          applicationHistoryStatus: FormzSubmissionStatus.failure,
          error: failure)),
      (data) => emit(state.copyWith(
          applicationHistoryStatus: FormzSubmissionStatus.success,
          applicationHistory: data)),
    );
  }

  Future<void> _onUpdateEmployerAppStatus(UpdateEmployerApplicationStatusEvent event, Emitter<VacancyState> emit) async {
    emit(state.copyWith(updateEmpAppStatus: FormzSubmissionStatus.inProgress));
    // ⚠ `fold` ning muvaffaqiyat shoxi `async` — u AWAIT qilinmasa handler
    // tugab, Emitter yopilgandan keyin `emit` chaqiriladi (bloc StateError
    // beradi) va ro'yxat/statistika/vakansiya kartasidagi sonlar yangilanmay
    // qoladi. Shuning uchun `await result.fold(...)`.
    final result = await dataSource.updateEmployerApplicationStatus(
      event.applicationId,
      event.status,
      interviewDatetime: event.interviewDatetime,
      type: event.type,
    );
    await result.fold(
      (failure) async => emit(state.copyWith(updateEmpAppStatus: FormzSubmissionStatus.failure, error: failure)),
      (_) async {
        emit(state.copyWith(updateEmpAppStatus: FormzSubmissionStatus.success));
        final refresh = await dataSource.getEmployerApplications();
        refresh.fold((_) {}, (list) => emit(state.copyWith(employerApplications: list)));
        // Otkliklar ekrani ochiq bo'lsa — ro'yxat, statistika va vakansiya
        // kartalaridagi sonlar ham yangilansin (§11).
        final vacancyId = state.vacancyApplications?.vacancy?.id;
        if (vacancyId != null) {
          final apps = await dataSource.getVacancyApplications(vacancyId);
          apps.fold((_) {}, (data) => emit(state.copyWith(vacancyApplications: data)));
          final vacancies = await dataSource.getEmployerVacancies();
          vacancies.fold((_) {}, (list) => emit(state.copyWith(employerVacancies: list)));
        }
      },
    );
    emit(state.copyWith(updateEmpAppStatus: FormzSubmissionStatus.initial));
  }
}
