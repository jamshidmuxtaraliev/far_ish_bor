import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/theme/jb_ui.dart';
import '../../data/models/candidate_model.dart';
import '../../data/models/employer_application_model.dart';
import '../logic/candidate_buckets.dart';
import '../logic/candidate_stages.dart';
import '../logic/vacancy_bloc.dart';
import '../screens/applicant_profile_screen.dart';
import '../screens/candidate_detail_screen.dart';
import 'candidate_card.dart'
    show confirmPaidUnlock, formatAmount, matchBucketColor;

/// PROMPT_NOMZODLAR_3TAB_MOBILE.md §12 — uch tab bitta karta tilini ulashadi:
/// ism · status/mos badge · kasb · hudud · yosh · telefon (niqob) · [Batafsil]
/// va tabga qarab harakat tugmalari.

String initialsOf(String? name) {
  final n = (name ?? '').trim();
  if (n.isEmpty) return '?';
  final parts = n.split(RegExp(r'\s+'));
  final first = parts.first.characters.first;
  final second =
      parts.length > 1 && parts[1].isNotEmpty ? parts[1].characters.first : '';
  return (first + second).toUpperCase();
}

Widget _avatar(String? name, {Color bg = JB_INDIGO_TINT, Color fg = JB_BLUE}) {
  return Container(
    width: 46,
    height: 46,
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
    alignment: Alignment.center,
    child: Text(
      initialsOf(name),
      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: fg),
    ),
  );
}

Widget _metaLine(String text) => Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 12.5, color: JB_GRAY),
    );

Widget _phoneRow({required String? phone, required String masked}) {
  final unlocked = phone != null && phone.isNotEmpty;
  return Row(
    children: [
      Icon(Icons.phone_rounded,
          size: 15, color: unlocked ? JB_GREEN_FG : JB_GRAY_LIGHT),
      const SizedBox(width: 7),
      Flexible(
        child: Text(
          unlocked ? phone : masked,
          style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: unlocked ? JB_INK : JB_GRAY),
        ),
      ),
    ],
  );
}

Widget _tone(String text, ({Color bg, Color fg}) tone) => JBChip(
      text: text,
      bg: tone.bg,
      fg: tone.fg,
      fontSize: 11.5,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    );

/// Kichik amal tugmasi (karta ichida).
Widget actionButton({
  required String label,
  required IconData icon,
  required Color color,
  required VoidCallback? onTap,
  bool outlined = false,
  bool expand = true,
}) {
  final child = outlined
      ? OutlinedButton.icon(
          onPressed: onTap,
          icon: Icon(icon, size: 15),
          label: Text(label,
              style: const TextStyle(
                  fontSize: 12.5, fontWeight: FontWeight.w700),
              overflow: TextOverflow.ellipsis),
          style: OutlinedButton.styleFrom(
            foregroundColor: color,
            side: BorderSide(color: color.withValues(alpha: 0.45), width: 1.5),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100)),
          ),
        )
      : ElevatedButton.icon(
          onPressed: onTap,
          icon: Icon(icon, size: 15),
          label: Text(label,
              style: const TextStyle(
                  fontSize: 12.5, fontWeight: FontWeight.w700),
              overflow: TextOverflow.ellipsis),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100)),
          ),
        );
  final sized = SizedBox(height: 38, child: child);
  return expand ? Expanded(child: sized) : sized;
}

// ── TAB 1 — ariza kartasi ────────────────────────────────────────────────────

/// "Ishga topshirgan nomzodlar" kartasi (§4). Telefon ochiq keladi —
/// nomzod o'zi murojaat qilgan (§4.4).
class ApplicationNomzodCard extends StatelessWidget {
  final EmployerApplicationModel app;

  /// Statusni o'zgartirish sheet'ini ochadi.
  final VoidCallback onChangeStatus;

  const ApplicationNomzodCard({
    super.key,
    required this.app,
    required this.onChangeStatus,
  });

