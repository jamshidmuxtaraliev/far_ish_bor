import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../../../../core/theme/jb_ui.dart';
import '../../data/models/employer_vacancy_model.dart';
import '../../data/models/vacancy_model.dart';
import '../logic/vacancy_bloc.dart';
import '../widgets/job_map_view.dart';
import '../widgets/vacancy_job_card.dart';
import 'create_vacancy_screen.dart';
import 'vacancy_applications_screen.dart';
import 'job_detail_screen.dart';
import '../../../../core/theme/jb_palette.dart';

class JobsScreen extends StatefulWidget {
  final bool isEmployer;
  const JobsScreen({super.key, this.isEmployer = false});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    if (widget.isEmployer) {
      context.read<VacancyBloc>().add(LoadEmployerVacanciesEvent());
    } else {
      context.read<VacancyBloc>().add(LoadSeekerVacanciesEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.isEmployer ? _EmployerJobsView(onRefresh: _load) : _SeekerJobsView(onRefresh: _load);
  }
}

// ── Seeker view ────────────────────────────────────────────────────────────────

class _SeekerJobsView extends StatefulWidget {
  final VoidCallback onRefresh;
  const _SeekerJobsView({required this.onRefresh});

  @override
  State<_SeekerJobsView> createState() => _SeekerJobsViewState();
}

class _SeekerJobsViewState extends State<_SeekerJobsView> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  bool _showMap = false;

