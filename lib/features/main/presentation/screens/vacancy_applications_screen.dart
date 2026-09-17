import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../../../../core/theme/jb_palette.dart';
import '../../data/models/application_stats_model.dart';
import '../../data/models/candidate_model.dart';
import '../../data/models/contact_unlock_model.dart';
import '../../data/models/employer_vacancy_model.dart';
import '../../data/models/vacancy_applications_model.dart';
import '../logic/application_status.dart';
import '../logic/vacancy_bloc.dart';
import '../widgets/nomzod_cards.dart' show pickSchedule;
import '../widgets/otklik_actions.dart';
import 'application_history_screen.dart';
import 'candidate_detail_screen.dart';
import 'edit_employer_screen.dart';

/// Otkliklarni bo'limlarga ajratish (§3.2, §4.3 statistika qatori).
enum _Bucket { all, isNew, inProgress, hired, closed }

/// Ekran 2 — «Vakansiya otkliklari» (PROMPT_VAKANSIYA_OTKLIKLARI_MOBILE.md §4).
///
/// Bitta vakansiyaga kelgan arizalar: statistika, nomzod kartalari, kontakt
/// holati (§8), bosqichni o'zgartirish (§6) va har bir otklikning tarixi (§5).
class VacancyApplicationsScreen extends StatefulWidget {
  final int vacancyId;

  /// Ro'yxatdan kelganda sarlavhani darhol chizish uchun (ixtiyoriy).
  final String? vacancyTitle;

  const VacancyApplicationsScreen({
    super.key,
    required this.vacancyId,
    this.vacancyTitle,
  });

  @override
  State<VacancyApplicationsScreen> createState() =>
      _VacancyApplicationsScreenState();
}

