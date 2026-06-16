import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../../../../core/constants/colors.dart';
import '../../../billing/presentation/screens/topup_screen.dart';
import '../../data/models/candidate_model.dart';
import '../../data/models/contact_unlock_model.dart';
import '../logic/vacancy_bloc.dart';
import 'candidate_detail_screen.dart';
import 'unlock_history_screen.dart';

class CandidatesScreen extends StatefulWidget {
  const CandidatesScreen({super.key});

  @override
  State<CandidatesScreen> createState() => _CandidatesScreenState();
}

class _CandidatesScreenState extends State<CandidatesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final bloc = context.read<VacancyBloc>();
    bloc.add(LoadCandidatesEvent());
    bloc.add(LoadRecommendedCandidatesEvent());
    bloc.add(LoadContactAccessEvent());
    bloc.add(LoadUnlockHistoryEvent());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
      child: BlocListener<VacancyBloc, VacancyState>(
        listenWhen: (prev, curr) => prev.unlockStatus != curr.unlockStatus,
        listener: (context, state) {
          if (state.unlockStatus.isSuccess && state.unlockResult != null) {
            _showUnlockSuccessSheet(context, state.unlockResult!);
          } else if (state.unlockStatus.isFailure) {
            final msg = state.error?.errorMessage ?? 'Xatolik';
            final isInsufficientBalance =
                state.error?.errorCode == 402;
            if (isInsufficientBalance) {
              _showInsufficientBalanceDialog(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(msg), backgroundColor: Colors.red),
              );
            }
          }
        },
        child: Scaffold(
          backgroundColor: LIGHT_GRAY_BG,
          body: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _CandidatesTab(
                      searchQuery: _searchQuery,
                      onSearchChanged: (v) =>
                          setState(() => _searchQuery = v.toLowerCase()),
                    ),
                    const _RecommendedTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 0,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Nomzodlar',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 2),
                    Text('60%+ mos va tasdiqlangan',
                        style: TextStyle(color: Colors.white54, fontSize: 13)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const UnlockHistoryScreen())),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.history, color: Colors.white70, size: 16),
                      SizedBox(width: 4),
                      Text('Tarix',
                          style:
                              TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TabBar(
            controller: _tabController,
            indicatorColor: PRIMARY_BLUE,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            labelStyle:
                const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            tabs: const [
              Tab(text: 'Mos nomzodlar'),
              Tab(text: 'Tavsiya etilgan'),
            ],
          ),
        ],
      ),
    );
  }

  void _showUnlockSuccessSheet(
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
                  style:
                      const TextStyle(fontSize: 14, color: GRAY_TEXT)),
            ],
            const SizedBox(height: 8),
            if (!result.free && result.fee > 0)
              Text(
                '${_formatAmount(result.fee)} so\'m yechildi • Qolgan balans: ${_formatAmount(result.balance ?? 0)} so\'m',
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

  void _showInsufficientBalanceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Balans yetarli emas',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: DARK_NAVY)),
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
                      builder: (_) =>
                          const TopUpScreen(isEmployer: true)));
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

  String _formatAmount(int amount) {
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

// ── Mos nomzodlar tab ─────────────────────────────────────────────────────────

class _CandidatesTab extends StatelessWidget {
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;

  const _CandidatesTab(
      {required this.searchQuery, required this.onSearchChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12)),
            child: TextField(
              onChanged: onSearchChanged,
              style: const TextStyle(color: DARK_NAVY, fontSize: 14),
              decoration: const InputDecoration(
                hintText: "Ism yoki kasb bo'yicha...",
                hintStyle: TextStyle(color: GRAY_TEXT),
                prefixIcon: Icon(Icons.search, color: GRAY_TEXT, size: 20),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
            ),
          ),
        ),
        Expanded(
          child: BlocBuilder<VacancyBloc, VacancyState>(
            builder: (context, state) {
              if (state.candidatesStatus.isInProgress) {
                return const Center(
                    child: CircularProgressIndicator(color: PRIMARY_BLUE));
              }
              if (state.candidatesStatus == FormzSubmissionStatus.failure) {
                return _ErrorView(
                  message:
                      state.error?.errorMessage ?? 'Xato yuz berdi',
                  onRetry: () =>
                      context.read<VacancyBloc>().add(LoadCandidatesEvent()),
                );
              }
              var candidates = state.candidates;
              if (searchQuery.isNotEmpty) {
                candidates = candidates.where((c) {
                  final name = (c.fullname ?? '').toLowerCase();
                  final job = (c.jobTypeName ?? '').toLowerCase();
                  return name.contains(searchQuery) ||
                      job.contains(searchQuery);
                }).toList();
              }
              if (candidates.isEmpty) {
                return _EmptyView(
                    icon: searchQuery.isEmpty
                        ? Icons.work_outline
                        : Icons.search_off,
                    message: searchQuery.isEmpty
                        ? 'Avval vakansiya joylang'
                        : 'Qidiruv natijasi topilmadi',
                    subtitle: searchQuery.isEmpty
                        ? 'Vakansiya qo\'shilgach mos nomzodlar bu yerda ko\'rinadi'
                        : null);
              }
              return RefreshIndicator(
                color: PRIMARY_BLUE,
                onRefresh: () async =>
                    context.read<VacancyBloc>().add(LoadCandidatesEvent()),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text('${candidates.length} ta nomzod',
                          style: const TextStyle(
                              fontSize: 13, color: GRAY_TEXT)),
                    ),
                    ...candidates.map((c) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _CandidateCard(candidate: c),
                        )),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Tavsiya etilgan tab ───────────────────────────────────────────────────────

class _RecommendedTab extends StatelessWidget {
  const _RecommendedTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VacancyBloc, VacancyState>(
      builder: (context, state) {
        if (state.recommendedStatus.isInProgress) {
          return const Center(
              child: CircularProgressIndicator(color: PRIMARY_BLUE));
        }
        if (state.recommendedCandidates.isEmpty) {
          return const _EmptyView(
              message: "Operator yo'naltirgach ko'rinadi",
              subtitle: 'Operator tavsiya qilgan nomzodlar kontakti bepul ochiladi');
        }
        return RefreshIndicator(
          color: PRIMARY_BLUE,
          onRefresh: () async => context
              .read<VacancyBloc>()
              .add(LoadRecommendedCandidatesEvent()),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: GREEN_COLOR.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.star, color: GREEN_COLOR, size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Operator tavsiya qilgan nomzodlar kontakti bepul ochiladi',
                          style: TextStyle(fontSize: 12, color: Color(0xFF166534)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 4),
              ...state.recommendedCandidates.map((c) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _CandidateCard(candidate: c, isRecommended: true),
                  )),
            ],
          ),
        );
      },
    );
  }
}

