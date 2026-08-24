import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../../../../core/theme/jb_ui.dart';
import '../../../../core/utils/custom_cached_network_image.dart';
import '../../data/models/candidate_model.dart';
import '../../data/models/contact_unlock_model.dart';
import '../logic/candidate_stages.dart';
import '../logic/vacancy_bloc.dart';
import '../screens/candidate_detail_screen.dart';
import 'otklik_actions.dart';
import '../../../../core/theme/jb_palette.dart';

/// Mos foiz / bucket bo'yicha badge rangi (§5.2):
/// 🟢 auto (≥80) yashil · 🔵 operator (60–79) ko'k · ⚪ past (<60) kulrang.
Color matchBucketColor(CandidateModel c) {
  switch (c.matchBucket) {
    case 'auto':
      return jb.green;
    case 'operator':
      return jb.blue;
    case 'past':
      return jb.gray;
  }
  final p = c.matchPercent;
  if (p >= 80) return jb.green;
  if (p >= 60) return jb.blue;
  return jb.gray;
}

const _assignmentLabels = {
  'suhbatga_yozildi': 'Suhbatga yozildi',
  'suhbatga_bordi': 'Suhbatga bordi',
  'bormadi': 'Kelmadi',
  'qabul_qilindi': 'Qabul qilindi',
  'mos_kelmadi': 'Mos kelmadi',
  // Eski statuslar (orqaga moslik)
  'yangi': 'Yangi',
  'ko\'rib_chiqilmoqda': "Ko'rib chiqilmoqda",
  'rad_etildi': 'Rad etildi',
};

String assignmentLabel(String status) => _assignmentLabels[status] ?? status;

/// Kontakt ochilganda muvaffaqiyat sheet'i, 402 da esa to'lov oynasini
/// ko'rsatadigan wrapper (PROMPT_OTKLIK §4, §10). Nomzod kartalari bo'lgan
/// ekranni shu bilan o'rang.
class CandidateUnlockListener extends StatelessWidget {
  final Widget child;
  const CandidateUnlockListener({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<VacancyBloc, VacancyState>(
      listenWhen: (prev, curr) => prev.unlockStatus != curr.unlockStatus,
      listener: (context, state) {
        if (state.unlockStatus.isSuccess && state.unlockResult != null) {
          final id = state.unlockResult!.anketaId != 0
              ? state.unlockResult!.anketaId
              : state.lastUnlockAttemptId;
          showUnlockSuccessSheet(
            context,
            state.unlockResult!,
            candidate: id != null ? state.findCandidate(id) : null,
          );
        } else if (state.unlockStatus.isFailure) {
          if (state.error?.errorCode == 402) {
            final id = state.lastUnlockAttemptId;
            showInsufficientBalanceDialog(
              context,
              candidate: id != null ? state.findCandidate(id) : null,
              fee: state.contactAccess?.fee,
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error?.errorMessage ?? 'Xatolik'),
                backgroundColor: context.jb.red,
              ),
            );
          }
        }
      },
      child: child,
    );
  }
}

/// §4.3 — ochilgach darhol uchta imkoniyat ko'rsatiladi.
void showUnlockSuccessSheet(
  BuildContext context,
  ContactUnlockResultModel result, {
  CandidateModel? candidate,
}) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    backgroundColor: context.jb.card,
    builder: (sheetCtx) => Padding(
      padding: EdgeInsets.fromLTRB(
          24, 24, 24, MediaQuery.of(sheetCtx).padding.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
                color: context.jb.greenBg, shape: BoxShape.circle),
            child: Icon(Icons.lock_open_rounded,
                color: context.jb.green, size: 30),
          ),
          const SizedBox(height: 16),
          Text('Nomzod ochildi!',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w800, color: context.jb.ink)),
          const SizedBox(height: 8),
          Text(
            result.phone,
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: context.jb.blue,
                letterSpacing: 1),
          ),
          if (result.additionalContact != null) ...[
            const SizedBox(height: 4),
            Text(result.additionalContact!,
                style: TextStyle(fontSize: 14, color: context.jb.gray)),
          ],
          const SizedBox(height: 8),
          if (result.charged && !result.free && result.fee > 0)
            Text(
              "${formatAmount(result.fee)} so'm yechildi"
              "${result.balance != null ? ' • Qolgan balans: ${formatAmount(result.balance!)} so\'m' : ''}",
              style: TextStyle(fontSize: 12, color: context.jb.gray),
              textAlign: TextAlign.center,
            )
          else
            Text('Bepul ochildi',
                style: TextStyle(fontSize: 12, color: context.jb.green)),
          const SizedBox(height: 18),
          if (candidate != null)
            UnlockedActionsRow(candidate: candidate, phone: result.phone),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(sheetCtx),
              child: Text('Yopish', style: TextStyle(color: context.jb.gray)),
            ),
          ),
        ],
      ),
    ),
  );
}

