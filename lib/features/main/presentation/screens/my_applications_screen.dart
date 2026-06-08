import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../../../../core/constants/colors.dart';
import '../../data/models/application_model.dart';
import '../logic/vacancy_bloc.dart';

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
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: LIGHT_GRAY_BG,
        body: BlocConsumer<VacancyBloc, VacancyState>(
          listenWhen: (prev, curr) => prev.updateAppStatus != curr.updateAppStatus,
          listener: (context, state) {
            if (state.updateAppStatus == FormzSubmissionStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error?.errorMessage ?? 'Xato yuz berdi'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                _buildHeader(context, state),
                Expanded(child: _buildBody(context, state)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, VacancyState state) {
    final count = state.myApplications.length;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 8,
        right: 20,
        bottom: 16,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mening arizalarim',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (count > 0)
                  Text(
                    '$count ta ariza',
                    style: const TextStyle(color: Colors.white54, fontSize: 13),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => context.read<VacancyBloc>().add(LoadMyApplicationsEvent()),
            icon: const Icon(Icons.refresh, color: Colors.white54, size: 20),
          ),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.folder_open_outlined, size: 64, color: GRAY_TEXT),
            const SizedBox(height: 16),
            const Text("Hozircha ariza yo'q", style: TextStyle(fontSize: 15, color: GRAY_TEXT)),
            const SizedBox(height: 8),
            const Text(
              "Vakansiyalarga ariza yuboring\nva natijani shu yerda kuzating",
              style: TextStyle(fontSize: 12, color: GRAY_TEXT),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final active = state.myApplications.where((a) => a.isActive).toList();
    final rejected = state.myApplications.where((a) => !a.isActive).toList();

    return RefreshIndicator(
      color: PRIMARY_BLUE,
      onRefresh: () async => context.read<VacancyBloc>().add(LoadMyApplicationsEvent()),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          if (active.isNotEmpty) ...[
            _SectionHeader(title: 'Faol arizalar', count: active.length),
            const SizedBox(height: 8),
            ...active.map((a) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ApplicationCard(
                application: a,
                isUpdating: state.updateAppStatus.isInProgress,
                onUpdateStatus: (newStatus) {
                  context.read<VacancyBloc>().add(UpdateApplicationStatusEvent(a.id, newStatus));
                },
              ),
            )),
          ],
          if (rejected.isNotEmpty) ...[
            const SizedBox(height: 4),
            _SectionHeader(title: 'Rad etilgan', count: rejected.length),
            const SizedBox(height: 8),
            ...rejected.map((a) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ApplicationCard(
                application: a,
                isUpdating: false,
                onUpdateStatus: null,
              ),
            )),
          ],
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  const _SectionHeader({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: DARK_NAVY)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(color: PRIMARY_BLUE.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
          child: Text('$count', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: PRIMARY_BLUE)),
        ),
      ],
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  final ApplicationModel application;
  final bool isUpdating;
  final void Function(String status)? onUpdateStatus;

  const _ApplicationCard({
    required this.application,
    required this.isUpdating,
    required this.onUpdateStatus,
  });

  Color get _statusColor {
    switch (application.status) {
      case 'pending': return const Color(0xFFF97316);
      case 'viewed': return PRIMARY_BLUE;
      case 'invited': return const Color(0xFF7C3AED);
      case 'scheduled': return const Color(0xFF16A34A);
      case 'confirmed': return const Color(0xFF16A34A);
      case 'on_way': return const Color(0xFF0891B2);
      case 'arrived': return const Color(0xFF16A34A);
      case 'hired': return const Color(0xFF16A34A);
      case 'missed': return GRAY_TEXT;
      case 'rejected': return const Color(0xFFDC2626);
      default: return GRAY_TEXT;
    }
  }

  @override
  Widget build(BuildContext context) {
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
          // Title row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Job type icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: PRIMARY_BLUE.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.work_outline, color: PRIMARY_BLUE, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      application.jobTypeName ?? 'Kasb noma\'lum',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: DARK_NAVY),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      application.companyName ?? 'Kompaniya',
                      style: const TextStyle(fontSize: 13, color: GRAY_TEXT),
                    ),
                  ],
                ),
              ),
              // Status chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  application.statusLabel,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _statusColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Location
          if (application.locationDisplay.isNotEmpty)
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 13, color: GRAY_TEXT),
                const SizedBox(width: 4),
                Text(application.locationDisplay, style: const TextStyle(fontSize: 12, color: GRAY_TEXT)),
              ],
            ),
          if (application.locationDisplay.isNotEmpty) const SizedBox(height: 4),
          // Sent date
          if (application.createdAtDisplay.isNotEmpty)
            Row(
              children: [
                const Icon(Icons.send_outlined, size: 13, color: GRAY_TEXT),
                const SizedBox(width: 4),
                Text('Yuborilgan: ${application.createdAtDisplay}', style: const TextStyle(fontSize: 12, color: GRAY_TEXT)),
              ],
            ),
          // Interview time
          if (application.status == 'scheduled' && application.interviewDisplay.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF16A34A).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 13, color: Color(0xFF16A34A)),
                  const SizedBox(width: 6),
                  Text(
                    'Suhbat: ${application.interviewDisplay}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF16A34A)),
                  ),
                ],
              ),
            ),
          ],
          // Action buttons for seeker
          if (onUpdateStatus != null && (application.canConfirm || application.canGoOnWay)) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (application.canConfirm)
                  Expanded(
                    child: SizedBox(
                      height: 36,
                      child: ElevatedButton(
                        onPressed: isUpdating ? null : () => onUpdateStatus!('confirmed'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF16A34A),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: isUpdating
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Tasdiqlash', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                  ),
                if (application.canConfirm && application.canGoOnWay) const SizedBox(width: 8),
                if (application.canGoOnWay && application.status == 'confirmed')
                  Expanded(
                    child: SizedBox(
                      height: 36,
                      child: OutlinedButton(
                        onPressed: isUpdating ? null : () => onUpdateStatus!('on_way'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF0891B2),
                          side: const BorderSide(color: Color(0xFF0891B2)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text("Yo'ldaman", style: TextStyle(fontSize: 12)),
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
