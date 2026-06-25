import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/utils/custom_cached_network_image.dart';
import '../../../billing/presentation/screens/topup_screen.dart';
import '../../data/models/candidate_model.dart';
import '../../data/models/contact_unlock_model.dart';
import '../logic/vacancy_bloc.dart';

/// "Batafsil" — nomzod to'liq rezyumesi (struktura: web reference 2-rasm; light).
/// B varianti: `detail.locked == true` bo'lsa rezyume yopiq panel ko'rsatiladi.
class CandidateDetailScreen extends StatefulWidget {
  final int candidateId;
  // Card from list — contains match_score/recommended (not in detail endpoint)
  final CandidateModel? card;

  const CandidateDetailScreen({
    super.key,
    required this.candidateId,
    this.card,
  });

  @override
  State<CandidateDetailScreen> createState() => _CandidateDetailScreenState();
}

class _CandidateDetailScreenState extends State<CandidateDetailScreen> {
  @override
  void initState() {
    super.initState();
    final bloc = context.read<VacancyBloc>();
    bloc.add(LoadCandidateDetailEvent(widget.candidateId));
    bloc.add(LoadContactAccessEvent());
  }

  void _reload() => context
      .read<VacancyBloc>()
      .add(LoadCandidateDetailEvent(widget.candidateId));

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: LIGHT_GRAY_BG,
        appBar: AppBar(
          backgroundColor: DARK_NAVY,
          foregroundColor: Colors.white,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          title: const Text('Rezyume',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: BlocListener<VacancyBloc, VacancyState>(
          listenWhen: (prev, curr) => prev.unlockStatus != curr.unlockStatus,
          listener: (context, state) {
            if (state.unlockStatus.isSuccess && state.unlockResult != null) {
              _showUnlockSuccess(context, state.unlockResult!);
              // Ochilgach to'liq rezyume + telefon kelishi uchun qayta yuklaymiz
              _reload();
            } else if (state.unlockStatus.isFailure) {
              final code = state.error?.errorCode;
              if (code == 402) {
                _showInsufficientBalance(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(state.error?.errorMessage ?? 'Xatolik'),
                  backgroundColor: Colors.red,
                ));
              }
            }
          },
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return BlocBuilder<VacancyBloc, VacancyState>(
      builder: (context, state) {
        if (state.candidateDetailStatus.isInProgress &&
            state.candidateDetail == null) {
          return const Center(
              child: CircularProgressIndicator(color: PRIMARY_BLUE));
        }
        if (state.candidateDetailStatus == FormzSubmissionStatus.failure &&
            state.candidateDetail == null) {
          return _ErrorView(
            message: state.error?.errorMessage ?? 'Xato yuz berdi',
            onRetry: _reload,
          );
        }
        final detail = state.candidateDetail;
        if (detail == null) {
          return const Center(
              child: CircularProgressIndicator(color: PRIMARY_BLUE));
        }

        final phone = detail.phoneRaw ?? state.unlockedPhones[detail.id];
        final isUnlocked =
            detail.isUnlocked || state.unlockedAnketaIds.contains(detail.id);
        final isRecommended = widget.card?.recommended ?? detail.recommended;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProfileHeader(detail: detail, card: widget.card),
              const SizedBox(height: 14),
              if (detail.locked)
                _LockedResumePanel(
                  detail: detail,
                  access: state.contactAccess,
                  isRecommended: isRecommended,
                  isUnlocking: state.unlockStatus.isInProgress,
                )
              else ...[
                _ContactBlock(
                  detail: detail,
                  phone: phone,
                  isUnlocked: isUnlocked,
                  isRecommended: isRecommended,
                  access: state.contactAccess,
                  isUnlocking: state.unlockStatus.isInProgress,
                ),
                const SizedBox(height: 14),
                _InfoGrid(detail: detail),
                if (detail.professions.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  _ProfessionsSection(detail.professions),
                ],
                if (detail.workHistory.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  _WorkHistorySection(detail.workHistory),
                ],
                if (_hasExtra(detail)) ...[
                  const SizedBox(height: 14),
                  _ExtraSection(detail),
                ],
              ],
            ],
          ),
        );
      },
    );
  }

  bool _hasExtra(CandidateModel d) =>
      (d.motivation?.isNotEmpty ?? false) ||
      (d.previousJobReason?.isNotEmpty ?? false) ||
      (d.professionText?.isNotEmpty ?? false);

  void _showUnlockSuccess(BuildContext context, ContactUnlockResultModel r) {
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
            const Text('Nomzod ochildi!',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: DARK_NAVY)),
            const SizedBox(height: 8),
            Text(r.phone,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: PRIMARY_BLUE,
                    letterSpacing: 1)),
            if (r.additionalContact != null) ...[
              const SizedBox(height: 4),
              Text(r.additionalContact!,
                  style: const TextStyle(fontSize: 14, color: GRAY_TEXT)),
            ],
            const SizedBox(height: 8),
            if (!r.free && r.fee > 0)
              Text('${_money(r.fee)} yechildi',
                  style: const TextStyle(fontSize: 12, color: GRAY_TEXT))
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

  void _showInsufficientBalance(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Balans yetarli emas',
            style: TextStyle(fontWeight: FontWeight.bold, color: DARK_NAVY)),
        content: const Text('Nomzodni ochish uchun balansni to\'ldiring.',
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
}

