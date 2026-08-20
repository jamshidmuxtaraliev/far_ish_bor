import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../../../../core/theme/jb_ui.dart';
import '../../../billing/data/models/balance_model.dart' show formatSom;
import '../../../billing/presentation/logic/billing_bloc.dart';
import '../../../billing/presentation/screens/topup_screen.dart';
import '../../data/models/employer_application_model.dart';
import '../../data/models/employer_vacancy_model.dart';
import '../../data/models/pipeline_model.dart';
import '../logic/candidate_buckets.dart';
import '../logic/vacancy_bloc.dart';
import '../widgets/candidate_card.dart' show CandidateUnlockListener;
import '../widgets/nomzod_cards.dart';
import '../widgets/state_views.dart';
import 'unlock_history_screen.dart';
import '../../../../core/theme/jb_palette.dart';

/// Ish beruvchi "Nomzodlar" ekrani — PROMPT_NOMZODLAR_3TAB_MOBILE.md.
///
/// 3 ta asosiy tab (manba bo'yicha) + har uchoviga umumiy "chrome":
///   • Vakansiya dropdown (Barcha vakansiyalar / bitta vakansiya)
///   • Status segmenti — Yangi · Jarayonda · Suhbat (sanoq bilan)
///   • Arxiv (N) — yakuniy holatdagilar alohida rejimda
///
/// ⚠️ Backend bu endpointlarda status/vakansiya filtri qabul qilmaydi (§0) —
/// manba bir marta yuklanadi, filtr va sanoq **mahalliy** hisoblanadi. Vakansiya
/// yoki segment o'zgarganda qayta so'rov YO'Q, faqat `setState`.
class CandidatesScreen extends StatefulWidget {
  const CandidatesScreen({super.key});

  @override
  State<CandidatesScreen> createState() => _CandidatesScreenState();
}

/// Asosiy tablar (§0).
enum _MainTab { applications, recommended, matched }

class _CandidatesScreenState extends State<CandidatesScreen> {
  _MainTab _tab = _MainTab.applications;

  /// Tanlangan vakansiya (`employer_requirement_id`); `null` = Barcha vakansiyalar.
  int? _selectedReqId;

  /// Status segmenti.
  Bucket _bucket = Bucket.yangi;

  /// "Arxiv (N)" rejimi — segment o'rniga yakuniy holatdagilar ko'rsatiladi.
  bool _archive = false;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  void _loadAll() {
    final vacancy = context.read<VacancyBloc>();
    vacancy.add(LoadEmployerApplicationsEvent()); // Tab 1
    vacancy.add(LoadRecommendedCandidatesEvent()); // Tab 2
    vacancy.add(LoadPipelineEvent()); // Tab 3 + status (assignments)
    vacancy.add(LoadEmployerVacanciesEvent()); // vakansiya dropdown
    vacancy.add(LoadContactAccessEvent());
    vacancy.add(LoadUnlockHistoryEvent());
    context.read<BillingBloc>().add(const LoadBalanceEvent(true));
  }

  Bucket get _activeBucket => _archive ? Bucket.arxiv : _bucket;

  /// Filtr metodlarida "joriy tanlovni ishlat" degani (null = Barcha vakansiyalar
  /// bilan aralashib ketmasligi uchun alohida sentinel).
  static const Object _kCurrent = Object();

  int? _resolveReq(Object? reqId) =>
      identical(reqId, _kCurrent) ? _selectedReqId : reqId as int?;

  // ── Vakansiya ro'yxati (§7) ─────────────────────────────────────────────────
  // Manba: /mobile/employer/vacancies; bo'sh bo'lsa /pipeline.requirements.

  List<EmployerVacancyModel> _vacancies(VacancyState s) {
    if (s.employerVacancies.isNotEmpty) return s.employerVacancies;
    return s.pipeline?.requirements ?? const [];
  }

  EmployerVacancyModel? _selectedVacancy(List<EmployerVacancyModel> list) {
    final id = _selectedReqId;
    if (id == null) return null;
    for (final v in list) {
      if (v.id == id) return v;
    }
    return null;
  }

