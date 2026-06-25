import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../../../../core/constants/colors.dart';
import '../../data/models/employer_vacancy_model.dart';
import '../../data/models/pipeline_model.dart';
import '../logic/candidate_stages.dart';
import '../logic/vacancy_bloc.dart';
import 'candidate_card.dart' show confirmPaidUnlock, formatAmount, matchBucketColor;
import 'state_views.dart';

/// "Mos nomzodlar" Kanban (PROMPT_MOS_NOMZODLAR_MOBILE.md §3.2):
/// vakansiya chiplari + 6 bosqich ustuni. Ko'chirish ketma-ket tugmalar bilan
/// (mobil yo'l, §7).
class PipelineKanban extends StatefulWidget {
  final VacancyState state;
  const PipelineKanban({super.key, required this.state});

  @override
  State<PipelineKanban> createState() => _PipelineKanbanState();
}

class _PipelineKanbanState extends State<PipelineKanban> {
  int? _selectedReqId;

  PipelineModel get _pipeline => widget.state.pipeline ?? const PipelineModel();

  EmployerVacancyModel? get _selectedReq {
    final reqs = _pipeline.requirements;
    if (reqs.isEmpty) return null;
    final id = _selectedReqId;
    return reqs.firstWhere((r) => r.id == id, orElse: () => reqs.first);
  }

  @override
  Widget build(BuildContext context) {
    final reqs = _pipeline.requirements;
    if (reqs.isEmpty) {
      return const EmptyView(
        icon: Icons.work_outline,
        message: 'Avval vakansiya joylashtiring',
        subtitle: 'Vakansiya qo\'shsangiz, mos nomzodlar shu yerda ko\'rinadi',
      );
    }

    final req = _selectedReq!;
    final columns = _pipeline.columnsFor(req.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _vacancyChips(reqs, req.id),
        const Divider(height: 1, color: CARD_BORDER),
        Expanded(child: _board(columns, req.id)),
      ],
    );
  }

  // ── Vakansiya chiplari ────────────────────────────────────────────────────────

  Widget _vacancyChips(List<EmployerVacancyModel> reqs, int activeId) {
    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: reqs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final r = reqs[i];
          final active = r.id == activeId;
          final count = _pipeline.candidatesOf(r.id).length;
          return GestureDetector(
            onTap: () => setState(() => _selectedReqId = r.id),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: active ? PRIMARY_BLUE : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: active ? PRIMARY_BLUE : CARD_BORDER),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    r.jobTypeName ?? 'Vakansiya',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: active ? Colors.white : DARK_NAVY,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: active
                          ? Colors.white.withValues(alpha: 0.22)
                          : LIGHT_GRAY_BG,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('$count',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: active ? Colors.white : GRAY_TEXT)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Ustunlar ──────────────────────────────────────────────────────────────────

  Widget _board(Map<String, List<PipelineColumnItem>> columns, int reqId) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      itemCount: kanbanColumns.length,
      separatorBuilder: (_, __) => const SizedBox(width: 12),
      itemBuilder: (context, i) {
        final status = kanbanColumns[i];
        final items = columns[status] ?? const [];
        return _column(status, items, reqId);
      },
    );
  }

  Widget _column(String status, List<PipelineColumnItem> items, int reqId) {
    final color = stageColor(status);
    return SizedBox(
      width: 280,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
              border: Border(left: BorderSide(color: color, width: 3)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(columnTitle(status),
                      style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: color)),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('${items.length}',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: color)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: items.isEmpty
                ? const _EmptyColumn()
                : ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) => PipelineCard(
                      item: items[i],
                      requirementId: reqId,
                      state: widget.state,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _EmptyColumn extends StatelessWidget {
  const _EmptyColumn();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: LIGHT_GRAY_BG,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CARD_BORDER),
      ),
      child: const Text('Bo\'sh',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12.5, color: GRAY_TEXT)),
    );
  }
}

// ── Kanban kartasi ─────────────────────────────────────────────────────────────

class PipelineCard extends StatelessWidget {
  final PipelineColumnItem item;
  final int requirementId;
  final VacancyState state;

  const PipelineCard({
    super.key,
    required this.item,
    required this.requirementId,
    required this.state,
  });

