import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../../../../core/constants/colors.dart';
import '../../data/models/balance_model.dart';
import '../../data/models/premium_tariff_model.dart';
import '../logic/billing_bloc.dart';
import 'topup_screen.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  int? _buyingId;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<BillingBloc>();
    bloc.add(const LoadBalanceEvent(false));
    bloc.add(const LoadPremiumTariffsEvent());
  }

  PremiumTariffModel? _tariffById(int? id) {
    if (id == null) return null;
    for (final t in context.read<BillingBloc>().state.premiumTariffs) {
      if (t.id == id) return t;
    }
    return null;
  }

  /// How much the balance is short for [tariff], or null when it covers the
  /// price (or the balance isn't loaded yet — then the server decides).
  int? _shortfall(PremiumTariffModel tariff) {
    final balance = context.read<BillingBloc>().state.balance;
    if (balance == null) return null;
    final missing = tariff.currentPrice - balance.balance;
    return missing > 0 ? missing : null;
  }

  /// Rounds a shortfall up to the nearest 1000 so the suggested top-up is a
  /// clean sum.
  static int _roundUp(int amount) => ((amount + 999) ~/ 1000) * 1000;

  void _buy(PremiumTariffModel tariff) {
    // Warn before spending a request: the balance can't cover this tariff.
    final missing = _shortfall(tariff);
    if (missing != null) {
      _showInsufficientDialog(tariff: tariff, missing: missing);
      return;
    }
    setState(() => _buyingId = tariff.id);
    context.read<BillingBloc>().add(BuyPremiumEvent(tariff.id));
  }

  Future<void> _showInsufficientDialog({
    PremiumTariffModel? tariff,
    int? missing,
    String? message,
  }) async {
    final balance = context.read<BillingBloc>().state.balance;
    final goTopUp = await showDialog<bool>(
      context: context,
      builder:
          (dCtx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Row(
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Color(0xFFD97706),
                  size: 22,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Balans yetarli emas',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: DARK_NAVY,
                    ),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message ??
                      (tariff != null
                          ? '"${tariff.name.isNotEmpty ? tariff.name : 'Premium'}" tarifini sotib olish uchun balansingizda mablag\' yetarli emas.'
                          : 'Premium sotib olish uchun balansni to\'ldiring.'),
                  style: const TextStyle(
                    fontSize: 14,
                    color: GRAY_TEXT,
                    height: 1.4,
                  ),
                ),
                if (tariff != null || balance != null || missing != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      children: [
                        if (tariff != null)
                          _summaryRow('Tarif narxi', tariff.priceDisplay),
                        if (balance != null)
                          _summaryRow('Balansingiz', balance.balanceDisplay),
                        if (missing != null)
                          _summaryRow(
                            'Yetishmayapti',
                            formatSom(missing),
                            highlight: true,
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dCtx, false),
                child: const Text('Bekor', style: TextStyle(color: GRAY_TEXT)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: PRIMARY_BLUE,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.pop(dCtx, true),
                child: const Text('Balansni to\'ldirish'),
              ),
            ],
          ),
    );

    if (goTopUp != true || !mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) => TopUpScreen(
              isEmployer: false,
              initialAmount: missing != null ? _roundUp(missing) : null,
            ),
      ),
    );
    if (!mounted) return;
    // Balance may have changed while topping up — refresh so the next tap
    // sees the new amount.
    context.read<BillingBloc>().add(const LoadBalanceEvent(false));
  }

  Widget _summaryRow(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: GRAY_TEXT)),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: highlight ? FontWeight.bold : FontWeight.w600,
              color: highlight ? const Color(0xFFDC2626) : DARK_NAVY,
            ),
          ),
        ],
      ),
    );
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
      child: Scaffold(
        backgroundColor: JB_BG,
        body: BlocListener<BillingBloc, BillingState>(
          listenWhen: (p, c) => p.buyPremiumStatus != c.buyPremiumStatus,
          listener: (context, state) {
            if (state.buyPremiumStatus == FormzSubmissionStatus.success) {
              setState(() => _buyingId = null);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ Premium faollashtirildi'),
                  backgroundColor: Color(0xFF10B981),
                ),
              );
            }
            if (state.buyPremiumStatus == FormzSubmissionStatus.failure) {
              final attempted = _tariffById(_buyingId);
              setState(() => _buyingId = null);
              if (state.error?.errorCode == 402) {
                // Server-side guard: balance was stale or changed meanwhile.
                context.read<BillingBloc>().add(const LoadBalanceEvent(false));
                _showInsufficientDialog(
                  tariff: attempted,
                  missing:
                      attempted != null ? _shortfall(attempted) : null,
                  message: state.error?.errorMessage,
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      state.error?.errorMessage ?? 'Xatolik yuz berdi',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: BlocBuilder<BillingBloc, BillingState>(
                  buildWhen:
                      (p, c) =>
                          p.premiumTariffs != c.premiumTariffs ||
                          p.premiumStatus != c.premiumStatus ||
                          p.balance != c.balance,
                  builder: (context, state) {
                    if (state.premiumStatus ==
                            FormzSubmissionStatus.inProgress &&
                        state.premiumTariffs.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(color: PRIMARY_BLUE),
                      );
                    }
                    if (state.premiumTariffs.isEmpty) {
                      return const Center(
                        child: Text(
                          'Hozircha tarif mavjud emas',
                          style: TextStyle(color: GRAY_TEXT),
                        ),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.premiumTariffs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder:
                          (_, i) => _buildTariffCard(state.premiumTariffs[i]),
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

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 12,
        right: 20,
        bottom: 16,
      ),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: JB_INK,
                  size: 20,
                ),
              ),
              const Icon(
                Icons.workspace_premium,
                color: Color(0xFFFBBF24),
                size: 22,
              ),
              const SizedBox(width: 8),
              const Text(
                'Premium',
                style: TextStyle(
                  color: JB_INK,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: BlocBuilder<BillingBloc, BillingState>(
              buildWhen: (p, c) => p.balance != c.balance,
              builder:
                  (context, state) => Text(
                    'Balans: ${state.balance?.balanceDisplay ?? '—'}',
                    style: const TextStyle(color: JB_GRAY, fontSize: 13),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTariffCard(PremiumTariffModel tariff) {
    final buying = _buyingId == tariff.id;
    final missing = _shortfall(tariff);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.workspace_premium,
                  color: Color(0xFFD97706),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tariff.name.isNotEmpty ? tariff.name : 'Premium',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: DARK_NAVY,
                      ),
                    ),
                    if (tariff.durationDisplay.isNotEmpty)
                      Text(
                        tariff.durationDisplay,
                        style: const TextStyle(fontSize: 13, color: GRAY_TEXT),
                      ),
                  ],
                ),
              ),
              Text(
                tariff.priceDisplay,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: PRIMARY_BLUE,
                ),
              ),
            ],
          ),
          if (missing != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Color(0xFFD97706),
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Balans yetarli emas — ${formatSom(missing)} yetishmayapti',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF92400E),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: buying ? null : () => _buy(tariff),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    missing != null ? const Color(0xFFD97706) : PRIMARY_BLUE,
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFFCBD5E1),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child:
                  buying
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                      : Text(
                        missing != null
                            ? 'Balansni to\'ldirish'
                            : 'Sotib olish (balansdan)',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
            ),
          ),
        ],
      ),
    );
  }
}
