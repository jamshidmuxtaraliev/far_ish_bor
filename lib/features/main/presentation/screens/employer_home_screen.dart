import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../../../../core/theme/jb_palette.dart';
import '../../../../core/theme/jb_ui.dart';
import '../../../auth/data/models/employer_model.dart';
import '../../../auth/presentation/logic/auth_bloc.dart';
import '../../../billing/data/models/balance_model.dart';
import '../../../billing/presentation/screens/otklik_shop_screen.dart';
import '../../../notifications/presentation/logic/notification_bloc.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';
import '../../data/models/contact_unlock_model.dart';
import '../../data/models/employer_application_model.dart';
import '../../data/models/employer_vacancy_model.dart';
import '../logic/application_status.dart';
import '../logic/interview_bloc.dart';
import '../logic/vacancy_bloc.dart';
import '../widgets/story_ring_row.dart';
import 'applicant_profile_screen.dart';
import 'candidates_screen.dart';
import 'create_vacancy_screen.dart';
import 'edit_employer_screen.dart';
import 'employer_interviews_screen.dart';
import 'unlock_history_screen.dart';
import 'vacancy_applications_screen.dart';

/// Ish beruvchining BOSH SAHIFASI — kompaniya ma'lumotlari + statistika.
///
/// Vakansiyalar ro'yxati bu ekrandan 2-tabga ko'chirildi ([JobsScreen]);
/// bu yerda ish beruvchi ertalab ochganda ko'rishi kerak bo'lgan narsalar:
/// kompaniya holati, TARIF + KALIT kartasi (balans EMAS), otklik varonkasi
/// va so'nggi harakatlar.
///
/// ⚠ Serverda alohida "dashboard" endpointi YO'Q — barcha sonlar mavjud
/// endpointlardan MIJOZ TOMONDA yig'iladi ([_EmployerStats]):
///   • `/mobile/employer/vacancies` → har bir vakansiyaning `applications` bloki
///   • `/mobile/employer/applications` → so'nggi otkliklar ro'yxati
///   • `/mobile/employer/interviews`, `/balance`, `/contact-access`,
///     `/contact-unlock` → suhbat, pul va kontakt sonlari
/// Yangi son kerak bo'lsa avval shu manbalarda bor-yo'qligini tekshiring —
/// qo'shimcha so'rov qo'shishdan oldin.
class EmployerHomeScreen extends StatefulWidget {
  /// Pastki menyu tabini almashtiradi
  /// (0=Asosiy, 1=E'lonlar, 2=Nomzodlar, 3=Xabarlar, 4=Profil).
  final ValueChanged<int>? onSelectTab;

  /// "Nomzodlar" tabini KERAKLI ichki bo'lim bilan ochadi.
  ///
  /// Alohida "Arizalar" tabi bo'lmagani uchun otkliklar shu ekranning
  /// `applications` ichki tabida yashaydi — `onSelectTab(2)` ni to'g'ridan
  /// to'g'ri chaqirsak, foydalanuvchi ilgari "Mos nomzodlar"ga o'tib qo'ygan
  /// bo'lsa banner noto'g'ri ro'yxatga tushirardi.
  final void Function(CandidatesTab tab)? onOpenCandidates;

  const EmployerHomeScreen({
    super.key,
    this.onSelectTab,
    this.onOpenCandidates,
  });

  @override
  State<EmployerHomeScreen> createState() => _EmployerHomeScreenState();
}

class _EmployerHomeScreenState extends State<EmployerHomeScreen> {
  @override
  void initState() {
    super.initState();
    _load(force: false);
  }

  /// [force] = pull-to-refresh. Aks holda allaqachon keshda turgan ro'yxat
  /// qayta so'ralmaydi — boshqa tabdan qaytilganda ekran ortiqcha so'rov
  /// yubormasin. Tablar dangasa quriladi ([MainScreen] ga qarang), shuning
  /// uchun ilova ochilishida faqat shu ekran so'rov yuboradi.
  void _load({required bool force}) {
    final vacancy = context.read<VacancyBloc>();
    final auth = context.read<AuthBloc>();
    final vs = vacancy.state;

    auth.add(GetMeEvent());
    if (force || auth.state.employer == null) auth.add(LoadEmployerEvent());
    if (force || vs.employerVacancies.isEmpty) {
      vacancy.add(LoadEmployerVacanciesEvent());
    }
    if (force || vs.employerApplications.isEmpty) {
      vacancy.add(LoadEmployerApplicationsEvent());
    }
    if (force || vs.contactAccess == null) vacancy.add(LoadContactAccessEvent());
    if (force || vs.unlockHistory.isEmpty) vacancy.add(LoadUnlockHistoryEvent());
    // Story lentasi ish beruvchiga ham ko'rinadi — admin qo'ygan e'lon
    // ikkala rolga ham yetib borishi kerak. `force` bo'lmasa kesh to'sadi.
    vacancy.add(LoadStoriesEvent(force: force));

    final interview = context.read<InterviewBloc>();
    if (force || interview.state.employerInterviews.isEmpty) {
      interview.add(const LoadEmployerInterviewsEvent());
    }

    context.read<NotificationBloc>().add(const LoadUnreadCountEvent());
  }