  String _metaLine() {
    final c = item.candidate;
    final parts = <String>[
      (c.jobTypeName != null && c.jobTypeName!.isNotEmpty) ? c.jobTypeName! : '—',
      if (c.region != null) c.region!.name,
      if (c.age != null) '${c.age} yosh',
    ];
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final c = item.candidate;
    final a = item.assignment;
    final status = a?.status ?? '';

    final phone = c.phoneRaw ?? state.unlockedPhones[c.id];
    final isUnlocked =
        c.isUnlocked || state.unlockedAnketaIds.contains(c.id);
    final premium = state.contactAccess?.freeContacts ?? false;
    final fee = state.contactAccess?.fee ?? 30000;
    final busy = state.assignmentActionStatus.isInProgress ||
        state.unlockStatus.isInProgress;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CARD_BORDER),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(c.fullname ?? "Ism noma'lum",
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: DARK_NAVY)),
              ),
              if (c.matchPercent > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: matchBucketColor(c).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('${c.matchPercent}%',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: matchBucketColor(c))),
                ),
              ],
            ],
          ),
          const SizedBox(height: 5),
          Text(_metaLine(),
              style: const TextStyle(fontSize: 12, color: GRAY_TEXT)),
          if (a != null && a.candidateResponse != 'pending') ...[
            const SizedBox(height: 6),
            _responseBadge(a.candidateResponse),
          ],
          const SizedBox(height: 8),
          _phoneRow(isUnlocked ? phone : null, c.maskedPhone),
          if (status == 'suhbatga_yozildi' && a != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.event, size: 14, color: GRAY_TEXT),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(a.interviewDisplay,
                      style: const TextStyle(fontSize: 12, color: DARK_NAVY)),
                ),
                GestureDetector(
                  onTap: busy ? null : () => _reschedule(context, a.id),
                  child: const Text('O\'zgartirish',
                      style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: PRIMARY_BLUE)),
                ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          ..._actions(context, status, c.id, a?.id, isUnlocked, premium, fee,
              busy),
        ],
      ),
    );
  }

  Widget _responseBadge(String response) {
    final b = candidateResponseBadge(response);
    if (b == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: b.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(b.icon, size: 12, color: b.color),
          const SizedBox(width: 4),
          Text(b.label,
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w600, color: b.color)),
        ],
      ),
    );
  }

  Widget _phoneRow(String? phone, String masked) {
    final unlocked = phone != null && phone.isNotEmpty;
    return Row(
      children: [
        Icon(Icons.phone, size: 14, color: unlocked ? GREEN_COLOR : GRAY_TEXT),
        const SizedBox(width: 6),
        Flexible(
          child: Text(unlocked ? phone : masked,
              style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: unlocked ? DARK_NAVY : GRAY_TEXT)),
        ),
      ],
    );
  }

  // ── Tugmalar (ketma-ket bosqich + kontakt + olib tashlash) ───────────────────

  List<Widget> _actions(
    BuildContext context,
    String status,
    int anketaId,
    int? assignmentId,
    bool isUnlocked,
    bool premium,
    int fee,
    bool busy,
  ) {
    final widgets = <Widget>[];

    // Matched ustun: kontakt gate + "Suhbatga chaqirish".
    if (status == '') {
      if (!isUnlocked && !premium) {
        widgets.add(_btn(
          label: 'Ochish · ${formatAmount(fee)}',
          icon: Icons.lock_outline,
          color: PRIMARY_BLUE,
          onTap: busy
              ? null
              : () => confirmPaidUnlock(context,
                  anketaId: anketaId, vacancyId: requirementId, fee: fee),
        ));
        widgets.add(const SizedBox(height: 7));
      } else if (!isUnlocked && premium) {
        widgets.add(_btn(
          label: 'Bepul ochish',
          icon: Icons.lock_open,
          color: GREEN_COLOR,
          onTap: busy
              ? null
              : () => context.read<VacancyBloc>().add(UnlockContactEvent(
                  anketaId: anketaId, vacancyId: requirementId)),
        ));
        widgets.add(const SizedBox(height: 7));
      }
      widgets.add(_btn(
        label: 'Suhbatga chaqirish',
        icon: Icons.event_available,
        color: stageColor('suhbatga_yozildi'),
        onTap: busy ? null : () => _invite(context, anketaId),
      ));
      return widgets;
    }

    // Biriktirilgan: ketma-ket keyingi bosqichlar.
    final nexts = nextStages[status] ?? const [];
    for (final next in nexts) {
      widgets.add(_btn(
        label: stageActionLabel(next),
        icon: _iconFor(next),
        color: stageColor(next),
        onTap: (busy || assignmentId == null)
            ? null
            : () => context
                .read<VacancyBloc>()
                .add(UpdateAssignmentEvent(id: assignmentId, status: next)),
      ));
      widgets.add(const SizedBox(height: 7));
    }
    if (widgets.isNotEmpty) widgets.removeLast();

    // Yakuniy bosqichlar: jarayondan olib tashlash.
    if (nexts.isEmpty && assignmentId != null) {
      widgets.add(_btn(
        label: 'Olib tashlash',
        icon: Icons.delete_outline,
        color: GRAY_TEXT,
        outlined: true,
        onTap: busy ? null : () => _confirmDelete(context, assignmentId),
      ));
    }
    return widgets;
  }

  IconData _iconFor(String status) => switch (status) {
        'suhbatga_yozildi' => Icons.event_available,
        'suhbatga_bordi' => Icons.how_to_reg,
        'bormadi' => Icons.person_off_outlined,
        'qabul_qilindi' => Icons.check_circle_outline,
        'mos_kelmadi' => Icons.cancel_outlined,
        _ => Icons.arrow_forward,
      };

  Widget _btn({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback? onTap,
    bool outlined = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 34,
      child: outlined
          ? OutlinedButton.icon(
              onPressed: onTap,
              icon: Icon(icon, size: 15),
              label: Text(label,
                  style: const TextStyle(fontSize: 12.5),
                  overflow: TextOverflow.ellipsis),
              style: OutlinedButton.styleFrom(
                foregroundColor: color,
                side: BorderSide(color: color.withValues(alpha: 0.5)),
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            )
          : ElevatedButton.icon(
              onPressed: onTap,
              icon: Icon(icon, size: 15),
              label: Text(label,
                  style: const TextStyle(fontSize: 12.5),
                  overflow: TextOverflow.ellipsis),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
    );
  }

  // ── Suhbatga chaqirish / qayta belgilash ─────────────────────────────────────

  Future<void> _invite(BuildContext context, int anketaId) async {
    final result = await _pickSchedule(context, title: 'Suhbatga chaqirish');
    if (result == null || !context.mounted) return; // bekor qilindi
    context.read<VacancyBloc>().add(CreateAssignmentEvent(
          anketaId: anketaId,
          requirementId: requirementId,
          interviewDatetime: result.isoOrNull,
        ));
  }

  Future<void> _reschedule(BuildContext context, int assignmentId) async {
    final result =
        await _pickSchedule(context, title: 'Vaqtni o\'zgartirish', requireTime: true);
    if (result == null || result.dateTime == null || !context.mounted) return;
    context.read<VacancyBloc>().add(UpdateAssignmentEvent(
          id: assignmentId,
          interviewDatetime: result.isoOrNull,
        ));
  }

  void _confirmDelete(BuildContext context, int assignmentId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Jarayondan olib tashlash',
            style: TextStyle(fontWeight: FontWeight.bold, color: DARK_NAVY)),
        content: const Text('Nomzodni jarayondan olib tashlaysizmi?',
            style: TextStyle(color: GRAY_TEXT)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Bekor', style: TextStyle(color: GRAY_TEXT)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<VacancyBloc>().add(DeleteAssignmentEvent(assignmentId));
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: RED_COLOR, foregroundColor: Colors.white),
            child: const Text('Olib tashlash'),
          ),
        ],
      ),
    );
  }

  /// Sana+vaqt tanlash. `null` → bekor qilindi. `requireTime=false` bo'lsa
  /// foydalanuvchi vaqtsiz ("Vaqtsiz") chaqirishi mumkin.
  Future<_ScheduleResult?> _pickSchedule(
    BuildContext context, {
    required String title,
    bool requireTime = false,
  }) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 180)),
      initialDate: now,
      helpText: title,
    );
    if (date == null) {
      // Vaqtsiz chaqirishga ruxsat (faqat yaratishda).
      return requireTime ? null : const _ScheduleResult(null);
    }
    if (!context.mounted) return null;
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
      helpText: title,
    );
    if (time == null) return requireTime ? null : const _ScheduleResult(null);
    return _ScheduleResult(DateTime(
        date.year, date.month, date.day, time.hour, time.minute));
  }
}

class _ScheduleResult {
  final DateTime? dateTime;
  const _ScheduleResult(this.dateTime);

  /// ISO 8601 (timezone'siz): `2026-06-23T09:00:00`.
  String? get isoOrNull {
    final d = dateTime;
    if (d == null) return null;
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)}T${two(d.hour)}:${two(d.minute)}:00';
  }
}