// ── Profil sarlavhasi ─────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  final CandidateModel detail;
  final CandidateModel? card;
  const _ProfileHeader({required this.detail, this.card});

  @override
  Widget build(BuildContext context) {
    final matchPct = card?.matchPercent ?? detail.matchPercent;
    final isRecommended = card?.recommended ?? detail.recommended;
    final matchColor = matchPct >= 80
        ? const Color(0xFF16A34A)
        : (matchPct >= 60 ? PRIMARY_BLUE : GRAY_TEXT);
    final photoUrl = detail.photoUrl ?? card?.photoUrl;

    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [PRIMARY_BLUE.withValues(alpha: 0.85), SECONDARY_BLUE]),
            shape: BoxShape.circle,
          ),
          clipBehavior: Clip.antiAlias,
          child: photoUrl != null
              ? CustomCachedNetworkImage(
                  url: photoUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  forUserImages: true,
                  borderRadius: BorderRadius.circular(30),
                )
              : Center(
                  child: Text(detail.initials,
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(detail.fullname ?? "Ism noma'lum",
                  style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: DARK_NAVY)),
              const SizedBox(height: 4),
              Text(detail.jobTypeName ?? '—',
                  style: const TextStyle(fontSize: 13, color: GRAY_TEXT)),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (isRecommended)
                    const _Pill('Operator tavsiyasi', VIOLET)
                  else if (matchPct > 0)
                    _Pill('$matchPct% mos', matchColor),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Kontakt bloki ─────────────────────────────────────────────────────────────

class _ContactBlock extends StatelessWidget {
  final CandidateModel detail;
  final String? phone;
  final bool isUnlocked;
  final bool isRecommended;
  final ContactAccessModel? access;
  final bool isUnlocking;

  const _ContactBlock({
    required this.detail,
    required this.phone,
    required this.isUnlocked,
    required this.isRecommended,
    required this.access,
    required this.isUnlocking,
  });

  @override
  Widget build(BuildContext context) {
    final isFree = isRecommended || (access?.freeContacts ?? false);
    final fee = detail.fee ?? access?.fee ?? 30000;

    if (isUnlocked && phone != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: GREEN_COLOR.withValues(alpha: 0.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.phone, color: GREEN_COLOR, size: 20),
                const SizedBox(width: 10),
                Text(phone!,
                    style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: DARK_NAVY,
                        letterSpacing: 0.5)),
              ],
            ),
            if (detail.additionalContact != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.phone_in_talk_outlined,
                      color: GREEN_COLOR, size: 18),
                  const SizedBox(width: 10),
                  Text(detail.additionalContact!,
                      style: const TextStyle(fontSize: 14, color: DARK_NAVY)),
                ],
              ),
            ],
          ],
        ),
      );
    }

    // locked == false, lekin hali ochilmagan (premium/tavsiya) → kontakt yopiq
    return _Card(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child:
                    const Icon(Icons.lock_outline, color: GRAY_TEXT, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Kontakt yopiq',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: DARK_NAVY)),
                    Text(isFree ? 'Bepul ochish mumkin' : '${_money(fee)} evaziga',
                        style: const TextStyle(fontSize: 12, color: GRAY_TEXT)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _UnlockWideButton(
            anketaId: detail.id,
            isFree: isFree,
            fee: fee,
            isUnlocking: isUnlocking,
          ),
        ],
      ),
    );
  }
}

// ── Rezyume yopiq paneli (B varianti: locked == true) ─────────────────────────

class _LockedResumePanel extends StatelessWidget {
  final CandidateModel detail;
  final ContactAccessModel? access;
  final bool isRecommended;
  final bool isUnlocking;

  const _LockedResumePanel({
    required this.detail,
    required this.access,
    required this.isRecommended,
    required this.isUnlocking,
  });