// ── Kandidat kartasi ──────────────────────────────────────────────────────────

class _CandidateCard extends StatelessWidget {
  final CandidateModel candidate;
  final bool isRecommended;

  const _CandidateCard({required this.candidate, this.isRecommended = false});

  Color get _matchColor {
    final p = candidate.matchPercent;
    if (p >= 80) return const Color(0xFF16A34A);
    if (p >= 60) return PRIMARY_BLUE;
    return const Color(0xFFF97316);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VacancyBloc, VacancyState>(
      builder: (context, vacState) {
        final phone = candidate.phoneRaw ??
            vacState.unlockedPhones[candidate.id];
        final isUnlocked = candidate.isUnlocked ||
            vacState.unlockedAnketaIds.contains(candidate.id) ||
            isRecommended;
        final isUnlocking = vacState.unlockStatus.isInProgress;
        final access = vacState.contactAccess;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: isRecommended
                    ? GREEN_COLOR.withValues(alpha: 0.3)
                    : const Color(0xFFE5E7EB)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row: avatar + info + badge
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [
                              PRIMARY_BLUE.withValues(alpha: 0.8),
                              SECONDARY_BLUE
                            ]),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(candidate.initials,
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      candidate.fullname ?? "Ism noma'lum",
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: DARK_NAVY),
                                    ),
                                  ),
                                  if (isRecommended)
                                    _Badge('Tavsiya', GREEN_COLOR)
                                  else if (candidate.matchPercent > 0)
                                    _Badge('${candidate.matchPercent}%',
                                        _matchColor),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                candidate.jobTypeName ?? 'Kasb ko\'rsatilmagan',
                                style: const TextStyle(
                                    fontSize: 12, color: GRAY_TEXT),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Meta row: region · yosh · oylik
                    Wrap(
                      spacing: 12,
                      runSpacing: 4,
                      children: [
                        if (candidate.region != null)
                          _MetaChip(
                              Icons.location_on_outlined,
                              candidate.region!.name),
                        if (candidate.age != null)
                          _MetaChip(Icons.cake_outlined,
                              '${candidate.age} yosh'),
                        if (candidate.expectedSalary != null)
                          _MetaChip(Icons.attach_money,
                              candidate.salaryDisplay),
                      ],
                    ),
                    // Assignment status for recommended
                    if (isRecommended && candidate.assignment != null) ...[
                      const SizedBox(height: 8),
                      _AssignmentChip(candidate.assignment!.status),
                    ],
                  ],
                ),
              ),
              // Phone or unlock + detail buttons
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: Color(0xFFF8FAFC),
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(16)),
                ),
                child: isUnlocked && phone != null
                    ? _PhoneRow(phone: phone)
                    : _ActionRow(
                        candidate: candidate,
                        access: access,
                        isUnlocking: isUnlocking,
                        isRecommended: isRecommended,
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
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(text,
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.bold, color: color)),
      );
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaChip(this.icon, this.label);

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: GRAY_TEXT),
          const SizedBox(width: 3),
          Text(label,
              style: const TextStyle(fontSize: 12, color: GRAY_TEXT)),
        ],
      );
}

