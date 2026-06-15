import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../../../../core/constants/colors.dart';
import '../../data/models/application_model.dart';
import '../logic/vacancy_bloc.dart';
import 'application_detail_screen.dart';

class MyApplicationsScreen extends StatefulWidget {
  const MyApplicationsScreen({super.key});

  @override
  State<MyApplicationsScreen> createState() => _MyApplicationsScreenState();
}

class _MyApplicationsScreenState extends State<MyApplicationsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<VacancyBloc>().add(LoadMyApplicationsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: LIGHT_GRAY_BG,
        body: BlocConsumer<VacancyBloc, VacancyState>(
          listenWhen: (prev, curr) => prev.updateAppStatus != curr.updateAppStatus,
          listener: (context, state) {
            if (state.updateAppStatus == FormzSubmissionStatus.failure) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.error?.errorMessage ?? 'Xato yuz berdi'), backgroundColor: Colors.red));
            }
          },
          builder: (context, state) {
            return Column(children: [_buildHeader(context, state), Expanded(child: _buildBody(context, state))]);
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, VacancyState state) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 8, left: 20, right: 8, bottom: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
      ),
      child:
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BlocBuilder<VacancyBloc, VacancyState>(
            buildWhen: (p, c) => p.savedVacancies != c.savedVacancies,
            builder: (context, state) => Text(
              'Mening arizalarim',
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 4),
          const Text('Vakansiyalarga ariza topshirgansiz', style: TextStyle(color: Colors.white60, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, VacancyState state) {
    if (state.applicationsStatus.isInProgress && state.myApplications.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: PRIMARY_BLUE));
    }
    if (state.applicationsStatus == FormzSubmissionStatus.failure && state.myApplications.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off_outlined, size: 64, color: GRAY_TEXT),
              const SizedBox(height: 16),
              Text(
                state.error?.errorMessage ?? 'Xato yuz berdi',
                style: const TextStyle(fontSize: 15, color: GRAY_TEXT),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.read<VacancyBloc>().add(LoadMyApplicationsEvent()),
                style: ElevatedButton.styleFrom(backgroundColor: PRIMARY_BLUE, foregroundColor: Colors.white, elevation: 0),
                child: const Text('Qayta urinish'),
              ),
            ],
          ),
        ),
      );
    }
    if (state.myApplications.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(color: LIGHT_GRAY_BG, borderRadius: BorderRadius.circular(20)),
                child: const Icon(Icons.folder_open_outlined, size: 36, color: GRAY_TEXT),
              ),
              const SizedBox(height: 16),
              const Text("Hozircha ariza yo'q", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: DARK_NAVY)),
              const SizedBox(height: 8),
              const Text(
                "Vakansiyalarga ariza yuboring\nva natijani shu yerda kuzating",
                style: TextStyle(fontSize: 13, color: GRAY_TEXT),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final active = state.myApplications.where((a) => a.isActive).toList();
    final rejected = state.myApplications.where((a) => !a.isActive).toList();

    return RefreshIndicator(
      color: PRIMARY_BLUE,
      onRefresh: () async => context.read<VacancyBloc>().add(LoadMyApplicationsEvent()),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          if (active.isNotEmpty) ...[
            _SectionHeader(title: 'Faol arizalar'),
            const SizedBox(height: 12),
            ...active.map(
              (a) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<VacancyBloc>(),
                        child: ApplicationDetailScreen(application: a),
                      ),
                    ),
                  ),
                  child: _ApplicationCard(
                    application: a,
                    isUpdating: state.updateAppStatus.isInProgress,
                    onUpdateStatus: (s) => context.read<VacancyBloc>().add(UpdateApplicationStatusEvent(a.id, s)),
                  ),
                ),
              ),
            ),
          ],
          if (rejected.isNotEmpty) ...[
            if (active.isNotEmpty) const SizedBox(height: 8),
            _SectionHeader(title: 'Rad etilgan'),
            const SizedBox(height: 12),
            ...rejected.map(
              (a) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<VacancyBloc>(),
                        child: ApplicationDetailScreen(application: a),
                      ),
                    ),
                  ),
                  child: _ApplicationCard(application: a, isUpdating: false, onUpdateStatus: null),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Section header ─────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: DARK_NAVY));
  }
}

// ── Application card ───────────────────────────────────────────────────────────

class _ApplicationCard extends StatelessWidget {
  final ApplicationModel application;
  final bool isUpdating;
  final void Function(String status)? onUpdateStatus;

  const _ApplicationCard({required this.application, required this.isUpdating, required this.onUpdateStatus});

