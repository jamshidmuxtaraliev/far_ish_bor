import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../../../../core/constants/colors.dart';
import '../../data/models/employer_vacancy_model.dart';
import '../logic/vacancy_bloc.dart';
import '../widgets/candidate_card.dart';
import '../widgets/state_views.dart';
import 'edit_employer_screen.dart';

/// EKRAN 2 — Vakansiya ichi: operator tavsiyalari + mos nomzodlar (scored).
class VacancyCandidatesScreen extends StatefulWidget {
  final EmployerVacancyModel vacancy;
  const VacancyCandidatesScreen({super.key, required this.vacancy});

  @override
  State<VacancyCandidatesScreen> createState() =>
      _VacancyCandidatesScreenState();
}

class _VacancyCandidatesScreenState extends State<VacancyCandidatesScreen> {
  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() => context
      .read<VacancyBloc>()
      .add(LoadVacancyCandidatesEvent(widget.vacancy.id));

  @override
  Widget build(BuildContext context) {
    return CandidateUnlockListener(
      child: Scaffold(
        backgroundColor: LIGHT_GRAY_BG,
        appBar: AppBar(
          backgroundColor: const Color(0xFF0F172A),
          foregroundColor: Colors.white,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          title: Text(widget.vacancy.jobTypeName ?? 'Vakansiya',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        ),
        body: BlocBuilder<VacancyBloc, VacancyState>(
          buildWhen: (p, c) =>
              p.vacancyCandidatesStatus != c.vacancyCandidatesStatus ||
              p.vacancyCandidates != c.vacancyCandidates ||
              p.unlockedAnketaIds != c.unlockedAnketaIds ||
              p.unlockedPhones != c.unlockedPhones,
          builder: (context, state) {
            final data = state.vacancyCandidates;
            final isThisVacancy = data?.vacancy.id == widget.vacancy.id;

            if (state.vacancyCandidatesStatus.isInProgress &&
                (data == null || !isThisVacancy)) {
              return const Center(
                  child: CircularProgressIndicator(color: PRIMARY_BLUE));
            }
            if (state.vacancyCandidatesStatus == FormzSubmissionStatus.failure &&
                (data == null || !isThisVacancy)) {
              return ErrorView(
                message: state.error?.errorMessage ?? 'Xato yuz berdi',
                onRetry: _load,
              );
            }
            if (data == null || !isThisVacancy) {
              return const SizedBox.shrink();
            }

            final recommended = data.recommended;
            final mos = data.mos;

            return RefreshIndicator(
              color: PRIMARY_BLUE,
              onRefresh: () async => _load(),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  _VacancyHeader(vacancy: data.vacancy),
                  const SizedBox(height: 16),
                  if (recommended.isEmpty && mos.isEmpty)
                    _emptyState(context)
                  else ...[
                    if (recommended.isNotEmpty) ...[
                      _SectionTitle(
                          'Operator tavsiyasi', recommended.length, GREEN_COLOR),
                      const SizedBox(height: 10),
                      ...recommended.map((c) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: CandidateCard(
                              candidate: c,
                              isRecommended: true,
                              vacancyId: widget.vacancy.id,
                            ),
                          )),
                      const SizedBox(height: 8),
                    ],
                    if (mos.isNotEmpty) ...[
                      _SectionTitle('Mos nomzodlar', mos.length, PRIMARY_BLUE),
                      const SizedBox(height: 10),
                      ...mos.map((c) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: CandidateCard(
                              candidate: c,
                              vacancyId: widget.vacancy.id,
                            ),
                          )),
                    ],
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return EmptyView(
      icon: Icons.person_search_outlined,
      message: 'Bu vakansiyaga hozircha mos nomzod topilmadi',
      subtitle: 'Qamrov hududlari yoki yosh oralig\'ini kengaytiring',
      action: OutlinedButton.icon(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EditEmployerScreen()),
        ),
        icon: const Icon(Icons.tune, size: 18),
        style: OutlinedButton.styleFrom(
          foregroundColor: PRIMARY_BLUE,
          side: BorderSide(color: PRIMARY_BLUE.withValues(alpha: 0.5)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        label: const Text('Qamrovni sozlash'),
      ),
    );
  }
}

class _VacancyHeader extends StatelessWidget {
  final EmployerVacancyModel vacancy;
  const _VacancyHeader({required this.vacancy});

  String get _ageRange {
    final lo = vacancy.minAge;
    final hi = vacancy.maxAge;
    if (lo == null && hi == null) return '';
    if (lo != null && hi != null) return '$lo–$hi yosh';
    if (lo != null) return '$lo+ yosh';
    return 'gacha $hi yosh';
  }

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[
      _meta(Icons.people_outline, '${vacancy.anketaCount ?? 0} ta o\'rin'),
      _meta(Icons.attach_money, vacancy.salaryDisplay),
      if (_ageRange.isNotEmpty) _meta(Icons.cake_outlined, _ageRange),
      if (vacancy.deadline != null)
        _meta(Icons.event_outlined, vacancy.deadline!),
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(vacancy.jobTypeName ?? 'Vakansiya',
              style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: DARK_NAVY)),
          const SizedBox(height: 10),
          Wrap(spacing: 14, runSpacing: 6, children: chips),
        ],
      ),
    );
  }

  Widget _meta(IconData icon, String label) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: GRAY_TEXT),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 13, color: GRAY_TEXT)),
        ],
      );
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  const _SectionTitle(this.title, this.count, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold, color: DARK_NAVY)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text('$count',
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.bold, color: color)),
        ),
      ],
    );
  }
}
