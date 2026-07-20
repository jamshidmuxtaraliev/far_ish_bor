import 'package:jobUp24/core/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/theme/jb_ui.dart';
import '../logic/vacancy_bloc.dart';
import '../widgets/vacancy_job_card.dart';
import 'job_detail_screen.dart';
import 'seeker_interviews_screen.dart';

class HomeScreen extends StatefulWidget {
  final bool isEmployer;

  /// Switches the parent [MainScreen] bottom-nav tab (0=Home,1=Jobs,2=Apps...).
  final ValueChanged<int>? onSelectTab;

  const HomeScreen({super.key, this.isEmployer = false, this.onSelectTab});

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

  void _goTab(int index) => widget.onSelectTab?.call(index);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarContrastEnforced: false,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: JB_BG,
        body: CustomScrollView(
          slivers: [
            // ---- White branded header ----
            SliverToBoxAdapter(
              child: Container(
                width: double.infinity,
                color: Colors.white,
                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 18, left: 20, right: 20, bottom: 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const JBWordmark(height: 26),
                        const Spacer(),
                        JBCircleButton(
                          icon: Icons.notifications_none_rounded,
                          bg: JB_CHIP_BG,
                          fg: JB_INK,
                          size: 40,
                          onTap: () => _goTab(4),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text('Orzuingizdagi ishni toping', style: TextStyle(fontSize: 15, color: JB_GRAY)),
                  ],
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ---- Action grid ----
                  Row(
                    children: [
                      Expanded(
                        child: _ActionCard.gradient(
                          icon: Icons.search_rounded,
                          label: 'Ish qidirish',
                          onTap: () => _goTab(1),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ActionCard.light(
                          icon: Icons.work_outline_rounded,
                          iconBg: JB_INDIGO_TINT,
                          iconFg: JB_BLUE,
                          label: 'Arizalarim',
                          onTap: () => _goTab(2),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // ---- Stats grid ----
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.work_outline_rounded,
                          iconBg: JB_INDIGO_TINT,
                          iconFg: JB_BLUE,
                          value: '12,450',
                          label: "Ish o'rinlari",
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.grid_view_rounded,
                          iconBg: JB_PURPLE_BG,
                          iconFg: JB_PURPLE_FG,
                          value: '3,200',
                          label: 'Kompaniyalar',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // ---- Suhbatlar row ----
                  JBCard(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                    onTap: () => startScreen(context, screen: const SeekerInterviewsScreen()),
                    child: Row(
                      children: [
                        const JBIconTile(icon: Icons.event_available_outlined, size: 40),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Suhbatlar', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: JB_INK)),
                              SizedBox(height: 1),
                              Text('Suhbat belgilangan nomzodlar', style: TextStyle(fontSize: 13, color: JB_GRAY)),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, color: JB_GRAY_LIGHT, size: 22),
                      ],
                    ),
                  ),
                ]),
              ),
            ),

            // ---- Tavsiya etilgan ishlar ----
            SliverToBoxAdapter(
              child: JBSectionHeader(
                title: 'Tavsiya etilgan ishlar',
                actionLabel: "Barchasini ko'r",
                onAction: () => _goTab(1),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              sliver: BlocBuilder<VacancyBloc, VacancyState>(
                buildWhen: (p, c) => p.seekerVacancies != c.seekerVacancies || p.vacanciesStatus != c.vacanciesStatus,
                builder: (context, state) {
                  if (state.vacanciesStatus.isInProgress) {
                    return const SliverToBoxAdapter(child: _VacancyLoadingList());
                  }
                  if (state.seekerVacancies.isEmpty) {
                    return const SliverToBoxAdapter(child: _EmptyVacancies());
                  }
                  final items = state.seekerVacancies.take(5).toList();
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: VacancyJobCard(
                          vacancy: items[i],
                          onTap: () => startScreen(context, screen: JobDetailScreen(vacancy: items[i])),
                        ),
                      ),
                      childCount: items.length,
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

/// Large action tile — either a blue gradient or a white card.
class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isGradient;
  final Color iconBg;
  final Color iconFg;

  const _ActionCard._({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isGradient,
    required this.iconBg,
    required this.iconFg,
  });

  factory _ActionCard.gradient({required IconData icon, required String label, required VoidCallback onTap}) {
    return _ActionCard._(
      icon: icon,
      label: label,
      onTap: onTap,
      isGradient: true,
      iconBg: Colors.white24,
      iconFg: Colors.white,
    );
  }

  factory _ActionCard.light({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color iconBg,
    required Color iconFg,
  }) {
    return _ActionCard._(icon: icon, label: label, onTap: onTap, isGradient: false, iconBg: iconBg, iconFg: iconFg);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: isGradient
            ? BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [JB_GRADIENT_START, JB_BLUE_LIGHT],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: JB_BLUE.withValues(alpha: 0.25), blurRadius: 24, offset: const Offset(0, 10))],
              )
            : jbCardDecoration(border: JB_BORDER, borderWidth: 1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
              alignment: Alignment.center,
              child: Icon(icon, color: iconFg, size: 18),
            ),
            const SizedBox(height: 30),
            Text(
              label,
              style: TextStyle(
                color: isGradient ? Colors.white : JB_INK,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconFg;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.iconBg,
    required this.iconFg,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return JBCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          JBIconTile(icon: icon, bg: iconBg, fg: iconFg, size: 36, iconSize: 17),
          const SizedBox(height: 14),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: JB_INK)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 13, color: JB_GRAY)),
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
          margin: const EdgeInsets.only(bottom: 14),
          height: 150,
          decoration: jbCardDecoration(),
          child: const Center(child: CircularProgressIndicator(color: JB_BLUE, strokeWidth: 2)),
        ),
      ),
    );
  }
}

class _EmptyVacancies extends StatelessWidget {
  const _EmptyVacancies();

  @override
  Widget build(BuildContext context) {
    return JBCard(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(color: JB_CHIP_BG, borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.work_off_outlined, color: JB_GRAY, size: 28),
          ),
          const SizedBox(height: 14),
          const Text(
            'Hozircha mos vakansiya topilmadi',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: JB_INK),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          const Text(
            "Anketangizni to'ldirib, ko'proq imkoniyatlarni oching",
            style: TextStyle(fontSize: 13, color: JB_GRAY),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