  // ── Manbalarni bucket'larga ajratish (§4.2, §5.2, §6.2) ─────────────────────

  /// anketa_id → biriktirish (pipeline'dan). Tab 2 statusini shundan olamiz.
  Map<int, PipelineAssignment> _assignmentsByAnketa(VacancyState s) {
    final map = <int, PipelineAssignment>{};
    for (final a in s.pipeline?.assignments ?? const <PipelineAssignment>[]) {
      map[a.anketaId] = a;
    }
    return map;
  }

  /// Tab 1 — arizalar, vakansiya bo'yicha filtrlangan.
  /// [reqId] berilmasa joriy tanlov ishlatiladi; `null` = filtrsiz (Barchasi).
  List<EmployerApplicationModel> _applications(VacancyState s,
      {Object? reqId = _kCurrent}) {
    final id = _resolveReq(reqId);
    final list = s.employerApplications;
    if (id == null) return list;
    return list.where((a) => a.requirementId == id).toList();
  }

  /// Tab 2 — ochilgan/tavsiya qilingan nomzodlar (+ pipeline'dan status).
  List<NomzodRow> _recommendedRows(VacancyState s, {Object? reqId = _kCurrent}) {
    final byAnketa = _assignmentsByAnketa(s);
    final id = _resolveReq(reqId);
    final rows = <NomzodRow>[];
    for (final c in s.recommendedCandidates) {
      // §7: vakansiyasi yo'q yozuvlar faqat "Barchasi"da ko'rinadi.
      if (id != null && c.vacancy?.id != id) continue;
      final a = byAnketa[c.id];
      rows.add(NomzodRow(
        candidate: c,
        requirementId: c.vacancy?.id ?? a?.employerRequirementId ?? id,
        assignmentId: a?.id ?? c.assignment?.id,
        assignmentStatus: a?.status ?? c.assignment?.status,
        interviewDisplay: a?.interviewDatetime != null ? a!.interviewDisplay : null,
      ));
    }
    return rows;
  }

  /// Tab 3 — mos nomzodlar (pipeline `candidatesByReq`, vakansiya bo'yicha).
  List<NomzodRow> _matchedRows(VacancyState s, {Object? reqId = _kCurrent}) {
    final pipeline = s.pipeline;
    if (pipeline == null) return const [];
    final id = _resolveReq(reqId);
    final rows = <NomzodRow>[];
    for (final grp in pipeline.candidatesByReq) {
      if (id != null && grp.requirementId != id) continue;
      for (final c in grp.candidates) {
        final a = pipeline.assignmentFor(grp.requirementId, c.id);
        rows.add(NomzodRow(
          candidate: c,
          requirementId: grp.requirementId,
          assignmentId: a?.id,
          assignmentStatus: a?.status,
          interviewDisplay:
              a?.interviewDatetime != null ? a!.interviewDisplay : null,
        ));
      }
    }
    return rows;
  }

  /// Joriy tab + vakansiya bo'yicha bucket sanoqlari (§8).
  Map<Bucket, int> _counts(VacancyState s) {
    final counts = {for (final b in Bucket.values) b: 0};
    switch (_tab) {
      case _MainTab.applications:
        for (final a in _applications(s)) {
          counts[bucketFromApplication(a.status)] =
              counts[bucketFromApplication(a.status)]! + 1;
        }
      case _MainTab.recommended:
        for (final r in _recommendedRows(s)) {
          final b = bucketFromAssignment(r.assignmentStatus);
          counts[b] = counts[b]! + 1;
        }
      case _MainTab.matched:
        for (final r in _matchedRows(s)) {
          final b = bucketFromAssignment(r.assignmentStatus);
          counts[b] = counts[b]! + 1;
        }
    }
    return counts;
  }

  bool _loadingCurrentTab(VacancyState s) => switch (_tab) {
        _MainTab.applications =>
          s.employerAppsStatus.isInProgress && s.employerApplications.isEmpty,
        _MainTab.recommended =>
          s.recommendedStatus.isInProgress && s.recommendedCandidates.isEmpty,
        _MainTab.matched => s.pipelineStatus.isInProgress && s.pipeline == null,
      };

