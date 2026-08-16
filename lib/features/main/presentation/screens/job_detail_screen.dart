import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/theme/jb_ui.dart';
import '../../../auth/presentation/logic/auth_bloc.dart';
import '../../data/models/application_access.dart';
import '../../data/models/application_model.dart';
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

  @override
  void initState() {
    super.initState();
    // Kontaktlar arizaning holatiga bog'liq — ro'yxatni yangilab olamiz.
    context.read<VacancyBloc>().add(LoadMyApplicationsEvent());
  }

  /// Shu vakansiyaga yuborilgan arizam (bo'lsa). Asosiy moslik — requirement
  /// id bo'yicha; backend uni qaytarmasa, korxona + kasb nomi bo'yicha.
  ApplicationModel? _myApplication(VacancyState state) {
    final v = widget.vacancy;
    for (final a in state.myApplications) {
      if (a.requirementId != null && a.requirementId == v.id) return a;
    }
    for (final a in state.myApplications) {
      if (a.requirementId == null &&
          a.companyName != null &&
          a.companyName == v.companyName &&
          a.jobTypeName == v.jobTypeName) {
        return a;
      }
    }
    return null;
  }

  void _openCompany() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) => BlocProvider.value(
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

  /// Simple confirm dialog — no cover-message field, the seeker just confirms.
  void _showApplyDialog(BuildContext context) {
    final v = widget.vacancy;
    showDialog(
      context: context,
      builder:
          (ctx) => BlocProvider.value(
            value: context.read<VacancyBloc>(),
            child: BlocConsumer<VacancyBloc, VacancyState>(
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
                return PopScope(
                  canPop: !isLoading,
                  child: Dialog(
                    backgroundColor: Colors.white,
                    insetPadding: const EdgeInsets.symmetric(horizontal: 28),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(22, 26, 22, 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: const BoxDecoration(color: JB_INDIGO_TINT, shape: BoxShape.circle),
                            child: const Icon(Icons.send_rounded, color: JB_BLUE, size: 28),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Ariza yuborilsinmi?',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: JB_INK),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            v.jobTypeName ?? 'Kasb #${v.jobTypeId}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: JB_INK),
                          ),
                          if (v.companyName?.isNotEmpty == true) ...[
                            const SizedBox(height: 2),
                            Text(
                              v.companyName!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 14, color: JB_GRAY),
                            ),
                          ],
                          const SizedBox(height: 14),
                          const Text(
                            'Profilingiz ma\'lumotlari ish beruvchiga yuboriladi.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: JB_GRAY, height: 1.4),
                          ),
                          const SizedBox(height: 22),
                          Row(
                            children: [
                              Expanded(
                                child: JBPillButton(
                                  label: 'Bekor',
                                  variant: isLoading ? JBBtnVariant.disabled : JBBtnVariant.outline,
                                  vPadding: 15,
                                  expand: true,
                                  onTap: isLoading ? null : () => Navigator.pop(ctx),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: SizedBox(
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed:
                                        isLoading
                                            ? null
                                            : () => context.read<VacancyBloc>().add(ApplyVacancyEvent(v.id)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: JB_BLUE,
                                      foregroundColor: Colors.white,
                                      disabledBackgroundColor: JB_BLUE.withValues(alpha: 0.7),
                                      elevation: 0,
                                      padding: EdgeInsets.zero,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                                    ),
                                    child:
                                        isLoading
                                            ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                            )
                                            : const Text(
                                              'Ha, yuborish',
                                              style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
                                            ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
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
        body: BlocBuilder<VacancyBloc, VacancyState>(
          buildWhen: (p, c) => p.myApplications != c.myApplications,
          builder: (context, state) {
            final myApp = _myApplication(state);
            // Korxona telefoni faqat ariza qabul qilingandan keyin ochiladi;
            // rad etilgan yoki kutilayotgan arizada yopiq turadi.
            final showPhone = v.companyPhone != null && isApplicationAccepted(myApp?.status);
            final applied = _applied || myApp != null;
            return Stack(
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
                              child: Text(
                                initial,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: JB_BLUE),
                              ),
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
                              style: const TextStyle(
                                fontSize: 23,
                                fontWeight: FontWeight.w800,
                                color: JB_INK,
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              v.salaryDisplay,
                              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: JB_BLUE),
                            ),
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
                                  _InfoRow(
                                    icon: Icons.person_outline_rounded,
                                    label: 'Yosh talabi',
                                    value: '${v.minAge ?? "?"}–${v.maxAge ?? "?"} yosh',
                                  ),
                                if (v.companyAddress != null)
                                  _InfoRow(
                                    icon: Icons.location_on_outlined,
                                    label: 'Manzil',
                                    value: v.companyAddress!,
                                    last: v.companyPhone == null,
                                  ),
                                if (showPhone)
                                  _InfoRow(
                                    icon: Icons.phone_outlined,
                                    label: 'Telefon',
                                    value: v.companyPhone!,
                                    last: true,
                                  )
                                else if (v.companyPhone != null)
                                  _InfoRow(
                                    icon: Icons.lock_outline_rounded,
                                    label: 'Telefon',
                                    value: kContactLockedHint,
                                    last: true,
                                    muted: true,
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Ish tavsifi',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: JB_INK),
                          ),
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
                        if (showPhone) ...[
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
                          const SizedBox(width: 10),
                        ],
                        Expanded(
                          flex: showPhone ? 1 : 2,
                          child:
                              applied
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
                                    onTap: () => _showApplyDialog(context),
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
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

  /// Yopiq (hali ochilmagan) qiymat — kulrang va yupqaroq ko'rinadi.
  final bool muted;
  const _InfoRow({required this.icon, required this.label, required this.value, this.last = false, this.muted = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(border: last ? null : const Border(bottom: BorderSide(color: JB_DIVIDER))),
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
              style: TextStyle(
                fontSize: muted ? 12.5 : 14.5,
                fontWeight: muted ? FontWeight.w500 : FontWeight.w700,
                color: muted ? JB_GRAY : JB_INK,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
