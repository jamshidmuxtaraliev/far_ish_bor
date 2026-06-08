import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../../../../core/constants/colors.dart';
import '../../data/models/employer_vacancy_model.dart';
import '../../data/models/vacancy_model.dart';
import '../logic/vacancy_bloc.dart';
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

class _SeekerJobsView extends StatelessWidget {
  final VoidCallback onRefresh;
  const _SeekerJobsView({required this.onRefresh});

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
        body: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 12,
                left: 16,
                right: 16,
                bottom: 16,
              ),
              color: const Color(0xFF0F172A),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mos vakansiyalar', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('Sizga mos ishlar', style: TextStyle(color: Colors.white54, fontSize: 13)),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<VacancyBloc, VacancyState>(
                builder: (context, state) {
                  if (state.vacanciesStatus.isInProgress) {
                    return const Center(child: CircularProgressIndicator(color: PRIMARY_BLUE));
                  }
                  if (state.vacanciesStatus == FormzSubmissionStatus.failure) {
                    return _ErrorView(message: state.error?.errorMessage ?? 'Xato yuz berdi', onRetry: onRefresh);
                  }
                  final vacancies = state.seekerVacancies;
                  if (vacancies.isEmpty) {
                    return _EmptyView(message: "Hozircha mos vakansiya yo'q", onRefresh: onRefresh);
                  }
                  return RefreshIndicator(
                    color: PRIMARY_BLUE,
                    onRefresh: () async => onRefresh(),
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: vacancies.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) => _SeekerVacancyCard(vacancy: vacancies[index]),
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
                color: const Color(0xFF0F172A),
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

// ── Seeker vacancy card ────────────────────────────────────────────────────────

class _SeekerVacancyCard extends StatelessWidget {
  final VacancyModel vacancy;
  const _SeekerVacancyCard({required this.vacancy});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => BlocProvider.value(
          value: context.read<VacancyBloc>(),
          child: JobDetailScreen(vacancy: vacancy),
        )),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(color: LIGHT_GRAY_BG, borderRadius: BorderRadius.circular(12)),
                  child: Center(
                    child: Text(
                      (vacancy.companyName?.isNotEmpty == true) ? vacancy.companyName![0].toUpperCase() : '?',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: DARK_NAVY),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vacancy.jobTypeName ?? 'Kasb #${vacancy.jobTypeId}',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: DARK_NAVY),
                      ),
                      const SizedBox(height: 2),
                      Text(vacancy.companyName ?? 'Kompaniya', style: const TextStyle(fontSize: 13, color: GRAY_TEXT)),
                    ],
                  ),
                ),
                if (vacancy.matchScore != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _matchColor(vacancy.matchPercent).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${vacancy.matchPercent}%',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _matchColor(vacancy.matchPercent)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.attach_money, size: 14, color: GRAY_TEXT),
                const SizedBox(width: 4),
                Text(vacancy.salaryDisplay, style: const TextStyle(fontSize: 13, color: GRAY_TEXT, fontWeight: FontWeight.w500)),
                if (vacancy.minAge != null || vacancy.maxAge != null) ...[
                  const SizedBox(width: 16),
                  const Icon(Icons.person_outline, size: 14, color: GRAY_TEXT),
                  const SizedBox(width: 4),
                  Text(
                    '${vacancy.minAge ?? "?"}–${vacancy.maxAge ?? "?"} yosh',
                    style: const TextStyle(fontSize: 13, color: GRAY_TEXT),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _matchColor(int percent) {
    if (percent >= 80) return const Color(0xFF16A34A);
    if (percent >= 60) return PRIMARY_BLUE;
    return const Color(0xFFF97316);
  }
}

// ── Employer vacancy card ─────────────────────────────────────────────────────

class _EmployerVacancyCard extends StatelessWidget {
  final EmployerVacancyModel vacancy;
  const _EmployerVacancyCard({required this.vacancy});

  String _formatDate(String iso) {
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
        title: const Text("O'chirish"),
        content: const Text("Bu vakansiyani o'chirishni tasdiqlaysizmi?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Bekor")),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<VacancyBloc>().add(DeleteVacancyEvent(vacancy.id));
            },
            child: const Text("O'chirish", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showEditScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CreateVacancyScreen(existing: vacancy)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  vacancy.jobTypeName ?? 'Kasb #${vacancy.jobTypeId}',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: DARK_NAVY),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (vacancy.isActive ? const Color(0xFF16A34A) : GRAY_TEXT).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
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
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.attach_money, size: 14, color: GRAY_TEXT),
              const SizedBox(width: 4),
              Text(vacancy.salaryDisplay, style: const TextStyle(fontSize: 13, color: GRAY_TEXT)),
              if (vacancy.anketaCount != null) ...[
                const SizedBox(width: 16),
                const Icon(Icons.people_outline, size: 14, color: GRAY_TEXT),
                const SizedBox(width: 4),
                Text('${vacancy.anketaCount} ta xodim', style: const TextStyle(fontSize: 13, color: GRAY_TEXT)),
              ],
            ],
          ),
          if (vacancy.deadline != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 14, color: GRAY_TEXT),
                const SizedBox(width: 4),
                Text(
                  'Muddat: ${_formatDate(vacancy.deadline!)}',
                  style: const TextStyle(fontSize: 13, color: GRAY_TEXT),
                ),
              ],
            ),
          ],
          if (vacancy.comment != null && vacancy.comment!.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Divider(height: 1, color: Color(0xFFF3F4F6)),
            const SizedBox(height: 8),
            Text(
              vacancy.comment!,
              style: const TextStyle(fontSize: 13, color: GRAY_TEXT, height: 1.4),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _ActionBtn(icon: Icons.edit_outlined, label: 'Tahrirlash', color: PRIMARY_BLUE, onTap: () => _showEditScreen(context)),
              const SizedBox(width: 8),
              _ActionBtn(icon: Icons.delete_outline, label: "O'chirish", color: Colors.red, onTap: () => _confirmDelete(context)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
        child: Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
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