  bool _failedCurrentTab(VacancyState s) => switch (_tab) {
        _MainTab.applications =>
          s.employerAppsStatus == FormzSubmissionStatus.failure &&
              s.employerApplications.isEmpty,
        _MainTab.recommended =>
          s.recommendedStatus == FormzSubmissionStatus.failure &&
              s.recommendedCandidates.isEmpty,
        _MainTab.matched => s.pipelineStatus == FormzSubmissionStatus.failure &&
            s.pipeline == null,
      };

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.jb.overlay,
      child: CandidateUnlockListener(
        child: MultiBlocListener(
          listeners: [
            // Biriktirish amali xatosi (ayniqsa kontakt gate — 402).
            BlocListener<VacancyBloc, VacancyState>(
              listenWhen: (p, c) =>
                  p.assignmentActionStatus != c.assignmentActionStatus,
              listener: _onAssignmentAction,
            ),
            // Ariza statusi o'zgarishi.
            BlocListener<VacancyBloc, VacancyState>(
              listenWhen: (p, c) => p.updateEmpAppStatus != c.updateEmpAppStatus,
              listener: _onApplicationStatusChanged,
            ),
            // Kontakt ochilgach balansni yangilaymiz.
            BlocListener<VacancyBloc, VacancyState>(
              listenWhen: (p, c) => p.unlockStatus != c.unlockStatus,
              listener: (context, state) {
                if (state.unlockStatus.isSuccess) {
                  context.read<BillingBloc>().add(const LoadBalanceEvent(true));
                }
              },
            ),
          ],
          child: Scaffold(
            backgroundColor: context.jb.bg,
            body: BlocBuilder<VacancyBloc, VacancyState>(
              builder: (context, state) {
                final counts = _counts(state);
                return Column(
                  children: [
                    _header(context),
                    _mainTabs(),
                    _filterRow(state, counts[Bucket.arxiv] ?? 0),
                    if (!_archive) _statusSegment(counts),
                    Expanded(child: _body(state)),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _onAssignmentAction(BuildContext context, VacancyState state) {
    if (!state.assignmentActionStatus.isFailure) return;
    final is402 = state.error?.errorCode == 402;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(is402
            ? 'Avval nomzod kontaktini oching'
            : (state.error?.errorMessage ?? 'Amalni bajarib bo\'lmadi')),
        backgroundColor: is402 ? context.jb.amber : context.jb.red,
      ),
    );
  }

  void _onApplicationStatusChanged(BuildContext context, VacancyState state) {
    if (state.updateEmpAppStatus.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Holat yangilandi'),
        backgroundColor: context.jb.green,
      ));
    } else if (state.updateEmpAppStatus.isFailure) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(state.error?.errorMessage ?? 'Holatni o\'zgartirib bo\'lmadi'),
        backgroundColor: context.jb.red,
      ));
    }
  }

  // ── Header ──────────────────────────────────────────────────────────────────

