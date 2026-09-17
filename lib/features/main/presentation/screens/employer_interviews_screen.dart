import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../../../../core/theme/jb_ui.dart';
import '../../data/models/interview_model.dart';
import '../logic/interview_bloc.dart';
import '../logic/vacancy_bloc.dart';
import 'employer_track_screen.dart';
import '../../../../core/theme/jb_palette.dart';

/// Employer — "Suhbatlar" ro'yxati (Jobup24 dizayni).
///
/// Ro'yxat "Nomzodlar" ekranidagi kabi IKKI guruhga bo'linadi:
///   • Tavsiya etilgan — kontakti ochilgan / operator tavsiya qilgan nomzodlar
///     (manba: `/mobile/employer/recommended` — Nomzodlar ekranining 2-tabi)
///   • Mos nomzodlar   — qolgan suhbatlar (vakansiyaga mos nomzodlar)
///
/// ⚠️ Backend suhbat yozuvida "manba" maydonini BERMAYDI — guruh mahalliy
/// hisoblanadi: anketa `recommendedCandidates` ro'yxatida bo'lsa "Tavsiya",
/// aks holda "Mos". Shu sababli hech bir suhbat ro'yxatdan tushib qolmaydi
/// (tavsiya ro'yxati hali yuklanmagan bo'lsa hammasi "Mos"da ko'rinadi va
/// ro'yxat kelgach o'z guruhiga o'tadi).
class EmployerInterviewsScreen extends StatefulWidget {
  /// Ekran alohida marshrut sifatida ochilganda (bosh sahifadagi "Suhbatlar"
  /// kartasi) sarlavhada orqaga qaytish tugmasi kerak. Pastki menyu tabi
  /// bo'lib turgan holatda `false` — qaytadigan joy yo'q.
  final bool showBack;

  const EmployerInterviewsScreen({super.key, this.showBack = false});

  @override
  State<EmployerInterviewsScreen> createState() =>
      _EmployerInterviewsScreenState();
}

/// Suhbat guruhi — nomzod qaysi manbadan kelgan.
enum _Group { tavsiya, mos }

