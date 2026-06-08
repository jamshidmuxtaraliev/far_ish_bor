import 'package:far_ish_bor/core/utils/utils.dart';
import 'package:far_ish_bor/features/main/presentation/screens/create_vacancy_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/constants/colors.dart';
import '../../../main/data/models/vacancy_model.dart';
import '../logic/vacancy_bloc.dart';
import 'my_applications_screen.dart';

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
                decoration: BoxDecoration(
                  gradient:
                      widget.isEmployer
                          ? const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF0D1B2A), Color(0xFF1A2F4A), Color(0xFF1E3A5F)],
                          )
                          : const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                          ),
                  borderRadius: widget.isEmployer ? const BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)) : null,
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
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 3))],
                      ),
                      child: Column(
                        children: [
                          _SearchRow(icon: Iconsax.search_normal, hint: 'Kasb, lavozim yoki kompaniya', hasBottom: true),
                          _SearchRow(icon: Iconsax.location, hint: 'Shahar yoki hudud', hasBottom: false),
                        ],
                      ),
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
                                  .map((v) => Padding(padding: const EdgeInsets.only(bottom: 12), child: _JobCard(vacancy: v)))
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

class _SearchRow extends StatelessWidget {
  final IconData icon;
  final String hint;
  final bool hasBottom;

  const _SearchRow({required this.icon, required this.hint, required this.hasBottom});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: hasBottom ? const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB)))) : null,
      child: Row(
        children: [
          Icon(icon, color: GRAY_TEXT, size: 20),
          const SizedBox(width: 10),
          Text(hint, style: const TextStyle(color: GRAY_TEXT, fontSize: 14)),
        ],
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

class _JobCard extends StatelessWidget {
  final VacancyModel vacancy;

  const _JobCard({required this.vacancy});

  @override
  Widget build(BuildContext context) {
    final match = vacancy.matchPercent;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
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
                      vacancy.jobTypeName ?? 'Kasb ko\'rsatilmagan',
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                    ),
                    const SizedBox(height: 4),
                    Text(vacancy.companyName ?? '', style: const TextStyle(fontSize: 14, color: GRAY_TEXT)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(color: LIGHT_GRAY_BG, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.business_outlined, color: GRAY_TEXT, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (vacancy.companyAddress != null) ...[
                const Icon(Icons.location_on_outlined, size: 15, color: GRAY_TEXT),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(vacancy.companyAddress!, style: const TextStyle(fontSize: 13, color: GRAY_TEXT), overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(width: 14),
              ],
              const Icon(Icons.attach_money, size: 15, color: GRAY_TEXT),
              const SizedBox(width: 2),
              Expanded(child: Text(vacancy.salaryDisplay, style: const TextStyle(fontSize: 13, color: GRAY_TEXT), overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (match > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: match >= 80 ? GREEN_COLOR.withValues(alpha: 0.12) : PRIMARY_BLUE.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome_rounded, size: 12, color: match >= 80 ? GREEN_COLOR : PRIMARY_BLUE),
                      const SizedBox(width: 4),
                      Text(
                        '$match% mos',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: match >= 80 ? GREEN_COLOR : PRIMARY_BLUE),
                      ),
                    ],
                  ),
                ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [PRIMARY_BLUE, SECONDARY_BLUE]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Ariza berish', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ],
          ),
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
