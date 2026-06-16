import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../../../../core/constants/colors.dart';
import '../../../billing/presentation/screens/topup_screen.dart';
import '../../data/models/candidate_model.dart';
import '../../data/models/contact_unlock_model.dart';
import '../logic/vacancy_bloc.dart';

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

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: BlocListener<VacancyBloc, VacancyState>(
        listenWhen: (prev, curr) => prev.unlockStatus != curr.unlockStatus,
        listener: (context, state) {
          if (state.unlockStatus.isSuccess && state.unlockResult != null) {
            _showUnlockSuccess(context, state.unlockResult!);
            // Reload detail so phone shows in the contact block
            context
                .read<VacancyBloc>()
                .add(LoadCandidateDetailEvent(widget.candidateId));
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
        child: Scaffold(
          backgroundColor: LIGHT_GRAY_BG,
          body: BlocBuilder<VacancyBloc, VacancyState>(
            builder: (context, state) {
              if (state.candidateDetailStatus.isInProgress) {
                return const _LoadingView();
              }
              if (state.candidateDetailStatus == FormzSubmissionStatus.failure) {
                return _ErrorView(
                  message: state.error?.errorMessage ?? 'Xato yuz berdi',
                  onRetry: () => context
                      .read<VacancyBloc>()
                      .add(LoadCandidateDetailEvent(widget.candidateId)),
                );
              }
              final detail = state.candidateDetail;
              if (detail == null) return const _LoadingView();

              final phone = detail.phoneRaw ??
                  state.unlockedPhones[detail.id];
              final isUnlocked = detail.isUnlocked ||
                  state.unlockedAnketaIds.contains(detail.id);
              final isRecommended =
                  widget.card?.recommended ?? detail.recommended;

              return CustomScrollView(
                slivers: [
                  _buildAppBar(context),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          _ProfileHeader(
                            detail: detail,
                            card: widget.card,
                          ),
                          const SizedBox(height: 12),
                          _ContactBlock(
                            detail: detail,
                            phone: phone,
                            isUnlocked: isUnlocked,
                            isRecommended: isRecommended,
                            access: state.contactAccess,
                            isUnlocking: state.unlockStatus.isInProgress,
                          ),
                          const SizedBox(height: 16),
                          _InfoGrid(detail: detail),
                          if (detail.professions.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            _ProfessionsSection(detail.professions),
                          ],
                          if (detail.workHistory.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            _WorkHistorySection(detail.workHistory),
                          ],
                          if (_hasExtra(detail)) ...[
                            const SizedBox(height: 16),
                            _ExtraSection(detail),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  bool _hasExtra(CandidateModel d) =>
      d.motivation != null ||
      d.previousJobReason != null ||
      d.information != null;

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: const Color(0xFF0F172A),
      foregroundColor: Colors.white,
      title: const Text('Rezyume',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 18),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

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
              child: const Icon(Icons.check_circle,
                  color: GREEN_COLOR, size: 32),
            ),
            const SizedBox(height: 16),
            const Text('Kontakt ochildi!',
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
                  style:
                      const TextStyle(fontSize: 14, color: GRAY_TEXT)),
            ],
            const SizedBox(height: 8),
            if (!r.free && r.fee > 0)
              Text(
                '${_fmt(r.fee)} so\'m yechildi',
                style: const TextStyle(fontSize: 12, color: GRAY_TEXT),
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

  void _showInsufficientBalance(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Balans yetarli emas',
            style: TextStyle(fontWeight: FontWeight.bold, color: DARK_NAVY)),
        content: const Text(
            'Kontaktni ochish uchun balansni to\'ldiring.',
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

  static String _fmt(int amount) {
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
}

// ── Profile header ────────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  final CandidateModel detail;
  final CandidateModel? card;

  const _ProfileHeader({required this.detail, this.card});

  Color get _matchColor {
    final p = card?.matchPercent ?? 0;
    if (p >= 80) return const Color(0xFF16A34A);
    if (p >= 60) return PRIMARY_BLUE;
    return const Color(0xFFF97316);
  }

  @override
  Widget build(BuildContext context) {
    final matchPct = card?.matchPercent ?? 0;
    final isRecommended = card?.recommended ?? detail.recommended;

    return Row(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [PRIMARY_BLUE.withValues(alpha: 0.8), SECONDARY_BLUE]),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(detail.initials,
                style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                detail.fullname ?? "Ism noma'lum",
                style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: DARK_NAVY),
              ),
              const SizedBox(height: 4),
              if (detail.jobTypeName != null)
                Text(detail.jobTypeName!,
                    style: const TextStyle(fontSize: 13, color: GRAY_TEXT)),
              const SizedBox(height: 6),
              Row(
                children: [
                  if (isRecommended)
                    _Chip('Operator tavsiyasi', GREEN_COLOR)
                  else if (matchPct > 0)
                    _Chip('$matchPct% mos', _matchColor),
                  if (detail.candidateCategory == 'bepul') ...[
                    const SizedBox(width: 6),
                    _Chip('Bepul', GRAY_TEXT),
                  ],
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
    final fee = access?.fee ?? 30000;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: isUnlocked && phone != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Kontakt',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: GRAY_TEXT)),
                const SizedBox(height: 10),
                _PhoneLine(
                    icon: Icons.phone, label: 'Telefon', value: phone!),
                if (detail.additionalContact != null) ...[
                  const SizedBox(height: 8),
                  _PhoneLine(
                    icon: Icons.phone_in_talk_outlined,
                    label: "Qo'shimcha",
                    value: detail.additionalContact!,
                  ),
                ],
              ],
            )
          : Column(
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
                      child: const Icon(Icons.lock_outline,
                          color: GRAY_TEXT, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Telefon raqam yashirin',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: DARK_NAVY)),
                          Text(
                            isFree
                                ? 'Bepul ochish mumkin'
                                : '${_fmt(fee)} so\'m evaziga',
                            style: const TextStyle(
                                fontSize: 12, color: GRAY_TEXT),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isUnlocking
                        ? null
                        : () => _onUnlock(context, isFree, fee),
                    icon: isUnlocking
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : Icon(
                            isFree ? Icons.lock_open : Icons.lock_open_outlined,
                            size: 18),
                    label: Text(
                        isFree ? 'Bepul ochish' : 'Ochish · ${_fmt(fee)} so\'m'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isFree ? GREEN_COLOR : PRIMARY_BLUE,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  void _onUnlock(BuildContext context, bool isFree, int fee) {
    if (isFree) {
      context
          .read<VacancyBloc>()
          .add(UnlockContactEvent(anketaId: detail.id));
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Kontaktni ochish',
            style: TextStyle(fontWeight: FontWeight.bold, color: DARK_NAVY)),
        content: Text(
          '${_fmt(fee)} so\'m balansingizdan yechiladi.\nDavom etasizmi?',
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
                  .add(UnlockContactEvent(anketaId: detail.id));
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

  static String _fmt(int amount) {
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
}

class _PhoneLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _PhoneLine(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, size: 16, color: GREEN_COLOR),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style:
                      const TextStyle(fontSize: 11, color: GRAY_TEXT)),
              Text(value,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: DARK_NAVY)),
            ],
          ),
        ],
      );
}

// ── Ma'lumotlar gridi ─────────────────────────────────────────────────────────

class _InfoGrid extends StatelessWidget {
  final CandidateModel detail;
  const _InfoGrid({required this.detail});

  @override
  Widget build(BuildContext context) {
    final items = <(IconData, String, String)>[
      if (detail.region != null)
        (Icons.location_on_outlined, 'Viloyat', detail.region!.name),
      if (detail.district != null)
        (Icons.location_city_outlined, 'Tuman', detail.district!.name),
      if (detail.age != null)
        (Icons.cake_outlined, 'Yosh', '${detail.age} yosh'),
      if (detail.genderLabel.isNotEmpty)
        (Icons.person_outline, 'Jins', detail.genderLabel),
      if (detail.experienceYear != null)
        (Icons.work_history_outlined, 'Tajriba',
            '${detail.experienceYear} yil'),
      if (detail.expectedSalary != null)
        (Icons.attach_money, 'Kutilayotgan oylik', detail.salaryDisplay),
      if (detail.lastSalary != null)
        (Icons.money_off_outlined, 'Oxirgi oylik',
            _fmtSalary(detail.lastSalary!)),
      if (detail.information != null && detail.information!.isNotEmpty)
        (Icons.school_outlined, "Ma'lumoti", detail.information!),
      if (detail.workStatusLabel.isNotEmpty)
        (Icons.circle_outlined, 'Holati', detail.workStatusLabel),
      if (detail.workScheduleLabels.isNotEmpty)
        (Icons.schedule_outlined, 'Ish vaqti',
            detail.workScheduleLabels.join(', ')),
      if (detail.languages.isNotEmpty)
        (Icons.language_outlined, 'Tillar', detail.languages.join(', ')),
    ];

    final skills = <String>[
      if (detail.hasLicense == true) 'Guvohnoma bor',
      if (detail.hasCar == true) 'Avto bor',
      if (detail.computerLiteracy != null &&
          detail.computerLiteracy!.isNotEmpty)
        'Kompyuter: ${detail.computerLiteracy}',
      if (detail.physicalWorkOk == true) "Jismoniy ish — Ha",
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle("Asosiy ma'lumotlar"),
          const SizedBox(height: 12),
          ...items.map((item) => _InfoRow(item.$1, item.$2, item.$3)),
          if (skills.isNotEmpty) ...[
            const Divider(height: 20, color: Color(0xFFF3F4F6)),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: skills
                  .map((s) => _Chip(s, PRIMARY_BLUE))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  static String _fmtSalary(int n) {
    if (n >= 1000000) return "${(n / 1000000).toStringAsFixed(1)} mln so'm";
    return "$n so'm";
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: GRAY_TEXT),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 11, color: GRAY_TEXT)),
                  Text(value,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: DARK_NAVY)),
                ],
              ),
            ),
          ],
        ),
      );
}

// ── Kasblar ───────────────────────────────────────────────────────────────────

class _ProfessionsSection extends StatelessWidget {
  final List<CandidateProfessionModel> professions;
  const _ProfessionsSection(this.professions);

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'Kasblar',
      child: Column(
        children: professions
            .map((p) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: PRIMARY_BLUE,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(p.name,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: DARK_NAVY)),
                      ),
                      Text('${p.experienceYear} yil',
                          style: const TextStyle(
                              fontSize: 12, color: GRAY_TEXT)),
                    ],
                  ),
                ))
            .toList(),
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
      title: 'Ish tajribasi',
      child: Column(
        children: history
            .map((h) => Padding(
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
                              width: 2,
                              height: 30,
                              color: const Color(0xFFE5E7EB),
                            ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              h.position ?? '',
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: DARK_NAVY),
                            ),
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
                ))
            .toList(),
      ),
    );
  }
}

