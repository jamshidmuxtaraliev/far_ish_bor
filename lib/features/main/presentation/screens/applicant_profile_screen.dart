import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../../../chat/presentation/screens/direct_chat_screen.dart';
import '../../data/models/application_access.dart';
import '../../data/models/employer_application_model.dart';
import '../logic/vacancy_bloc.dart';
import 'messages_screen.dart';
import '../../../../core/theme/jb_palette.dart';

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
        return jb.gray;
      case 'viewed':
        return jb.cyan;
      case 'invited':
        return jb.blue;
      case 'scheduled':
        return jb.amber;
      case 'confirmed':
        return jb.violet;
      case 'on_way':
        return jb.amber;
      case 'arrived':
        return jb.cyan;
      case 'accepted':
      case 'probation':
      case 'hired':
        return jb.green;
      case 'missed':
      case 'rejected':
        return jb.red;
      default:
        return jb.gray;
    }
  }

  /// Chat tugmasi — iloji bo'lsa AYNAN shu nomzod bilan suhbatni ochadi.
  ///
  /// Ilgari bu yer butun "Xabarlar" ro'yxatini `push` qilardi: ro'yxat endi
  /// pastki menyuda tab bo'lgani uchun bu shunchaki tabning ikkinchi nusxasini
  /// ustiga qo'yardi. Suhbat kaliti faqat kontakt ochilgach keladi, shuning
  /// uchun u hali yo'q bo'lsa ro'yxatga (orqaga tugmasi bilan) tushamiz.
  void _openChat(BuildContext context) {
    final anketaId = app.anketaId;
    final key = anketaId == null
        ? null
        : context.read<VacancyBloc>().state.capabilitiesOf(anketaId)?.chatSessionKey;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => key == null || key.isEmpty
            ? const MessagesScreen(showBack: true)
            : DirectChatScreen(
                sessionKey: key,
                peerName: app.anketaFullname ?? 'Nomzod',
              ),
      ),
    );
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
                  title: Text(
                    'Status o\'zgartirish',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: jb.ink,
                      fontSize: 16,
                    ),
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Yangi status:',
                          style: TextStyle(fontSize: 13, color: jb.gray),
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
                            activeColor: jb.blue,
                            onChanged: (v) => setS(() => selectedStatus = v),
                          ),
                        ),
                        if (selectedStatus == 'scheduled') ...[
                          const Divider(),
                          Text(
                            'Suhbat vaqti (YYYY-MM-DD HH:MM):',
                            style: TextStyle(fontSize: 13, color: jb.gray),
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
                      child: Text(
                        'Bekor',
                        style: TextStyle(color: jb.gray),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: jb.blue,
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
            SnackBar(
              content: Text('Status yangilandi'),
              backgroundColor: context.jb.green,
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
        value: context.jb.overlay,
        child: Scaffold(
          backgroundColor: context.jb.card,
          body: CustomScrollView(
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
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    color: context.jb.ink,
                    size: 20,
                  ),
                ),
                title: Text(
                  'Nomzod profili',
                  style: TextStyle(
                    color: context.jb.ink,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
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
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [context.jb.borderStrong, context.jb.grayLight],
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
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: context.jb.ink,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                app.anketaJobType ??
                                    app.requirementJobTypeName ??
                                    'Kasb',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: context.jb.gray,
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
                                backgroundColor: context.jb.blue,
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
                            // Chat faqat ariza qabul qilingandan keyin ochiladi.
                            onPressed: isApplicationAccepted(app.status)
                                ? () => _openChat(context)
                                : null,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: context.jb.ink,
                              disabledForegroundColor: context.jb.gray,
                              side: BorderSide(color: context.jb.borderStrong),
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Icon(
                              isApplicationAccepted(app.status)
                                  ? Icons.chat_bubble_outline
                                  : Icons.lock_outline_rounded,
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
          Icon(icon, size: 18, color: context.jb.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: context.jb.gray),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    color: context.jb.ink,
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
