import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/theme/jb_ui.dart';
import '../../../auth/presentation/logic/auth_bloc.dart';
import '../../data/models/vacancy_model.dart';
import '../logic/vacancy_bloc.dart';
import 'company_profile_screen.dart';

class JobDetailScreen extends StatefulWidget {
  final VacancyModel vacancy;
  const JobDetailScreen({super.key, required this.vacancy});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  bool _applied = false;

  void _openCompany() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<VacancyBloc>(),
          child: CompanyProfileScreen(vacancy: widget.vacancy),
        ),
      ),
    );
  }

  Future<void> _call(String phone) async {
    final uri = Uri.parse('tel:${phone.replaceAll(' ', '')}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _showApplySheet(BuildContext context) {
    final msgCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => BlocProvider.value(
        value: context.read<VacancyBloc>(),
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 22, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(color: const Color(0xFFE2E5EC), borderRadius: BorderRadius.circular(3)),
                ),
              ),
              const Text('Ariza yuborish', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: JB_INK)),
              const SizedBox(height: 4),
              Text(
                widget.vacancy.jobTypeName ?? 'Kasb #${widget.vacancy.jobTypeId}',
                style: const TextStyle(color: JB_GRAY, fontSize: 14),
              ),
              const SizedBox(height: 18),
              const Text("Qo'shimcha xabar (ixtiyoriy)", style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: JB_INK)),
              const SizedBox(height: 8),
              TextField(
                controller: msgCtrl,
                maxLines: 3,
                style: const TextStyle(fontSize: 14.5, color: JB_INK),
                decoration: InputDecoration(
                  hintText: 'Ish beruvchiga xabar...',
                  hintStyle: const TextStyle(color: JB_GRAY_LIGHT),
                  filled: true,
                  fillColor: JB_CHIP_BG,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: JB_BLUE, width: 1.5)),
                ),
              ),
              const SizedBox(height: 18),
              BlocConsumer<VacancyBloc, VacancyState>(
                listener: (ctx2, state) {
                  if (state.applyStatus == FormzSubmissionStatus.success) {
                    Navigator.pop(ctx);
                    setState(() => _applied = true);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ariza muvaffaqiyatli yuborildi!'), backgroundColor: JB_GREEN_FG),
                    );
                  } else if (state.applyStatus == FormzSubmissionStatus.failure) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.error?.errorMessage ?? 'Xato'), backgroundColor: Colors.red.shade600),
                    );
                  }
                },
                builder: (ctx2, state) {
                  final isLoading = state.applyStatus.isInProgress;
                  return SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              context.read<VacancyBloc>().add(ApplyVacancyEvent(
                                widget.vacancy.id,
                                coverMessage: msgCtrl.text.trim().isEmpty ? null : msgCtrl.text.trim(),
                              ));
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: JB_BLUE,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: JB_BLUE.withValues(alpha: 0.7),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                      ),
                      child: isLoading
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                          : const Text('Ariza yuborish', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.vacancy;
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final initial = (v.companyName?.isNotEmpty == true) ? v.companyName![0].toUpperCase() : '?';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: JB_BG,
        body: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  backgroundColor: Colors.white,
                  surfaceTintColor: Colors.white,
                  foregroundColor: JB_INK,
                  elevation: 0,
                  scrolledUnderElevation: 0.5,
                  leading: Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Center(child: JBCircleButton(onTap: () => Navigator.of(context).pop())),
                  ),
                  title: GestureDetector(
                    onTap: _openCompany,
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(color: JB_INDIGO_TINT, borderRadius: BorderRadius.circular(12)),
                          alignment: Alignment.center,
                          child: Text(initial, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: JB_BLUE)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                v.companyName ?? 'Kompaniya',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: JB_INK),
                              ),
                              if (v.companyAddress != null)
                                Text(
                                  v.companyAddress!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 12, color: JB_GRAY),
                                ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, color: JB_GRAY_LIGHT, size: 20),
                      ],
                    ),
                  ),
                  actions: [
                    BlocBuilder<VacancyBloc, VacancyState>(
                      buildWhen: (p, c) => p.savedVacancies != c.savedVacancies,
                      builder: (context, state) {
                        final isSaved = state.savedVacancies.any((s) => s.vacancyId == v.id);
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: JBCircleButton(
                            icon: isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                            fg: isSaved ? JB_BLUE : JB_INK,
                            onTap: () {
                              final userId = context.read<AuthBloc>().state.user?.id;
                              if (userId == null) return;
                              if (isSaved) {
                                context.read<VacancyBloc>().add(UnsaveVacancyEvent(userId, v.id));
                              } else {
                                context.read<VacancyBloc>().add(SaveVacancyEvent(userId, v.id));
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          v.jobTypeName ?? 'Kasb #${v.jobTypeId}',
                          style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w800, color: JB_INK, height: 1.25),
                        ),
                        const SizedBox(height: 8),
                        Text(v.salaryDisplay, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: JB_BLUE)),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            if (v.matchScore != null) ...[
                              JBMatchBadge(percent: v.matchPercent),
                              const SizedBox(width: 10),
                            ],
                            JBChip(
                              text: v.status == 'active' ? 'Faol' : 'Nofaol',
                              bg: v.status == 'active' ? JB_GREEN_BG : JB_CHIP_BG,
                              fg: v.status == 'active' ? JB_GREEN_FG : JB_GRAY,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(20, 16, 20, bottomPad + 100),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      JBCard(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                        child: Column(
                          children: [
                            _InfoRow(icon: Icons.payments_outlined, label: 'Maosh', value: v.salaryDisplay),
                            if (v.minAge != null || v.maxAge != null)
                              _InfoRow(icon: Icons.person_outline_rounded, label: 'Yosh talabi', value: '${v.minAge ?? "?"}–${v.maxAge ?? "?"} yosh'),
                            if (v.companyAddress != null)
                              _InfoRow(icon: Icons.location_on_outlined, label: 'Manzil', value: v.companyAddress!, last: v.companyPhone == null),
                            if (v.companyPhone != null)
                              _InfoRow(icon: Icons.phone_outlined, label: 'Telefon', value: v.companyPhone!, last: true),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('Ish tavsifi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: JB_INK)),
                      const SizedBox(height: 10),
                      const Text(
                        'Ushbu vakansiyaga murojaat qilish uchun "Ishga topshirish" tugmasini bosing. '
                        "Ish beruvchi siz bilan bog'lanadi.",
                        style: TextStyle(fontSize: 14, color: JB_GRAY, height: 1.6),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
            // Sticky bottom bar
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(20, 14, 20, bottomPad + 14),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: JB_BORDER)),
                ),
                child: Row(
                  children: [
                    if (v.companyPhone != null)
                      Expanded(
                        child: JBPillButton(
                          label: "Bog'lanish",
                          leadingIcon: Icons.phone_outlined,
                          variant: JBBtnVariant.outline,
                          vPadding: 15,
                          expand: true,
                          onTap: () => _call(v.companyPhone!),
                        ),
                      ),
                    if (v.companyPhone != null) const SizedBox(width: 10),
                    Expanded(
                      flex: v.companyPhone != null ? 1 : 2,
                      child: _applied
                          ? const JBPillButton(
                              label: 'Ariza yuborildi ✓',
                              variant: JBBtnVariant.disabled,
                              vPadding: 15,
                              expand: true,
                            )
                          : JBPillButton(
                              label: 'Ishga topshirish',
                              trailingIcon: Icons.chevron_right_rounded,
                              vPadding: 15,
                              expand: true,
                              elevated: true,
                              onTap: () => _showApplySheet(context),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool last;
  const _InfoRow({required this.icon, required this.label, required this.value, this.last = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: last ? null : const Border(bottom: BorderSide(color: JB_DIVIDER)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: JB_GRAY_LIGHT),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontSize: 14, color: JB_GRAY)),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: JB_INK),
            ),
          ),
        ],
      ),
    );
  }
}