// ── Qo'shimcha ma'lumotlar ────────────────────────────────────────────────────

class _ExtraSection extends StatelessWidget {
  final CandidateModel detail;
  const _ExtraSection(this.detail);

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: "Qo'shimcha",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (detail.motivation != null && detail.motivation!.isNotEmpty) ...[
            const Text('Motivatsiya',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: GRAY_TEXT)),
            const SizedBox(height: 4),
            Text(detail.motivation!,
                style: const TextStyle(fontSize: 13, color: DARK_NAVY)),
            const SizedBox(height: 12),
          ],
          if (detail.previousJobReason != null &&
              detail.previousJobReason!.isNotEmpty) ...[
            const Text('Oldingi ishdan ketish sababi',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: GRAY_TEXT)),
            const SizedBox(height: 4),
            Text(detail.previousJobReason!,
                style: const TextStyle(fontSize: 13, color: DARK_NAVY)),
            const SizedBox(height: 12),
          ],
          if (detail.professionText != null &&
              detail.professionText!.isNotEmpty) ...[
            const Text("Qo'shimcha kasb / izoh",
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: GRAY_TEXT)),
            const SizedBox(height: 4),
            Text(detail.professionText!,
                style: const TextStyle(fontSize: 13, color: DARK_NAVY)),
          ],
        ],
      ),
    );
  }
}

// ── Umumiy yordamchi widgetlar ────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final String title;
  final Widget child;
  const _Card({required this.title, required this.child});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle(title),
            const SizedBox(height: 12),
            child,
          ],
        ),
      );
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.bold, color: DARK_NAVY),
      );
}

class _Chip extends StatelessWidget {
  final String text;
  final Color color;
  const _Chip(this.text, this.color);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(text,
            style: TextStyle(
                fontSize: 12, color: color, fontWeight: FontWeight.w500)),
      );
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) => const Scaffold(
        backgroundColor: LIGHT_GRAY_BG,
        body: Center(
            child: CircularProgressIndicator(color: PRIMARY_BLUE)),
      );
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: LIGHT_GRAY_BG,
        appBar: AppBar(
          backgroundColor: const Color(0xFF0F172A),
          foregroundColor: Colors.white,
          title: const Text('Rezyume'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off_outlined,
                    size: 64, color: GRAY_TEXT),
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
        ),
      );
}
