import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../../../../core/constants/colors.dart';
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

  void _buy(PremiumTariffModel tariff) {
    setState(() => _buyingId = tariff.id);
    context.read<BillingBloc>().add(BuyPremiumEvent(tariff.id));
  }

  void _showInsufficientDialog(String? message) {
    showDialog(
      context: context,
      builder:
          (dCtx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Balans yetarli emas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: DARK_NAVY,
              ),
            ),
            content: Text(
              message ?? 'Premium sotib olish uchun balansni to\'ldiring.',
              style: const TextStyle(fontSize: 14, color: GRAY_TEXT),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dCtx),
                child: const Text('Bekor', style: TextStyle(color: GRAY_TEXT)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: PRIMARY_BLUE,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(dCtx);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const TopUpScreen(isEmployer: false),
                    ),
                  );
                },
                child: const Text('Balansni to\'ldirish'),
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
              setState(() => _buyingId = null);
              if (state.error?.errorCode == 402) {
                _showInsufficientDialog(state.error?.errorMessage);
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
                          p.premiumStatus != c.premiumStatus,
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
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: buying ? null : () => _buy(tariff),
              style: ElevatedButton.styleFrom(
                backgroundColor: PRIMARY_BLUE,
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
                      : const Text(
                        'Sotib olish (balansdan)',
                        style: TextStyle(
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