// ── Nomzod kartasi (§3.3 yopiq / §6 ochilgan) ────────────────────────────────

class CandidateCard extends StatelessWidget {
  final CandidateModel candidate;
  final bool isRecommended;
  final int? vacancyId;

  const CandidateCard({
    super.key,
    required this.candidate,
    this.isRecommended = false,
    this.vacancyId,
  });

  /// Yopiq kartada **hudud ko'rsatilmaydi** (§3.3) — server uni yubormaydi ham.
  String _metaLine({required bool unlocked}) {
    final parts = <String>[
      if ((candidate.jobTypeName ?? '').isNotEmpty) candidate.jobTypeName!,
      if (unlocked && candidate.region != null) candidate.region!.name,
      if (candidate.age != null) '${candidate.age} yosh',
      if (candidate.genderLabel.isNotEmpty) candidate.genderLabel,
    ];
    return parts.isEmpty ? '—' : parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VacancyBloc, VacancyState>(
      builder: (context, vacState) {
        final isUnlocked = vacState.isUnlocked(candidate);
        final phone = vacState.phoneOf(candidate);
        final isUnlocking = vacState.unlockStatus.isInProgress;
        final isFree = isRecommended || vacState.isFreeUnlock(candidate);
        final fee = vacState.feeFor(candidate);
        final experience = candidate.experienceYear;

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: jbCardDecoration(
            radius: 18,
            border: isRecommended
                ? context.jb.violet.withValues(alpha: 0.28)
                : context.jb.border,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Yopiq kartada foto yo'q → ism bosh harflari (§3.3).
                  _Avatar(candidate: candidate, showPhoto: isUnlocked),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          candidate.fullname ?? "Ism noma'lum",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                              color: context.jb.ink),
                        ),
                        const SizedBox(height: 4),
                        Text(_metaLine(unlocked: isUnlocked),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 12.5, color: context.jb.gray)),
                        if (experience != null && experience > 0) ...[
                          const SizedBox(height: 3),
                          Text('Tajriba: $experience yil',
                              style: TextStyle(
                                  fontSize: 12.5, color: context.jb.gray)),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (isRecommended)
                    _Badge('Operator tavsiyasi', context.jb.violet)
                  else if (candidate.matchPercent > 0)
                    _Badge('${candidate.matchPercent}%',
                        matchBucketColor(candidate)),
                ],
              ),
              if (isRecommended && candidate.assignment != null) ...[
                const SizedBox(height: 8),
                Text(
                  assignmentLabel(candidate.assignment!.status),
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: context.jb.violet),
                ),
              ],
              const SizedBox(height: 12),
              if (isUnlocked)
                _PhoneRow(phone: phone)
              else
                const LockedNoticeRow(),
              const SizedBox(height: 12),
              if (isUnlocked) ...[
                UnlockedActionsRow(
                  candidate: candidate,
                  requirementId: vacancyId,
                  phone: phone,
                  busy: vacState.assignmentActionStatus.isInProgress,
                ),
                const SizedBox(height: 8),
                _DetailButton(candidate: candidate, expand: true),
              ] else
                Row(
                  children: [
                    Expanded(child: _DetailButton(candidate: candidate)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: UnlockButton(
                        candidate: candidate,
                        isUnlocking: isUnlocking,
                        isFree: isFree,
                        fee: fee,
                        vacancyId: vacancyId,
                      ),
                    ),
                  ],
                ),
              if (isRecommended && candidate.assignment != null)
                _StageControl(assignment: candidate.assignment!),
            ],
          ),
        );
      },
    );
  }
}