class _VacancyApplicationsScreenState extends State<VacancyApplicationsScreen> {
  late int _vacancyId = widget.vacancyId;
  _Bucket _bucket = _Bucket.all;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<VacancyBloc>();
    bloc.add(LoadVacancyApplicationsEvent(_vacancyId));
    // Yuqoridagi vakansiya chip'lari va ochish narxi uchun.
    bloc.add(LoadEmployerVacanciesEvent());
    bloc.add(LoadContactAccessEvent());
  }

  void _load() =>
      context.read<VacancyBloc>().add(LoadVacancyApplicationsEvent(_vacancyId));

  void _selectVacancy(int id) {
    if (id == _vacancyId) return;
    setState(() {
      _vacancyId = id;
      _bucket = _Bucket.all;
    });
    _load();
  }

  bool _matchesBucket(String status) => switch (_bucket) {
        _Bucket.all => true,
        _Bucket.isNew => status == 'pending',
        _Bucket.hired => status == 'hired',
        _Bucket.closed => status == 'rejected' || status == 'missed',
        _Bucket.inProgress => status != 'pending' &&
            status != 'hired' &&
            status != 'rejected' &&
            status != 'missed',
      };

  @override
  Widget build(BuildContext context) {
    final p = context.jb;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: p.overlay,
      child: Scaffold(
        backgroundColor: p.bg,
        body: BlocConsumer<VacancyBloc, VacancyState>(
          listenWhen: (prev, curr) =>
              prev.updateEmpAppStatus != curr.updateEmpAppStatus ||
              prev.unlockStatus != curr.unlockStatus,
          listener: (context, state) {
            if (state.updateEmpAppStatus.isSuccess) {
              _snack(context, 'Bosqich yangilandi', color: p.green);
            } else if (state.updateEmpAppStatus.isFailure) {
              _snack(context, state.error?.errorMessage ?? 'Bosqich saqlanmadi',
                  color: Colors.red);
            } else if (state.unlockStatus.isSuccess) {
              // §8 — ochilgandan keyin ro'yxatni qayta chaqiramiz:
              // `contact_open` va `capabilities` to'ladi.
              _load();
            } else if (state.unlockStatus.isFailure) {
              if (state.error?.errorCode == 402) {
                showInsufficientBalanceDialog(
                  context,
                  candidate: state.lastUnlockAttemptId != null
                      ? _findCandidate(state, state.lastUnlockAttemptId!)
                      : null,
                  vacancyId: _vacancyId,
                );
              } else {
                _snack(context, state.error?.errorMessage ?? 'Ochilmadi',
                    color: Colors.red);
              }
            }
          },
          builder: (context, state) {
            final data = state.vacancyApplications;
            final isCurrent = data?.vacancy?.id == _vacancyId;
            final loading =
                state.vacancyApplicationsStatus.isInProgress && !isCurrent;
            final stats = isCurrent ? data!.stats : ApplicationStatsModel.empty;
            final items = isCurrent
                ? data!.items.where((e) => _matchesBucket(e.status)).toList()
                : const <VacancyApplicationModel>[];

            return Column(
              children: [
                _buildHeader(context, isCurrent ? data!.vacancy : null),
                _buildVacancyChips(state.employerVacancies),
                if (!loading) _buildStatsRow(stats),
                Expanded(
                  child: loading
                      ? Center(child: CircularProgressIndicator(color: p.blue))
                      : (!isCurrent &&
                              state.vacancyApplicationsStatus.isFailure)
                          ? _ErrorView(
                              message: state.error?.errorMessage ??
                                  'Otkliklarni olib bo\'lmadi',
                              errorCode: state.error?.errorCode,
                              onRetry: _load,
                            )
                          : RefreshIndicator(
                              color: p.blue,
                              onRefresh: () async => _load(),
                              child: items.isEmpty
                                  ? _EmptyList(bucket: _bucket)
                                  : ListView.separated(
                                      padding: const EdgeInsets.fromLTRB(
                                          16, 12, 16, 24),
                                      itemCount: items.length,
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(height: 12),
                                      itemBuilder: (_, i) => _ApplicationCard(
                                        item: items[i],
                                        contactPolicy: data?.contactPolicy,
                                        vacancyId: _vacancyId,
                                        onChangeStatus: () =>
                                            _changeStatus(items[i]),
                                        onOpenHistory: () =>
                                            _openHistory(items[i]),
                                      ),
                                    ),
                            ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  CandidateModel? _findCandidate(VacancyState state, int anketaId) {
    for (final item in state.vacancyApplications?.items ?? const []) {
      if (item.candidate?.id == anketaId) return item.candidate;
    }
    return state.findCandidate(anketaId);
  }

  Widget _buildHeader(BuildContext context, EmployerVacancyModel? vacancy) {
    final p = context.jb;
    final title = vacancy?.jobTypeName ?? widget.vacancyTitle ?? 'Otkliklar';
    return Container(
      width: double.infinity,
      color: p.card,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 8,
        right: 16,
        bottom: 12,
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new, size: 18, color: p.ink),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vakansiya otkliklari',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800, color: p.ink),
                ),
                const SizedBox(height: 2),
                Text(
                  vacancy != null
                      ? '$title · ${vacancy.salaryDisplay}'
                      : title,
                  style: TextStyle(fontSize: 12.5, color: p.gray),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// §4.3 — ekranlar orasida sakramaslik uchun vakansiya tanlash chip'lari.
  Widget _buildVacancyChips(List<EmployerVacancyModel> vacancies) {
    if (vacancies.length < 2) return const SizedBox.shrink();
    final p = context.jb;
    return Container(
      color: p.card,
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: vacancies.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final v = vacancies[i];
            final selected = v.id == _vacancyId;
            final count = v.applications.total;
            return GestureDetector(
              onTap: () => _selectVacancy(v.id),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? p.blue : p.chipBg,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  children: [
                    Text(
                      v.jobTypeName ?? 'Vakansiya #${v.id}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : p.gray,
                      ),
                    ),
                    if (count > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: selected
                              ? Colors.white.withValues(alpha: 0.25)
                              : p.card,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          '$count',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: selected ? Colors.white : p.ink,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Jami · Yangi · Jarayonda · Ishga olindi · Yopilgan — bosilganda ro'yxat
  /// shu bo'lim bo'yicha filtrlanadi.
  Widget _buildStatsRow(ApplicationStatsModel stats) {
    final p = context.jb;
    final tiles = <({_Bucket bucket, String label, int value, Color color})>[
      (bucket: _Bucket.all, label: 'Jami', value: stats.total, color: p.ink),
      (
        bucket: _Bucket.isNew,
        label: 'Yangi',
        value: stats.newCount,
        color: p.red
      ),
      (
        bucket: _Bucket.inProgress,
        label: 'Jarayonda',
        value: stats.inProgress,
        color: p.blue
      ),
      (
        bucket: _Bucket.hired,
        label: 'Ishga olindi',
        value: stats.hired,
        color: p.green
      ),
      (
        bucket: _Bucket.closed,
        label: 'Yopilgan',
        value: stats.closed,
        color: p.gray
      ),
    ];

    return Container(
      color: p.card,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Row(
        children: [
          for (final t in tiles)
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _bucket = t.bucket),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: _bucket == t.bucket
                        ? t.color.withValues(alpha: 0.12)
                        : p.cardAlt,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _bucket == t.bucket
                          ? t.color.withValues(alpha: 0.5)
                          : Colors.transparent,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${t.value}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: t.color,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        t.label,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 10.5, color: p.gray),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _openHistory(VacancyApplicationModel item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ApplicationHistoryScreen(
          applicationId: item.id,
          subtitle: item.candidateName,
        ),
      ),
    );
  }

  /// §6 — ruxsat etilgan keyingi bosqichlar. `scheduled` uchun suhbat vaqti
  /// majburiy.
  Future<void> _changeStatus(VacancyApplicationModel item) async {
    final next = nextStatusesFor(item.status);
    if (next.isEmpty) {
      _snack(context, 'Bu bosqich yakuniy');
      return;
    }
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: context.jb.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: ctx.jb.border,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Keyingi bosqich',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: ctx.jb.ink,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${item.candidateName} · '
                  '${item.statusLabel ?? applicationStatusFallbackLabel(item.status)}',
                  style: TextStyle(fontSize: 13, color: ctx.jb.gray),
                ),
              ),
            ),
            for (final status in next)
              ListTile(
                leading: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: applicationStatusColor(status)
                        .withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    applicationStatusIcon(status),
                    size: 17,
                    color: applicationStatusColor(status),
                  ),
                ),
                title: Text(
                  applicationStatusFallbackLabel(status),
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: ctx.jb.ink,
                  ),
                ),
                subtitle: status == 'scheduled'
                    ? Text(
                        'Suhbat vaqti so\'raladi',
                        style: TextStyle(fontSize: 12, color: ctx.jb.gray),
                      )
                    : null,
                onTap: () => Navigator.pop(ctx, status),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (picked == null || !mounted) return;

    String? interviewIso;
    if (picked == 'scheduled') {
      final schedule = await pickSchedule(
        context,
        title: 'Suhbat vaqti',
        requireTime: true,
      );
      if (schedule?.iso == null || !mounted) return;
      interviewIso = schedule!.iso;
    }

    context.read<VacancyBloc>().add(
          UpdateEmployerApplicationStatusEvent(
            item.id,
            picked,
            interviewDatetime: interviewIso,
            type: interviewIso != null ? 'offline' : null,
          ),
        );
  }
}

void _snack(BuildContext context, String message, {Color? color}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), backgroundColor: color ?? context.jb.amber),
  );
}

// ── Otklik kartasi ───────────────────────────────────────────────────────────

class _ApplicationCard extends StatelessWidget {
  final VacancyApplicationModel item;
  final ContactPolicyModel? contactPolicy;
  final int vacancyId;
  final VoidCallback onChangeStatus;
  final VoidCallback onOpenHistory;

  const _ApplicationCard({
    required this.item,
    required this.contactPolicy,
    required this.vacancyId,
    required this.onChangeStatus,
    required this.onOpenHistory,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.jb;
    final candidate = item.candidate;
    final tone = applicationStatusTone(item.status);
    // Serverning `contact_open` bayrog'i eng ishonchli; shu sessiyada ochilgan
    // nomzod ro'yxat yangilanmasidan ham ochiq ko'rinsin.
    final openedNow = candidate != null &&
        context.select<VacancyBloc, bool>(
            (b) => b.state.unlockedAnketaIds.contains(candidate.id));
    // ⚠ Tarif kontaktni OCHMAYDI (2026-09-17) — `free_contacts` bu yerda
    // hisobga olinmaydi. Telefon faqat otklik qilingan nomzodda ochiladi.
    final contactOpen = item.contactOpen || openedNow;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Avatar(candidate: candidate),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.candidateName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: p.ink,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: tone.bg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item.statusLabel ??
                                applicationStatusFallbackLabel(item.status),
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: tone.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      candidate?.jobTypeName ?? 'Kasb ko\'rsatilmagan',
                      style: TextStyle(fontSize: 13.5, color: p.gray),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 14,
                      runSpacing: 6,
                      children: [
                        if (candidate?.age != null)
                          _meta(context, Icons.cake_outlined,
                              '${candidate!.age} yosh'),
                        if ((candidate?.experienceYear ?? 0) > 0)
                          _meta(context, Icons.work_outline,
                              '${candidate!.experienceYear} yil tajriba'),
                        if (item.appliedDisplay.isNotEmpty)
                          _meta(context, Icons.schedule, item.appliedDisplay),
                        if (candidate?.isBlacklisted == true)
                          _meta(context, Icons.block, "Qora ro'yxat",
                              color: p.red),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (item.interviewDatetime != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.event_available_outlined, size: 15, color: p.amber),
                const SizedBox(width: 6),
                Text(
                  'Suhbat: ${item.interviewDisplay}',
                  style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: p.amber),
                ),
              ],
            ),
          ],
          if ((item.coverMessage ?? '').isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: p.cardAlt,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                item.coverMessage!,
                style: TextStyle(
                  fontSize: 13,
                  color: p.ink,
                  height: 1.45,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          // §8 — kontakt siyosati: ochiq bo'lsa telefon/chat, aks holda "Ochish".
          if (candidate != null)
            contactOpen
                ? _ContactRow(item: item, candidate: candidate)
                : _UnlockButton(
                    candidate: candidate,
                    vacancyId: vacancyId,
                    fee: contactPolicy?.fee,
                  ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onOpenHistory,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: p.ink,
                    side: BorderSide(color: p.borderStrong),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.history, size: 17),
                  label: const Text(
                    'Tarix',
                    style:
                        TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed:
                      isFinalApplicationStatus(item.status) ? null : onChangeStatus,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: p.blue,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: p.chipBg,
                    disabledForegroundColor: p.gray,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.swap_horiz_rounded, size: 17),
                  label: const Text(
                    'Bosqich',
                    style:
                        TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _meta(BuildContext context, IconData icon, String text,
      {Color? color}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color ?? context.jb.gray),
        const SizedBox(width: 4),
        Text(text,
            style:
                TextStyle(fontSize: 12.5, color: color ?? context.jb.gray)),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  final CandidateModel? candidate;
  const _Avatar({required this.candidate});

  @override
  Widget build(BuildContext context) {
    final p = context.jb;
    final photo = candidate?.photoUrl;
    return GestureDetector(
      onTap: candidate == null
          ? null
          : () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CandidateDetailScreen(
                    candidateId: candidate!.id,
                    card: candidate,
                  ),
                ),
              ),
      child: Container(
        width: 52,
        height: 52,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: p.cardAlt,
          shape: BoxShape.circle,
          border: Border.all(color: p.border),
        ),
        child: photo != null
            ? Image.network(photo, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _initials(context))
            : _initials(context),
      ),
    );
  }

  Widget _initials(BuildContext context) => Center(
        child: Text(
          candidate?.initials ?? '?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: context.jb.gray,
          ),
        ),
      );
}

/// Ochiq kontakt: telefon + chat (§4.3).
class _ContactRow extends StatelessWidget {
  final VacancyApplicationModel item;
  final CandidateModel candidate;

  const _ContactRow({required this.item, required this.candidate});

  @override
  Widget build(BuildContext context) {
    final p = context.jb;
    final caps = item.capabilities ??
        context.select<VacancyBloc, ContactCapabilitiesModel?>(
            (b) => b.state.capabilitiesOf(candidate.id));
    final phone = item.capabilities?.phone ??
        candidate.phoneRaw ??
        context.read<VacancyBloc>().state.phoneOf(candidate);
    final hasChat = caps?.hasChat ?? false;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => callCandidate(context, phone),
            style: OutlinedButton.styleFrom(
              foregroundColor: p.green,
              side: BorderSide(color: p.green.withValues(alpha: 0.4), width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100)),
            ),
            icon: const Icon(Icons.phone_rounded, size: 16),
            label: Text(
              phone ?? 'Telefon',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: hasChat
                ? () => openCandidateChat(context,
                    candidate: candidate, capabilities: caps)
                : null,
            style: OutlinedButton.styleFrom(
              foregroundColor: p.blue,
              disabledForegroundColor: p.grayLight,
              side: BorderSide(
                  color: (hasChat ? p.blue : p.grayLight)
                      .withValues(alpha: 0.4),
                  width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100)),
            ),
            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
            label: const Text(
              'Chat',
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}

/// Yopiq kontakt: `Ochish · {fee}` (§8).
class _UnlockButton extends StatelessWidget {
  final CandidateModel candidate;
  final int vacancyId;
  final int? fee;

  const _UnlockButton({
    required this.candidate,
    required this.vacancyId,
    this.fee,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.jb;
    final busy = context.select<VacancyBloc, bool>((b) =>
        b.state.unlockStatus.isInProgress &&
        b.state.lastUnlockAttemptId == candidate.id);
    final price = fee ??
        context.read<VacancyBloc>().state.feeFor(candidate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const LockedNoticeRow(),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: busy
                ? null
                : () => startUnlock(context,
                    candidate: candidate, vacancyId: vacancyId),
            style: ElevatedButton.styleFrom(
              backgroundColor: p.blue,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100)),
            ),
            icon: busy
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                : const Icon(Icons.lock_open_rounded, size: 17),
            label: Text(
              price > 0 ? "Ochish · ${formatAmount(price)} so'm" : 'Ochish',
              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyList extends StatelessWidget {
  final _Bucket bucket;
  const _EmptyList({required this.bucket});

  @override
  Widget build(BuildContext context) {
    final p = context.jb;
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 32),
      children: [
        Icon(Icons.inbox_outlined, size: 56, color: p.grayLight),
        const SizedBox(height: 14),
        Text(
          bucket == _Bucket.all
              ? 'Bu vakansiyaga hali otklik yo\'q'
              : 'Bu bo\'limda otklik yo\'q',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w600, color: p.ink),
        ),
        const SizedBox(height: 6),
        Text(
          'Nomzodlar ariza yuborishi bilan shu yerda ko\'rinadi',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: p.gray),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  /// §9 — 403 «Kompaniya topilmadi»: profil to'ldirilmagan.
  final int? errorCode;

  const _ErrorView({
    required this.message,
    required this.onRetry,
    this.errorCode,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.jb;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 44, color: p.gray),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: p.gray)),
            const SizedBox(height: 12),
            if (errorCode == 403)
              TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const EditEmployerScreen()),
                ),
                child: Text("Kompaniya ma'lumotlarini to'ldirish",
                    style: TextStyle(color: p.blue)),
              )
            else
              TextButton(
                onPressed: onRetry,
                child: Text('Qayta urinish', style: TextStyle(color: p.blue)),
              ),
          ],
        ),
      ),
    );
  }
}
