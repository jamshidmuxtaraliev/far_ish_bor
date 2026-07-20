import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/theme/jb_ui.dart';
import '../../data/models/vacancy_model.dart';
import '../logic/vacancy_bloc.dart';
import 'job_detail_screen.dart';

/// Seeker-facing company ("Korxona") profile, opened from a job's company header.
/// Company details come from the source [vacancy]; the vacancy list is derived
/// from the already-loaded seeker vacancies that share the same company.
class CompanyProfileScreen extends StatefulWidget {
  final VacancyModel vacancy;
  const CompanyProfileScreen({super.key, required this.vacancy});

  @override
  State<CompanyProfileScreen> createState() => _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends State<CompanyProfileScreen> {
  int _tab = 0; // 0 = Korxona haqida, 1 = Vakansiyalar
  bool _subscribed = false;

  List<VacancyModel> _companyVacancies(VacancyState state) {
    final v = widget.vacancy;
    bool sameCompany(VacancyModel o) {
      if (v.companyId != null && o.companyId != null) return o.companyId == v.companyId;
      return o.companyName != null && o.companyName == v.companyName;
    }

    final list = state.seekerVacancies.where(sameCompany).toList();
    // Manba vakansiyasi ro'yxatda bo'lmasa, uni ham qo'shamiz.
    if (!list.any((o) => o.id == v.id)) list.insert(0, v);
    return list;
  }

  void _openJob(VacancyModel v) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<VacancyBloc>(),
          child: JobDetailScreen(vacancy: v),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.vacancy;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: JB_BG,
        body: BlocBuilder<VacancyBloc, VacancyState>(
          buildWhen: (p, c) => p.seekerVacancies != c.seekerVacancies,
          builder: (context, state) {
            final vacancies = _companyVacancies(state);
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildHeader(v, vacancies.length)),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(20, 16, 20, bottomPad + 28),
                  sliver: _tab == 0 ? _buildAbout(v) : _buildVacancies(vacancies),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(VacancyModel v, int vacancyCount) {
    final topPad = MediaQuery.of(context).padding.top;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: 150,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [JB_BLUE, JB_BLUE_LIGHT],
                ),
              ),
            ),
            Positioned(
              top: topPad + 8,
              left: 20,
              child: JBCircleButton(bg: Colors.white24, fg: Colors.white, onTap: () => Navigator.pop(context)),
            ),
            Positioned(
              left: 20,
              bottom: -42,
              child: Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: kJbSoftShadow,
                ),
                alignment: Alignment.center,
                child: Text(
                  v.companyInitial,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: JB_BLUE),
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 54, 20, 0),
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
                          v.companyName ?? 'Kompaniya',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: JB_INK),
                        ),
                        if (v.companyCategory != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            v.companyCategory!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13.5, color: JB_GRAY),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => setState(() => _subscribed = !_subscribed),
                    child: JBChip(
                      text: _subscribed ? "Obuna bo'lindi" : "Obuna bo'lish",
                      bg: _subscribed ? JB_INDIGO_TINT : JB_CHIP_BG,
                      fg: _subscribed ? JB_BLUE : JB_INK,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              JBSegmented(
                tabs: ['Korxona haqida', 'Vakansiyalar ($vacancyCount)'],
                index: _tab,
                onChanged: (i) => setState(() => _tab = i),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAbout(VacancyModel v) {
    final rows = <Widget>[
      if (v.companyPhone != null)
        _InfoTile(icon: Icons.phone_outlined, label: 'Telefon raqami', value: v.companyPhone!),
      if (v.companyAddress != null)
        _InfoTile(icon: Icons.location_on_outlined, label: 'Joylashuv', value: v.companyAddress!),
      if (v.companyContact != null)
        _InfoTile(icon: Icons.person_outline_rounded, label: "Mas'ul shaxs", value: v.companyContact!),
    ];

    final hasContent = v.companyAbout != null || rows.isNotEmpty;

    return SliverList(
      delegate: SliverChildListDelegate([
        if (v.companyAbout != null)
          JBCard(
            padding: const EdgeInsets.all(20),
            child: Text(v.companyAbout!, style: const TextStyle(fontSize: 14, color: JB_GRAY, height: 1.6)),
          ),
        if (v.companyAbout != null && rows.isNotEmpty) const SizedBox(height: 14),
        if (rows.isNotEmpty)
          JBCard(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Column(
              children: [
                for (int i = 0; i < rows.length; i++)
                  Container(
                    decoration: BoxDecoration(
                      border: i == rows.length - 1 ? null : const Border(bottom: BorderSide(color: JB_DIVIDER)),
                    ),
                    child: rows[i],
                  ),
              ],
            ),
          ),
        if (!hasContent)
          const Padding(
            padding: EdgeInsets.only(top: 40),
            child: Center(child: Text("Korxona haqida ma'lumot yo'q", style: TextStyle(color: JB_GRAY, fontSize: 14))),
          ),
      ]),
    );
  }

  Widget _buildVacancies(List<VacancyModel> vacancies) {
    if (vacancies.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.only(top: 40),
          child: Center(child: Text("Vakansiyalar yo'q", style: TextStyle(color: JB_GRAY, fontSize: 14))),
        ),
      );
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, i) => Padding(
          padding: EdgeInsets.only(bottom: i == vacancies.length - 1 ? 0 : 14),
          child: _CompanyVacancyCard(vacancy: vacancies[i], onOpen: () => _openJob(vacancies[i])),
        ),
        childCount: vacancies.length,
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: JB_BLUE),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12.5, color: JB_GRAY_LIGHT)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: JB_INK)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompanyVacancyCard extends StatelessWidget {
  final VacancyModel vacancy;
  final VoidCallback onOpen;
  const _CompanyVacancyCard({required this.vacancy, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return JBCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            vacancy.jobTypeName ?? "Kasb ko'rsatilmagan",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: JB_INK),
          ),
          const SizedBox(height: 6),
          Text(vacancy.salaryDisplay, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: JB_BLUE)),
          const SizedBox(height: 10),
          JBChip(
            text: vacancy.status == 'active' ? 'Faol' : (vacancy.status ?? 'Vakansiya'),
            bg: JB_CHIP_BG,
            fg: JB_GRAY,
            fontSize: 12.5,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          ),
          const SizedBox(height: 14),
          JBPillButton(
            label: "Batafsil ko'rish",
            trailingIcon: Icons.chevron_right_rounded,
            expand: true,
            vPadding: 13,
            onTap: onOpen,
          ),
        ],
      ),
    );
  }
}