  Widget _header(BuildContext context) {
    return Container(
      width: double.infinity,
      color: context.jb.card,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 12,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text('Nomzodlar',
                style: TextStyle(
                    color: context.jb.ink, fontSize: 22, fontWeight: FontWeight.w800)),
          ),
          _balanceChip(context),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const UnlockHistoryScreen())),
            child: Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: context.jb.chipBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.history_rounded, color: context.jb.gray, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  /// Tarifli bo'lsa → "Premium" (otklik yo'q, §9.1), aks holda balans chipi.
  Widget _balanceChip(BuildContext context) {
    return BlocBuilder<VacancyBloc, VacancyState>(
      buildWhen: (p, c) => p.contactAccess != c.contactAccess,
      builder: (context, vacState) {
        if (!vacState.isOtklikMode) {
          return JBChip(
            text: '✦ Premium',
            bg: context.jb.greenBg,
            fg: context.jb.green,
            fontSize: 12,
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          );
        }
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const TopUpScreen(isEmployer: true)),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: context.jb.blueTint,
              borderRadius: BorderRadius.circular(100),
            ),
            child: BlocBuilder<BillingBloc, BillingState>(
              buildWhen: (p, c) =>
                  p.balance != c.balance || p.balanceStatus != c.balanceStatus,
              builder: (context, billing) {
                final balance = billing.balance;
                final loading =
                    balance == null && billing.balanceStatus.isInProgress;
                // Balans `contact-access` javobida ham keladi (§2) — biri
                // yetib kelmasa ikkinchisini ko'rsatamiz.
                final fallback = vacState.contactAccess?.balance;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      loading
                          ? '...'
                          : (balance?.balanceDisplay ??
                              (fallback != null
                                  ? formatSom(fallback)
                                  : "0 so'm")),
                      style: TextStyle(
                          color: context.jb.blue,
                          fontSize: 12,
                          fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(width: 5),
                    Icon(Icons.add_circle_outline,
                        color: context.jb.blue, size: 16),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  // ── 3 asosiy tab (§2) ───────────────────────────────────────────────────────

  Widget _mainTabs() {
    const labels = {
      _MainTab.applications: 'Ishga topshirgan',
      _MainTab.recommended: 'Tavsiya etilgan',
      _MainTab.matched: 'Mos nomzodlar',
    };
    return Container(
      color: jb.card,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: jb.chipBg,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          children: _MainTab.values.map((t) {
            final active = _tab == t;
            return Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() {
                  _tab = t;
                  _bucket = Bucket.yangi;
                  _archive = false;
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: active ? jb.blue : Colors.transparent,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    labels[t]!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: active ? Colors.white : jb.gray,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ── Vakansiya dropdown + Arxiv (§2, §7) ─────────────────────────────────────

  Widget _filterRow(VacancyState state, int archiveCount) {
    final vacancies = _vacancies(state);
    final selected = _selectedVacancy(vacancies);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: vacancies.isEmpty
                    ? null
                    : () => _openVacancySheet(vacancies, state),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  height: 46,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: jb.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: _selectedReqId == null ? jb.border : jb.blue,
                        width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.business_center_rounded,
                          size: 17,
                          color:
                              _selectedReqId == null ? jb.grayLight : jb.blue),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          selected?.jobTypeName ?? 'Barcha vakansiyalar',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: _selectedReqId == null ? jb.ink : jb.blue,
                          ),
                        ),
                      ),
                      Icon(Icons.keyboard_arrow_down_rounded,
                          color: jb.gray, size: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => setState(() => _archive = !_archive),
            child: Container(
              height: 46,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: _archive ? jb.ink : jb.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: _archive ? jb.ink : jb.border, width: 1.5),
              ),
              child: Row(
                children: [
                  Icon(Icons.inventory_2_outlined,
                      size: 17, color: _archive ? Colors.white : jb.ink),
                  const SizedBox(width: 7),
                  Text(
                    'Arxiv ($archiveCount)',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _archive ? Colors.white : jb.ink),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openVacancySheet(
      List<EmployerVacancyModel> vacancies, VacancyState state) async {
    // Sheet'dagi sanoq — joriy tab bo'yicha, o'sha vakansiyaga tegishli yozuvlar.
    int countFor(int? reqId) => switch (_tab) {
          _MainTab.applications => _applications(state, reqId: reqId).length,
          _MainTab.recommended => _recommendedRows(state, reqId: reqId).length,
          _MainTab.matched => _matchedRows(state, reqId: reqId).length,
        };

    final picked = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: jb.card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => _VacancySheet(
        vacancies: vacancies,
        selectedId: _selectedReqId,
        countFor: countFor,
      ),
    );
    if (picked == null || !mounted) return; // bekor qilindi
    setState(() => _selectedReqId = picked == -1 ? null : picked);
  }

  // ── Status segmenti (§2, §8) ────────────────────────────────────────────────

  Widget _statusSegment(Map<Bucket, int> counts) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: jb.card,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: jb.border, width: 1.5),
        ),
        child: Row(
          children: kSegmentBuckets.map((b) {
            final active = _bucket == b;
            final count = counts[b] ?? 0;
            return Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => _bucket = b),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: active ? jb.blueTint : Colors.transparent,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          bucketLabel(b),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: active ? jb.blue : jb.gray,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 1),
                        decoration: BoxDecoration(
                          color: active ? jb.blue : jb.chipBg,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          '$count',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: active ? Colors.white : jb.gray,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ── Kontent ─────────────────────────────────────────────────────────────────

  Widget _body(VacancyState state) {
    // §2 — operator nomzod bazasini yopgan bo'lsa mos nomzodlar ko'rsatilmaydi.
    final access = state.contactAccess;
    if (_tab == _MainTab.matched && access != null && !access.canSearchCandidates) {
      return EmptyView(
        icon: Icons.lock_outline_rounded,
        message: 'Nomzodlar bazasi yopiq',
        subtitle: 'Bazadan foydalanish uchun operator bilan bog\'laning.',
      );
    }
    if (_loadingCurrentTab(state)) {
      return Center(child: CircularProgressIndicator(color: jb.blue));
    }
    if (_failedCurrentTab(state)) {
      return ErrorView(
        message: state.error?.errorMessage ?? 'Xato yuz berdi',
        onRetry: _loadAll,
      );
    }

    final bucket = _activeBucket;
    final children = switch (_tab) {
      _MainTab.applications => _applications(state)
          .where((a) => bucketFromApplication(a.status) == bucket)
          .map<Widget>((a) => ApplicationNomzodCard(
                app: a,
                onChangeStatus: () => _openStatusSheet(a),
              ))
          .toList(),
      _MainTab.recommended => _recommendedRows(state)
          .where((r) => bucketFromAssignment(r.assignmentStatus) == bucket)
          .map<Widget>((r) => NomzodCard(row: r, state: state))
          .toList(),
      _MainTab.matched => _matchedRows(state)
          .where((r) => bucketFromAssignment(r.assignmentStatus) == bucket)
          .map<Widget>((r) =>
              NomzodCard(row: r, state: state, showMatch: true))
          .toList(),
    };

    if (children.isEmpty) return _empty();

    return RefreshIndicator(
      color: jb.blue,
      onRefresh: () async => _loadAll(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        itemCount: children.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) => i == 0
            ? Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text('${children.length} ta nomzod',
                    style: TextStyle(fontSize: 13, color: jb.gray)),
              )
            : children[i - 1],
      ),
    );
  }

  Widget _empty() {
    return LayoutBuilder(
      builder: (context, constraints) => RefreshIndicator(
        color: jb.blue,
        onRefresh: () async => _loadAll(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: constraints.maxHeight,
            child: EmptyView(
              icon: _archive
                  ? Icons.inventory_2_outlined
                  : Icons.people_outline_rounded,
              message: 'Kechirasiz, ma\'lumot yo\'q…',
              subtitle: _selectedReqId == null
                  ? '${bucketLabel(_activeBucket)} bo\'limida hozircha nomzod yo\'q'
                  : 'Tanlangan vakansiya bo\'yicha ${bucketLabel(_activeBucket).toLowerCase()} nomzod yo\'q',
              action: _selectedReqId == null
                  ? null
                  : JBPillButton(
                      label: 'Barcha vakansiyalar',
                      leadingIcon: Icons.clear_all_rounded,
                      variant: JBBtnVariant.outline,
                      vPadding: 11,
                      onTap: () => setState(() => _selectedReqId = null),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Ariza statusini o'zgartirish (§4.3) ─────────────────────────────────────

  Future<void> _openStatusSheet(EmployerApplicationModel app) async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: jb.card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => _StatusSheet(current: app.status),
    );
    if (picked == null || !mounted) return;

    // 'scheduled' — interview_datetime MAJBURIY (§4.3).
    String? iso;
    if (picked == 'scheduled') {
      final schedule = await pickSchedule(context,
          title: 'Suhbat vaqtini belgilang', requireTime: true);
      if (schedule?.dateTime == null || !mounted) return;
      iso = schedule!.iso;
    }
    if (!mounted) return;
    context.read<VacancyBloc>().add(UpdateEmployerApplicationStatusEvent(
          app.id,
          picked,
          interviewDatetime: iso,
          type: picked == 'scheduled' ? 'offline' : null,
        ));
  }
}

// ── Vakansiya tanlash sheet'i ─────────────────────────────────────────────────

/// `Navigator.pop` qiymatlari: `-1` = Barcha vakansiyalar, id = aniq vakansiya,
/// `null` = bekor qilindi.
class _VacancySheet extends StatelessWidget {
  final List<EmployerVacancyModel> vacancies;
  final int? selectedId;
  final int Function(int? reqId) countFor;

  const _VacancySheet({
    required this.vacancies,
    required this.selectedId,
    required this.countFor,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _SheetHandle(),
            Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Vakansiyani tanlang',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: context.jb.ink)),
              ),
            ),
            Flexible(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                shrinkWrap: true,
                itemCount: vacancies.length + 1,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  if (i == 0) {
                    return _row(
                      context,
                      title: 'Barcha vakansiyalar',
                      subtitle: '${vacancies.length} ta vakansiya',
                      count: countFor(null),
                      active: selectedId == null,
                      value: -1,
                    );
                  }
                  final v = vacancies[i - 1];
                  return _row(
                    context,
                    title: v.jobTypeName ?? 'Vakansiya #${v.id}',
                    subtitle: v.salaryDisplay,
                    count: countFor(v.id),
                    active: selectedId == v.id,
                    value: v.id,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(
    BuildContext context, {
    required String title,
    required String subtitle,
    required int count,
    required bool active,
    required int value,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.pop(context, value),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: active ? context.jb.blueTint : context.jb.card,
            borderRadius: BorderRadius.circular(16),
            border:
                Border.all(color: active ? context.jb.blue : context.jb.border, width: 1.5),
          ),
          child: Row(
            children: [
              Icon(
                active
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                size: 20,
                color: active ? context.jb.blue : context.jb.grayLight,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: active ? context.jb.blue : context.jb.ink)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: context.jb.gray)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              JBChip(
                text: '$count',
                bg: active ? context.jb.card : context.jb.chipBg,
                fg: active ? context.jb.blue : context.jb.gray,
                fontSize: 12,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Ariza statusini tanlash sheet'i ───────────────────────────────────────────

class _StatusSheet extends StatelessWidget {
  final String current;
  const _StatusSheet({required this.current});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _SheetHandle(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Holatni o\'zgartirish',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: context.jb.ink)),
                  const SizedBox(height: 4),
                  Text('Joriy holat: ${applicationStatusLabel(current)}',
                      style: TextStyle(fontSize: 13, color: context.jb.gray)),
                ],
              ),
            ),
            Flexible(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                shrinkWrap: true,
                itemCount: kEmployerAllowedStatuses.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final s = kEmployerAllowedStatuses[i];
                  final tone = statusTone(s);
                  final isCurrent = s == current;
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap:
                          isCurrent ? null : () => Navigator.pop(context, s),
                      borderRadius: BorderRadius.circular(16),
                      child: Opacity(
                        opacity: isCurrent ? 0.45 : 1,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: context.jb.card,
                            borderRadius: BorderRadius.circular(16),
                            border:
                                Border.all(color: context.jb.border, width: 1.5),
                          ),
                          child: Row(
                            children: [
                              JBIconTile(
                                icon: applicationActionIcon(s),
                                bg: tone.bg,
                                fg: tone.fg,
                                size: 36,
                                radius: 12,
                                iconSize: 17,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  applicationActionLabel(s),
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: context.jb.ink),
                                ),
                              ),
                              if (isCurrent)
                                JBChip(
                                  text: 'Joriy',
                                  bg: context.jb.chipBg,
                                  fg: context.jb.gray,
                                  fontSize: 11,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 9, vertical: 4),
                                )
                              else
                                Icon(Icons.chevron_right_rounded,
                                    color: context.jb.grayLight, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(top: 10),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: context.jb.border,
          borderRadius: BorderRadius.circular(100),
        ),
      );
}