  void _openJob(BuildContext context, VacancyModel vacancy) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<VacancyBloc>(),
          child: JobDetailScreen(vacancy: vacancy),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.jb.overlay,
      child: Scaffold(
        backgroundColor: context.jb.bg,
        body: Column(
          children: [
            // ── White header ──
            Container(
              width: double.infinity,
              color: context.jb.card,
              padding: EdgeInsets.only(top: topPad + 18, left: 20, right: 20, bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ishlar', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: context.jb.ink)),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 46,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(color: context.jb.chipBg, borderRadius: BorderRadius.circular(14)),
                          child: Row(
                            children: [
                              Icon(Icons.search_rounded, color: context.jb.grayLight, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _searchCtrl,
                                  onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
                                  style: TextStyle(fontSize: 14, color: context.jb.ink),
                                  decoration: InputDecoration(
                                    isCollapsed: true,
                                    hintText: 'Qidirish...',
                                    hintStyle: TextStyle(color: context.jb.grayLight, fontSize: 14),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(color: context.jb.blue, borderRadius: BorderRadius.circular(14)),
                        child: const Icon(Icons.tune_rounded, color: Colors.white, size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  JBSegmented(
                    tabs: const ["Ro'yxat", 'Xarita'],
                    index: _showMap ? 1 : 0,
                    onChanged: (i) => setState(() => _showMap = i == 1),
                  ),
                ],
              ),
            ),
            // ── Results count row ──
            Expanded(
              child: BlocBuilder<VacancyBloc, VacancyState>(
                builder: (context, state) {
                  if (state.vacanciesStatus.isInProgress) {
                    return Center(child: CircularProgressIndicator(color: context.jb.blue));
                  }
                  if (state.vacanciesStatus == FormzSubmissionStatus.failure) {
                    return _ErrorView(message: state.error?.errorMessage ?? 'Xato yuz berdi', onRetry: widget.onRefresh);
                  }
                  final all = state.seekerVacancies;
                  final vacancies = _query.isEmpty
                      ? all
                      : all.where((v) {
                          final name = (v.jobTypeName ?? '').toLowerCase();
                          final company = (v.companyName ?? '').toLowerCase();
                          return name.contains(_query) || company.contains(_query);
                        }).toList();

                  final listContent = Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                        child: Row(
                          children: [
                            Text(
                              '${vacancies.length} ta ish topildi',
                              style: TextStyle(fontSize: 13, color: context.jb.gray),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {},
                              child: Text(
                                'Saralash',
                                style: TextStyle(fontSize: 13, color: context.jb.blue, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: vacancies.isEmpty
                            ? _EmptyView(message: "Hozircha mos vakansiya yo'q", onRefresh: widget.onRefresh)
                            : RefreshIndicator(
                                color: context.jb.blue,
                                onRefresh: () async => widget.onRefresh(),
                                child: ListView.separated(
                                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                                  itemCount: vacancies.length,
                                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                                  itemBuilder: (context, index) => VacancyJobCard(
                                    vacancy: vacancies[index],
                                    onTap: () => _openJob(context, vacancies[index]),
                                  ),
                                ),
                              ),
                      ),
                    ],
                  );

                  return _showMap
                      ? JobMapView(
                          vacancies: vacancies,
                          onOpenJob: (v) => _openJob(context, v),
                        )
                      : listContent;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Employer view ──────────────────────────────────────────────────────────────

class _EmployerJobsView extends StatelessWidget {
  final VoidCallback onRefresh;
  const _EmployerJobsView({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.jb.overlay,
      child: Scaffold(
        backgroundColor: context.jb.bg,
        body: BlocListener<VacancyBloc, VacancyState>(
          listener: (context, state) {
            if (state.manageVacancyStatus == FormzSubmissionStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error?.errorMessage ?? 'Xato'), backgroundColor: Colors.red.shade600),
              );
            }
          },
          child: Column(
            children: [
              Container(
                width: double.infinity,
                color: context.jb.card,
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 18,
                  left: 20,
                  right: 20,
                  bottom: 16,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Vakansiyalarim', style: TextStyle(color: context.jb.ink, fontSize: 22, fontWeight: FontWeight.w800)),
                          SizedBox(height: 4),
                          Text("Kompaniya vakansiyalari", style: TextStyle(color: context.jb.gray, fontSize: 13.5)),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CreateVacancyScreen()),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [context.jb.blue, context.jb.blueLight]),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.add, color: Colors.white, size: 18),
                            SizedBox(width: 4),
                            Text("Qo'shish", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: BlocBuilder<VacancyBloc, VacancyState>(
                  builder: (context, state) {
                    if (state.vacanciesStatus.isInProgress && state.employerVacancies.isEmpty) {
                      return Center(child: CircularProgressIndicator(color: context.jb.blue));
                    }
                    if (state.vacanciesStatus == FormzSubmissionStatus.failure && state.employerVacancies.isEmpty) {
                      return _ErrorView(message: state.error?.errorMessage ?? 'Xato', onRetry: onRefresh);
                    }
                    final vacancies = state.employerVacancies;
                    if (vacancies.isEmpty) {
                      return _EmptyView(message: "Hech qanday vakansiya yo'q", onRefresh: onRefresh);
                    }
                    return RefreshIndicator(
                      color: context.jb.blue,
                      onRefresh: () async => onRefresh(),
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: vacancies.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) => _EmployerVacancyCard(vacancy: vacancies[index]),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// ── Employer vacancy card ─────────────────────────────────────────────────────

class _EmployerVacancyCard extends StatelessWidget {
  final EmployerVacancyModel vacancy;
  const _EmployerVacancyCard({required this.vacancy});

  String _timeAgo(String? iso) {
    if (iso == null) return '';
    try {
      final d = DateTime.parse(iso);
      final diff = DateTime.now().difference(d);
      if (diff.inDays == 0) return 'Bugun';
      if (diff.inDays == 1) return '1 kun oldin';
      return '${diff.inDays} kun oldin';
    } catch (_) {
      return '';
    }
  }

  String _formatDeadline(String iso) {
    try {
      final d = DateTime.parse(iso);
      return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
    } catch (_) {
      return iso;
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("O'chirish"),
        content: const Text("Bu vakansiyani o'chirishni tasdiqlaysizmi?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Bekor")),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<VacancyBloc>().add(DeleteVacancyEvent(vacancy.id));
            },
            child: Text("O'chirish", style: TextStyle(color: context.jb.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = vacancy.jobTypeName ?? 'Kasb #${vacancy.jobTypeId}';
    final initial = title.isNotEmpty ? title[0].toUpperCase() : '?';
    final timeAgo = _timeAgo(vacancy.createdAt);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.jb.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.jb.border),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Logo + title + status ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: context.jb.cardAlt,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: context.jb.ink),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: context.jb.ink),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Kompaniyam',
                      style: TextStyle(fontSize: 13, color: context.jb.gray),
                    ),
                  ],
                ),
              ),
              Builder(
                builder: (context) {
                  // To'xtatilgan vakansiya "Nofaol" emas — alohida holat:
                  // ish beruvchi uni bir bosishda qayta yoqa oladi.
                  final color = vacancy.isPaused
                      ? context.jb.amber
                      : (vacancy.isActive ? context.jb.green : context.jb.gray);
                  final label = vacancy.isPaused
                      ? "To'xtatilgan"
                      : (vacancy.isActive ? 'Faol' : 'Nofaol');
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 14),
          // ── Info chips ──
          Wrap(
            spacing: 14,
            runSpacing: 8,
            children: [
              _InfoRow(icon: Icons.attach_money_outlined, text: vacancy.salaryDisplay),
              if (vacancy.deadline != null)
                _InfoRow(icon: Icons.calendar_today_outlined, text: 'Muddat: ${_formatDeadline(vacancy.deadline!)}'),
              if (timeAgo.isNotEmpty)
                _InfoRow(icon: Icons.access_time_outlined, text: timeAgo),
            ],
          ),
          if (vacancy.comment != null && vacancy.comment!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Divider(height: 1, color: context.jb.cardAlt),
            const SizedBox(height: 10),
            Text(
              vacancy.comment!,
              style: TextStyle(fontSize: 13, color: context.jb.gray, height: 1.45),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 12),
          // ── Otkliklar (arizalar) qatori — bosilganda shu vakansiyaning
          //    otkliklar ekrani ochiladi (§3.2) ──
          _ApplicationsRow(vacancy: vacancy, title: title),
          const SizedBox(height: 14),
          // ── Action buttons ──
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => CreateVacancyScreen(existing: vacancy)),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [context.jb.blue, context.jb.blueLight]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.edit_outlined, color: Colors.white, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Tahrirlash',
                          style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // ── Play / Pause — vaqtincha to'xtatib turish ──
              // O'chirishdan farqi: vakansiya va unga kelgan otkliklar joyida
              // qoladi, faqat sayt/ilovada ko'rinmay turadi. Mavsumiy ish
              // beruvchi har safar qaytadan e'lon yozmasin.
              // Ikonka-tugma (matnsiz): uchta matnli tugma tor ekranda
              // (360dp) qatorga sig'may, "Tahrirlash" ni siqib yuborardi.
              if (vacancy.canTogglePause)
                Tooltip(
                  message: vacancy.isPaused
                      ? 'Vakansiyani qayta yoqish'
                      : "Vakansiyani vaqtincha to'xtatish",
                  child: GestureDetector(
                    onTap: () => context
                        .read<VacancyBloc>()
                        .add(SetVacancyPausedEvent(vacancy.id, !vacancy.isPaused)),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: vacancy.isPaused ? context.jb.greenBg : context.jb.amberBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        vacancy.isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                        color: vacancy.isPaused ? context.jb.green : context.jb.amber,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              if (vacancy.canTogglePause) const SizedBox(width: 10),
              GestureDetector(
                onTap: () => _confirmDelete(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  decoration: BoxDecoration(
                    color: context.jb.redBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.jb.redBg),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, color: context.jb.red, size: 16),
                      SizedBox(width: 6),
                      Text(
                        "O'chirish",
                        style: TextStyle(color: context.jb.red, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Vakansiya kartasidagi otklik (ariza) statistikasi — PROMPT_VAKANSIYA_
/// OTKLIKLARI_MOBILE.md §3.2. `total == 0` bo'lsa kul rang, aks holda ko'k;
/// yangi arizalar qizil nishonda ko'rsatiladi.
class _ApplicationsRow extends StatelessWidget {
  final EmployerVacancyModel vacancy;
  final String title;

  const _ApplicationsRow({required this.vacancy, required this.title});

  @override
  Widget build(BuildContext context) {
    final p = context.jb;
    final stats = vacancy.applications;
    final hasAny = stats.total > 0;
    final accent = hasAny ? p.blue : p.gray;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => VacancyApplicationsScreen(
            vacancyId: vacancy.id,
            vacancyTitle: title,
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: hasAny ? p.blueTint : p.cardAlt,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.people_outline, size: 17, color: accent),
                const SizedBox(width: 8),
                Text(
                  'Otkliklar: ${stats.total}',
                  style: TextStyle(
                      fontSize: 13.5, fontWeight: FontWeight.w700, color: accent),
                ),
                if (stats.newCount > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: p.red,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      '${stats.newCount} yangi',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                Icon(Icons.chevron_right, size: 20, color: p.gray),
              ],
            ),
            if (hasAny &&
                (stats.inProgress > 0 || stats.hired > 0 || stats.closed > 0)) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  if (stats.inProgress > 0)
                    _StatChip(
                        label: 'Jarayonda: ${stats.inProgress}', color: p.blue),
                  if (stats.hired > 0)
                    _StatChip(
                      label: vacancy.anketaCount != null
                          ? 'Ishga olindi: ${stats.hired} / ${vacancy.anketaCount}'
                          : 'Ishga olindi: ${stats.hired}',
                      color: p.green,
                    ),
                  if (stats.closed > 0)
                    _StatChip(label: 'Yopilgan: ${stats.closed}', color: p.gray),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final Color color;
  const _StatChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 11.5, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: context.jb.gray),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(fontSize: 13, color: context.jb.gray, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

// ── Shared helpers ─────────────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  final String message;
  final VoidCallback onRefresh;
  const _EmptyView({required this.message, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.work_off_outlined, size: 64, color: context.jb.gray),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(fontSize: 15, color: context.jb.gray), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          TextButton(onPressed: onRefresh, child: Text('Yangilash', style: TextStyle(color: context.jb.blue))),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_outlined, size: 64, color: context.jb.gray),
            const SizedBox(height: 16),
            Text(message, style: TextStyle(fontSize: 15, color: context.jb.gray), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(backgroundColor: context.jb.blue, foregroundColor: Colors.white, elevation: 0),
              child: const Text('Qayta urinish'),
            ),
          ],
        ),
      ),
    );
  }
}
