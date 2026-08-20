import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../billing/presentation/logic/billing_bloc.dart';
import '../../../billing/presentation/screens/topup_screen.dart';
import '../../../chat/presentation/screens/direct_chat_screen.dart';
import '../../data/models/candidate_model.dart';
import '../../data/models/contact_unlock_model.dart';
import '../../data/models/employer_vacancy_model.dart';
import '../logic/vacancy_bloc.dart';
import 'nomzod_cards.dart' show pickSchedule;
import '../../../../core/theme/jb_palette.dart';

/// PROMPT_OTKLIK_MOBILE.md — otklik oqimining umumiy amallari:
/// ochish (§4) · to'lov (§5) · uchta imkoniyat: telefon · chat · suhbat (§6, §8).

/// `30000` → `30 000` (uz-UZ, probel bilan; birliksiz).
String formatAmount(int amount) {
  final s = amount.abs().toString();
  final buf = StringBuffer();
  var count = 0;
  for (var i = s.length - 1; i >= 0; i--) {
    if (count > 0 && count % 3 == 0) buf.write(' ');
    buf.write(s[i]);
    count++;
  }
  return buf.toString().split('').reversed.join();
}

// ── §4 Ochish ────────────────────────────────────────────────────────────────

/// Nomzodni ochish oqimi:
/// bepul → darhol; pullik va balans yetadi → tasdiq oynasi; balans yetmaydi →
/// so'rov yubormasdan to'g'ridan-to'g'ri to'lov ekrani (§4.2).
Future<void> startUnlock(
  BuildContext context, {
  required CandidateModel candidate,
  int? vacancyId,
}) async {
  final bloc = context.read<VacancyBloc>();
  final state = bloc.state;
  final fee = state.feeFor(candidate);

  if (state.isFreeUnlock(candidate)) {
    bloc.add(UnlockContactEvent(anketaId: candidate.id, vacancyId: vacancyId));
    return;
  }

  // Balansni bilamiz va yetmayapti → to'g'ridan-to'g'ri to'lovga (§4.2).
  // `contact-access.balance` eng yangi manba; nomzod javobidagi
  // `can_pay_from_balance` esa zaxira (eskirgan bo'lishi mumkin).
  final liveBalance = state.contactAccess?.balance;
  final canPay = liveBalance != null
      ? liveBalance >= fee
      : (candidate.canPayFromBalance ?? true);
  if (!canPay) {
    await topUpThenUnlock(context,
        candidate: candidate, vacancyId: vacancyId, fee: fee);
    return;
  }

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Nomzodni ochish',
          style: TextStyle(fontWeight: FontWeight.w800, color: context.jb.ink)),
      content: Text(
        "${formatAmount(fee)} so'm hisobingizdan yechiladi.\n"
        'Nomzodning telefoni, chati va suhbat imkoniyati ochiladi.',
        style: TextStyle(color: context.jb.gray, height: 1.4),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text('Bekor', style: TextStyle(color: context.jb.gray)),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: context.jb.blue,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text("To'lab ochish"),
        ),
      ],
    ),
  );
  if (confirmed != true) return;
  bloc.add(UnlockContactEvent(anketaId: candidate.id, vacancyId: vacancyId));
}

/// §5 — balansni to'ldirish, so'ng to'landi bo'lsa nomzodni **avtomatik** ochish
/// (foydalanuvchi tugmani qayta bosmasin).
Future<void> topUpThenUnlock(
  BuildContext context, {
  required CandidateModel candidate,
  int? vacancyId,
  required int fee,
}) async {
  final bloc = context.read<VacancyBloc>();
  final billing = context.read<BillingBloc>();
  final paid = await Navigator.push<bool>(
    context,
    MaterialPageRoute(
      builder: (_) => TopUpScreen(
        isEmployer: true,
        initialAmount: fee,
        purpose: '"${candidate.fullname ?? 'Nomzod'}" ni ochish '
            "— ${formatAmount(fee)} so'm",
      ),
    ),
  );
  billing.add(const LoadBalanceEvent(true));
  bloc.add(LoadContactAccessEvent());
  if (paid == true) {
    bloc.add(UnlockContactEvent(anketaId: candidate.id, vacancyId: vacancyId));
  }
}

/// 402 — balans yetmadi (§10). To'ldirgach nomzod avtomatik ochiladi.
void showInsufficientBalanceDialog(
  BuildContext context, {
  CandidateModel? candidate,
  int? vacancyId,
  int? fee,
}) {
  final price = fee ?? context.read<VacancyBloc>().state.contactAccess?.fee ?? 0;
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Balans yetarli emas',
          style: TextStyle(fontWeight: FontWeight.w800, color: context.jb.ink)),
      content: Text(
        price > 0
            ? "Nomzodni ochish uchun ${formatAmount(price)} so'm kerak. "
                "Hisobni to'ldiring."
            : "Nomzodni ochish uchun hisobni to'ldiring.",
        style: TextStyle(color: context.jb.gray, height: 1.4),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text('Bekor', style: TextStyle(color: context.jb.gray)),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(ctx);
            if (candidate != null) {
              topUpThenUnlock(context,
                  candidate: candidate, vacancyId: vacancyId, fee: price);
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const TopUpScreen(isEmployer: true)),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: context.jb.blue,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text("Hisobni to'ldirish"),
        ),
      ],
    ),
  );
}

// ── §6 Uchta imkoniyat ───────────────────────────────────────────────────────

/// `tel:` — OS qo'ng'iroq ekrani.
Future<void> callCandidate(BuildContext context, String? phone) async {
  final digits = (phone ?? '').trim();
  if (digits.isEmpty) {
    _snack(context, 'Telefon raqami topilmadi');
    return;
  }
  final uri = Uri(scheme: 'tel', path: digits.replaceAll(' ', ''));
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    if (context.mounted) _snack(context, "Qo'ng'iroq ekrani ochilmadi");
  }
}

