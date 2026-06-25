import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/colors.dart';
import '../../data/models/interview_model.dart';
import '../logic/interview_bloc.dart';
import '../widgets/state_views.dart';
import 'seeker_track_screen.dart';

/// Seeker aksenti — indigo (PROMPT §3).
const Color _indigo = Color(0xFF4F46E5);

/// Seeker — "Suhbatlar" ro'yxati (PROMPT_SUHBATLAR_MOBILE.md §3.1).
class SeekerInterviewsScreen extends StatefulWidget {
  const SeekerInterviewsScreen({super.key});

  @override
  State<SeekerInterviewsScreen> createState() => _SeekerInterviewsScreenState();
}

class _SeekerInterviewsScreenState extends State<SeekerInterviewsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<InterviewBloc>().add(const LoadMyInterviewsEvent());
  }

  void _load() => context.read<InterviewBloc>().add(const LoadMyInterviewsEvent());

  Future<void> _openLink(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Havolani ochib bo\'lmadi')),
      );
    }
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
        body: Column(
          children: [
            _header(context),
            Expanded(
              child: BlocBuilder<InterviewBloc, InterviewState>(
                buildWhen: (p, c) =>
                    p.myInterviews != c.myInterviews ||
                    p.myStatus != c.myStatus ||
                    p.travelById != c.travelById,
                builder: (context, state) {
                  if (state.myStatus.isInProgress &&
                      state.myInterviews.isEmpty) {
                    return const Center(
                        child: CircularProgressIndicator(color: _indigo));
                  }
                  if (state.myStatus == FormzSubmissionStatus.failure &&
                      state.myInterviews.isEmpty) {
                    return ErrorView(
                      message: state.error?.errorMessage ?? 'Xato yuz berdi',
                      onRetry: _load,
                    );
                  }
                  if (state.myInterviews.isEmpty) {
                    return const EmptyView(
                      icon: Icons.event_busy_outlined,
                      message: 'Rejalashtirilgan suhbat yo\'q',
                      subtitle:
                          'Ish beruvchi yoki operator suhbat vaqtini belgilaganda shu yerda ko\'rinadi',
                    );
                  }
                  return RefreshIndicator(
                    color: _indigo,
                    onRefresh: () async => _load(),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                      itemCount: state.myInterviews.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) {
                        final interview = state.myInterviews[i];
                        return _SeekerInterviewCard(
                          interview: interview,
                          travelStatus: state.travelOf(interview),
                          onTrack: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  SeekerTrackScreen(interview: interview),
                            ),
                          ).then((_) => _load()),
                          onJoinOnline: () =>
                              _openLink(interview.onlineLink ?? ''),
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
        color: _indigo,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: const Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Suhbatlar',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 2),
                Text('Rejalashtirilgan suhbatlaringiz',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
          Icon(Icons.event_available_outlined, color: Colors.white70),
        ],
      ),
    );
  }
}

class _SeekerInterviewCard extends StatelessWidget {
  final InterviewModel interview;
  final String travelStatus;
  final VoidCallback onTrack;
  final VoidCallback onJoinOnline;

  const _SeekerInterviewCard({
    required this.interview,
    required this.travelStatus,
    required this.onTrack,
    required this.onJoinOnline,
  });

  @override
  Widget build(BuildContext context) {
    final isOnline = interview.isOnline;
    final onWay = travelStatus == 'on_way';
    final arrived = travelStatus == 'arrived';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CARD_BORDER),
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
                  interview.employer?.name ?? 'Kompaniya',
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
          _iconRow(Icons.calendar_month_outlined, interview.scheduledDisplay),
          const SizedBox(height: 6),
          if (isOnline)
            _iconRow(Icons.videocam_outlined, 'Onlayn suhbat')
          else
            _iconRow(Icons.location_on_outlined,
                interview.employer?.address ?? 'Manzil ko\'rsatilmagan'),
          if (travelStatus != 'idle') ...[
            const SizedBox(height: 10),
            _Pill(interview.travelLabel, interview.travelColor, filled: true),
          ],
          const SizedBox(height: 14),
          _action(isOnline, onWay, arrived),
        ],
      ),
    );
  }

  Widget _action(bool isOnline, bool onWay, bool arrived) {
    if (isOnline) {
      final hasLink = (interview.onlineLink ?? '').isNotEmpty;
      return _wideButton(
        label: 'Onlayn suhbatga ulanish',
        icon: Icons.videocam,
        color: _indigo,
        onTap: hasLink ? onJoinOnline : null,
      );
    }
    if (arrived) {
      return _wideButton(
        label: 'Yetib keldingiz 🤝',
        icon: Icons.check_circle_outline,
        color: GREEN_COLOR,
        onTap: null,
      );
    }
    if (!interview.isManageable) {
      return _wideButton(
        label: interview.statusLabel,
        icon: Icons.lock_outline,
        color: GRAY_TEXT,
        onTap: null,
      );
    }
    return _wideButton(
      label: onWay
          ? 'Lokatsiyani davom ettirish'
          : 'Yo\'lga chiqish va lokatsiyani ulashish',
      icon: onWay ? Icons.navigation : Icons.my_location,
      color: onWay ? AMBER_COLOR : _indigo,
      onTap: onTrack,
    );
  }

  Widget _wideButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          disabledBackgroundColor: color.withValues(alpha: 0.4),
          disabledForegroundColor: Colors.white,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _iconRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
  final bool filled;
  const _Pill(this.text, this.color, {this.filled = false});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: filled ? 0.15 : 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(text,
            style: TextStyle(
                fontSize: 11.5, fontWeight: FontWeight.w600, color: color)),
      );
}