  /// "Rejalashtirilgan" suhbatlar: yakunlangan (`done`), bekor qilingan
  /// (`cancelled`) va kelmagan (`no_show`) hisobga olinmaydi; vaqti o'tib
  /// ketganlari ham — bugundan oldingi suhbat rejada turmaydi.
  int _upcomingInterviews(InterviewState iv) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return iv.employerInterviews.where((i) {
      if (i.status == 'cancelled' ||
          i.status == 'done' ||
          i.status == 'no_show') {
        return false;
      }
      final at = i.scheduledAt;
      return at == null || !at.isBefore(today);
    }).length;
  }

  void _goTab(int index) => widget.onSelectTab?.call(index);

  /// Otkliklar ro'yxati — "Nomzodlar" tabining `applications` ichki bo'limi.
  void _goApplications() =>
      widget.onOpenCandidates?.call(CandidatesTab.applications);

  /// Mos nomzodlar ro'yxati — ayni tabning `matched` ichki bo'limi.
  void _goCandidates() => widget.onOpenCandidates?.call(CandidatesTab.matched);

  Future<void> _open(Widget screen) {
    return Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => screen));
  }

  /// Pul yoki kontakt bilan bog'liq ekrandan qaytgach sonlar eskirgan
  /// bo'ladi — shuning uchun qaytishda jimgina yangilaymiz.
  Future<void> _openAndRefresh(Widget screen) async {
    await _open(screen);
    if (mounted) _load(force: true);
  }

  /// Pull-to-refresh: so'rovlar ketgach indikator darhol yo'qolib qolmasin.
  Future<void> _refresh() async {
    _load(force: true);
    await Future<void>.delayed(const Duration(milliseconds: 700));
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.jb.overlayOnBrand,
      child: Scaffold(
        backgroundColor: context.jb.bg,
        body: RefreshIndicator(
          color: context.jb.blue,
          onRefresh: _refresh,
          // Uchta manba uchun uchta builder: kompaniya (auth), vakansiya va
          // otkliklar (vacancy), suhbatlar (interview). Har biri o'zi
          // o'zgarganda qayta chiziladi — `context.watch` bilan bloc holati
          // kuzatilmaydi.
          child: BlocBuilder<AuthBloc, AuthState>(
            buildWhen: (p, c) =>
                p.employer != c.employer ||
                p.user != c.user ||
                p.employerStatus != c.employerStatus,
            builder: (context, auth) {
              return BlocBuilder<VacancyBloc, VacancyState>(
                buildWhen: (p, c) =>
                    p.employerVacancies != c.employerVacancies ||
                    p.employerApplications != c.employerApplications ||
                    p.vacanciesStatus != c.vacanciesStatus ||
                    p.employerAppsStatus != c.employerAppsStatus ||
                    p.contactAccess != c.contactAccess ||
                    p.unlockHistory != c.unlockHistory ||
                    p.stories != c.stories ||
                    p.viewedStoryIds != c.viewedStoryIds,
                builder: (context, vs) {
                  return BlocBuilder<InterviewBloc, InterviewState>(
                    buildWhen: (p, c) =>
                        p.employerInterviews != c.employerInterviews,
                    builder: (context, iv) {
                      final stats = _EmployerStats.from(
                        vacancies: vs.employerVacancies,
                        interviews: _upcomingInterviews(iv),
                      );
                      return _content(auth, vs, stats);
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _content(AuthState auth, VacancyState vs, _EmployerStats stats) {
    final employer = auth.employer;
    final loading =
        vs.vacanciesStatus.isInProgress && vs.employerVacancies.isEmpty;

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          // ⚠ Sarlavha va tarif kartasi BITTA sliverda bo'lishi SHART.
          // Viewport sliverlarni teskari tartibda chizadi (birinchi sliver eng
          // USTIDA), shuning uchun alohida sliverda -26px surilgan karta
          // gradient TAGIDA qolib ketardi — karta matni ko'rinmasdi.
          // Bitta Column ichida esa karta sarlavhadan KEYIN chiziladi.
          child: Column(
            children: [
              _Header(
                employer: employer,
                fallbackName: auth.user?.displayName,
                onNotifications: () => _open(const NotificationsScreen()),
                onEdit: () => _openAndRefresh(const EditEmployerScreen()),
              ),
              // Karta gradient ustiga chiqadi (Transform faqat chizishga
              // ta'sir qiladi — joy sarlavhaning `bottom: 46` paddingidan).
              Transform.translate(
                offset: const Offset(0, -26),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _PlanCard(
                    access: vs.contactAccess,
                    unlockedContacts: vs.unlockHistory.length,
                    onBuyKeys: () =>
                        _openAndRefresh(const OtklikShopScreen()),
                    onHistory: () => _open(const UnlockHistoryScreen()),
                  ),
                ),
              ),
            ],
          ),
        ),
        SliverPadding(
          // Karta 26px tepaga surilgani uchun tepadan qo'shimcha joy shart emas.
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              ..._alerts(employer, stats, loading),
              _KpiGrid(
                stats: stats,
                loading: loading,
                onVacancies: () => _goTab(1),
                onApplications: _goApplications,
                onInterviews: () =>
                    _open(const EmployerInterviewsScreen(showBack: true)),
              ),
              const SizedBox(height: 14),
              _FunnelCard(stats: stats, loading: loading, onOpen: _goApplications),
              const SizedBox(height: 14),
              _QuickActions(
                onCreate: () => _openAndRefresh(const CreateVacancyScreen()),
                onCandidates: _goCandidates,
                onInterviews: () =>
                    _open(const EmployerInterviewsScreen(showBack: true)),
                onUnlockHistory: () => _open(const UnlockHistoryScreen()),
              ),
            ]),
          ),
        ),
        // ---- Story lentasi ----
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 12),
            child: StoryRingRow(onSelectTab: widget.onSelectTab),
          ),
        ),
        _recentApplications(vs),
        _vacancyBreakdown(vs),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
            child: _CompanyCard(
              employer: employer,
              onEdit: () => _openAndRefresh(const EditEmployerScreen()),
            ),
          ),
        ),
      ],
    );
  }

  /// Diqqat talab qiladigan holatlar — faqat haqiqatan muammo bo'lsa chiqadi.
  List<Widget> _alerts(
      EmployerModel? employer, _EmployerStats stats, bool loading) {
    final items = <Widget>[];

    if (employer != null) {
      final completeness = _profileCompleteness(employer);
      if (completeness < 1.0) {
        items.add(_ProfileMeter(
          value: completeness,
          onFill: () => _openAndRefresh(const EditEmployerScreen()),
        ));
        items.add(const SizedBox(height: 12));
      }
      if (employer.lifecycleStatus == 'yangi' ||
          employer.lifecycleStatus == 'kutilmoqda') {
        items.add(_AlertBanner(
          icon: Icons.hourglass_bottom_rounded,
          color: context.jb.amber,
          bg: context.jb.amberBg,
          title: 'Kompaniya tekshiruvda',
          message:
              "Operator ma'lumotlarni tasdiqlagach vakansiyalaringiz saytda ko'rinadi",
        ));
        items.add(const SizedBox(height: 12));
      }
    }

    // ⚠ Yuklanayotganda sonlar 0 bo'ladi — "vakansiyangiz yo'q" banneri har
    // ochilganda chaqnab ketmasligi uchun yuklash tugashini kutamiz.
    if (loading) return items;

    if (stats.totalVacancies == 0) {
      items.add(_AlertBanner(
        icon: Icons.post_add_rounded,
        color: context.jb.blue,
        bg: context.jb.blueTint,
        title: "Birinchi vakansiyangizni joylang",
        message: 'Vakansiya joylanganda nomzodlar otklik yubora boshlaydi',
        actionLabel: "Qo'shish",
        onAction: () => _openAndRefresh(const CreateVacancyScreen()),
      ));
      items.add(const SizedBox(height: 12));
    } else if (stats.newApplications > 0) {
      items.add(_AlertBanner(
        icon: Icons.mark_email_unread_outlined,
        color: context.jb.blue,
        bg: context.jb.blueTint,
        title: '${stats.newApplications} ta yangi otklik kutmoqda',
        message: "Ko'rib chiqilmagan nomzodlar sizning javobingizni kutyapti",
        actionLabel: "Ko'rish",
        onAction: _goApplications,
      ));
      items.add(const SizedBox(height: 12));
    }

    return items;
  }

  // ── So'nggi otkliklar ──────────────────────────────────────────────────────

  Widget _recentApplications(VacancyState vs) {
    final items = vs.employerApplications.take(3).toList();
    if (items.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          JBSectionHeader(
            title: "So'nggi otkliklar",
            actionLabel: "Barchasi",
            onAction: _goApplications,
            padding: const EdgeInsets.fromLTRB(16, 22, 16, 8),
          ),
          ...items.map(
            (a) => Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: _ApplicationRow(
                app: a,
                onTap: () => _open(ApplicantProfileScreen(app: a)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Vakansiyalar bo'yicha taqsimot ─────────────────────────────────────────

  Widget _vacancyBreakdown(VacancyState vs) {
    final items = [...vs.employerVacancies]
      ..sort((a, b) => b.applications.total.compareTo(a.applications.total));
    final top = items.take(3).toList();
    if (top.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
    final max = top.first.applications.total;

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          JBSectionHeader(
            title: 'Vakansiyalar bo\'yicha',
            actionLabel: 'Barchasi',
            onAction: () => _goTab(1),
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: JBCard(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
              child: Column(
                children: [
                  for (var i = 0; i < top.length; i++) ...[
                    if (i > 0) Divider(height: 1, color: context.jb.divider),
                    _VacancyStatRow(
                      vacancy: top[i],
                      maxTotal: max,
                      onTap: () => _open(
                        VacancyApplicationsScreen(
                          vacancyId: top[i].id,
                          vacancyTitle: top[i].jobTypeName,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Statistika yig'uvchi
// ═══════════════════════════════════════════════════════════════════════════

/// Bosh sahifadagi barcha sonlar — bitta joyda hisoblanadi.
///
/// Manba: vakansiyalar ro'yxatining `applications` bloki (server `by_status`
/// beradi). Eski backend `by_status` yubormasa qisqa yorliqlardan
/// (`new/in_progress/hired/closed`) yig'iladi — shuning uchun varonka hech
/// qachon bo'sh chiqmaydi.
class _EmployerStats {
  final int totalVacancies;
  final int activeVacancies;
  final int pausedVacancies;
  final int totalApplications;
  final int newApplications;
  final int inProgress;
  final int hired;
  final int closed;
  final int interviews;
  final int neededWorkers;

  /// Varonka bosqichlari — tartib muhim (yuqoridan pastga).
  final Map<String, int> byStatus;

  const _EmployerStats({
    this.totalVacancies = 0,
    this.activeVacancies = 0,
    this.pausedVacancies = 0,
    this.totalApplications = 0,
    this.newApplications = 0,
    this.inProgress = 0,
    this.hired = 0,
    this.closed = 0,
    this.interviews = 0,
    this.neededWorkers = 0,
    this.byStatus = const {},
  });

  factory _EmployerStats.from({
    required List<EmployerVacancyModel> vacancies,
    required int interviews,
  }) {
    var active = 0, paused = 0, total = 0, newCount = 0;
    var inProgress = 0, hired = 0, closed = 0, needed = 0;
    final byStatus = <String, int>{};

    for (final v in vacancies) {
      if (v.isActive) active++;
      if (v.isPaused) paused++;
      needed += v.anketaCount ?? 0;
      final s = v.applications;
      total += s.total;
      newCount += s.newCount;
      inProgress += s.inProgress;
      hired += s.hired;
      closed += s.closed;
      s.byStatus.forEach((k, n) => byStatus[k] = (byStatus[k] ?? 0) + n);
    }

    return _EmployerStats(
      totalVacancies: vacancies.length,
      activeVacancies: active,
      pausedVacancies: paused,
      totalApplications: total,
      newApplications: newCount,
      inProgress: inProgress,
      hired: hired,
      closed: closed,
      interviews: interviews,
      neededWorkers: needed,
      byStatus: byStatus,
    );
  }

  int _sum(List<String> keys) {
    var n = 0;
    for (final k in keys) {
      n += byStatus[k] ?? 0;
    }
    return n;
  }

  /// Varonka — 5 bosqich. `by_status` bo'lmasa qisqa yorliqlarga tushadi.
  List<_FunnelStage> get funnel {
    final hasDetail = byStatus.isNotEmpty;
    return [
      _FunnelStage(
        label: 'Yangi',
        icon: applicationStatusIcon('pending'),
        count: hasDetail ? _sum(['pending']) : newApplications,
        tone: _FunnelTone.wait,
      ),
      _FunnelStage(
        label: "Ko'rib chiqilmoqda",
        icon: applicationStatusIcon('viewed'),
        count: hasDetail ? _sum(['viewed', 'invited']) : inProgress,
        tone: _FunnelTone.progress,
      ),
      _FunnelStage(
        label: 'Suhbatda',
        icon: applicationStatusIcon('scheduled'),
        count: hasDetail
            ? _sum(['scheduled', 'confirmed', 'on_way', 'arrived'])
            : interviews,
        tone: _FunnelTone.interview,
      ),
      _FunnelStage(
        label: 'Ishga olindi',
        icon: applicationStatusIcon('hired'),
        count: hasDetail ? _sum(['accepted', 'probation', 'hired']) : hired,
        tone: _FunnelTone.good,
      ),
      _FunnelStage(
        label: 'Yopilgan',
        icon: applicationStatusIcon('rejected'),
        count: hasDetail ? _sum(['rejected', 'missed']) : closed,
        tone: _FunnelTone.closed,
      ),
    ];
  }

  /// Kerakli xodimning qanchasi yopilgan (0..1). Vakansiyalarda "Soni"
  /// ko'rsatilmagan bo'lsa `null` — o'shanda meter chizilmaydi.
  double? get hiringProgress {
    if (neededWorkers <= 0) return null;
    final v = hired / neededWorkers;
    if (v <= 0) return 0.0;
    return v > 1 ? 1.0 : v;
  }
}

enum _FunnelTone { wait, progress, interview, good, closed }

class _FunnelStage {
  final String label;
  final IconData icon;
  final int count;
  final _FunnelTone tone;

  const _FunnelStage({
    required this.label,
    required this.icon,
    required this.count,
    required this.tone,
  });
}

/// Kompaniya profili to'ldirilgan ulushi (0..1).
double _profileCompleteness(EmployerModel e) {
  final checks = <bool>[
    e.name.trim().isNotEmpty,
    (e.logo ?? '').isNotEmpty,
    (e.phone ?? '').isNotEmpty,
    (e.contactPerson ?? '').isNotEmpty,
    (e.address ?? '').isNotEmpty,
    e.regionId != null,
    (e.tin ?? '').isNotEmpty,
    e.latitude != null && e.longitude != null,
  ];
  final filled = checks.where((c) => c).length;
  return filled / checks.length;
}

/// `GET /mobile/employer/contact-unlock` javobidagi qator chegarasi
/// (`paginateOptional(cap: 300)`), ya'ni ro'yxat uzunligi = aniq son EMAS.
const int _unlockHistoryCap = 300;

/// ISO sana → `12.10.2026`. Noto'g'ri/bo'sh qiymatda `null`.
String? _fmtDate(String? iso) {
  if (iso == null || iso.isEmpty) return null;
  final d = DateTime.tryParse(iso);
  if (d == null) return null;
  final l = d.toLocal();
  return '${l.day.toString().padLeft(2, '0')}.'
      '${l.month.toString().padLeft(2, '0')}.${l.year}';
}

/// 12450 → "12 450". Sonlar uch xonadan ajratiladi (so'm formati bilan bir xil).
String _fmt(int n) {
  final digits = n.abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buf.write(' ');
    buf.write(digits[i]);
  }
  return '${n < 0 ? '-' : ''}$buf';
}

// ═══════════════════════════════════════════════════════════════════════════
// Sarlavha — kompaniya identifikatsiyasi
// ═══════════════════════════════════════════════════════════════════════════

class _Header extends StatelessWidget {
  final EmployerModel? employer;
  final String? fallbackName;
  final VoidCallback onNotifications;
  final VoidCallback onEdit;

  const _Header({
    required this.employer,
    required this.fallbackName,
    required this.onNotifications,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.jb;
    final name = employer?.name.trim().isNotEmpty == true
        ? employer!.name
        : (fallbackName ?? 'Kompaniya');
    final logo = employer?.logoUrl;
    final place = [
      employer?.region?.name,
      employer?.district?.name,
    ].where((e) => (e ?? '').isNotEmpty).join(' · ');

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 14,
        left: 20,
        right: 20,
        // Hamyon kartasi ustiga chiqadi — pastdan qo'shimcha joy.
        bottom: 46,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [p.gradientStart, p.blueLight],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const JBWordmark(height: 22, onDarkBackground: true),
              const Spacer(),
              _BellButton(onTap: onNotifications),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _CompanyAvatar(logoUrl: logo, name: name),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _LifecycleChip(employer: employer),
                        if (place.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              place,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.82),
                                fontSize: 12.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onEdit,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.edit_outlined,
                      color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompanyAvatar extends StatelessWidget {
  final String? logoUrl;
  final String name;

  const _CompanyAvatar({required this.logoUrl, required this.name});

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
        image: logoUrl != null
            ? DecorationImage(image: NetworkImage(logoUrl!), fit: BoxFit.cover)
            : null,
      ),
      alignment: Alignment.center,
      child: logoUrl != null
          ? null
          : Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
    );
  }
}

/// ⚠ "Tasdiqlangan" yorlig'i HAR DOIM emas, faqat `lifecycle_status='faol'`
/// bo'lganda chiqadi — aks holda ilova moderatsiyadan o'tmagan kompaniyaga
/// ham tasdiq bergandek ko'rinadi.
class _LifecycleChip extends StatelessWidget {
  final EmployerModel? employer;
  const _LifecycleChip({required this.employer});

  @override
  Widget build(BuildContext context) {
    final status = employer?.lifecycleStatus;
    final label = employer?.lifecycleLabel ?? 'Yangi';
    final icon = switch (status) {
      'faol' => Icons.verified_rounded,
      'kutilmoqda' => Icons.hourglass_bottom_rounded,
      'rad_etildi' => Icons.cancel_outlined,
      'tugallangan' => Icons.flag_outlined,
      'faol_emas' => Icons.pause_circle_outline,
      _ => Icons.fiber_new_rounded,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _BellButton extends StatelessWidget {
  final VoidCallback onTap;
  const _BellButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationBloc, NotificationState>(
      buildWhen: (p, c) => p.unreadCount != c.unreadCount,
      builder: (context, state) {
        return GestureDetector(
          onTap: onTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.notifications_none_rounded,
                    color: Colors.white, size: 20),
              ),
              if (state.unreadCount > 0)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5, vertical: 2),
                    constraints: const BoxConstraints(minWidth: 18),
                    decoration: BoxDecoration(
                      color: context.jb.red,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      state.unreadCount > 99 ? '99+' : '${state.unreadCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Tarif + kalit kartasi
// ════════════════════════════════════════════════════════════════════════════

/// Bosh sahifadagi asosiy karta.
///
/// ⚠ **BALANS (pul qoldig'i) KO'RSATILMAYDI.** Ish beruvchiga pul emas,
/// KALIT kerak (nomzod kontaktini ochish huquqi) — pul raqami "to'ldirdim,
/// lekin nomzod ochilmadi" chalkashligini keltirib chiqarardi. O'rniga:
/// sotib olingan tarif nomi · muddati · necha kun qolgani · kalit qoldig'i.
/// Manba — `GET /mobile/employer/contact-access` javobidagi `plan` bloki.
class _PlanCard extends StatelessWidget {
  final ContactAccessModel? access;
  final int unlockedContacts;

  /// ⚠ Balansni TO'LDIRISH tugmasi yo'q — tugma kalit paketi/obunasi
  /// ekraniga olib boradi.
  final VoidCallback onBuyKeys;
  final VoidCallback onHistory;

  const _PlanCard({
    required this.access,
    required this.unlockedContacts,
    required this.onBuyKeys,
    required this.onHistory,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.jb;
    final free = access?.freeContacts == true;
    final fee = access?.fee ?? 0;
    final quota = access?.paysFromQuota == true;
    final hasQuota = access?.hasQuotaPlan == true;
    final available = access?.otklikAvailable ?? 0;
    final total = access?.otklikTotal ?? 0;
    final plan = access?.plan ?? const EmployerPlan();

    // ⚠ Ikki muddat ARALASHTIRILMASIN:
    //   `planExpires`  — butun tarif/paket muddati (12 oylik ham bo'ladi);
    //   `quotaExpires` — joriy 30 kunlik KALIT oynasi (qoldiq keyingi oyga
    //                     o'tmaydi, shuning uchun alohida qator bilan aytiladi).
    final planExpires = _fmtDate(plan.expiresAt);
    final quotaExpires = _fmtDate(access?.otklikExpiresAt);
    final daysLeft = plan.daysLeft;

    return JBCard(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      child: Column(
        children: [
          Row(
            children: [
              JBIconTile(
                icon: plan.hasPlan
                    ? Icons.vpn_key_rounded
                    : Icons.vpn_key_outlined,
                bg: plan.hasPlan ? p.greenBg : p.chipBg,
                fg: plan.hasPlan ? p.green : p.gray,
                size: 42,
                iconSize: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(plan.hasPlan ? 'Tarifingiz' : 'Tarif',
                        style: TextStyle(fontSize: 12.5, color: p.gray)),
                    const SizedBox(height: 2),
                    Text(
                      plan.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: plan.hasPlan ? p.ink : p.gray,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              JBPillButton(
                label: plan.hasPlan ? 'Kalit olish' : 'Tanlash',
                leadingIcon: Icons.add_rounded,
                onTap: onBuyKeys,
                vPadding: 10,
                fontSize: 13,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(height: 1, color: p.divider),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: plan.hasPlan && daysLeft != null
                    ? _MiniFact(
                        icon: Icons.event_available_outlined,
                        label: 'Amal qiladi',
                        value: daysLeft > 0 ? '$daysLeft kun' : 'Bugun tugaydi',
                      )
                    : _MiniFact(
                        // Tarifi yo'qqa kalit NARXINI aytamiz — pul qoldig'ini emas.
                        icon: free
                            ? Icons.lock_open_rounded
                            : (quota
                                ? Icons.vpn_key_outlined
                                : Icons.sell_outlined),
                        label: 'Bitta kontakt',
                        // ⚠ Tartib: bepul → kalit kvotasi → narx.
                        value: free
                            ? 'Bepul'
                            : (quota ? '1 kalit' : formatSom(fee)),
                      ),
              ),
              Container(width: 1, height: 30, color: p.divider),
              Expanded(
                child: GestureDetector(
                  onTap: onHistory,
                  behavior: HitTestBehavior.opaque,
                  child: _MiniFact(
                    icon: Icons.how_to_reg_outlined,
                    label: 'Ochilgan kontakt',
                    // ⚠ `/contact-unlock` sahifalangan (cap 300) — undan
                    // katta son "300+" bo'lib ko'rsatiladi, aks holda
                    // hisoblagich jim turib qolgandek tuyuladi.
                    value: unlockedContacts >= _unlockHistoryCap
                        ? '${_fmt(_unlockHistoryCap)}+'
                        : _fmt(unlockedContacts),
                    chevron: true,
                  ),
                ),
              ),
            ],
          ),
          if (hasQuota) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Text(
                  "Kalit qoldig'i",
                  style: TextStyle(fontSize: 12, color: p.gray),
                ),
                const Spacer(),
                Text(
                  '${_fmt(available)} / ${_fmt(total)}',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: p.ink,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 7),
            _MagnitudeBar(
              fraction: total == 0 ? 0.0 : available / total,
              color: available > 0 ? p.blue : p.red,
              track: p.blueTint,
            ),
            if (planExpires != null || quotaExpires != null) ...[
              const SizedBox(height: 6),
              Text(
                '${planExpires ?? quotaExpires} gacha amal qiladi',
                style: TextStyle(fontSize: 11.5, color: p.gray),
              ),
            ],
            // 12 oylik obunada kalit har 30 kunda yangilanadi — shuni aytamiz.
            if (quotaExpires != null &&
                planExpires != null &&
                quotaExpires != planExpires) ...[
              const SizedBox(height: 3),
              Text(
                'Kalitlar $quotaExpires da yangilanadi',
                style: TextStyle(fontSize: 11.5, color: p.gray),
              ),
            ],
          ] else ...[
            // Kalitlar tugaganda hamyon "active" bo'lmay qoladi, ya'ni
            // `total` ham 0 ga tushadi — shuning uchun bu yerda tarif BOR
            // holatini alohida aytamiz, aks holda obunachi "tarif tanlang"
            // degan matnni ko'rib chalkashardi.
            const SizedBox(height: 12),
            Text(
              plan.hasPlan
                  ? (_fmtDate(plan.cycleEndsAt) != null
                      ? 'Kalitlar tugadi — yangi kvota '
                          '${_fmtDate(plan.cycleEndsAt)} da ochiladi.'
                      : 'Kalitlar tugadi — yangi paket oling.')
                  : "Nomzod kontaktini ochish uchun kalit kerak — "
                      'tarif yoki paket tanlang.',
              style: TextStyle(fontSize: 11.5, color: p.gray),
            ),
          ],
        ],
      ),
    );
  }
}

class _MiniFact extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool chevron;

  const _MiniFact({
    required this.icon,
    required this.label,
    required this.value,
    this.chevron = false,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.jb;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          Icon(icon, size: 16, color: p.gray),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11.5, color: p.gray)),
                const SizedBox(height: 1),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: p.ink,
                  ),
                ),
              ],
            ),
          ),
          if (chevron)
            Icon(Icons.chevron_right_rounded, size: 18, color: p.grayLight),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Ogohlantirish banneri + profil to'ldirilgani
// ═══════════════════════════════════════════════════════════════════════════

class _AlertBanner extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bg;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _AlertBanner({
    required this.icon,
    required this.color,
    required this.bg,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.jb;
    return GestureDetector(
      onTap: onAction,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: p.ink,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    message,
                    style: TextStyle(fontSize: 12.5, color: p.gray, height: 1.35),
                  ),
                ],
              ),
            ),
            if (actionLabel != null) ...[
              const SizedBox(width: 8),
              Text(
                actionLabel!,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Meter — to'ldirilgan ulush. Yo'lak fonи bir xil ramkadan ochroq qadam
/// (ko'k ustiga ko'k), shuning uchun holat butun chiziqda o'qiladi.
class _ProfileMeter extends StatelessWidget {
  final double value; // 0..1
  final VoidCallback onFill;

  const _ProfileMeter({required this.value, required this.onFill});

  @override
  Widget build(BuildContext context) {
    final p = context.jb;
    final percent = (value * 100).round();
    // Qanchalik to'liq bo'lsa shuncha xotirjam rang (ogohlantirish → normal).
    final color = percent >= 80 ? p.blue : p.amber;
    final track = percent >= 80 ? p.blueTint : p.amberBg;

    return JBCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      onTap: onFill,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.badge_outlined, size: 18, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Kompaniya profili to'ldirilgani",
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: p.ink,
                  ),
                ),
              ),
              Text(
                '$percent%',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _MagnitudeBar(fraction: value, color: color, track: track, height: 8),
          const SizedBox(height: 8),
          Text(
            "To'liq profil nomzodlarda ishonch uyg'otadi — logotip, manzil va INN qo'shing",
            style: TextStyle(fontSize: 12, color: p.gray, height: 1.35),
          ),
        ],
      ),
    );
  }
}

/// Bitta o'lchov chizig'i: kenglik = miqdor. Nol bo'lmagan qiymat har doim
/// ko'rinsin uchun minimal kenglik beriladi.
class _MagnitudeBar extends StatelessWidget {
  final double fraction;
  final Color color;
  final Color track;
  final double height;

  const _MagnitudeBar({
    required this.fraction,
    required this.color,
    required this.track,
    this.height = 6,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        double f = fraction.isNaN ? 0.0 : fraction;
        if (f < 0) f = 0.0;
        if (f > 1) f = 1.0;
        // Nol bo'lmagan qiymat har doim ko'rinsin — minimal kenglik = balandlik.
        double filled = f <= 0 ? 0.0 : w * f;
        if (filled > 0 && filled < height) filled = height;
        if (filled > w) filled = w;
        return Stack(
          children: [
            Container(
              height: height,
              decoration: BoxDecoration(
                color: track,
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 420),
              curve: Curves.easeOutCubic,
              height: height,
              width: filled,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// KPI kartalari
// ═══════════════════════════════════════════════════════════════════════════

class _KpiGrid extends StatelessWidget {
  final _EmployerStats stats;
  final bool loading;
  final VoidCallback onVacancies;
  final VoidCallback onApplications;
  final VoidCallback onInterviews;

  const _KpiGrid({
    required this.stats,
    required this.loading,
    required this.onVacancies,
    required this.onApplications,
    required this.onInterviews,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.jb;
    if (loading) return const _KpiSkeleton();

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _KpiTile(
                icon: Icons.work_outline_rounded,
                iconBg: p.blueTint,
                iconFg: p.blue,
                value: _fmt(stats.activeVacancies),
                label: 'Faol vakansiya',
                sub: stats.pausedVacancies > 0
                    ? "${stats.pausedVacancies} ta to'xtatilgan"
                    : 'Jami ${stats.totalVacancies} ta',
                onTap: onVacancies,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _KpiTile(
                icon: Icons.mark_email_unread_outlined,
                iconBg: p.amberBg,
                iconFg: p.amber,
                value: _fmt(stats.newApplications),
                label: 'Yangi otklik',
                sub: "Ko'rilmagan arizalar",
                onTap: onApplications,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _KpiTile(
                icon: Icons.event_available_outlined,
                iconBg: p.violetBg,
                iconFg: p.violet,
                value: _fmt(stats.interviews),
                label: 'Suhbat',
                sub: 'Rejalashtirilgan',
                onTap: onInterviews,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _KpiTile(
                icon: Icons.verified_user_outlined,
                iconBg: p.greenBg,
                iconFg: p.green,
                value: _fmt(stats.hired),
                label: 'Ishga olindi',
                sub: stats.neededWorkers > 0
                    ? '${stats.neededWorkers} ta kerak'
                    : 'Jami qabul qilingan',
                onTap: onApplications,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _KpiTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconFg;
  final String value;
  final String label;
  final String? sub;
  final VoidCallback? onTap;

  const _KpiTile({
    required this.icon,
    required this.iconBg,
    required this.iconFg,
    required this.value,
    required this.label,
    this.sub,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.jb;
    return JBCard(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              JBIconTile(
                  icon: icon, bg: iconBg, fg: iconFg, size: 34, iconSize: 16),
              const Spacer(),
              if (onTap != null)
                Icon(Icons.north_east_rounded, size: 14, color: p.grayLight),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: p.ink,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: p.ink,
            ),
          ),
          if (sub != null) ...[
            const SizedBox(height: 2),
            Text(
              sub!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11.5, color: p.gray),
            ),
          ],
        ],
      ),
    );
  }
}

class _KpiSkeleton extends StatelessWidget {
  const _KpiSkeleton();

  @override
  Widget build(BuildContext context) {
    Widget box() => Expanded(
          child: Container(
            height: 118,
            decoration: jbCardDecoration(
              color: context.jb.card,
              border: context.jb.border,
              borderWidth: 1,
            ),
          ),
        );
    return Column(
      children: [
        Row(children: [box(), const SizedBox(width: 12), box()]),
        const SizedBox(height: 12),
        Row(children: [box(), const SizedBox(width: 12), box()]),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Otklik varonkasi
// ═══════════════════════════════════════════════════════════════════════════

class _FunnelCard extends StatelessWidget {
  final _EmployerStats stats;
  final bool loading;
  final VoidCallback onOpen;

  const _FunnelCard({
    required this.stats,
    required this.loading,
    required this.onOpen,
  });

  ({Color color, Color track}) _tone(BuildContext context, _FunnelTone t) {
    final p = context.jb;
    return switch (t) {
      _FunnelTone.wait => (color: p.amber, track: p.amberBg),
      _FunnelTone.progress => (color: p.blue, track: p.blueTint),
      _FunnelTone.interview => (color: p.violet, track: p.violetBg),
      _FunnelTone.good => (color: p.green, track: p.greenBg),
      _FunnelTone.closed => (color: p.grayLight, track: p.chipBg),
    };
  }

  @override
  Widget build(BuildContext context) {
    final p = context.jb;
    if (loading) {
      return Container(
        height: 230,
        decoration: jbCardDecoration(
            color: p.card, border: p.border, borderWidth: 1),
      );
    }

    final stages = stats.funnel;
    final max = stages.fold<int>(0, (m, s) => s.count > m ? s.count : m);
    final empty = stats.totalApplications == 0;

    return JBCard(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Otkliklar varonkasi',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: p.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Barcha vakansiyalar bo\'yicha',
                      style: TextStyle(fontSize: 12, color: p.gray),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onOpen,
                child: Text(
                  'Arizalar',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: p.blue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Bosh raqam — ekrandagi yagona "hero" son.
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _fmt(stats.totalApplications),
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  color: p.ink,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'jami otklik',
                style: TextStyle(fontSize: 13.5, color: p.gray),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (empty)
            const _FunnelEmpty()
          else
            for (var i = 0; i < stages.length; i++) ...[
              if (i > 0) const SizedBox(height: 12),
              Builder(
                builder: (context) {
                  final s = stages[i];
                  final tone = _tone(context, s.tone);
                  return Row(
                    children: [
                      Icon(s.icon, size: 15, color: tone.color),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 108,
                        child: Text(
                          s.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12.5, color: p.gray),
                        ),
                      ),
                      Expanded(
                        child: _MagnitudeBar(
                          fraction: max == 0 ? 0.0 : s.count / max,
                          color: tone.color,
                          track: tone.track,
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 34,
                        child: Text(
                          _fmt(s.count),
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: p.ink,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          if (!empty && stats.hiringProgress != null) ...[
            const SizedBox(height: 16),
            Divider(height: 1, color: p.divider),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.groups_outlined, size: 16, color: p.gray),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Kerakli xodim: ${_fmt(stats.hired)} / ${_fmt(stats.neededWorkers)}',
                    style: TextStyle(fontSize: 12.5, color: p.gray),
                  ),
                ),
                Text(
                  '${((stats.hiringProgress ?? 0) * 100).round()}%',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: p.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _MagnitudeBar(
              fraction: stats.hiringProgress ?? 0.0,
              color: p.green,
              track: p.greenBg,
              height: 8,
            ),
          ],
        ],
      ),
    );
  }
}

class _FunnelEmpty extends StatelessWidget {
  const _FunnelEmpty();

  @override
  Widget build(BuildContext context) {
    final p = context.jb;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
      decoration: BoxDecoration(
        color: p.chipBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 26, color: p.grayLight),
          const SizedBox(height: 8),
          Text(
            'Hozircha otklik yo\'q',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: p.ink,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Vakansiya faol bo\'lsa nomzodlar ariza yubora boshlaydi',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: p.gray, height: 1.35),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Tezkor amallar
// ═══════════════════════════════════════════════════════════════════════════

class _QuickActions extends StatelessWidget {
  final VoidCallback onCreate;
  final VoidCallback onCandidates;
  final VoidCallback onInterviews;
  final VoidCallback onUnlockHistory;

  const _QuickActions({
    required this.onCreate,
    required this.onCandidates,
    required this.onInterviews,
    required this.onUnlockHistory,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.jb;
    // ⚠ Yorliqlar QISQA bo'lsin — to'rt ustun 360dp ekranda ~74dp joy oladi,
    // uzun so'z uch nuqta bilan kesiladi.
    final items = <_QuickAction>[
      _QuickAction(
        icon: Icons.add_circle_outline_rounded,
        bg: p.blueTint,
        fg: p.blue,
        label: 'Vakansiya',
        onTap: onCreate,
      ),
      _QuickAction(
        icon: Icons.people_outline_rounded,
        bg: p.violetBg,
        fg: p.violet,
        label: 'Nomzodlar',
        onTap: onCandidates,
      ),
      _QuickAction(
        icon: Icons.event_note_outlined,
        bg: p.amberBg,
        fg: p.amber,
        label: 'Suhbatlar',
        onTap: onInterviews,
      ),
      _QuickAction(
        icon: Icons.history_rounded,
        bg: p.greenBg,
        fg: p.green,
        label: 'Tarix',
        onTap: onUnlockHistory,
      ),
    ];

    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(child: _QuickActionTile(action: items[i])),
        ],
      ],
    );
  }
}

class _QuickAction {
  final IconData icon;
  final Color bg;
  final Color fg;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.bg,
    required this.fg,
    required this.label,
    required this.onTap,
  });
}

class _QuickActionTile extends StatelessWidget {
  final _QuickAction action;
  const _QuickActionTile({required this.action});

  @override
  Widget build(BuildContext context) {
    final p = context.jb;
    return GestureDetector(
      onTap: action.onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        decoration: jbCardDecoration(radius: 18, color: p.card),
        child: Column(
          children: [
            JBIconTile(
              icon: action.icon,
              bg: action.bg,
              fg: action.fg,
              size: 38,
              iconSize: 18,
            ),
            const SizedBox(height: 8),
            Text(
              action.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: p.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// So'nggi otkliklar qatori
// ═══════════════════════════════════════════════════════════════════════════

class _ApplicationRow extends StatelessWidget {
  final EmployerApplicationModel app;
  final VoidCallback onTap;

  const _ApplicationRow({required this.app, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = context.jb;
    final tone = applicationStatusTone(app.status);
    final name = (app.anketaFullname ?? '').trim();
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return JBCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      radius: 18,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: p.chipBg,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Text(
              initial,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: p.ink,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isEmpty ? 'Nomzod' : name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: p.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  [app.requirementJobTypeName, app.anketaRegion]
                      .where((e) => (e ?? '').isNotEmpty)
                      .join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: p.gray),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: tone.bg,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(applicationStatusIcon(app.status),
                    size: 11, color: tone.color),
                const SizedBox(width: 4),
                Text(
                  app.statusLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: tone.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Vakansiya bo'yicha qator
// ═══════════════════════════════════════════════════════════════════════════

class _VacancyStatRow extends StatelessWidget {
  final EmployerVacancyModel vacancy;
  final int maxTotal;
  final VoidCallback onTap;

  const _VacancyStatRow({
    required this.vacancy,
    required this.maxTotal,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.jb;
    final s = vacancy.applications;
    final title = vacancy.jobTypeName ?? 'Kasb #${vacancy.jobTypeId}';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: p.ink,
                    ),
                  ),
                ),
                if (s.newCount > 0) ...[
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: p.amberBg,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      '${s.newCount} yangi',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: p.amber,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  _fmt(s.total),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: p.ink,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right_rounded, size: 18, color: p.grayLight),
              ],
            ),
            const SizedBox(height: 8),
            _MagnitudeBar(
              fraction: maxTotal == 0 ? 0.0 : s.total / maxTotal,
              color: vacancy.isActive ? p.blue : p.grayLight,
              track: p.chipBg,
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                _TinyFact(
                  label: vacancy.isPaused
                      ? "To'xtatilgan"
                      : (vacancy.isActive ? 'Faol' : 'Nofaol'),
                  color: vacancy.isPaused
                      ? p.amber
                      : (vacancy.isActive ? p.green : p.gray),
                ),
                const SizedBox(width: 12),
                _TinyFact(label: 'Ishga olindi: ${s.hired}', color: p.gray),
                const SizedBox(width: 8),
                // Maosh matni uzun bo'lsa qatorni yormasin (360dp ekran).
                Expanded(
                  child: Text(
                    vacancy.salaryDisplay,
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11.5, color: p.gray),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TinyFact extends StatelessWidget {
  final String label;
  final Color color;
  const _TinyFact({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(label, style: TextStyle(fontSize: 11.5, color: context.jb.gray)),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Kompaniya ma'lumotlari
// ═══════════════════════════════════════════════════════════════════════════

class _CompanyCard extends StatelessWidget {
  final EmployerModel? employer;
  final VoidCallback onEdit;

  const _CompanyCard({required this.employer, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final p = context.jb;
    final e = employer;
    if (e == null) {
      return JBCard(
        padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 18),
        child: Row(
          children: [
            Icon(Icons.business_outlined, color: p.grayLight, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "Kompaniya ma'lumotlari yuklanmoqda…",
                style: TextStyle(fontSize: 13, color: p.gray),
              ),
            ),
          ],
        ),
      );
    }

    final place = [e.region?.name, e.district?.name, e.address]
        .where((x) => (x ?? '').trim().isNotEmpty)
        .join(', ');

    return JBCard(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "Kompaniya ma'lumotlari",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: p.ink,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onEdit,
                child: Text(
                  'Tahrirlash',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: p.blue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _CompanyRow(
            icon: Icons.badge_outlined,
            label: 'Mas\'ul shaxs',
            value: e.contactPerson,
          ),
          _CompanyRow(
            icon: Icons.phone_outlined,
            label: 'Telefon',
            value: [e.phone, e.phone2]
                .where((x) => (x ?? '').isNotEmpty)
                .join(' · '),
          ),
          _CompanyRow(
            icon: Icons.receipt_long_outlined,
            label: 'INN (STIR)',
            value: e.tin,
          ),
          _CompanyRow(
            icon: Icons.place_outlined,
            label: 'Manzil',
            value: place,
          ),
          _CompanyRow(
            icon: Icons.account_tree_outlined,
            label: 'Filiallar',
            value: e.branches.isEmpty ? null : '${e.branches.length} ta manzil',
          ),
          _CompanyRow(
            icon: Icons.map_outlined,
            label: 'Qamrov',
            value: e.isAllRegions
                ? "Barcha viloyatlar"
                : (e.coverageRegions.isEmpty
                    ? null
                    : e.coverageRegions.map((c) => c.displayName).join(', ')),
            last: true,
          ),
        ],
      ),
    );
  }
}

class _CompanyRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final bool last;

  const _CompanyRow({
    required this.icon,
    required this.label,
    required this.value,
    this.last = false,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.jb;
    final filled = (value ?? '').trim().isNotEmpty;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 11),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 17, color: p.grayLight),
              const SizedBox(width: 12),
              SizedBox(
                width: 104,
                child: Text(
                  label,
                  style: TextStyle(fontSize: 12.5, color: p.gray),
                ),
              ),
              Expanded(
                child: Text(
                  filled ? value!.trim() : "Ko'rsatilmagan",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: filled ? FontWeight.w600 : FontWeight.w400,
                    color: filled ? p.ink : p.grayLight,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!last) Divider(height: 1, color: p.divider),
      ],
    );
  }
}
