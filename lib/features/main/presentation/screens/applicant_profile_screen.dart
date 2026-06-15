import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../../../../core/constants/colors.dart';
import '../../data/models/employer_application_model.dart';
import '../logic/vacancy_bloc.dart';
import 'messages_screen.dart';

// Deterministic placeholders until the backend exposes rating / experience.
// TODO: reyting va tajriba backenddan kelganda haqiqiy qiymatga almashtirilsin.
double _placeholderRating(int id) => 4.5 + (id % 5) * 0.1;
int _placeholderExperience(int id) => 1 + id % 7;

String _initialsOf(String? name) {
  final n = (name ?? '').trim();
  if (n.isEmpty) return '?';
  final parts = n.split(RegExp(r'\s+'));
  if (parts.length >= 2 && parts[1].isNotEmpty) {
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
  return n[0].toUpperCase();
}

class ApplicantProfileScreen extends StatelessWidget {
  final EmployerApplicationModel app;
  const ApplicantProfileScreen({super.key, required this.app});

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.grey;
      case 'viewed':
        return const Color(0xFF0EA5E9);
      case 'invited':
        return PRIMARY_BLUE;
      case 'scheduled':
        return const Color(0xFFF59E0B);
      case 'confirmed':
        return const Color(0xFF6366F1);
      case 'on_way':
        return const Color(0xFFF59E0B);
      case 'arrived':
        return const Color(0xFF0EA5E9);
      case 'accepted':
      case 'probation':
      case 'hired':
        return const Color(0xFF10B981);
      case 'missed':
      case 'rejected':
        return const Color(0xFFF43F5E);
      default:
        return Colors.grey;
    }
  }

  void _openChat(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const MessagesScreen()));
  }

  void _showStatusDialog(BuildContext ctx) {
    final statuses = [
      'viewed',
      'invited',
      'scheduled',
      'arrived',
      'accepted',
      'probation',
      'hired',
      'missed',
      'rejected',
    ];
    final labels = {
      'viewed': "Ko'rildi",
      'invited': 'Taklif qilindi',
      'scheduled': 'Suhbat belgilandi',
      'arrived': 'Keldi',
      'accepted': 'Maqul keldi',
      'probation': 'Sinov davrida',
      'hired': 'Ishga kirdi',
      'missed': 'Kelmadi',
      'rejected': 'Rad etildi',
    };

    String? selectedStatus;
    final dateCtrl = TextEditingController();

    showDialog(
      context: ctx,
      builder:
          (dCtx) => StatefulBuilder(
            builder:
                (dCtx, setS) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: const Text(
                    'Status o\'zgartirish',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: DARK_NAVY,
                      fontSize: 16,
                    ),
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Yangi status:',
                          style: TextStyle(fontSize: 13, color: GRAY_TEXT),
                        ),
                        const SizedBox(height: 8),
                        ...statuses.map(
                          (s) => RadioListTile<String>(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              labels[s] ?? s,
                              style: const TextStyle(fontSize: 14),
                            ),
                            value: s,
                            groupValue: selectedStatus,
                            activeColor: PRIMARY_BLUE,
                            onChanged: (v) => setS(() => selectedStatus = v),
                          ),
                        ),
                        if (selectedStatus == 'scheduled') ...[
                          const Divider(),
                          const Text(
                            'Suhbat vaqti (YYYY-MM-DD HH:MM):',
                            style: TextStyle(fontSize: 13, color: GRAY_TEXT),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: dateCtrl,
                            style: const TextStyle(fontSize: 14),
                            decoration: InputDecoration(
                              hintText: '2026-06-15 10:00',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dCtx),
                      child: const Text(
                        'Bekor',
                        style: TextStyle(color: GRAY_TEXT),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PRIMARY_BLUE,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed:
                          selectedStatus == null
                              ? null
                              : () {
                                Navigator.pop(dCtx);
                                ctx.read<VacancyBloc>().add(
                                  UpdateEmployerApplicationStatusEvent(
                                    app.id,
                                    selectedStatus!,
                                    interviewDatetime:
                                        selectedStatus == 'scheduled' &&
                                                dateCtrl.text.isNotEmpty
                                            ? dateCtrl.text.trim()
                                            : null,
                                    type:
                                        selectedStatus == 'scheduled'
                                            ? 'offline'
                                            : null,
                                  ),
                                );
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
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final statusColor = _statusColor(app.status);

    return BlocListener<VacancyBloc, VacancyState>(
      listenWhen: (p, c) => p.updateEmpAppStatus != c.updateEmpAppStatus,
      listener: (context, state) {
        if (state.updateEmpAppStatus == FormzSubmissionStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Status yangilandi'),
              backgroundColor: Color(0xFF10B981),
            ),
          );
          Navigator.pop(context);
        }
        if (state.updateEmpAppStatus == FormzSubmissionStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error?.errorMessage ?? 'Xato yuz berdi'),
              backgroundColor: Colors.red,
            ),
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
          backgroundColor: Colors.white,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: const Color(0xFF0F172A),
                leading: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                title: const Text(
                  'Nomzod profili',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(20, 24, 20, bottomPad + 24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Header: avatar + name + position + status
                    Row(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFFD1D5DB), Color(0xFF9CA3AF)],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              _initialsOf(app.anketaFullname),
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                app.anketaFullname ?? 'Nomzod',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: DARK_NAVY,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                app.anketaJobType ??
                                    app.requirementJobTypeName ??
                                    'Kasb',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: GRAY_TEXT,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  app.statusLabel,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: statusColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Details
                    _DetailRow(
                      icon: Icons.star_rounded,
                      label: 'Reyting',
                      value: _placeholderRating(app.id).toStringAsFixed(1),
                    ),
                    _DetailRow(
                      icon: Icons.work_outline,
                      label: 'Tajriba',
                      value: '${_placeholderExperience(app.id)} yil',
                    ),
                    if (app.anketaRegion != null)
                      _DetailRow(
                        icon: Icons.location_on_outlined,
                        label: 'Joylashuv',
                        value: app.anketaRegion!,
                      ),
                    if (app.requirementJobTypeName != null)
                      _DetailRow(
                        icon: Icons.badge_outlined,
                        label: 'Vakansiya',
                        value: app.requirementJobTypeName!,
                      ),
                    if (app.requirementSalary != null &&
                        app.requirementSalary! > 0)
                      _DetailRow(
                        icon: Icons.attach_money,
                        label: 'Maosh',
                        value: app.salaryDisplay,
                      ),
                    if (app.interviewDatetime != null)
                      _DetailRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'Suhbat',
                        value: app.interviewDisplay,
                      ),
                    if (app.anketaPhone != null)
                      _DetailRow(
                        icon: Icons.phone_outlined,
                        label: 'Telefon',
                        value: app.anketaPhone!,
                      ),

                    const SizedBox(height: 24),
                    // Actions
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: ElevatedButton.icon(
                              onPressed: () => _showStatusDialog(context),
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              label: const Text(
                                'Statusni o\'zgartirish',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: PRIMARY_BLUE,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          height: 52,
                          width: 52,
                          child: OutlinedButton(
                            onPressed: () => _openChat(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: DARK_NAVY,
                              side: const BorderSide(color: Color(0xFFD1D5DB)),
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Icon(
                              Icons.chat_bubble_outline,
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: PRIMARY_BLUE),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: GRAY_TEXT),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    color: DARK_NAVY,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