class _EmployerInterviewsScreenState extends State<EmployerInterviewsScreen> {
  _Group _group = _Group.tavsiya;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<InterviewBloc>();
    bloc.add(const LoadEmployerInterviewsEvent());
    // Jonli holatlarni eshitish uchun socketni ulaymiz.
    bloc.add(const ConnectSocketEvent());
    // Guruhlash uchun "Tavsiya etilgan" nomzodlar ro'yxati kerak.
    context.read<VacancyBloc>().add(LoadRecommendedCandidatesEvent());
  }

  void _load() {
    context.read<InterviewBloc>().add(const LoadEmployerInterviewsEvent());
    context.read<VacancyBloc>().add(LoadRecommendedCandidatesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.jb.overlay,
      child: Scaffold(
        backgroundColor: context.jb.bg,
        body: BlocBuilder<VacancyBloc, VacancyState>(
          buildWhen: (p, c) =>
              p.recommendedCandidates != c.recommendedCandidates,
          builder: (context, vacancy) {
            final recommendedIds = {
              for (final c in vacancy.recommendedCandidates) c.id
            };
            return BlocBuilder<InterviewBloc, InterviewState>(
              buildWhen: (p, c) =>
                  p.employerInterviews != c.employerInterviews ||
                  p.employerStatus != c.employerStatus ||
                  p.travelById != c.travelById,
              builder: (context, state) {
                final tavsiya = <InterviewModel>[];
                final mos = <InterviewModel>[];
                for (final i in state.employerInterviews) {
                  if (recommendedIds.contains(i.anketa?.id)) {
                    tavsiya.add(i);
                  } else {
                    mos.add(i);
                  }
                }
                return Column(
                  children: [
                    _header(context),
                    _groupTabs(tavsiya.length, mos.length),
                    Expanded(
                      child: _body(
                        state,
                        _group == _Group.tavsiya ? tavsiya : mos,
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  /// Tanlangan guruh ro'yxati — yuklanish / xato / bo'sh holatlari bilan.
  Widget _body(InterviewState state, List<InterviewModel> list) {
    if (state.employerStatus.isInProgress && state.employerInterviews.isEmpty) {
      return Center(child: CircularProgressIndicator(color: context.jb.blue));
    }
    if (state.employerStatus == FormzSubmissionStatus.failure &&
        state.employerInterviews.isEmpty) {
      return _JbErrorView(
        message: state.error?.errorMessage ?? 'Xato yuz berdi',
        onRetry: _load,
      );
    }
    if (list.isEmpty) {
      return _JbEmptyView(
        icon: Icons.event_busy_outlined,
        message: _group == _Group.tavsiya
            ? 'Tavsiya etilgan nomzod bilan suhbat yo\'q'
            : 'Mos nomzod bilan suhbat yo\'q',
        subtitle: _group == _Group.tavsiya
            ? 'Kontakti ochilgan nomzod bilan vaqt belgilansa shu yerda ko\'rinadi'
            : 'Vakansiyangizga mos nomzodni suhbatga chaqirsangiz shu yerda ko\'rinadi',
      );
    }

    // Yo'ldagilar tepada.
    final sorted = [...list]..sort((a, b) {
        final aw = state.travelOf(a) == 'on_way' ? 0 : 1;
        final bw = state.travelOf(b) == 'on_way' ? 0 : 1;
        return aw.compareTo(bw);
      });
    final onWayCount =
        sorted.where((i) => state.travelOf(i) == 'on_way').length;

    return RefreshIndicator(
      color: context.jb.blue,
      onRefresh: () async => _load(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        itemCount: sorted.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          if (i == 0) return _countRow(sorted.length, onWayCount);
          final interview = sorted[i - 1];
          return _EmployerInterviewCard(
            interview: interview,
            travelStatus: state.travelOf(interview),
            onTrack: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EmployerTrackScreen(interview: interview),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _countRow(int total, int onWay) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Text('$total ta suhbat',
              style: TextStyle(fontSize: 13, color: jb.gray)),
          const Spacer(),
          if (onWay > 0)
            JBChip(
              text: "$onWay ta yo'lda",
              bg: jb.amberBg,
              fg: jb.amber,
              fontSize: 11.5,
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
            ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      width: double.infinity,
      color: context.jb.card,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 18,
        left: 20,
        right: 20,
        bottom: 12,
      ),
      child: Row(
        children: [
          if (widget.showBack) ...[
            JBCircleButton(onTap: () => Navigator.of(context).maybePop()),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Suhbatlar',
                    style: TextStyle(
                        color: context.jb.ink,
                        fontSize: 22,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 3),
                Text('Rejalashtirilgan suhbatlar',
                    style: TextStyle(color: context.jb.gray, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Ikki guruh segmenti — "Nomzodlar" ekranidagi tab uslubi bilan bir xil.
  Widget _groupTabs(int tavsiyaCount, int mosCount) {
    const labels = {
      _Group.tavsiya: 'Tavsiya etilgan',
      _Group.mos: 'Mos nomzodlar',
    };
    final counts = {_Group.tavsiya: tavsiyaCount, _Group.mos: mosCount};
    return Container(
      color: context.jb.card,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: context.jb.chipBg,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          children: _Group.values.map((g) {
            final active = _group == g;
            return Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => _group = g),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: active ? context.jb.blue : Colors.transparent,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    '${labels[g]!} (${counts[g]})',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: active ? Colors.white : context.jb.gray,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
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

  /// Suhbat statusi uchun JB chip ranglari.
  (Color, Color) get _statusColors => switch (interview.status) {
        'confirmed' => (jb.blueTint, jb.blue),
        'done' => (jb.greenBg, jb.green),
        'cancelled' => (jb.redBg, jb.red),
        'no_show' => (jb.amberBg, jb.amber),
        _ => (jb.chipBg, jb.gray),
      };

  String get _initials {
    final name = (interview.anketa?.fullname ?? '').trim();
    if (name.isEmpty) return '?';
    final parts = name.split(RegExp(r'\s+'));
    final first = parts.first.characters.first;
    final second = parts.length > 1 ? parts[1].characters.first : '';
    return (first + second).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final onWay = travelStatus == 'on_way';
    final arrived = travelStatus == 'arrived';
    final (chipBg, chipFg) = _statusColors;

    return JBCard(
      padding: const EdgeInsets.all(16),
      border: onWay ? context.jb.amber.withValues(alpha: 0.35) : context.jb.border,
      onTap: onWay ? onTrack : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: onWay ? context.jb.amberTile : context.jb.blueTint,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(
                  _initials,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: onWay ? context.jb.amber : context.jb.blue,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      interview.anketa?.fullname ?? 'Nomzod',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: context.jb.ink),
                    ),
                    if ((interview.vacancyJobType ?? '').isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        interview.vacancyJobType!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 13, color: context.jb.gray),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              JBChip(
                text: interview.statusLabel,
                bg: chipBg,
                fg: chipFg,
                fontSize: 11.5,
                padding:
                    const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(height: 1, thickness: 1, color: context.jb.divider),
          const SizedBox(height: 12),
          Row(
            children: [
              JBIconTile(
                icon: Icons.schedule_rounded,
                bg: context.jb.chipBg,
                fg: context.jb.gray,
                size: 32,
                radius: 10,
                iconSize: 16,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  interview.scheduledDisplay,
                  style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: context.jb.ink),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (onWay)
            Row(
              children: [
                JBChip(
                  text: "● Yo'lda",
                  bg: context.jb.amberBg,
                  fg: context.jb.amber,
                  fontSize: 12,
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                ),
                const Spacer(),
                JBPillButton(
                  label: 'Kuzatish',
                  leadingIcon: Icons.location_searching_rounded,
                  onTap: onTrack,
                  vPadding: 10,
                  fontSize: 13.5,
                ),
              ],
            )
          else
            Row(
              children: [
                Icon(
                  arrived
                      ? Icons.check_circle_rounded
                      : Icons.event_available_rounded,
                  size: 16,
                  color: arrived ? context.jb.green : context.jb.grayLight,
                ),
                const SizedBox(width: 7),
                Text(
                  arrived ? 'Yetib keldi' : 'Rejalashtirilgan',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: arrived ? context.jb.green : context.jb.gray),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

/// JB uslubidagi bo'sh holat.
class _JbEmptyView extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? subtitle;

  const _JbEmptyView({
    required this.icon,
    required this.message,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: context.jb.blueTint,
                borderRadius: BorderRadius.circular(24),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 34, color: context.jb.blue),
            ),
            const SizedBox(height: 18),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 15.5, fontWeight: FontWeight.w700, color: context.jb.ink),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13, color: context.jb.gray, height: 1.4),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// JB uslubidagi xatolik holati.
class _JbErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _JbErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: context.jb.redBg,
                borderRadius: BorderRadius.circular(24),
              ),
              alignment: Alignment.center,
              child: Icon(Icons.cloud_off_rounded,
                  size: 34, color: context.jb.red),
            ),
            const SizedBox(height: 18),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14, color: context.jb.gray, height: 1.4),
            ),
            const SizedBox(height: 18),
            JBPillButton(
              label: 'Qayta urinish',
              leadingIcon: Icons.refresh_rounded,
              onTap: onRetry,
              vPadding: 12,
            ),
          ],
        ),
      ),
    );
  }
}
