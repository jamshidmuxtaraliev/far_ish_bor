import 'package:far_ish_bor/core/utils/utils.dart';
import 'package:far_ish_bor/features/main/presentation/screens/create_vacancy_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../../../../core/constants/colors.dart';
import '../logic/vacancy_bloc.dart';
import '../widgets/vacancy_job_card.dart';
import 'employer_interviews_screen.dart';
import 'my_applications_screen.dart';
import 'seeker_interviews_screen.dart';

class HomeScreen extends StatefulWidget {
  final bool isEmployer;

  const HomeScreen({super.key, this.isEmployer = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    if (!widget.isEmployer) {
      context.read<VacancyBloc>().add(LoadSeekerVacanciesEvent());
    }
  }

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
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 16, left: 20, right: 20, bottom: 24),
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
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'FARISHBOR',
                                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.isEmployer ? 'Eng yaxshi nomzodlarni toping' : 'Orzuingizdagi ishni toping',
                                style: const TextStyle(color: Colors.white60, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        if (widget.isEmployer) ...[
                          _HeaderIconBtn(icon: CupertinoIcons.location, onTap: () {}, bgColor: Colors.black, borderColor: PRIMARY_BLUE),
                          const SizedBox(width: 8),
                          _HeaderIconBtn(icon: Icons.add, onTap: () => startScreen(context, screen: CreateVacancyScreen()), bgColor: PRIMARY_BLUE),
                        ] else ...[
                          _HeaderIconBtn(icon: Icons.notifications_outlined, onTap: () {}),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Row(
                    children: [
                      Expanded(
                        child: _QuickActionCard(
                          icon: widget.isEmployer ? Icons.post_add_outlined : Icons.search,
                          label: widget.isEmployer ? 'Vakansiyalar' : 'Ish qidirish',
                          gradientColors: const [PRIMARY_BLUE, SECONDARY_BLUE],
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QuickActionCard(
                          icon: widget.isEmployer ? Icons.trending_up : Icons.folder_open_outlined,
                          label: widget.isEmployer ? 'Kuzatuv' : 'Arizalarim',
                          gradientColors: const [Color(0xFF1E293B), Color(0xFF334155)],
                          onTap: () => startScreen(context, screen: MyApplicationsScreen()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(child: _StatsCard(icon: Icons.work_outline, label: "Ish o'rinlari", value: '12,450', iconColor: PRIMARY_BLUE)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatsCard(icon: Icons.business_outlined, label: 'Kompaniyalar', value: '3,200', iconColor: const Color(0xFF7C3AED)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _InterviewsCard(
                    onTap: () => startScreen(
                      context,
                      screen: widget.isEmployer
                          ? const EmployerInterviewsScreen()
                          : const SeekerInterviewsScreen(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (!widget.isEmployer) ...[
                    _SectionTitle(title: "Tavsiya etilgan ishlar"),
                    const SizedBox(height: 12),
                    BlocBuilder<VacancyBloc, VacancyState>(
                      buildWhen: (p, c) => p.seekerVacancies != c.seekerVacancies || p.vacanciesStatus != c.vacanciesStatus,
                      builder: (context, state) {
                        if (state.vacanciesStatus.isInProgress) {
                          return const _VacancyLoadingList();
                        }
                        if (state.seekerVacancies.isEmpty) {
                          return const _EmptyVacancies();
                        }
                        return Column(
                          children:
                              state.seekerVacancies
                                  .take(5)
                                  .map((v) => Padding(padding: const EdgeInsets.only(bottom: 12), child: VacancyJobCard(vacancy: v)))
                                  .toList(),
                        );
                      },
                    ),
                  ],
                  const SizedBox(height: 20),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InterviewsCard extends StatelessWidget {
  final VoidCallback onTap;

  const _InterviewsCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: PRIMARY_BLUE.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.event_available_outlined, color: PRIMARY_BLUE, size: 22),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Suhbatlar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: DARK_NAVY)),
                  SizedBox(height: 2),
                  Text('Suhbat belgilangan nomzodlar', style: TextStyle(fontSize: 12, color: GRAY_TEXT)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: GRAY_TEXT),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: DARK_NAVY)),
        const Spacer(),
        GestureDetector(
          onTap: () {},
          child: const Text("Barchasini ko'r", style: TextStyle(fontSize: 13, color: PRIMARY_BLUE, fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }
}

class _HeaderIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? bgColor;
  final Color? borderColor;

  const _HeaderIconBtn({required this.icon, required this.onTap, this.bgColor, this.borderColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: bgColor ?? Colors.white.withValues(alpha: 0.12),
          shape: BoxShape.circle,
          border: borderColor != null ? Border.all(color: borderColor!, width: 1.5) : null,
        ),
        child: Icon(icon, color: borderColor ?? Colors.white, size: 20),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _QuickActionCard({required this.icon, required this.label, required this.gradientColors, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(gradient: LinearGradient(colors: gradientColors), borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const Spacer(),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;

  const _StatsCard({required this.icon, required this.label, required this.value, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: DARK_NAVY)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 12, color: GRAY_TEXT)),
        ],
      ),
    );
  }
}


class _VacancyLoadingList extends StatelessWidget {
  const _VacancyLoadingList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (_) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 140,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE5E7EB))),
          child: const Center(child: CircularProgressIndicator(color: PRIMARY_BLUE, strokeWidth: 2)),
        ),
      ),
    );
  }
}

class _EmptyVacancies extends StatelessWidget {
  const _EmptyVacancies();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE5E7EB))),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(color: LIGHT_GRAY_BG, borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.work_off_outlined, color: GRAY_TEXT, size: 28),
          ),
          const SizedBox(height: 14),
          const Text(
            "Hozircha mos vakansiya topilmadi",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: DARK_NAVY),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          const Text(
            "Anketangizni to'ldirib, ko'proq imkoniyatlarni oching",
            style: TextStyle(fontSize: 13, color: GRAY_TEXT),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