  _StatusStyle get _style {
    switch (application.status) {
      case 'pending':
        return _StatusStyle(color: const Color(0xFFD97706), bgColor: const Color(0xFFFEF3C7), icon: Icons.timelapse_rounded, label: 'Kutilmoqda');
      case 'viewed':
        return _StatusStyle(
          color: const Color(0xFF4F46E5),
          bgColor: const Color(0xFFEEF2FF),
          icon: Icons.check_circle_outline_rounded,
          label: "Ko'rildi",
        );
      case 'invited':
        return _StatusStyle(
          color: const Color(0xFF7C3AED),
          bgColor: const Color(0xFFF5F3FF),
          icon: Icons.mail_outline_rounded,
          label: 'Taklif qilindi',
        );
      case 'scheduled':
        return _StatusStyle(
          color: const Color(0xFF16A34A),
          bgColor: const Color(0xFFF0FDF4),
          icon: Icons.calendar_month_rounded,
          label: 'Suhbatga chaqirildi',
        );
      case 'confirmed':
        return _StatusStyle(color: const Color(0xFF16A34A), bgColor: const Color(0xFFF0FDF4), icon: Icons.check_circle_rounded, label: 'Tasdiqlandi');
      case 'on_way':
        return _StatusStyle(
          color: const Color(0xFF0891B2),
          bgColor: const Color(0xFFECFEFF),
          icon: Icons.directions_walk_rounded,
          label: "Yo'ldaman",
        );
      case 'arrived':
        return _StatusStyle(color: const Color(0xFF16A34A), bgColor: const Color(0xFFF0FDF4), icon: Icons.location_on_rounded, label: 'Keldi');
      case 'hired':
        return _StatusStyle(color: const Color(0xFF16A34A), bgColor: const Color(0xFFF0FDF4), icon: Icons.handshake_outlined, label: 'Ishga olindi');
      case 'missed':
        return _StatusStyle(color: GRAY_TEXT, bgColor: const Color(0xFFF3F4F6), icon: Icons.event_busy_rounded, label: 'Kelmadi');
      case 'rejected':
        return _StatusStyle(color: const Color(0xFFDC2626), bgColor: const Color(0xFFFEF2F2), icon: Icons.cancel_outlined, label: 'Rad etildi');
      default:
        return _StatusStyle(color: GRAY_TEXT, bgColor: const Color(0xFFF3F4F6), icon: Icons.info_outline, label: application.statusLabel);
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = _style;
    final createdAt = application.createdAtDisplay;
    final hasInterview =
        application.interviewDatetime != null &&
        (application.status == 'scheduled' || application.status == 'confirmed' || application.status == 'on_way');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title row + status badge ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      application.jobTypeName ?? "Kasb noma'lum",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: DARK_NAVY),
                    ),
                    const SizedBox(height: 4),
                    Text(application.companyName ?? 'Kompaniya', style: const TextStyle(fontSize: 13, color: GRAY_TEXT)),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: style.bgColor, borderRadius: BorderRadius.circular(20)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(style.icon, size: 14, color: style.color),
                    const SizedBox(width: 5),
                    Text(style.label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: style.color)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // ── Info rows ──
          if (application.salaryDisplay.isNotEmpty) ...[
            _InfoRow(icon: Icons.attach_money_outlined, text: application.salaryDisplay),
            const SizedBox(height: 6),
          ],
          if (createdAt.isNotEmpty) _InfoRow(icon: Icons.access_time_rounded, text: 'Yuborilgan: $createdAt'),
          // ── Interview box ──
          if (hasInterview) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month_rounded, size: 20, color: Color(0xFF16A34A)),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Suhbat belgilandi', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF16A34A))),
                      const SizedBox(height: 2),
                      Text(application.interviewDisplay, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF166534))),
                    ],
                  ),
                ],
              ),
            ),
          ],
          // ── Action buttons ──
          if (onUpdateStatus != null && (application.canConfirm || application.canGoOnWay)) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (application.canConfirm)
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        onPressed: isUpdating ? null : () => onUpdateStatus!('confirmed'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF16A34A),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child:
                            isUpdating
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text('Tasdiqlash', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                if (application.canConfirm && application.canGoOnWay) const SizedBox(width: 8),
                if (application.canGoOnWay && application.status == 'confirmed')
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: OutlinedButton(
                        onPressed: isUpdating ? null : () => onUpdateStatus!('on_way'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF0891B2),
                          side: const BorderSide(color: Color(0xFF0891B2)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text("Yo'ldaman", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: GRAY_TEXT),
        const SizedBox(width: 6),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: GRAY_TEXT))),
      ],
    );
  }
}

class _StatusStyle {
  final Color color;
  final Color bgColor;
  final IconData icon;
  final String label;

  const _StatusStyle({required this.color, required this.bgColor, required this.icon, required this.label});
}
