import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../../../../core/constants/colors.dart';
import '../../data/models/interview_model.dart';
import '../logic/interview_bloc.dart';
import '../widgets/state_views.dart';
import 'employer_track_screen.dart';

/// Employer — "Suhbatlar" ro'yxati (PROMPT_SUHBATLAR_MOBILE.md §3.3).
class EmployerInterviewsScreen extends StatefulWidget {
  const EmployerInterviewsScreen({super.key});

  @override
  State<EmployerInterviewsScreen> createState() =>
      _EmployerInterviewsScreenState();
}

class _EmployerInterviewsScreenState extends State<EmployerInterviewsScreen> {
  @override
  void initState() {
    super.initState();
    final bloc = context.read<InterviewBloc>();
    bloc.add(const LoadEmployerInterviewsEvent());
    // Jonli holatlarni eshitish uchun socketni ulaymiz.
    bloc.add(const ConnectSocketEvent());
  }

  void _load() =>
      context.read<InterviewBloc>().add(const LoadEmployerInterviewsEvent());

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
        body: Column(
          children: [
            _header(context),
            Expanded(
              child: BlocBuilder<InterviewBloc, InterviewState>(
                buildWhen: (p, c) =>
                    p.employerInterviews != c.employerInterviews ||
                    p.employerStatus != c.employerStatus ||
                    p.travelById != c.travelById,
                builder: (context, state) {
                  if (state.employerStatus.isInProgress &&
                      state.employerInterviews.isEmpty) {
                    return const Center(
                        child: CircularProgressIndicator(color: PRIMARY_BLUE));
                  }
                  if (state.employerStatus == FormzSubmissionStatus.failure &&
                      state.employerInterviews.isEmpty) {
                    return ErrorView(
                      message: state.error?.errorMessage ?? 'Xato yuz berdi',
                      onRetry: _load,
                    );
                  }
                  if (state.employerInterviews.isEmpty) {
                    return const EmptyView(
                      icon: Icons.event_busy_outlined,
                      message: 'Hozircha rejalashtirilgan suhbat yo\'q',
                      subtitle:
                          'Operator yoki siz vaqt belgilaganda shu yerda ko\'rinadi',
                    );
                  }
                  // Yo'ldagilar tepada.
                  final list = [...state.employerInterviews]..sort((a, b) {
                      final aw = state.travelOf(a) == 'on_way' ? 0 : 1;
                      final bw = state.travelOf(b) == 'on_way' ? 0 : 1;
                      return aw.compareTo(bw);
                    });
                  return RefreshIndicator(
                    color: PRIMARY_BLUE,
                    onRefresh: () async => _load(),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) {
                        final interview = list[i];
                        return _EmployerInterviewCard(
                          interview: interview,
                          travelStatus: state.travelOf(interview),
                          onTrack: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  EmployerTrackScreen(interview: interview),
                            ),
                          ),
                        );
                      },
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

  Widget _header(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 18,
      ),
      decoration: const BoxDecoration(
        color: DARK_NAVY,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Suhbatlar',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 2),
                Text('Rejalashtirilgan suhbatlar',
                    style: TextStyle(color: Colors.white54, fontSize: 13)),
              ],
            ),
          ),
          BlocBuilder<InterviewBloc, InterviewState>(
            buildWhen: (p, c) => p.socketConnected != c.socketConnected,
            builder: (context, state) => Icon(
              state.socketConnected ? Icons.wifi_tethering : Icons.wifi_off,
              color: state.socketConnected
                  ? const Color(0xFF34D399)
                  : Colors.white38,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmployerInterviewCard extends StatelessWidget {
  final InterviewModel interview;
  final String travelStatus;
  final VoidCallback onTrack;

  const _EmployerInterviewCard({
    required this.interview,
    required this.travelStatus,
    required this.onTrack,
  });

  @override
  Widget build(BuildContext context) {
    final onWay = travelStatus == 'on_way';
    final arrived = travelStatus == 'arrived';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: onWay ? AMBER_COLOR.withValues(alpha: 0.08) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: onWay ? AMBER_COLOR.withValues(alpha: 0.4) : CARD_BORDER),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  interview.anketa?.fullname ?? 'Nomzod',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: DARK_NAVY),
                ),
              ),
              _Pill(interview.statusLabel, interview.statusColor),
            ],
          ),
          const SizedBox(height: 10),
          if ((interview.vacancyJobType ?? '').isNotEmpty) ...[
            _iconRow(Icons.work_outline, interview.vacancyJobType!),
            const SizedBox(height: 6),
          ],
          _iconRow(Icons.schedule, interview.scheduledDisplay),
          const SizedBox(height: 14),
          if (onWay)
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AMBER_COLOR.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.sensors, size: 14, color: AMBER_COLOR),
                      SizedBox(width: 5),
                      Text('Yo\'lda',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AMBER_COLOR)),
                    ],
                  ),
                ),
                const Spacer(),
                SizedBox(
                  height: 40,
                  child: ElevatedButton.icon(
                    onPressed: onTrack,
                    icon: const Icon(Icons.location_searching, size: 16),
                    label: const Text('Kuzatish',
                        style: TextStyle(
                            fontSize: 13.5, fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AMBER_COLOR,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                Icon(arrived ? Icons.check_circle : Icons.event_available,
                    size: 16, color: arrived ? GREEN_COLOR : GRAY_TEXT),
                const SizedBox(width: 6),
                Text(arrived ? 'Yetib keldi' : 'Rejalashtirilgan',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: arrived ? GREEN_COLOR : GRAY_TEXT)),
              ],
            ),
        ],
      ),
    );
  }

  Widget _iconRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: GRAY_TEXT),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text,
              style: const TextStyle(fontSize: 13.5, color: DARK_NAVY)),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final Color color;
  const _Pill(this.text, this.color);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(text,
            style: TextStyle(
                fontSize: 11.5, fontWeight: FontWeight.w600, color: color)),
      );
}
