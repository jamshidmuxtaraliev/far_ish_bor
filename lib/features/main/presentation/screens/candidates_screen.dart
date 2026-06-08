import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../../../../core/constants/colors.dart';
import '../../data/models/candidate_model.dart';
import '../logic/vacancy_bloc.dart';

class CandidatesScreen extends StatefulWidget {
  const CandidatesScreen({super.key});

  @override
  State<CandidatesScreen> createState() => _CandidatesScreenState();
}

class _CandidatesScreenState extends State<CandidatesScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<VacancyBloc>().add(LoadCandidatesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: LIGHT_GRAY_BG,
        body: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                left: 20,
                right: 20,
                bottom: 16,
              ),
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
                  const Text('Mos nomzodlar', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('Vakansiyalaringizga mos anketalar', style: TextStyle(color: Colors.white54, fontSize: 13)),
                  const SizedBox(height: 14),
                  Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                    child: TextField(
                      onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                      style: const TextStyle(color: DARK_NAVY, fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'Ism yoki kasb bo\'yicha qidirish...',
                        hintStyle: TextStyle(color: GRAY_TEXT),
                        prefixIcon: Icon(Icons.search, color: GRAY_TEXT, size: 20),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // List
            Expanded(
              child: BlocBuilder<VacancyBloc, VacancyState>(
                builder: (context, state) {
                  if (state.candidatesStatus.isInProgress) {
                    return const Center(child: CircularProgressIndicator(color: PRIMARY_BLUE));
                  }
                  if (state.candidatesStatus == FormzSubmissionStatus.failure) {
                    return _ErrorView(
                      message: state.error?.errorMessage ?? 'Xato yuz berdi',
                      onRetry: () => context.read<VacancyBloc>().add(LoadCandidatesEvent()),
                    );
                  }

                  var candidates = state.candidates;
                  if (_searchQuery.isNotEmpty) {
                    candidates = candidates.where((c) {
                      final name = (c.fullname ?? '').toLowerCase();
                      final job = (c.jobTypeName ?? '').toLowerCase();
                      return name.contains(_searchQuery) || job.contains(_searchQuery);
                    }).toList();
                  }

                  if (candidates.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.people_outline, size: 64, color: GRAY_TEXT),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty ? "Hozircha mos nomzod yo'q" : "Qidiruv natijasi topilmadi",
                            style: const TextStyle(fontSize: 15, color: GRAY_TEXT),
                          ),
                          if (_searchQuery.isEmpty) ...[
                            const SizedBox(height: 8),
                            const Text(
                              '60%+ mos va tasdiqlangan nomzodlar ko\'rinadi',
                              style: TextStyle(fontSize: 12, color: GRAY_TEXT),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: PRIMARY_BLUE,
                    onRefresh: () async => context.read<VacancyBloc>().add(LoadCandidatesEvent()),
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            '${candidates.length} ta nomzod topildi',
                            style: const TextStyle(fontSize: 13, color: GRAY_TEXT),
                          ),
                        ),
                        ...candidates.map((c) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _CandidateCard(candidate: c),
                        )),
                      ],
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

class _CandidateCard extends StatelessWidget {
  final CandidateModel candidate;
  const _CandidateCard({required this.candidate});

  void _showProfile(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _CandidateProfileSheet(candidate: candidate),
    );
  }

  Color get _matchColor {
    final p = candidate.matchPercent;
    if (p >= 80) return const Color(0xFF16A34A);
    if (p >= 60) return PRIMARY_BLUE;
    return const Color(0xFFF97316);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [PRIMARY_BLUE.withValues(alpha: 0.8), SECONDARY_BLUE],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(candidate.initials, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            candidate.fullname ?? 'Ism noma\'lum',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: DARK_NAVY),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _matchColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${candidate.matchPercent}%',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _matchColor),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      candidate.jobTypeName ?? 'Kasb #${candidate.jobTypeId}',
                      style: const TextStyle(fontSize: 13, color: GRAY_TEXT),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Info row
          Row(
            children: [
              if (candidate.experienceYear != null) ...[
                const Icon(Icons.work_outline, size: 13, color: GRAY_TEXT),
                const SizedBox(width: 4),
                Text('${candidate.experienceYear} yil tajriba', style: const TextStyle(fontSize: 12, color: GRAY_TEXT)),
                const SizedBox(width: 12),
              ],
              if (candidate.salaryDisplay.isNotEmpty) ...[
                const Icon(Icons.attach_money, size: 13, color: GRAY_TEXT),
                const SizedBox(width: 2),
                Text(candidate.salaryDisplay, style: const TextStyle(fontSize: 12, color: GRAY_TEXT)),
              ],
            ],
          ),
          if (candidate.languages.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.language_outlined, size: 13, color: GRAY_TEXT),
                const SizedBox(width: 4),
                Text(candidate.languages.join(', ').toUpperCase(), style: const TextStyle(fontSize: 12, color: GRAY_TEXT)),
              ],
            ),
          ],
          const SizedBox(height: 12),
          // Buttons
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 38,
                  child: ElevatedButton(
                    onPressed: () => _showProfile(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PRIMARY_BLUE,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text("Profilni ko'rish", style: TextStyle(fontSize: 13)),
                  ),
                ),
              ),
              if (candidate.phone != null) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 38,
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.phone_outlined, size: 14),
                      label: const Text('Aloqa', style: TextStyle(fontSize: 13)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: DARK_NAVY,
                        side: const BorderSide(color: Color(0xFFD1D5DB)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ── Candidate profile bottom sheet ─────────────────────────────────────────────

class _CandidateProfileSheet extends StatelessWidget {
  final CandidateModel candidate;
  const _CandidateProfileSheet({required this.candidate});

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ListView(
          controller: scrollCtrl,
          padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPad + 20),
          children: [
            Center(
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFD1D5DB), borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 20),
            // Avatar + name
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [PRIMARY_BLUE.withValues(alpha: 0.8), SECONDARY_BLUE]),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(candidate.initials, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    candidate.fullname ?? "Ism ko'rsatilmagan",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: DARK_NAVY),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    candidate.jobTypeName ?? 'Kasb #${candidate.jobTypeId}',
                    style: const TextStyle(fontSize: 14, color: GRAY_TEXT),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16A34A).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Moslik: ${candidate.matchPercent}%',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF16A34A)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            _ProfileRow(icon: Icons.work_outline, label: 'Tajriba', value: candidate.experienceYear != null ? '${candidate.experienceYear} yil' : "Ko'rsatilmagan"),
            if (candidate.salaryDisplay.isNotEmpty)
              _ProfileRow(icon: Icons.attach_money, label: 'Kutilayotgan maosh', value: candidate.salaryDisplay),
            if (candidate.workStatus != null)
              _ProfileRow(icon: Icons.circle, label: 'Holati', value: candidate.workStatus!),
            if (candidate.workSchedule != null)
              _ProfileRow(icon: Icons.schedule_outlined, label: 'Ish grafigi', value: candidate.workSchedule!),
            if (candidate.languages.isNotEmpty)
              _ProfileRow(icon: Icons.language_outlined, label: 'Tillar', value: candidate.languages.join(', ').toUpperCase()),
            if (candidate.phone != null)
              _ProfileRow(icon: Icons.phone_outlined, label: 'Telefon', value: candidate.phone!),
          ],
        ),
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _ProfileRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: PRIMARY_BLUE),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: GRAY_TEXT)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 14, color: DARK_NAVY, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
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
