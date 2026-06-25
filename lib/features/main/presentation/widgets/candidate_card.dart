import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../../../../core/constants/colors.dart';
import '../../../billing/presentation/screens/topup_screen.dart';
import '../../data/models/candidate_model.dart';
import '../../data/models/contact_unlock_model.dart';
import '../logic/candidate_stages.dart';
import '../logic/vacancy_bloc.dart';
import '../screens/candidate_detail_screen.dart';

/// Mos foiz / bucket bo'yicha badge rangi (§5.2):
/// 🟢 auto (≥80) yashil · 🔵 operator (60–79) ko'k · ⚪ past (<60) kulrang.
Color matchBucketColor(CandidateModel c) {
  switch (c.matchBucket) {
    case 'auto':
      return const Color(0xFF16A34A);
    case 'operator':
      return PRIMARY_BLUE;
    case 'past':
      return GRAY_TEXT;
  }
  final p = c.matchPercent;
  if (p >= 80) return const Color(0xFF16A34A);
  if (p >= 60) return PRIMARY_BLUE;
  return GRAY_TEXT;
}

const _assignmentLabels = {
  'suhbatga_yozildi': 'Suhbatga yozildi',
  'suhbatga_bordi': 'Suhbatga bordi',
  'bormadi': 'Bormadi',
  'qabul_qilindi': 'Qabul qilindi',
  'mos_kelmadi': 'Mos kelmadi',
  // Eski statuslar (orqaga moslik)
  'yangi': 'Yangi',
  'ko\'rib_chiqilmoqda': "Ko'rib chiqilmoqda",
  'rad_etildi': 'Rad etildi',
};

String assignmentLabel(String status) => _assignmentLabels[status] ?? status;

/// Kontakt ochilganda muvaffaqiyat sheet / balans yetmaganida dialog ko'rsatadigan
/// wrapper. Nomzod kartalari bo'lgan ekranni shu bilan o'rang.
class CandidateUnlockListener extends StatelessWidget {
  final Widget child;
  const CandidateUnlockListener({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<VacancyBloc, VacancyState>(
      listenWhen: (prev, curr) => prev.unlockStatus != curr.unlockStatus,
      listener: (context, state) {
        if (state.unlockStatus.isSuccess && state.unlockResult != null) {
          showUnlockSuccessSheet(context, state.unlockResult!);
        } else if (state.unlockStatus.isFailure) {
          final isInsufficientBalance = state.error?.errorCode == 402;
          if (isInsufficientBalance) {
            showInsufficientBalanceDialog(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error?.errorMessage ?? 'Xatolik'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
      child: child,
    );
  }
}

String formatAmount(int amount) {
  final s = amount.toString();
  final buf = StringBuffer();
  int count = 0;
  for (int i = s.length - 1; i >= 0; i--) {
    if (count > 0 && count % 3 == 0) buf.write(' ');
    buf.write(s[i]);
    count++;
  }
  return buf.toString().split('').reversed.join();
}

void showUnlockSuccessSheet(
    BuildContext context, ContactUnlockResultModel result) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    backgroundColor: Colors.white,
    builder: (_) => Padding(
      padding: EdgeInsets.fromLTRB(
          24, 24, 24, MediaQuery.of(context).padding.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
                color: Color(0xFFDCFCE7), shape: BoxShape.circle),
            child: const Icon(Icons.check_circle, color: GREEN_COLOR, size: 32),
          ),
          const SizedBox(height: 16),
          const Text('Kontakt ochildi!',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: DARK_NAVY)),
          const SizedBox(height: 8),
          Text(
            result.phone,
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: PRIMARY_BLUE,
                letterSpacing: 1),
          ),
          if (result.additionalContact != null) ...[
            const SizedBox(height: 4),
            Text(result.additionalContact!,
                style: const TextStyle(fontSize: 14, color: GRAY_TEXT)),
          ],
          const SizedBox(height: 8),
          if (!result.free && result.fee > 0)
            Text(
              '${formatAmount(result.fee)} so\'m yechildi • Qolgan balans: ${formatAmount(result.balance ?? 0)} so\'m',
              style: const TextStyle(fontSize: 12, color: GRAY_TEXT),
              textAlign: TextAlign.center,
            )
          else
            const Text('Bepul ochildi',
                style: TextStyle(fontSize: 12, color: GREEN_COLOR)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                  backgroundColor: PRIMARY_BLUE,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              child: const Text('Yopish'),
            ),
          ),
        ],
      ),
    ),
  );
}

void showInsufficientBalanceDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Balans yetarli emas',
          style: TextStyle(fontWeight: FontWeight.bold, color: DARK_NAVY)),
      content: const Text('Kontaktni ochish uchun balansni to\'ldiring.',
          style: TextStyle(color: GRAY_TEXT)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Bekor', style: TextStyle(color: GRAY_TEXT)),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(ctx);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const TopUpScreen(isEmployer: true)));
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: PRIMARY_BLUE,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10))),
          child: const Text("To'ldirish"),
        ),
      ],
    ),
  );
}

/// Pulli ochishni tasdiqlash dialogi (umumiy — karta va detalda ishlatiladi).
void confirmPaidUnlock(
  BuildContext context, {
  required int anketaId,
  int? vacancyId,
  required int fee,
}) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Nomzodni ochish',
          style: TextStyle(fontWeight: FontWeight.bold, color: DARK_NAVY)),
      content: Text(
        '${formatAmount(fee)} so\'m balansingizdan yechiladi.\nDavom etasizmi?',
        style: const TextStyle(color: GRAY_TEXT),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Bekor', style: TextStyle(color: GRAY_TEXT)),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(ctx);
            context.read<VacancyBloc>().add(
                UnlockContactEvent(anketaId: anketaId, vacancyId: vacancyId));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: PRIMARY_BLUE,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text("To'lab ochish"),
        ),
      ],
    ),
  );
}

// ── Nomzod kartasi (struktura: web reference 1-rasm; uslub: light) ────────────

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

  String _metaLine() {
    final parts = <String>[
      (candidate.jobTypeName != null && candidate.jobTypeName!.isNotEmpty)
          ? candidate.jobTypeName!
          : '—',
      if (candidate.region != null) candidate.region!.name,
      if (candidate.age != null) '${candidate.age} yosh',
    ];
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VacancyBloc, VacancyState>(
      builder: (context, vacState) {
        final phone =
            candidate.phoneRaw ?? vacState.unlockedPhones[candidate.id];
        final isUnlocked = candidate.isUnlocked ||
            vacState.unlockedAnketaIds.contains(candidate.id);
        final isUnlocking = vacState.unlockStatus.isInProgress;
        final isFree =
            isRecommended || (vacState.contactAccess?.freeContacts ?? false);
        final fee = vacState.contactAccess?.fee ?? 30000;

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: isRecommended
                    ? VIOLET.withValues(alpha: 0.3)
                    : CARD_BORDER),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      candidate.fullname ?? "Ism noma'lum",
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: DARK_NAVY),
                    ),
                    const SizedBox(height: 6),
                    if (isRecommended)
                      const _Badge('Operator tavsiyasi', VIOLET)
                    else if (candidate.matchPercent > 0)
                      _Badge('${candidate.matchPercent}%',
                          matchBucketColor(candidate)),
                    const SizedBox(height: 6),
                    Text(_metaLine(),
                        style:
                            const TextStyle(fontSize: 12.5, color: GRAY_TEXT)),
                    if (isRecommended && candidate.assignment != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        assignmentLabel(candidate.assignment!.status),
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: VIOLET),
                      ),
                    ],
                    const SizedBox(height: 10),
                    _PhoneRow(
                      phone: isUnlocked ? phone : null,
                      masked: candidate.maskedPhone,
                    ),
                    if (isRecommended && candidate.assignment != null)
                      _StageControl(assignment: candidate.assignment!),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 124,
                child: Column(
                  children: [
                    _DetailButton(candidate: candidate),
                    const SizedBox(height: 8),
                    _UnlockButton(
                      candidate: candidate,
                      isUnlocked: isUnlocked,
                      isUnlocking: isUnlocking,
                      isFree: isFree,
                      fee: fee,
                      vacancyId: vacancyId,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Karta ichi kichik widgetlar ───────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  const _Badge(this.text, this.color);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(text,
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600, color: color)),
      );
}