class _AssignmentChip extends StatelessWidget {
  final String status;
  const _AssignmentChip(this.status);

  static const _labels = {
    'yangi': 'Yangi',
    'ko\'rib_chiqilmoqda': "Ko'rib chiqilmoqda",
    'suhbatga_yozildi': 'Suhbatga belgilandi',
    'qabul_qilindi': 'Qabul qilindi',
    'rad_etildi': 'Rad etildi',
  };

  @override
  Widget build(BuildContext context) {
    final label = _labels[status] ?? status;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: GREEN_COLOR.withValues(alpha: 0.3)),
      ),
      child: Text(label,
          style: const TextStyle(fontSize: 11, color: GREEN_COLOR)),
    );
  }
}

class _PhoneRow extends StatelessWidget {
  final String phone;
  const _PhoneRow({required this.phone});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: GREEN_COLOR.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.phone, color: GREEN_COLOR, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(phone,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: DARK_NAVY)),
          ),
          const Icon(Icons.check_circle, color: GREEN_COLOR, size: 16),
        ],
      );
}

class _ActionRow extends StatelessWidget {
  final CandidateModel candidate;
  final ContactAccessModel? access;
  final bool isUnlocking;
  final bool isRecommended;

  const _ActionRow({
    required this.candidate,
    required this.access,
    required this.isUnlocking,
    required this.isRecommended,
  });

  void _onUnlock(BuildContext context) {
    final isFree = isRecommended || (access?.freeContacts ?? false);
    if (isFree) {
      context
          .read<VacancyBloc>()
          .add(UnlockContactEvent(anketaId: candidate.id));
      return;
    }
    final fee = access?.fee ?? 30000;
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
                  .add(UnlockContactEvent(anketaId: candidate.id));
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

  @override
  Widget build(BuildContext context) {
    final isFree = isRecommended || (access?.freeContacts ?? false);
    final fee = access?.fee ?? 30000;
    final unlockLabel =
        isFree ? 'Bepul ochish' : 'Ochish · ${_fmt(fee)} so\'m';

    return Row(
      children: [
        // Batafsil
        Expanded(
          child: SizedBox(
            height: 36,
            child: OutlinedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CandidateDetailScreen(
                    candidateId: candidate.id,
                    card: candidate,
                  ),
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: DARK_NAVY,
                side: const BorderSide(color: Color(0xFFE5E7EB)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: EdgeInsets.zero,
              ),
              child: const Text('Batafsil',
                  style: TextStyle(fontSize: 13)),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Unlock
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 36,
            child: ElevatedButton.icon(
              onPressed: isUnlocking ? null : () => _onUnlock(context),
              icon: isUnlocking
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : Icon(
                      isFree ? Icons.lock_open : Icons.lock_open_outlined,
                      size: 15),
              label: Text(unlockLabel,
                  style: const TextStyle(fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: isFree ? GREEN_COLOR : PRIMARY_BLUE,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Helpers ────────────────────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  final String message;
  final String? subtitle;
  final IconData icon;

  const _EmptyView({
    required this.message,
    this.subtitle,
    this.icon = Icons.people_outline,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: GRAY_TEXT),
            const SizedBox(height: 16),
            Text(message,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: DARK_NAVY),
                textAlign: TextAlign.center),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(subtitle!,
                  style: const TextStyle(fontSize: 12, color: GRAY_TEXT),
                  textAlign: TextAlign.center),
            ],
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
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
                  foregroundColor: Colors.white,
                  elevation: 0),
              child: const Text('Qayta urinish'),
            ),
          ],
        ),
      ),
    );
  }
}