// ── Karta ichi kichik widgetlar ───────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final CandidateModel candidate;
  final bool showPhoto;
  const _Avatar({required this.candidate, required this.showPhoto});

  @override
  Widget build(BuildContext context) {
    final url = showPhoto ? candidate.photoUrl : null;
    if (url != null) {
      return CustomCachedNetworkImage(
        url: url,
        width: 46,
        height: 46,
        fit: BoxFit.cover,
        forUserImages: true,
        borderRadius: BorderRadius.circular(14),
      );
    }
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: context.jb.blueTint,
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: Alignment.center,
      child: Text(
        candidate.initials,
        style: TextStyle(
            fontSize: 15, fontWeight: FontWeight.w800, color: context.jb.blue),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  const _Badge(this.text, this.color);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(text,
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w700, color: color)),
      );
}

class _PhoneRow extends StatelessWidget {
  final String? phone;
  const _PhoneRow({required this.phone});

  @override
  Widget build(BuildContext context) {
    final value = (phone ?? '').isNotEmpty ? phone! : '—';
    return Row(
      children: [
        Icon(Icons.phone_rounded, size: 15, color: context.jb.green),
        const SizedBox(width: 7),
        Flexible(
          child: Text(value,
              style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: context.jb.ink)),
        ),
      ],
    );
  }
}

class _DetailButton extends StatelessWidget {
  final CandidateModel candidate;
  final bool expand;
  const _DetailButton({required this.candidate, this.expand = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      width: expand ? double.infinity : null,
      child: OutlinedButton.icon(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CandidateDetailScreen(
                candidateId: candidate.id, card: candidate),
          ),
        ),
        icon: const Icon(Icons.visibility_outlined, size: 15),
        style: OutlinedButton.styleFrom(
          foregroundColor: context.jb.ink,
          side: BorderSide(color: context.jb.border, width: 1.5),
          padding: EdgeInsets.zero,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        ),
        label: const Text('Batafsil',
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

/// "Ochish · 30 000" / "Bepul ochish" / "Ochilmoqda…" (§12 lug'ati).
class UnlockButton extends StatelessWidget {
  final CandidateModel candidate;
  final bool isUnlocking;
  final bool isFree;
  final int fee;
  final int? vacancyId;

  const UnlockButton({
    super.key,
    required this.candidate,
    required this.isUnlocking,
    required this.isFree,
    required this.fee,
    this.vacancyId,
  });

  @override
  Widget build(BuildContext context) {
    final label = isUnlocking
        ? 'Ochilmoqda…'
        : (isFree ? 'Bepul ochish' : 'Ochish · ${formatAmount(fee)}');

    return SizedBox(
      height: 38,
      child: ElevatedButton.icon(
        onPressed: isUnlocking
            ? null
            : () => startUnlock(context,
                candidate: candidate, vacancyId: vacancyId),
        icon: isUnlocking
            ? const SizedBox(
                width: 13,
                height: 13,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
            : Icon(isFree ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
                size: 15),
        label: Text(label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
        style: ElevatedButton.styleFrom(
          backgroundColor: isFree ? context.jb.green : context.jb.blue,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.zero,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        ),
      ),
    );
  }
}

/// Tavsiya tab kartasidagi ketma-ket bosqich boshqaruvi (§3.1):
/// joriy bosqichdan faqat ruxsat etilgan keyingilarga o'tkazadi.
class _StageControl extends StatelessWidget {
  final CandidateAssignmentModel assignment;
  const _StageControl({required this.assignment});

  @override
  Widget build(BuildContext context) {
    final nexts = nextStages[assignment.status] ?? const [];
    if (nexts.isEmpty) return const SizedBox.shrink();

    return BlocBuilder<VacancyBloc, VacancyState>(
      buildWhen: (p, c) =>
          p.assignmentActionStatus != c.assignmentActionStatus,
      builder: (context, state) {
        final busy = state.assignmentActionStatus.isInProgress;
        return Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: nexts.map((next) {
              final color = stageColor(next);
              return OutlinedButton(
                onPressed: busy
                    ? null
                    : () => context.read<VacancyBloc>().add(
                        UpdateAssignmentEvent(id: assignment.id, status: next)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: color,
                  side: BorderSide(color: color.withValues(alpha: 0.5)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100)),
                ),
                child: Text(stageActionLabel(next),
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600)),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