  @override
  Widget build(BuildContext context) {
    final isFree = isRecommended || (access?.freeContacts ?? false);
    final fee = detail.fee ?? access?.fee ?? 30000;

    return _Card(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.lock_outline, color: GRAY_TEXT, size: 30),
          ),
          const SizedBox(height: 16),
          const Text("To'liq rezyume yopiq",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: DARK_NAVY)),
          const SizedBox(height: 8),
          Text(
            isFree
                ? 'Bu nomzodning to\'liq rezyumesi va kontaktini bepul ochishingiz mumkin.'
                : 'To\'liq rezyume va kontaktni ochish uchun ${_money(fee)} bir marta yechiladi.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: GRAY_TEXT, height: 1.4),
          ),
          const SizedBox(height: 20),
          _UnlockWideButton(
            anketaId: detail.id,
            isFree: isFree,
            fee: fee,
            isUnlocking: isUnlocking,
          ),
        ],
      ),
    );
  }
}

/// Keng "ochish" tugmasi — kontakt va rezyume yopiq panellarda umumiy.
class _UnlockWideButton extends StatelessWidget {
  final int anketaId;
  final bool isFree;
  final int fee;
  final bool isUnlocking;

  const _UnlockWideButton({
    required this.anketaId,
    required this.isFree,
    required this.fee,
    required this.isUnlocking,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isUnlocking ? null : () => _onUnlock(context),
        icon: isUnlocking
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
            : Icon(isFree ? Icons.lock_open : Icons.lock_open_outlined,
                size: 18),
        label: Text(isUnlocking
            ? 'Ochilmoqda...'
            : (isFree ? 'Bepul ochish' : 'Ochish · ${_money(fee)}')),
        style: ElevatedButton.styleFrom(
          backgroundColor: isFree ? GREEN_COLOR : PRIMARY_BLUE,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  void _onUnlock(BuildContext context) {
    if (isFree) {
      context.read<VacancyBloc>().add(UnlockContactEvent(anketaId: anketaId));
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Nomzodni ochish',
            style: TextStyle(fontWeight: FontWeight.bold, color: DARK_NAVY)),
        content: Text(
          '${_money(fee)} balansingizdan yechiladi.\nDavom etasizmi?',
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
              context
                  .read<VacancyBloc>()
                  .add(UnlockContactEvent(anketaId: anketaId));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: PRIMARY_BLUE,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("To'lab ochish"),
          ),
        ],
      ),
    );
  }
}

// ── Ma'lumotlar gridi (2 ustun, barcha maydonlar — bo'shi "—") ────────────────

class _InfoGrid extends StatelessWidget {
  final CandidateModel detail;
  const _InfoGrid({required this.detail});

  String _bool(bool? v) => v == null ? '—' : (v ? 'Ha' : "Yo'q");

  String _orDash(String? v) => (v != null && v.isNotEmpty) ? v : '—';

  @override
  Widget build(BuildContext context) {
    final hudud = [
      if (detail.region != null) detail.region!.name,
      if (detail.district != null) detail.district!.name,
    ].join(', ');

    final pairs = <(String, String)>[
      ('HUDUD', hudud.isEmpty ? '—' : hudud),
      ('YOSH', detail.age != null ? '${detail.age} yosh' : '—'),
      ('JINSI', _orDash(detail.genderLabel)),
      ('TAJRIBA',
          detail.rawExperienceYear != null
              ? '${detail.rawExperienceYear} yil'
              : '—'),
      ('KUTILAYOTGAN OYLIK',
          detail.expectedSalary != null ? _money(detail.expectedSalary!) : '—'),
      ('OXIRGI OYLIK',
          detail.lastSalary != null ? _money(detail.lastSalary!) : '—'),
      ("MA'LUMOTI", _orDash(detail.information)),
      ('ISH HOLATI', _orDash(detail.workStatusLabel)),
      ('ISH VAQTI',
          detail.workScheduleLabels.isNotEmpty
              ? detail.workScheduleLabels.join(', ')
              : '—'),
      ('TILLAR',
          detail.languages.isNotEmpty ? detail.languages.join(', ') : '—'),
      ('HAYDOVCHILIK GUVOHNOMASI', _bool(detail.hasLicense)),
      ('SHAXSIY AVTOMOBIL', _bool(detail.hasCar)),
      ('KOMPYUTER SAVODXONLIGI', _orDash(detail.computerLiteracy)),
      ('JISMONIY ISHGA ROZI', _bool(detail.physicalWorkOk)),
    ];

    final rows = <Widget>[];
    for (var i = 0; i < pairs.length; i += 2) {
      rows.add(Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _cell(pairs[i])),
            const SizedBox(width: 12),
            Expanded(
                child: i + 1 < pairs.length
                    ? _cell(pairs[i + 1])
                    : const SizedBox.shrink()),
          ],
        ),
      ));
    }

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle("Ma'lumotlar"),
          const SizedBox(height: 14),
          ...rows,
        ],
      ),
    );
  }

  Widget _cell((String, String) p) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(p.$1,
              style: const TextStyle(
                  fontSize: 10.5,
                  letterSpacing: 0.4,
                  fontWeight: FontWeight.w600,
                  color: GRAY_TEXT)),
          const SizedBox(height: 3),
          Text(p.$2,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: DARK_NAVY)),
        ],
      );
}

