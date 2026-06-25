import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../../../../core/constants/colors.dart';
import '../../../billing/presentation/logic/billing_bloc.dart';
import '../../../billing/presentation/screens/topup_screen.dart';
import '../logic/vacancy_bloc.dart';
import '../widgets/candidate_card.dart';
import '../widgets/pipeline_kanban.dart';
import '../widgets/state_views.dart';
import 'unlock_history_screen.dart';

// Tavsiya hinti rangi (binafsha, light) — PROMPT §3.3.
const _purpleBg = Color(0xFFEDE9FE);

/// "Nomzodlar" ekrani (PROMPT_NOMZODLAR_MOBILE.md).
/// Ikki manbali tekis ro'yxat:
///   • Tavsiya etilgan — operator yo'naltirgan nomzodlar (kontakt bepul)
///   • Qidiruv          — vakansiyalarga mos (smart-matching) nomzodlar (otklik haqi)
/// Ochilganda 5 ta so'rov parallel ketadi (candidates · recommended ·
/// contact-access · contact-unlock · balance).
class CandidatesScreen extends StatefulWidget {
  const CandidatesScreen({super.key});

  @override
  State<CandidatesScreen> createState() => _CandidatesScreenState();
}

class _CandidatesScreenState extends State<CandidatesScreen> {
  /// 0 = Tavsiya etilgan, 1 = Qidiruv.
  int _tab = 0;

  /// Tavsiya bo'sh bo'lsa avtomatik "Qidiruv"ga faqat bir marta o'tamiz.
  bool _autoSwitched = false;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  void _loadAll() {
    final vacancy = context.read<VacancyBloc>();
    vacancy.add(LoadRecommendedCandidatesEvent());
    vacancy.add(LoadPipelineEvent());
    vacancy.add(LoadContactAccessEvent());
    vacancy.add(LoadUnlockHistoryEvent());
    context.read<BillingBloc>().add(const LoadBalanceEvent(true));
  }

