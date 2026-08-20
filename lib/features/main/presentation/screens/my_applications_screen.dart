import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../../../../core/theme/jb_ui.dart';
import '../../data/models/application_model.dart';
import '../logic/vacancy_bloc.dart';
import 'application_detail_screen.dart';
import '../../../../core/theme/jb_palette.dart';

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
      value: context.jb.overlay,
      child: Scaffold(
        backgroundColor: context.jb.bg,
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
      color: context.jb.card,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 18, left: 20, right: 20, bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Mening arizalarim', style: TextStyle(color: context.jb.ink, fontSize: 22, fontWeight: FontWeight.w800)),
          SizedBox(height: 6),
          Text('Vakansiyalarga ariza topshirgansiz', style: TextStyle(color: context.jb.gray, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, VacancyState state) {
    if (state.applicationsStatus.isInProgress && state.myApplications.isEmpty) {
      return Center(child: CircularProgressIndicator(color: context.jb.blue));
    }
    if (state.applicationsStatus == FormzSubmissionStatus.failure && state.myApplications.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off_outlined, size: 64, color: context.jb.gray),
              const SizedBox(height: 16),
              Text(
                state.error?.errorMessage ?? 'Xato yuz berdi',
                style: TextStyle(fontSize: 15, color: context.jb.gray),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.read<VacancyBloc>().add(LoadMyApplicationsEvent()),
                style: ElevatedButton.styleFrom(backgroundColor: context.jb.blue, foregroundColor: Colors.white, elevation: 0),
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
                decoration: BoxDecoration(color: context.jb.bg, borderRadius: BorderRadius.circular(20)),
                child: Icon(Icons.folder_open_outlined, size: 36, color: context.jb.gray),
              ),
              const SizedBox(height: 16),
              Text("Hozircha ariza yo'q", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: context.jb.ink)),
              const SizedBox(height: 8),
              Text(
                "Vakansiyalarga ariza yuboring\nva natijani shu yerda kuzating",
                style: TextStyle(fontSize: 13, color: context.jb.gray),
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
      color: context.jb.blue,
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
    return Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: context.jb.ink));
  }
}

// ── Application card ───────────────────────────────────────────────────────────

class _ApplicationCard extends StatelessWidget {
  final ApplicationModel application;
  final bool isUpdating;
  final void Function(String status)? onUpdateStatus;

  const _ApplicationCard({required this.application, required this.isUpdating, required this.onUpdateStatus});

  @override
  Widget build(BuildContext context) {
    final createdAt = application.createdAtDisplay;
    final hasInterview =
        application.interviewDatetime != null &&
        (application.status == 'scheduled' || application.status == 'confirmed' || application.status == 'on_way');

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: jbCardDecoration(),
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
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: context.jb.ink),
                    ),
                    const SizedBox(height: 4),
                    Text(application.companyName ?? 'Kompaniya', style: TextStyle(fontSize: 13.5, color: context.jb.gray)),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: application.statusBgColor, borderRadius: BorderRadius.circular(100)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(application.statusIcon, size: 14, color: application.statusColor),
                    const SizedBox(width: 5),
                    Text(application.statusLabel, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: application.statusColor)),
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
                color: context.jb.greenBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.jb.greenBg),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_month_rounded, size: 20, color: context.jb.green),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Suhbat belgilandi', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: context.jb.green)),
                      const SizedBox(height: 2),
                      Text(application.interviewDisplay, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: context.jb.green)),
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
                          backgroundColor: context.jb.green,
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
                          foregroundColor: context.jb.cyan,
                          side: BorderSide(color: context.jb.cyan),
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
        Icon(icon, size: 15, color: context.jb.gray),
        const SizedBox(width: 6),
        Expanded(child: Text(text, style: TextStyle(fontSize: 13, color: context.jb.gray))),
      ],
    );
  }
}