// ── Kasblar ───────────────────────────────────────────────────────────────────

class _ProfessionsSection extends StatelessWidget {
  final List<CandidateProfessionModel> professions;
  const _ProfessionsSection(this.professions);

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Kasblar'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: professions
                .map((p) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: VIOLET.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(20),
                        border:
                            Border.all(color: VIOLET.withValues(alpha: 0.35)),
                      ),
                      child: Text('${p.name} · ${p.experienceYear} yil',
                          style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              color: VIOLET)),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

// ── Ish tarixi ────────────────────────────────────────────────────────────────

class _WorkHistorySection extends StatelessWidget {
  final List<WorkHistoryModel> history;
  const _WorkHistorySection(this.history);

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Ish tajribasi'),
          const SizedBox(height: 12),
          ...history.map((h) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: h.isCurrent ? GREEN_COLOR : PRIMARY_BLUE,
                            shape: BoxShape.circle,
                          ),
                        ),
                        if (h != history.last)
                          Container(
                              width: 2, height: 30, color: CARD_BORDER),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(h.position ?? '',
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: DARK_NAVY)),
                          if (h.companyName != null)
                            Text(h.companyName!,
                                style: const TextStyle(
                                    fontSize: 12, color: GRAY_TEXT)),
                          Text(
                            h.isCurrent
                                ? '${h.startYear} — hozir'
                                : '${h.startYear} — ${h.endYear}',
                            style: const TextStyle(
                                fontSize: 11, color: GRAY_TEXT),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

// ── Qo'shimcha ────────────────────────────────────────────────────────────────

class _ExtraSection extends StatelessWidget {
  final CandidateModel detail;
  const _ExtraSection(this.detail);

  @override
  Widget build(BuildContext context) {
    Widget block(String title, String value) => Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: GRAY_TEXT)),
              const SizedBox(height: 4),
              Text(value,
                  style: const TextStyle(
                      fontSize: 13, color: DARK_NAVY, height: 1.4)),
            ],
          ),
        );

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle("Qo'shimcha"),
          const SizedBox(height: 12),
          if (detail.motivation?.isNotEmpty ?? false)
            block('Motivatsiya', detail.motivation!),
          if (detail.previousJobReason?.isNotEmpty ?? false)
            block('Oldingi ishdan ketish sababi', detail.previousJobReason!),
          if (detail.professionText?.isNotEmpty ?? false)
            block("Qo'shimcha kasb / izoh", detail.professionText!),
        ],
      ),
    );
  }
}

// ── Umumiy yordamchi widgetlar ────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const _Card({required this.child, this.padding = const EdgeInsets.all(16)});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: CARD_BORDER),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: child,
      );
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
            fontSize: 15, fontWeight: FontWeight.bold, color: DARK_NAVY),
      );
}

class _Pill extends StatelessWidget {
  final String text;
  final Color color;
  const _Pill(this.text, this.color);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(text,
            style: TextStyle(
                fontSize: 11.5, color: color, fontWeight: FontWeight.w600)),
      );
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off_outlined, size: 64, color: GRAY_TEXT),
              const SizedBox(height: 16),
              Text(message,
                  style: const TextStyle(fontSize: 15, color: GRAY_TEXT),
                  textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                    backgroundColor: PRIMARY_BLUE,
                    foregroundColor: Colors.white),
                child: const Text('Qayta urinish'),
              ),
            ],
          ),
        ),
      );
}

/// 3 000 000 → "3 000 000 so'm" (probel bilan, uz-UZ).
String _money(int amount) {
  final s = amount.abs().toString();
  final buf = StringBuffer();
  int count = 0;
  for (int i = s.length - 1; i >= 0; i--) {
    if (count > 0 && count % 3 == 0) buf.write(' ');
    buf.write(s[i]);
    count++;
  }
  final grouped = buf.toString().split('').reversed.join();
  return "$grouped so'm";
}