class _PhoneRow extends StatelessWidget {
  /// Ochilgan bo'lsa to'liq telefon; aks holda `null`.
  final String? phone;

  /// Yopiq holatda ko'rsatiladigan maskalangan telefon (PROMPT §3.4).
  final String masked;
  const _PhoneRow({required this.phone, required this.masked});

  @override
  Widget build(BuildContext context) {
    final unlocked = phone != null && phone!.isNotEmpty;
    final display = unlocked ? phone! : masked;
    return Row(
      children: [
        Icon(Icons.phone, size: 15, color: unlocked ? GREEN_COLOR : GRAY_TEXT),
        const SizedBox(width: 7),
        Flexible(
          child: Text(display,
              style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: unlocked ? DARK_NAVY : GRAY_TEXT)),
        ),
      ],
    );
  }
}

class _DetailButton extends StatelessWidget {
  final CandidateModel candidate;
  const _DetailButton({required this.candidate});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      width: double.infinity,
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
          foregroundColor: DARK_NAVY,
          side: const BorderSide(color: CARD_BORDER),
          padding: EdgeInsets.zero,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        label: const Text('Batafsil', style: TextStyle(fontSize: 12.5)),
      ),
    );
  }
}

class _UnlockButton extends StatelessWidget {
  final CandidateModel candidate;
  final bool isUnlocked;
  final bool isUnlocking;
  final bool isFree;
  final int fee;
  final int? vacancyId;

  const _UnlockButton({
    required this.candidate,
    required this.isUnlocked,
    required this.isUnlocking,
    required this.isFree,
    required this.fee,
    required this.vacancyId,
  });

  @override
  Widget build(BuildContext context) {
    if (isUnlocked) {
      return SizedBox(
        height: 34,
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.lock_open, size: 15),
          label: const Text('Ochilgan', style: TextStyle(fontSize: 12.5)),
          style: ElevatedButton.styleFrom(
            backgroundColor: GREEN_COLOR.withValues(alpha: 0.12),
            disabledBackgroundColor: GREEN_COLOR.withValues(alpha: 0.12),
            foregroundColor: GREEN_COLOR,
            disabledForegroundColor: GREEN_COLOR,
            elevation: 0,
            padding: EdgeInsets.zero,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      );
    }

    final label = isUnlocking
        ? 'Ochilmoqda...'
        : (isFree ? 'Bepul ochish' : 'Ochish · ${formatAmount(fee)}');

    return SizedBox(
      height: 34,
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isUnlocking ? null : () => _onUnlock(context),
        icon: isUnlocking
            ? const SizedBox(
                width: 13,
                height: 13,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
            : Icon(isFree ? Icons.lock_open : Icons.lock_outline, size: 15),
        label: Text(label,
            style: const TextStyle(fontSize: 11.5),
            overflow: TextOverflow.ellipsis),
        style: ElevatedButton.styleFrom(
          backgroundColor: isFree ? GREEN_COLOR : PRIMARY_BLUE,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.zero,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  void _onUnlock(BuildContext context) {
    if (isFree) {
      context.read<VacancyBloc>().add(
          UnlockContactEvent(anketaId: candidate.id, vacancyId: vacancyId));
      return;
    }
    confirmPaidUnlock(context,
        anketaId: candidate.id, vacancyId: vacancyId, fee: fee);
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
                      borderRadius: BorderRadius.circular(8)),
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