  void _maybeAutoSwitch(VacancyState state) {
    if (_autoSwitched || _tab != 0) return;
    if (state.recommendedStatus.isSuccess &&
        state.recommendedCandidates.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_autoSwitched) {
          setState(() {
            _autoSwitched = true;
            _tab = 1;
          });
        }
      });
    }
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
      child: CandidateUnlockListener(
        child: BlocListener<VacancyBloc, VacancyState>(
          // Biriktirish amali xato bo'lsa (ayniqsa kontakt gate — 402) xabar.
          listenWhen: (p, c) =>
              p.assignmentActionStatus != c.assignmentActionStatus,
          listener: _onAssignmentAction,
          child: BlocListener<VacancyBloc, VacancyState>(
            // Ochishdan keyin balansni yangilab qo'yamiz (header to'g'ri ko'rsin).
            listenWhen: (p, c) => p.unlockStatus != c.unlockStatus,
            listener: (context, state) {
              if (state.unlockStatus.isSuccess) {
                context.read<BillingBloc>().add(const LoadBalanceEvent(true));
              }
            },
            child: Scaffold(
              backgroundColor: LIGHT_GRAY_BG,
              body: Column(
                children: [
                  _buildHeader(context),
                  _buildTabs(),
                  Expanded(child: _buildBody()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onAssignmentAction(BuildContext context, VacancyState state) {
    if (!state.assignmentActionStatus.isFailure) return;
    final is402 = state.error?.errorCode == 402;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(is402
            ? 'Avval nomzod kontaktini oching'
            : (state.error?.errorMessage ?? 'Amalni bajarib bo\'lmadi')),
        backgroundColor: is402 ? AMBER_COLOR : RED_COLOR,
      ),
    );
  }

  // ── Header: sarlavha + balans/premium + tarix ────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 16,
      ),
      decoration: const BoxDecoration(
        color: DARK_NAVY,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
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
                Text('Sizga mos nomzodlar',
                    style: TextStyle(color: Colors.white54, fontSize: 13)),
              ],
            ),
          ),
          _buildBalanceChip(context),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const UnlockHistoryScreen())),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.history, color: Colors.white70, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  /// Premium bo'lsa → "Premium · bepul", aks holda → balans + to'ldirish.
  Widget _buildBalanceChip(BuildContext context) {
    return BlocBuilder<VacancyBloc, VacancyState>(
      buildWhen: (p, c) => p.contactAccess != c.contactAccess,
      builder: (context, vacState) {
        final premium = vacState.contactAccess?.freeContacts ?? false;
        if (premium) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: GREEN_COLOR.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.workspace_premium, color: Color(0xFF34D399), size: 16),
                SizedBox(width: 5),
                Text('Premium · kontaktlar bepul',
                    style: TextStyle(
                        color: Color(0xFFD1FAE5),
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          );
        }
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const TopUpScreen(isEmployer: true)),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: BlocBuilder<BillingBloc, BillingState>(
              buildWhen: (p, c) =>
                  p.balance != c.balance || p.balanceStatus != c.balanceStatus,
              builder: (context, billing) {
                final balance = billing.balance;
                final loading = balance == null &&
                    billing.balanceStatus.isInProgress;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      loading
                          ? '...'
                          : 'Balans: ${balance?.balanceDisplay ?? "0 so'm"}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 5),
                    const Icon(Icons.add_circle_outline,
                        color: Color(0xFF93C5FD), size: 16),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  // ── Tablar ────────────────────────────────────────────────────────────────────

  Widget _buildTabs() {
    return BlocBuilder<VacancyBloc, VacancyState>(
      buildWhen: (p, c) => p.recommendedCandidates != c.recommendedCandidates,
      builder: (context, state) {
        final recCount = state.recommendedCandidates.length;
        return Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              _tabItem(
                label: 'Tavsiya etilgan',
                icon: Icons.auto_awesome,
                badge: recCount,
                index: 0,
              ),
              _tabItem(
                label: 'Mos nomzodlar',
                icon: Icons.view_kanban_outlined,
                index: 1,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _tabItem({
    required String label,
    required IconData icon,
    required int index,
    int badge = 0,
  }) {
    final active = _tab == index;
    final color = active ? PRIMARY_BLUE : GRAY_TEXT;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => _tab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: active ? PRIMARY_BLUE : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                      color: color),
                ),
              ),
              if (badge > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('$badge',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: color)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ── Ro'yxat ─────────────────────────────────────────────────────────────────

  Widget _buildBody() {
    return BlocBuilder<VacancyBloc, VacancyState>(
      buildWhen: (p, c) =>
          p.recommendedStatus != c.recommendedStatus ||
          p.pipelineStatus != c.pipelineStatus ||
          p.recommendedCandidates != c.recommendedCandidates ||
          p.pipeline != c.pipeline ||
          p.contactAccess != c.contactAccess ||
          p.assignmentActionStatus != c.assignmentActionStatus ||
          p.unlockedAnketaIds != c.unlockedAnketaIds ||
          p.unlockedPhones != c.unlockedPhones,
      builder: (context, state) {
        _maybeAutoSwitch(state);
        return _tab == 0 ? _recommendedBody(state) : _pipelineBody(state);
      },
    );
  }

  // Tavsiya etilgan — tekis ro'yxat.
  Widget _recommendedBody(VacancyState state) {
    final list = state.recommendedCandidates;
    final status = state.recommendedStatus;

    if (status.isInProgress && list.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: PRIMARY_BLUE));
    }
    if (status == FormzSubmissionStatus.failure && list.isEmpty) {
      return ErrorView(
        message: state.error?.errorMessage ?? 'Xato yuz berdi',
        onRetry: _loadAll,
      );
    }
    if (list.isEmpty) return _emptyRecommended();

    return RefreshIndicator(
      color: PRIMARY_BLUE,
      onRefresh: () async => _loadAll(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _recommendHint(),
          ...list.map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: CandidateCard(candidate: c, isRecommended: true),
              )),
        ],
      ),
    );
  }

  // Mos nomzodlar — Kanban.
  Widget _pipelineBody(VacancyState state) {
    final status = state.pipelineStatus;
    if (status.isInProgress && state.pipeline == null) {
      return const Center(child: CircularProgressIndicator(color: PRIMARY_BLUE));
    }
    if (status == FormzSubmissionStatus.failure && state.pipeline == null) {
      return ErrorView(
        message: state.error?.errorMessage ?? 'Xato yuz berdi',
        onRetry: _loadAll,
      );
    }
    return PipelineKanban(state: state);
  }

  Widget _recommendHint() {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _purpleBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.auto_awesome, color: VIOLET, size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Operator siz uchun tanlagan nomzodlar — kontakti bepul ochiladi.',
              style: TextStyle(fontSize: 12.5, color: VIOLET, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyRecommended() {
    return EmptyView(
      icon: Icons.auto_awesome_outlined,
      message: 'Hozircha tavsiya yo\'q',
      subtitle:
          'Operator sizga mos nomzodlarni yo\'naltirgach, shu yerda ko\'rinadi',
      action: OutlinedButton.icon(
        onPressed: () => setState(() => _tab = 1),
        icon: const Icon(Icons.view_kanban_outlined, size: 18),
        style: OutlinedButton.styleFrom(
          foregroundColor: PRIMARY_BLUE,
          side: BorderSide(color: PRIMARY_BLUE.withValues(alpha: 0.5)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        label: const Text('Mos nomzodlar'),
      ),
    );
  }
}
