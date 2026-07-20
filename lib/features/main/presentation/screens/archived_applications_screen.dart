import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/colors.dart';
import '../../data/models/employer_application_model.dart';
import '../logic/vacancy_bloc.dart';
import 'applicant_profile_screen.dart';
import 'candidates_screen.dart' show kArchivedAppStatuses;

/// Arxiv — jarayoni yopilgan arizalar (ishga kirdi / rad etildi / kelmadi).
/// "Nomzodlar" oynasidagi "Arxiv" tugmasidan ochiladi. Ma'lumot
/// [VacancyBloc.employerApplications] dan filtrlanadi (qo'shimcha so'rovsiz).
class ArchivedApplicationsScreen extends StatelessWidget {
  const ArchivedApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LIGHT_GRAY_BG,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        foregroundColor: DARK_NAVY,
        title: const Text('Arxiv',
            style: TextStyle(
                color: DARK_NAVY, fontSize: 18, fontWeight: FontWeight.bold)),
        shape: const Border(bottom: BorderSide(color: CARD_BORDER)),
      ),
      body: BlocBuilder<VacancyBloc, VacancyState>(
        buildWhen: (p, c) =>
            p.employerApplications != c.employerApplications ||
            p.employerAppsStatus != c.employerAppsStatus,
        builder: (context, state) {
          final archived = state.employerApplications
              .where((a) => kArchivedAppStatuses.contains(a.status))
              .toList();

          if (archived.isEmpty) {
            return const _EmptyArchive();
          }

          return RefreshIndicator(
            color: PRIMARY_BLUE,
            onRefresh: () async =>
                context.read<VacancyBloc>().add(LoadEmployerApplicationsEvent()),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: archived.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (ctx, i) => _ArchiveCard(
                app: archived[i],
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => ApplicantProfileScreen(app: archived[i])),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EmptyArchive extends StatelessWidget {
  const _EmptyArchive();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.inventory_2_outlined,
                color: GRAY_TEXT, size: 34),
          ),
          const SizedBox(height: 16),
          const Text('Arxiv bo\'sh',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: DARK_NAVY)),
          const SizedBox(height: 6),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Jarayoni yakunlangan arizalar (ishga kirdi, rad etildi, kelmadi) shu yerda ko\'rinadi',
              style: TextStyle(fontSize: 13, color: GRAY_TEXT),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _ArchiveCard extends StatelessWidget {
  final EmployerApplicationModel app;
  final VoidCallback onTap;

  const _ArchiveCard({required this.app, required this.onTap});

  ({Color color, Color bg}) get _statusTone => switch (app.status) {
        'hired' => (color: const Color(0xFF15803D), bg: GREEN_COLOR.withValues(alpha: 0.12)),
        'rejected' => (color: RED_COLOR, bg: RED_COLOR.withValues(alpha: 0.1)),
        'missed' => (color: AMBER_COLOR, bg: AMBER_COLOR.withValues(alpha: 0.14)),
        _ => (color: GRAY_TEXT, bg: LIGHT_GRAY_BG),
      };

  @override
  Widget build(BuildContext context) {
    final tone = _statusTone;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: CARD_BORDER),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFD1D5DB), Color(0xFF9CA3AF)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _initials(app.anketaFullname),
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app.anketaFullname ?? 'Nomzod',
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: DARK_NAVY),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      app.anketaJobType ??
                          app.requirementJobTypeName ??
                          'Kasb',
                      style: const TextStyle(fontSize: 13, color: GRAY_TEXT),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: tone.bg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        app.statusLabel,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: tone.color),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: GRAY_TEXT),
            ],
          ),
        ),
      ),
    );
  }

  static String _initials(String? name) {
    final n = (name ?? '').trim();
    if (n.isEmpty) return '?';
    final parts = n.split(RegExp(r'\s+'));
    if (parts.length >= 2 && parts[1].isNotEmpty) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return n[0].toUpperCase();
  }
}
