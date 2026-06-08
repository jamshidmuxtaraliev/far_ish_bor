import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../../../../core/constants/colors.dart';
import '../../data/models/vacancy_model.dart';
import '../logic/vacancy_bloc.dart';

class JobDetailScreen extends StatefulWidget {
  final VacancyModel vacancy;
  const JobDetailScreen({super.key, required this.vacancy});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  bool _applied = false;

  void _showApplySheet(BuildContext context) {
    final msgCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => BlocProvider.value(
        value: context.read<VacancyBloc>(),
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Ariza yuborish', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: DARK_NAVY)),
              const SizedBox(height: 8),
              Text(
                widget.vacancy.jobTypeName ?? 'Kasb #${widget.vacancy.jobTypeId}',
                style: const TextStyle(color: GRAY_TEXT, fontSize: 14),
              ),
              const SizedBox(height: 16),
              const Text('Qo\'shimcha xabar (ixtiyoriy)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: DARK_NAVY)),
              const SizedBox(height: 8),
              TextField(
                controller: msgCtrl,
                maxLines: 3,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Ish beruvchiga xabar...',
                  hintStyle: const TextStyle(color: GRAY_TEXT),
                  filled: true,
                  fillColor: LIGHT_GRAY_BG,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: PRIMARY_BLUE, width: 2)),
                ),
              ),
              const SizedBox(height: 16),
              BlocConsumer<VacancyBloc, VacancyState>(
                listener: (ctx2, state) {
                  if (state.applyStatus == FormzSubmissionStatus.success) {
                    Navigator.pop(ctx);
                    setState(() => _applied = true);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ariza muvaffaqiyatli yuborildi!'), backgroundColor: Color(0xFF16A34A)),
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
                    height: 50,
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
                        backgroundColor: PRIMARY_BLUE,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: PRIMARY_BLUE.withValues(alpha: 0.7),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: isLoading
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                          : const Text('Ariza yuborish', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
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

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  backgroundColor: const Color(0xFF0F172A),
                  leading: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                  ),
                  title: Text(
                    v.jobTypeName ?? 'Vakansiya',
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(20, 24, 20, bottomPad + 80),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Company header
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(color: LIGHT_GRAY_BG, borderRadius: BorderRadius.circular(16)),
                            child: Center(
                              child: Text(
                                (v.companyName?.isNotEmpty == true) ? v.companyName![0].toUpperCase() : '?',
                                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: DARK_NAVY),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  v.jobTypeName ?? 'Kasb #${v.jobTypeId}',
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: DARK_NAVY),
                                ),
                                const SizedBox(height: 4),
                                Text(v.companyName ?? 'Kompaniya', style: const TextStyle(fontSize: 14, color: GRAY_TEXT)),
                                if (v.matchScore != null) ...[
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF16A34A).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'Moslik: ${v.matchPercent}%',
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF16A34A)),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Info grid
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.8,
                        children: [
                          _InfoCard(icon: Icons.attach_money, label: 'Maosh', value: v.salaryDisplay),
                          if (v.minAge != null || v.maxAge != null)
                            _InfoCard(icon: Icons.person_outline, label: 'Yosh talabi', value: '${v.minAge ?? "?"}–${v.maxAge ?? "?"} yosh'),
                          if (v.companyAddress != null)
                            _InfoCard(icon: Icons.location_on_outlined, label: 'Manzil', value: v.companyAddress!),
                          _InfoCard(icon: Icons.work_outline, label: 'Holati', value: v.status == 'active' ? 'Faol' : 'Nofaol'),
                        ],
                      ),
                      const SizedBox(height: 24),
                      if (v.companyPhone != null) ...[
                        const _Section(title: "Bog'lanish"),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.phone_outlined, size: 18, color: PRIMARY_BLUE),
                            const SizedBox(width: 8),
                            Text(v.companyPhone!, style: const TextStyle(fontSize: 15, color: DARK_NAVY)),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                      const _Section(title: "Vakansiya haqida"),
                      const SizedBox(height: 10),
                      const Text(
                        'Ushbu vakansiyaga murojaat qilish uchun "Ariza yuborish" tugmasini bosing. '
                        'Ish beruvchi siz bilan bog\'lanadi.',
                        style: TextStyle(fontSize: 14, color: GRAY_TEXT, height: 1.6),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
            // Apply button
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPad + 12),
                color: Colors.white,
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _applied ? null : () => _showApplySheet(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _applied ? const Color(0xFF16A34A) : PRIMARY_BLUE,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFF16A34A),
                      disabledForegroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(
                      _applied ? 'Ariza yuborildi ✓' : 'Ariza yuborish',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  const _Section({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: DARK_NAVY));
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoCard({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: LIGHT_GRAY_BG, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E7EB))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: PRIMARY_BLUE),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 11, color: GRAY_TEXT)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: DARK_NAVY), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
