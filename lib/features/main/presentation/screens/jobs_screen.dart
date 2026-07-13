import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../../../../core/constants/colors.dart';
import '../../data/models/employer_vacancy_model.dart';
import '../../data/models/vacancy_model.dart';
import '../logic/vacancy_bloc.dart';
import '../widgets/job_map_view.dart';
import '../widgets/vacancy_job_card.dart';
import 'create_vacancy_screen.dart';
import 'job_detail_screen.dart';

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
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarContrastEnforced: false,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: LIGHT_GRAY_BG,
        body: Column(
          children: [
            // ── Dark header ──
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(top: topPad + 16, left: 16, right: 16, bottom: 20),
              decoration: const BoxDecoration(
                color: Color(0xFF0F172A),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ishlar',
                    style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: TextField(
                            controller: _searchCtrl,
                            onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
                            style: const TextStyle(fontSize: 14, color: Color(0xFF111827)),
                            decoration: const InputDecoration(
                              hintText: 'Qidirish...',
                              hintStyle: TextStyle(color: GRAY_TEXT, fontSize: 14),
                              prefixIcon: Icon(Icons.search, color: GRAY_TEXT, size: 20),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: PRIMARY_BLUE,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.tune_rounded, color: Colors.white, size: 22),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // ── Results count row ──
            Expanded(
              child: BlocBuilder<VacancyBloc, VacancyState>(
                builder: (context, state) {
                  if (state.vacanciesStatus.isInProgress) {
                    return const Center(child: CircularProgressIndicator(color: PRIMARY_BLUE));
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
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                        child: Row(
                          children: [
                            Text(
                              '${vacancies.length} ta ish topildi',
                              style: const TextStyle(fontSize: 13, color: GRAY_TEXT, fontWeight: FontWeight.w500),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {},
                              child: const Text(
                                'Saralash',
                                style: TextStyle(fontSize: 13, color: PRIMARY_BLUE, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: vacancies.isEmpty
                            ? _EmptyView(message: "Hozircha mos vakansiya yo'q", onRefresh: widget.onRefresh)
                            : RefreshIndicator(
                                color: PRIMARY_BLUE,
                                onRefresh: () async => widget.onRefresh(),
                                child: ListView.separated(
                                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
                                  itemCount: vacancies.length,
                                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                                  itemBuilder: (context, index) => VacancyJobCard(
                                    vacancy: vacancies[index],
                                    onTap: () => _openJob(context, vacancies[index]),
                                  ),
                                ),
                              ),
                      ),
                    ],
                  );

                  return Stack(
                    children: [
                      Positioned.fill(
                        child: _showMap
                            ? JobMapView(
                                vacancies: vacancies,
                                onOpenJob: (v) => _openJob(context, v),
                              )
                            : listContent,
                      ),
                      // Ro'yxat ⇄ Xarita almashtirish tugmasi (screenshotdagidek)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 16,
                        child: Center(
                          child: _MapListToggle(
                            showingMap: _showMap,
                            onTap: () => setState(() => _showMap = !_showMap),
                          ),
                        ),
                      ),
                    ],
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

// ── Employer view ──────────────────────────────────────────────────────────────

class _EmployerJobsView extends StatelessWidget {
  final VoidCallback onRefresh;
  const _EmployerJobsView({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarContrastEnforced: false,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: LIGHT_GRAY_BG,
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
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 12,
                  left: 16,
                  right: 16,
                  bottom: 16,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFF0F172A),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Vakansiyalarim', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text("Kompaniya vakansiyalari", style: TextStyle(color: Colors.white54, fontSize: 13)),
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
                          gradient: const LinearGradient(colors: [PRIMARY_BLUE, SECONDARY_BLUE]),
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
                      return const Center(child: CircularProgressIndicator(color: PRIMARY_BLUE));
                    }
                    if (state.vacanciesStatus == FormzSubmissionStatus.failure && state.employerVacancies.isEmpty) {
                      return _ErrorView(message: state.error?.errorMessage ?? 'Xato', onRetry: onRefresh);
                    }
                    final vacancies = state.employerVacancies;
                    if (vacancies.isEmpty) {
                      return _EmptyView(message: "Hech qanday vakansiya yo'q", onRefresh: onRefresh);
                    }
                    return RefreshIndicator(
                      color: PRIMARY_BLUE,
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
            child: const Text("O'chirish", style: TextStyle(color: Color(0xFFDC2626))),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 3))],
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
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: DARK_NAVY),
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
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: DARK_NAVY),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Kompaniyam',
                      style: TextStyle(fontSize: 13, color: GRAY_TEXT),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (vacancy.isActive ? const Color(0xFF16A34A) : GRAY_TEXT).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  vacancy.isActive ? 'Faol' : 'Nofaol',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: vacancy.isActive ? const Color(0xFF16A34A) : GRAY_TEXT,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // ── Info rows ──
          _InfoRow(icon: Icons.attach_money_outlined, text: vacancy.salaryDisplay),
          if (vacancy.deadline != null) ...[
            const SizedBox(height: 7),
            _InfoRow(icon: Icons.calendar_today_outlined, text: 'Muddat: ${_formatDeadline(vacancy.deadline!)}'),
          ],
          if (timeAgo.isNotEmpty) ...[
            const SizedBox(height: 7),
            _InfoRow(icon: Icons.access_time_outlined, text: timeAgo),
          ],
          if (vacancy.applicationsCount != null && vacancy.applicationsCount! > 0) ...[
            const SizedBox(height: 7),
            _InfoRow(icon: Icons.people_outline, text: '${vacancy.applicationsCount} ta ariza'),
          ],
          if (vacancy.comment != null && vacancy.comment!.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 10),
            Text(
              vacancy.comment!,
              style: const TextStyle(fontSize: 13, color: GRAY_TEXT, height: 1.45),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
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
                      gradient: const LinearGradient(colors: [PRIMARY_BLUE, SECONDARY_BLUE]),
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
              GestureDetector(
                onTap: () => _confirmDelete(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFECACA)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.delete_outline, color: Color(0xFFDC2626), size: 16),
                      SizedBox(width: 6),
                      Text(
                        "O'chirish",
                        style: TextStyle(color: Color(0xFFDC2626), fontSize: 13, fontWeight: FontWeight.w600),
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

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: GRAY_TEXT),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 13, color: GRAY_TEXT, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

// ── Shared helpers ─────────────────────────────────────────────────────────────

/// Ro'yxat va xarita ko'rinishlari orasida almashtiruvchi suzuvchi tugma.
class _MapListToggle extends StatelessWidget {
  final bool showingMap;
  final VoidCallback onTap;
  const _MapListToggle({required this.showingMap, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
      elevation: 6,
      shadowColor: Colors.black.withValues(alpha: 0.25),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(showingMap ? Icons.format_list_bulleted_rounded : Icons.map_outlined, size: 20, color: DARK_NAVY),
              const SizedBox(width: 8),
              Text(
                showingMap ? "Ro'yxat" : 'Xarita',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: DARK_NAVY),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
          const Icon(Icons.work_off_outlined, size: 64, color: GRAY_TEXT),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(fontSize: 15, color: GRAY_TEXT), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          TextButton(onPressed: onRefresh, child: const Text('Yangilash', style: TextStyle(color: PRIMARY_BLUE))),
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
            const Icon(Icons.cloud_off_outlined, size: 64, color: GRAY_TEXT),
            const SizedBox(height: 16),
            Text(message, style: const TextStyle(fontSize: 15, color: GRAY_TEXT), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(backgroundColor: PRIMARY_BLUE, foregroundColor: Colors.white, elevation: 0),
              child: const Text('Qayta urinish'),
            ),
          ],
        ),
      ),
    );
  }
}
