import 'package:jobUp24/core/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../../../../core/theme/jb_ui.dart';
import '../../../auth/presentation/logic/auth_bloc.dart';
import '../logic/vacancy_bloc.dart';
import '../widgets/ad_banner_slider.dart';
import '../widgets/story_ring_row.dart';
import '../widgets/vacancy_job_card.dart';
import 'job_detail_screen.dart';
import 'seeker_interviews_screen.dart';
import '../../../../core/theme/jb_palette.dart';

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
    if (!widget.isEmployer) _load(force: false);
  }

  /// [force] = pull-to-refresh. Aks holda keshdagi ro'yxatlar qayta
  /// so'ralmaydi (boshqa tabdan qaytilganda ortiqcha so'rov ketmasin).
  ///
  /// ⚠ Story va reklamani `force` bilan so'rash SHART: admin panelda
  /// qo'shilgan yangi story aks holda ilova qayta ochilmaguncha chiqmaydi.
  void _load({required bool force}) {
    final vacancy = context.read<VacancyBloc>();
    vacancy.add(LoadSeekerVacanciesEvent());
    vacancy.add(LoadStoriesEvent(force: force));
    vacancy.add(LoadPublicAdsEvent(force: force));
    // Bosh ekrandagi ikkita raqam — `GET /stats/public` dan (ilgari kodda
    // qotirilgan "12,450" va "3,200" turardi).
    context.read<AuthBloc>().add(LoadPublicStatsEvent(force: force));
  }

  /// Pull-to-refresh: so'rovlar ketgach indikator darhol yo'qolib qolmasin.
  Future<void> _refresh() async {
    _load(force: true);
    await Future<void>.delayed(const Duration(milliseconds: 700));
  }

  void _goTab(int index) => widget.onSelectTab?.call(index);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.jb.overlay,
      child: Scaffold(
        backgroundColor: context.jb.bg,
        body: RefreshIndicator(
          color: context.jb.blue,
          onRefresh: _refresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
            // ---- White branded header ----
            SliverToBoxAdapter(
              child: Container(
                width: double.infinity,
                color: context.jb.card,
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
                          bg: context.jb.chipBg,
                          fg: context.jb.ink,
                          size: 40,
                          onTap: () => _goTab(4),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text('Orzuingizdagi ishni toping', style: TextStyle(fontSize: 15, color: context.jb.gray)),
                  ],
                ),
              ),
            ),

            // ---- Story lentasi ----
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 14),
                child: StoryRingRow(onSelectTab: widget.onSelectTab),
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
                          iconBg: context.jb.blueTint,
                          iconFg: context.jb.blue,
                          label: 'Arizalarim',
                          onTap: () => _goTab(2),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // ---- Stats grid (jonli — /stats/public) ----
                  BlocBuilder<AuthBloc, AuthState>(
                    buildWhen: (a, b) => a.publicStats != b.publicStats,
                    builder: (context, authState) {
                      final stats = authState.publicStats;
                      return Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              icon: Icons.work_outline_rounded,
                              iconBg: context.jb.blueTint,
                              iconFg: context.jb.blue,
                              value: _statValue(stats?.vacancies),
                              label: "Ish o'rinlari",
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.grid_view_rounded,
                              iconBg: context.jb.violetBg,
                              iconFg: context.jb.violet,
                              value: _statValue(stats?.employers),
                              label: 'Kompaniyalar',
                            ),
                          ),
                        ],
                      );
                    },
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Suhbatlar', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: context.jb.ink)),
                              SizedBox(height: 1),
                              Text('Suhbat belgilangan nomzodlar', style: TextStyle(fontSize: 13, color: context.jb.gray)),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded, color: context.jb.grayLight, size: 22),
                      ],
                    ),
                  ),
                ]),
              ),
            ),

            // ---- Reklama lentasi ----
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: AdBannerSlider(onSelectTab: widget.onSelectTab),
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
      ),
    );
  }
}

/// Statistika hali kelmagan bo'lsa "—" ko'rsatiladi. ⚠ Bu yerga taxminiy
/// raqam YOZILMAYDI: raqam faqat `GET /stats/public` dan keladi.
String _statValue(int? n) {
  if (n == null) return '—';
  final s = n.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
    buf.write(s[i]);
  }
  return buf.toString();
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
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [context.jb.gradientStart, context.jb.blueLight],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: context.jb.blue.withValues(alpha: 0.25), blurRadius: 24, offset: const Offset(0, 10))],
              )
            : jbCardDecoration(border: context.jb.border, borderWidth: 1),
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
                color: isGradient ? Colors.white : context.jb.ink,
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
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: context.jb.ink)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 13, color: context.jb.gray)),
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
          child: Center(child: CircularProgressIndicator(color: context.jb.blue, strokeWidth: 2)),
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
            decoration: BoxDecoration(color: context.jb.chipBg, borderRadius: BorderRadius.circular(16)),
            child: Icon(Icons.work_off_outlined, color: context.jb.gray, size: 28),
          ),
          const SizedBox(height: 14),
          Text(
            'Hozircha mos vakansiya topilmadi',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: context.jb.ink),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            "Anketangizni to'ldirib, ko'proq imkoniyatlarni oching",
            style: TextStyle(fontSize: 13, color: context.jb.gray),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