/// Chat — faqat ochilgan nomzodda (§7.5). Kalit `capabilities.chat.session_key`
/// dan keladi; bo'lmasa suhbat hali tayyor emas.
void openCandidateChat(
  BuildContext context, {
  required CandidateModel candidate,
  ContactCapabilitiesModel? capabilities,
}) {
  final key = capabilities?.chatSessionKey ??
      context.read<VacancyBloc>().state.capabilitiesOf(candidate.id)?.chatSessionKey;
  if (key == null || key.isEmpty) {
    _snack(context, 'Suhbat kaliti topilmadi — sahifani yangilang');
    return;
  }
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => DirectChatScreen(
        sessionKey: key,
        peerName: candidate.fullname ?? 'Nomzod',
        peerPhotoUrl: candidate.photoUrl,
      ),
    ),
  );
}

/// §8 — suhbatga chaqirish: vakansiya + sana/vaqt tanlanadi, so'ng Kanban
/// biriktirishi yaratiladi (`status: suhbatga_yozildi`).
Future<void> inviteToInterview(
  BuildContext context, {
  required CandidateModel candidate,
  int? requirementId,
}) async {
  final bloc = context.read<VacancyBloc>();
  var reqId = requirementId;
  if (reqId == null) {
    final vacancies = bloc.state.employerVacancies.isNotEmpty
        ? bloc.state.employerVacancies
        : (bloc.state.pipeline?.requirements ?? const <EmployerVacancyModel>[]);
    if (vacancies.isEmpty) {
      bloc.add(LoadEmployerVacanciesEvent());
      _snack(context, 'Avval vakansiya yarating');
      return;
    }
    if (vacancies.length == 1) {
      reqId = vacancies.first.id;
    } else {
      reqId = await _pickVacancy(context, vacancies);
      if (reqId == null || !context.mounted) return;
    }
  }

  final picked =
      await pickSchedule(context, title: 'Suhbatga chaqirish', requireTime: true);
  if (picked?.dateTime == null || !context.mounted) return;
  bloc.add(CreateAssignmentEvent(
    anketaId: candidate.id,
    requirementId: reqId,
    status: 'suhbatga_yozildi',
    interviewDatetime: picked!.iso,
  ));
}

Future<int?> _pickVacancy(
    BuildContext context, List<EmployerVacancyModel> vacancies) {
  return showModalBottomSheet<int>(
    context: context,
    backgroundColor: context.jb.card,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (ctx) => SafeArea(
      child: ConstrainedBox(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.jb.border,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Qaysi vakansiyaga?',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: context.jb.ink)),
              ),
            ),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                itemCount: vacancies.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final v = vacancies[i];
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.pop(ctx, v.id),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 13),
                        decoration: BoxDecoration(
                          color: context.jb.card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: context.jb.border, width: 1.5),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.business_center_rounded,
                                size: 18, color: context.jb.blue),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(v.jobTypeName ?? 'Vakansiya #${v.id}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w700,
                                          color: context.jb.ink)),
                                  const SizedBox(height: 2),
                                  Text(v.salaryDisplay,
                                      style: TextStyle(
                                          fontSize: 12, color: context.jb.gray)),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right_rounded,
                                color: context.jb.grayLight, size: 20),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void _snack(BuildContext context, String message, {Color? color}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), backgroundColor: color ?? context.jb.amber),
  );
}

// ── Umumiy widgetlar ─────────────────────────────────────────────────────────

/// Yopiq kartadagi qulf qatori (§3.3).
class LockedNoticeRow extends StatelessWidget {
  const LockedNoticeRow({super.key});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(Icons.lock_outline_rounded, size: 15, color: context.jb.grayLight),
          SizedBox(width: 7),
          Expanded(
            child: Text(
              'Telefon, chat va suhbat yopiq',
              style: TextStyle(
                  fontSize: 12.5, fontWeight: FontWeight.w600, color: context.jb.gray),
            ),
          ),
        ],
      );
}

/// Ochilgan nomzodning uchta amali: 📞 Telefon · 💬 Chat · 📅 Suhbat (§6).
class UnlockedActionsRow extends StatelessWidget {
  final CandidateModel candidate;
  final int? requirementId;
  final String? phone;
  final bool busy;

  const UnlockedActionsRow({
    super.key,
    required this.candidate,
    this.requirementId,
    this.phone,
    this.busy = false,
  });

  @override
  Widget build(BuildContext context) {
    final caps = context.select<VacancyBloc, ContactCapabilitiesModel?>(
      (b) => b.state.capabilitiesOf(candidate.id),
    );
    final number = phone ?? caps?.phone;
    final canChat = caps?.hasChat ?? false;

    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: Icons.phone_rounded,
            label: 'Telefon',
            color: context.jb.green,
            onTap: busy ? null : () => callCandidate(context, number),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ActionButton(
            icon: Icons.chat_bubble_outline_rounded,
            label: 'Chat',
            color: context.jb.blue,
            onTap: busy || !canChat
                ? null
                : () => openCandidateChat(context,
                    candidate: candidate, capabilities: caps),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ActionButton(
            icon: Icons.event_available_rounded,
            label: 'Suhbat',
            color: context.jb.violet,
            onTap: busy
                ? null
                : () => inviteToInterview(context,
                    candidate: candidate, requirementId: requirementId),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return SizedBox(
      height: 40,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          disabledForegroundColor: context.jb.grayLight,
          side: BorderSide(
              color: (enabled ? color : context.jb.grayLight).withValues(alpha: 0.4),
              width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 6),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15),
            const SizedBox(width: 5),
            Flexible(
              child: Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 12.5, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}
