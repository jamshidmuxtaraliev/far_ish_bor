import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../../../../core/constants/colors.dart';
import '../../data/models/employer_application_model.dart';
import '../logic/vacancy_bloc.dart';

class EmployerApplicationsScreen extends StatefulWidget {
  const EmployerApplicationsScreen({super.key});

  @override
  State<EmployerApplicationsScreen> createState() => _EmployerApplicationsScreenState();
}

class _EmployerApplicationsScreenState extends State<EmployerApplicationsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<VacancyBloc>().add(LoadEmployerApplicationsEvent());
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending': return Colors.grey;
      case 'viewed': return const Color(0xFF0EA5E9);
      case 'invited': return PRIMARY_BLUE;
      case 'scheduled': return const Color(0xFFF59E0B);
      case 'confirmed': return const Color(0xFF6366F1);
      case 'on_way': return const Color(0xFFF59E0B);
      case 'arrived': return const Color(0xFF0EA5E9);
      case 'accepted':
      case 'probation':
      case 'hired': return const Color(0xFF10B981);
      case 'missed':
      case 'rejected': return const Color(0xFFF43F5E);
      default: return Colors.grey;
    }
  }

  void _showStatusDialog(BuildContext ctx, EmployerApplicationModel app) {
    final statuses = ['viewed', 'invited', 'scheduled', 'arrived', 'accepted', 'probation', 'hired', 'missed', 'rejected'];
    final labels = {
      'viewed': "Ko'rildi", 'invited': 'Taklif qilindi', 'scheduled': 'Suhbat belgilandi',
      'arrived': 'Keldi', 'accepted': 'Maqul keldi', 'probation': 'Sinov davrida',
      'hired': 'Ishga kirdi', 'missed': 'Kelmadi', 'rejected': 'Rad etildi',
    };

    String? selectedStatus;
    final dateCtrl = TextEditingController();

    showDialog(
      context: ctx,
      builder: (dCtx) => StatefulBuilder(
        builder: (dCtx, setS) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Status o\'zgartirish', style: const TextStyle(fontWeight: FontWeight.bold, color: DARK_NAVY, fontSize: 16)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Yangi status:', style: TextStyle(fontSize: 13, color: GRAY_TEXT)),
                const SizedBox(height: 8),
                ...statuses.map((s) => RadioListTile<String>(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(labels[s] ?? s, style: const TextStyle(fontSize: 14)),
                  value: s,
                  groupValue: selectedStatus,
                  activeColor: PRIMARY_BLUE,
                  onChanged: (v) => setS(() => selectedStatus = v),
                )),
                if (selectedStatus == 'scheduled') ...[
                  const Divider(),
                  const Text('Suhbat vaqti (YYYY-MM-DD HH:MM):', style: TextStyle(fontSize: 13, color: GRAY_TEXT)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: dateCtrl,
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: '2026-06-15 10:00',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dCtx), child: const Text('Bekor', style: TextStyle(color: GRAY_TEXT))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: PRIMARY_BLUE, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              onPressed: selectedStatus == null
                  ? null
                  : () {
                      Navigator.pop(dCtx);
                      ctx.read<VacancyBloc>().add(UpdateEmployerApplicationStatusEvent(
                        app.id,
                        selectedStatus!,
                        interviewDatetime: selectedStatus == 'scheduled' && dateCtrl.text.isNotEmpty ? dateCtrl.text.trim() : null,
                        type: selectedStatus == 'scheduled' ? 'offline' : null,
                      ));
                    },
              child: const Text('Saqlash'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VacancyBloc, VacancyState>(
      listenWhen: (p, c) => p.updateEmpAppStatus != c.updateEmpAppStatus,
      listener: (context, state) {
        if (state.updateEmpAppStatus == FormzSubmissionStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Status yangilandi'), backgroundColor: Color(0xFF10B981)),
          );
        }
        if (state.updateEmpAppStatus == FormzSubmissionStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error?.errorMessage ?? 'Xato yuz berdi'), backgroundColor: Colors.red),
          );
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        child: Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 16,
                  left: 20,
                  right: 20,
                  bottom: 20,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF7C3AED), Color(0xFF9333EA)],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BlocBuilder<VacancyBloc, VacancyState>(
                      buildWhen: (p, c) => p.employerApplications != c.employerApplications,
                      builder: (context, state) => Text(
                        'Kelgan arizalar (${state.employerApplications.length})',
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text('Nomzodlarning arizalarini boshqaring', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
              Expanded(
                child: BlocBuilder<VacancyBloc, VacancyState>(
                  buildWhen: (p, c) => p.employerApplications != c.employerApplications || p.employerAppsStatus != c.employerAppsStatus,
                  builder: (context, state) {
                    if (state.employerAppsStatus.isInProgress) {
                      return const Center(child: CircularProgressIndicator(color: PRIMARY_BLUE, strokeWidth: 2));
                    }
                    if (state.employerApplications.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(20)),
                              child: const Icon(Icons.inbox_outlined, color: GRAY_TEXT, size: 36),
                            ),
                            const SizedBox(height: 16),
                            const Text('Hali ariza kelmagan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: DARK_NAVY)),
                            const SizedBox(height: 6),
                            const Text('Vakansiyalaringizga nomzodlar ariza yuborishini kuting', style: TextStyle(fontSize: 13, color: GRAY_TEXT), textAlign: TextAlign.center),
                          ],
                        ),
                      );
                    }
                    return RefreshIndicator(
                      color: PRIMARY_BLUE,
                      onRefresh: () async => context.read<VacancyBloc>().add(LoadEmployerApplicationsEvent()),
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.employerApplications.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (ctx, i) => _AppCard(
                          app: state.employerApplications[i],
                          statusColor: _statusColor(state.employerApplications[i].status),
                          onChangeStatus: () => _showStatusDialog(context, state.employerApplications[i]),
                        ),
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

class _AppCard extends StatelessWidget {
  final EmployerApplicationModel app;
  final Color statusColor;
  final VoidCallback onChangeStatus;

  const _AppCard({required this.app, required this.statusColor, required this.onChangeStatus});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    (app.anketaFullname ?? '?').isNotEmpty ? (app.anketaFullname![0].toUpperCase()) : '?',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: PRIMARY_BLUE),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app.anketaFullname ?? 'Nomzod',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: DARK_NAVY),
                    ),
                    if (app.anketaJobType != null)
                      Text(app.anketaJobType!, style: const TextStyle(fontSize: 13, color: GRAY_TEXT)),
                    if (app.anketaRegion != null)
                      Row(children: [
                        const Icon(Icons.location_on_outlined, size: 13, color: GRAY_TEXT),
                        const SizedBox(width: 2),
                        Text(app.anketaRegion!, style: const TextStyle(fontSize: 12, color: GRAY_TEXT)),
                      ]),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(app.statusLabel, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (app.requirementJobTypeName != null)
            Row(children: [
              const Icon(Icons.work_outline, size: 14, color: GRAY_TEXT),
              const SizedBox(width: 4),
              Text('Vakansiya: ${app.requirementJobTypeName}', style: const TextStyle(fontSize: 12, color: GRAY_TEXT)),
              if (app.requirementSalary != null && app.requirementSalary! > 0) ...[
                const SizedBox(width: 10),
                Text(app.salaryDisplay, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF10B981))),
              ],
            ]),
          if (app.interviewDatetime != null) ...[
            const SizedBox(height: 6),
            Row(children: [
              const Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFFF59E0B)),
              const SizedBox(width: 4),
              Text('Suhbat: ${app.interviewDisplay}', style: const TextStyle(fontSize: 12, color: Color(0xFFF59E0B), fontWeight: FontWeight.w500)),
            ]),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 38,
            child: OutlinedButton.icon(
              onPressed: onChangeStatus,
              icon: const Icon(Icons.edit_outlined, size: 16),
              label: const Text('Statusni o\'zgartirish', style: TextStyle(fontSize: 13)),
              style: OutlinedButton.styleFrom(
                foregroundColor: PRIMARY_BLUE,
                side: const BorderSide(color: PRIMARY_BLUE),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
