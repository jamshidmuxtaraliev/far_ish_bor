import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../../data/models/application_access.dart';
import '../../data/models/application_model.dart';
import '../logic/vacancy_bloc.dart';
import '../../../../core/theme/jb_palette.dart';

class ApplicationDetailScreen extends StatelessWidget {
  final ApplicationModel application;
  const ApplicationDetailScreen({super.key, required this.application});

  @override
  Widget build(BuildContext context) {
    final a = application;
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final hasInterview = a.interviewDatetime != null &&
        (a.status == 'scheduled' || a.status == 'confirmed' || a.status == 'on_way');
    final showActions = a.canConfirm || a.canGoOnWay;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.jb.overlay,
      child: Scaffold(
        backgroundColor: context.jb.card,
        body: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  backgroundColor: context.jb.card,
                  surfaceTintColor: context.jb.card,
                  foregroundColor: context.jb.ink,
                  elevation: 0,
                  scrolledUnderElevation: 0.5,
                  leading: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back_ios_new, color: context.jb.ink, size: 20),
                  ),
                  title: Text(
                    a.jobTypeName ?? 'Ariza',
                    style: TextStyle(color: context.jb.ink, fontSize: 17, fontWeight: FontWeight.w800),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(20, 24, 20, bottomPad + (showActions ? 80 : 32)),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Company header
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(color: context.jb.bg, borderRadius: BorderRadius.circular(16)),
                            child: Center(
                              child: Text(
                                (a.companyName?.isNotEmpty == true) ? a.companyName![0].toUpperCase() : '?',
                                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: context.jb.ink),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  a.jobTypeName ?? "Kasb noma'lum",
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: context.jb.ink),
                                ),
                                const SizedBox(height: 4),
                                Text(a.companyName ?? 'Kompaniya', style: TextStyle(fontSize: 14, color: context.jb.gray)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Status banner
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: a.statusBgColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: a.statusColor.withValues(alpha: 0.25)),
                        ),
                        child: Row(
                          children: [
                            Icon(a.statusIcon, size: 24, color: a.statusColor),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Ariza holati', style: TextStyle(fontSize: 11, color: context.jb.gray)),
                                  const SizedBox(height: 2),
                                  Text(
                                    a.statusLabel,
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: a.statusColor),
                                  ),
                                ],
                              ),
                            ),
                            if (a.createdAtDisplay.isNotEmpty)
                              Text(a.createdAtDisplay, style: TextStyle(fontSize: 12, color: context.jb.gray)),
                          ],
                        ),
                      ),

                      // Interview box
                      if (hasInterview) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: context.jb.greenBg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: context.jb.greenBg),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_month_rounded, size: 22, color: context.jb.green),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Suhbat belgilandi',
                                    style: TextStyle(fontSize: 12, color: context.jb.green),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    a.interviewDisplay,
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: context.jb.green),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Info grid
                      if (a.salaryDisplay.isNotEmpty || a.minAge != null || a.deadline != null) ...[
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1.8,
                          children: [
                            if (a.salaryDisplay.isNotEmpty)
                              _InfoCard(icon: Icons.attach_money, label: 'Maosh', value: a.salaryDisplay),
                            if (a.minAge != null || a.maxAge != null)
                              _InfoCard(
                                icon: Icons.person_outline,
                                label: 'Yosh talabi',
                                value: '${a.minAge ?? "?"}–${a.maxAge ?? "?"} yosh',
                              ),
                            if (a.deadline != null)
                              _InfoCard(icon: Icons.schedule_outlined, label: 'Muddat', value: a.deadline!),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Company phone — faqat ariza qabul qilingandan keyin.
                      if (a.companyPhone != null) ...[
                        Text("Bog'lanish", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: context.jb.ink)),
                        const SizedBox(height: 10),
                        if (a.isAccepted)
                          Row(
                            children: [
                              Icon(Icons.phone_outlined, size: 18, color: context.jb.blue),
                              const SizedBox(width: 8),
                              Text(a.companyPhone!, style: TextStyle(fontSize: 15, color: context.jb.ink)),
                            ],
                          )
                        else
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: context.jb.bg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: context.jb.border),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.lock_outline_rounded, size: 18, color: context.jb.gray),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    kContactLockedHint,
                                    style: TextStyle(fontSize: 13.5, color: context.jb.gray, height: 1.4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 24),
                      ],

                      // Vacancy description
                      if (a.requirementComment != null) ...[
                        Text('Vakansiya haqida', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: context.jb.ink)),
                        const SizedBox(height: 10),
                        Text(
                          a.requirementComment!,
                          style: TextStyle(fontSize: 14, color: context.jb.gray, height: 1.6),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Cover message
                      if (a.coverMessage != null && a.coverMessage!.isNotEmpty) ...[
                        Text('Mening xabarim', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: context.jb.ink)),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: context.jb.bg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: context.jb.border),
                          ),
                          child: Text(
                            a.coverMessage!,
                            style: TextStyle(fontSize: 14, color: context.jb.ink, height: 1.5),
                          ),
                        ),
                      ],
                    ]),
                  ),
                ),
              ],
            ),

            // Action buttons
            if (showActions)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: BlocConsumer<VacancyBloc, VacancyState>(
                  listenWhen: (p, c) => p.updateAppStatus != c.updateAppStatus,
                  listener: (context, state) {
                    if (state.updateAppStatus == FormzSubmissionStatus.success) {
                      Navigator.pop(context);
                    }
                  },
                  buildWhen: (p, c) => p.updateAppStatus != c.updateAppStatus,
                  builder: (context, state) {
                    final isLoading = state.updateAppStatus.isInProgress;
                    return Container(
                      padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPad + 12),
                      decoration: BoxDecoration(
                        color: context.jb.card,
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, -4))],
                      ),
                      child: Row(
                        children: [
                          if (a.canConfirm)
                            Expanded(
                              child: SizedBox(
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: isLoading
                                      ? null
                                      : () => context.read<VacancyBloc>().add(UpdateApplicationStatusEvent(a.id, 'confirmed')),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: context.jb.green,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor: context.jb.green.withValues(alpha: 0.7),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                  child: isLoading
                                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                                      : const Text('Tasdiqlash', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                ),
                              ),
                            ),
                          if (a.canConfirm && a.canGoOnWay) const SizedBox(width: 12),
                          if (a.canGoOnWay)
                            Expanded(
                              child: SizedBox(
                                height: 52,
                                child: OutlinedButton(
                                  onPressed: isLoading
                                      ? null
                                      : () => context.read<VacancyBloc>().add(UpdateApplicationStatusEvent(a.id, 'on_way')),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: context.jb.cyan,
                                    side: BorderSide(color: context.jb.cyan, width: 1.5),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                  child: const Text("Yo'ldaman", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                ),
                              ),
                            ),
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

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoCard({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.jb.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.jb.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: context.jb.blue),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(fontSize: 11, color: context.jb.gray)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: context.jb.ink), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