  @override
  Widget build(BuildContext context) {
    final tone = statusTone(app.status);
    final meta = [
      if ((app.anketaJobType ?? app.requirementJobTypeName ?? '').isNotEmpty)
        (app.anketaJobType ?? app.requirementJobTypeName)!,
      if ((app.anketaRegion ?? '').isNotEmpty) app.anketaRegion!,
    ].join(' · ');

    return JBCard(
      padding: const EdgeInsets.all(16),
      border: JB_BORDER,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _avatar(app.anketaFullname),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app.anketaFullname ?? 'Nomzod',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: JB_INK),
                    ),
                    if (meta.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      _metaLine(meta),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _tone(applicationStatusLabel(app.status), tone),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 1, color: JB_DIVIDER),
          const SizedBox(height: 12),
          if ((app.requirementJobTypeName ?? '').isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.business_center_outlined,
                      size: 15, color: JB_GRAY_LIGHT),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      '${app.requirementJobTypeName} · ${app.salaryDisplay}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12.5, color: JB_GRAY),
                    ),
                  ),
                ],
              ),
            ),
          if (app.interviewDisplay.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.event_rounded,
                      size: 15, color: JB_AMBER_FG),
                  const SizedBox(width: 7),
                  Text(app.interviewDisplay,
                      style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: JB_INK)),
                ],
              ),
            ),
          _phoneRow(
            phone: app.anketaPhone,
            masked: '+998 ** *** ** **',
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              actionButton(
                label: 'Batafsil',
                icon: Icons.visibility_outlined,
                color: JB_INK,
                outlined: true,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ApplicantProfileScreen(app: app)),
                ),
              ),
              const SizedBox(width: 10),
              actionButton(
                label: 'Holatni o\'zgartirish',
                icon: Icons.swap_horiz_rounded,
                color: JB_BLUE,
                onTap: onChangeStatus,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── TAB 2 / TAB 3 — nomzod kartasi ───────────────────────────────────────────

/// Bitta nomzod qatori: nomzod + (agar bo'lsa) biriktirish + vakansiya.
class NomzodRow {
  final CandidateModel candidate;

  /// Amallar (biriktirish / kontakt ochish) shu vakansiyaga bog'lanadi.
  final int? requirementId;

  /// Biriktirish id'si (bosqichni yangilash uchun); `null` = biriktirilmagan.
  final int? assignmentId;

  /// `anketa_assignment.status`; `null` = biriktirilmagan (→ Bucket.yangi).
  final String? assignmentStatus;

  /// Belgilangan suhbat vaqti (biriktirishdan).
  final String? interviewDisplay;

  const NomzodRow({
    required this.candidate,
    this.requirementId,
    this.assignmentId,
    this.assignmentStatus,
    this.interviewDisplay,
  });
}

/// Tavsiya etilgan (§5) va Mos nomzodlar (§6) tablari uchun umumiy karta.
/// `contactGate = true` (Mos tab) → telefon yopiq, avval "Ochish" kerak.
class NomzodCard extends StatelessWidget {
  final NomzodRow row;
  final VacancyState state;
  final bool showMatch;
  final bool contactGate;

  const NomzodCard({
    super.key,
    required this.row,
    required this.state,
    this.showMatch = false,
    this.contactGate = false,
  });

  CandidateModel get c => row.candidate;

  @override
  Widget build(BuildContext context) {
    final unlocked = c.isUnlocked ||
        state.unlockedAnketaIds.contains(c.id) ||
        (c.phoneRaw ?? '').isNotEmpty;
    final phone = c.phoneRaw ?? state.unlockedPhones[c.id];
    final premium = state.contactAccess?.freeContacts ?? false;
    final fee = state.contactAccess?.fee ?? 30000;
    final busy = state.assignmentActionStatus.isInProgress ||
        state.unlockStatus.isInProgress;

    final meta = [
      if ((c.jobTypeName ?? '').isNotEmpty) c.jobTypeName!,
      if (c.region != null) c.region!.name,
      if (c.age != null) '${c.age} yosh',
    ].join(' · ');

    return JBCard(
      padding: const EdgeInsets.all(16),
      border: JB_BORDER,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _avatar(c.fullname),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.fullname ?? "Ism noma'lum",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: JB_INK),
                    ),
                    if (meta.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      _metaLine(meta),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (showMatch && c.matchPercent > 0)
                _tone(
                  '${c.matchPercent}%',
                  (
                    bg: matchBucketColor(c).withValues(alpha: 0.12),
                    fg: matchBucketColor(c)
                  ),
                )
              else
                _tone(assignmentStatusLabel(row.assignmentStatus),
                    assignmentTone(row.assignmentStatus)),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 1, color: JB_DIVIDER),
          const SizedBox(height: 12),
          if (showMatch && row.assignmentStatus != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _tone(assignmentStatusLabel(row.assignmentStatus),
                  assignmentTone(row.assignmentStatus)),
            ),
          if ((row.interviewDisplay ?? '').isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.event_rounded, size: 15, color: JB_AMBER_FG),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(row.interviewDisplay!,
                        style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: JB_INK)),
                  ),
                  if (row.assignmentId != null)
                    GestureDetector(
                      onTap: busy
                          ? null
                          : () => _reschedule(context, row.assignmentId!),
                      child: const Text("O'zgartirish",
                          style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: JB_BLUE)),
                    ),
                ],
              ),
            ),
          _phoneRow(
            phone: unlocked ? phone : null,
            masked: c.maskedPhone,
          ),
          const SizedBox(height: 14),
          ..._actions(context, unlocked, premium, fee, busy),
        ],
      ),
    );
  }

  List<Widget> _actions(BuildContext context, bool unlocked, bool premium,
      int fee, bool busy) {
    final detail = actionButton(
      label: 'Batafsil',
      icon: Icons.visibility_outlined,
      color: JB_INK,
      outlined: true,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              CandidateDetailScreen(candidateId: c.id, card: c),
        ),
      ),
    );

    // Kontakt gate (Mos tab): avval ochish (§6.4).
    if (contactGate && !unlocked && !premium) {
      return [
        Row(
          children: [
            detail,
            const SizedBox(width: 10),
            actionButton(
              label: 'Ochish · ${formatAmount(fee)}',
              icon: Icons.lock_outline_rounded,
              color: JB_BLUE,
              onTap: busy
                  ? null
                  : () => confirmPaidUnlock(context,
                      anketaId: c.id, vacancyId: row.requirementId, fee: fee),
            ),
          ],
        ),
      ];
    }
    if (contactGate && !unlocked && premium) {
      return [
        Row(
          children: [
            detail,
            const SizedBox(width: 10),
            actionButton(
              label: 'Bepul ochish',
              icon: Icons.lock_open_rounded,
              color: JB_GREEN_FG,
              onTap: busy
                  ? null
                  : () => context.read<VacancyBloc>().add(UnlockContactEvent(
                      anketaId: c.id, vacancyId: row.requirementId)),
            ),
          ],
        ),
      ];
    }

    // Bosqich harakatlari (§5.3 / PROMPT_MOS_NOMZODLAR §5).
    final status = row.assignmentStatus ?? '';
    final nexts = nextStages[status] ?? const [];
    final buttons = <Widget>[];

    if (nexts.isEmpty && row.assignmentId != null) {
      buttons.add(actionButton(
        label: 'Olib tashlash',
        icon: Icons.delete_outline_rounded,
        color: JB_GRAY,
        outlined: true,
        onTap: busy ? null : () => _confirmDelete(context, row.assignmentId!),
      ));
    }
    for (final next in nexts) {
      buttons.add(actionButton(
        label: stageActionLabel(next),
        icon: _iconFor(next),
        color: stageColor(next),
        onTap: busy
            ? null
            : () {
                if (row.assignmentId == null) {
                  _invite(context, next);
                } else {
                  context.read<VacancyBloc>().add(
                      UpdateAssignmentEvent(id: row.assignmentId!, status: next));
                }
              },
      ));
    }

    // Birinchi qator: [Batafsil] + birinchi amal; qolganlari 2 tadan.
    final rows = <Widget>[
      Row(children: [
        detail,
        if (buttons.isNotEmpty) ...[const SizedBox(width: 10), buttons.first],
      ]),
    ];
    for (var i = 1; i < buttons.length; i += 2) {
      final hasSecond = i + 1 < buttons.length;
      rows.add(const SizedBox(height: 8));
      rows.add(Row(children: [
        buttons[i],
        if (hasSecond) ...[const SizedBox(width: 10), buttons[i + 1]] else
          const Spacer(),
      ]));
    }
    return rows;
  }

  IconData _iconFor(String status) => switch (status) {
        'suhbatga_yozildi' => Icons.event_available_rounded,
        'suhbatga_bordi' => Icons.how_to_reg_rounded,
        'bormadi' => Icons.person_off_outlined,
        'qabul_qilindi' => Icons.check_circle_outline_rounded,
        'mos_kelmadi' => Icons.cancel_outlined,
        _ => Icons.arrow_forward_rounded,
      };

  // ── Suhbatga chaqirish / qayta belgilash ────────────────────────────────────

  Future<void> _invite(BuildContext context, String status) async {
    final reqId = row.requirementId;
    if (reqId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Avval vakansiyani tanlang'),
        backgroundColor: JB_AMBER_FG,
      ));
      return;
    }
    final picked = await pickSchedule(context, title: 'Suhbatga chaqirish');
    if (picked == null || !context.mounted) return; // bekor qilindi
    context.read<VacancyBloc>().add(CreateAssignmentEvent(
          anketaId: c.id,
          requirementId: reqId,
          status: status,
          interviewDatetime: picked.iso,
        ));
  }

  Future<void> _reschedule(BuildContext context, int assignmentId) async {
    final picked = await pickSchedule(context,
        title: "Vaqtni o'zgartirish", requireTime: true);
    if (picked?.dateTime == null || !context.mounted) return;
    context.read<VacancyBloc>().add(UpdateAssignmentEvent(
          id: assignmentId,
          interviewDatetime: picked!.iso,
        ));
  }

  void _confirmDelete(BuildContext context, int assignmentId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Jarayondan olib tashlash',
            style: TextStyle(fontWeight: FontWeight.w800, color: JB_INK)),
        content: const Text('Nomzodni jarayondan olib tashlaysizmi?',
            style: TextStyle(color: JB_GRAY)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Bekor', style: TextStyle(color: JB_GRAY)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context
                  .read<VacancyBloc>()
                  .add(DeleteAssignmentEvent(assignmentId));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: JB_RED_FG,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100)),
            ),
            child: const Text('Olib tashlash'),
          ),
        ],
      ),
    );
  }
}

// ── Sana/vaqt tanlash (umumiy) ───────────────────────────────────────────────

class ScheduleResult {
  final DateTime? dateTime;
  const ScheduleResult(this.dateTime);

  /// ISO 8601 (timezone'siz): `2026-07-25T09:00:00`.
  String? get iso {
    final d = dateTime;
    if (d == null) return null;
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)}T${two(d.hour)}:${two(d.minute)}:00';
  }
}

/// Sana + vaqt tanlash. `null` → bekor qilindi.
/// `requireTime = false` bo'lsa vaqtsiz ham davom etish mumkin.
Future<ScheduleResult?> pickSchedule(
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
  if (date == null) return requireTime ? null : const ScheduleResult(null);
  if (!context.mounted) return null;
  final time = await showTimePicker(
    context: context,
    initialTime: const TimeOfDay(hour: 9, minute: 0),
    helpText: title,
  );
  if (time == null) return requireTime ? null : const ScheduleResult(null);
  return ScheduleResult(
      DateTime(date.year, date.month, date.day, time.hour, time.minute));
}
