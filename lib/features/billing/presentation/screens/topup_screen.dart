import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/theme/jb_ui.dart';
import '../../data/models/balance_model.dart';
import '../../data/models/online_payment_model.dart';
import '../../data/models/payment_system_model.dart';
import '../logic/billing_bloc.dart';

class TopUpScreen extends StatefulWidget {
  /// Employer vs job-seeker balance (different endpoints).
  final bool isEmployer;
  const TopUpScreen({super.key, required this.isEmployer});

  @override
  State<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends State<TopUpScreen> {
  static const _presets = [50000, 100000, 200000, 500000, 1000000];
  // Poll roughly every 3s; give up after ~5 minutes.
  static const _maxPollTicks = 100;

  final _amountCtrl = TextEditingController();
  int? _selectedAmount;
  int? _selectedSystemId;

  Timer? _pollTimer;
  int _pollTicks = 0;
  bool _waiting = false;
  bool _testMode = false;
  bool _checkoutHandled = false;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<BillingBloc>();
    bloc.add(LoadBalanceEvent(widget.isEmployer));
    bloc.add(const LoadPaymentSystemsEvent());
    if (widget.isEmployer) {
      bloc.add(const LoadEmployerInvoicesEvent());
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _amountCtrl.dispose();
    super.dispose();
  }

  int? get _amount {
    if (_selectedAmount != null) return _selectedAmount;
    final raw = _amountCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
    final v = int.tryParse(raw);
    return (v != null && v > 0) ? v : null;
  }

  bool get _canPay => _amount != null && _selectedSystemId != null && !_waiting;

  void _snack(String message, {Color? color}) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  void _onPayPressed() {
    FocusScope.of(context).unfocus();
    final amount = _amount;
    if (amount == null || _selectedSystemId == null) return;
    _checkoutHandled = false;
    context.read<BillingBloc>().add(
      CreateCheckoutEvent(paymentSystemId: _selectedSystemId!, amount: amount),
    );
  }

  void _onCheckoutReady(CheckoutResponse checkout) {
    if (checkout.needsTestConfirm) {
      // Test provider: no WebView — user confirms in-app via test-confirm.
      setState(() {
        _waiting = true;
        _testMode = true;
      });
      return;
    }
    _launchCheckout(checkout);
  }

  Future<void> _launchCheckout(CheckoutResponse checkout) async {
    final url = checkout.checkoutUrl;
    if (url == null || url.isEmpty) {
      _snack(
        'To\'lov havolasi olinmadi. Provayder sozlamasini tekshiring.',
        color: Colors.red,
      );
      return;
    }
    final launched = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (!launched) {
      _snack('To\'lov sahifasi ochilmadi', color: Colors.red);
      return;
    }
    setState(() {
      _waiting = true;
      _testMode = false;
    });
    _startPolling(checkout.payment.id);
  }

  void _confirmTestPayment() {
    final pay = context.read<BillingBloc>().state.payment;
    if (pay == null) return;
    context.read<BillingBloc>().add(
      ConfirmTestPaymentEvent(id: pay.id, isEmployer: widget.isEmployer),
    );
  }

  void _startPolling(int paymentId) {
    _pollTimer?.cancel();
    _pollTicks = 0;
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _pollTicks++;
      if (_pollTicks > _maxPollTicks) {
        _stopWaiting();
        _snack(
          'To\'lov vaqti tugadi. Keyinroq tekshiring.',
          color: Colors.orange,
        );
        return;
      }
      context.read<BillingBloc>().add(PollPaymentStatusEvent(paymentId));
    });
  }

  void _stopWaiting() {
    _pollTimer?.cancel();
    _pollTimer = null;
    if (mounted) {
      setState(() {
        _waiting = false;
        _testMode = false;
      });
    }
    context.read<BillingBloc>().add(const ResetCheckoutEvent());
  }

  void _onPaid() {
    _pollTimer?.cancel();
    _pollTimer = null;
    setState(() {
      _waiting = false;
      _testMode = false;
    });
    context.read<BillingBloc>().add(LoadBalanceEvent(widget.isEmployer));
    context.read<BillingBloc>().add(const ResetCheckoutEvent());
    showDialog(
      context: context,
      builder:
          (dCtx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF10B981),
                  size: 56,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Hisob to\'ldirildi',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: DARK_NAVY,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Balansingiz yangilandi',
                  style: TextStyle(fontSize: 13, color: GRAY_TEXT),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dCtx),
                child: const Text('Yopish'),
              ),
            ],
          ),
    );
  }

  void _onFailed() {
    _pollTimer?.cancel();
    _pollTimer = null;
    setState(() {
      _waiting = false;
      _testMode = false;
    });
    context.read<BillingBloc>().add(const ResetCheckoutEvent());
    _snack('To\'lov amalga oshmadi yoki bekor qilindi', color: Colors.red);
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
          listenWhen:
              (p, c) =>
                  p.checkoutStatus != c.checkoutStatus ||
                  p.payment != c.payment ||
                  p.confirmStatus != c.confirmStatus ||
                  p.blacklistPayStatus != c.blacklistPayStatus,
          listener: (context, state) {
            if (state.checkoutStatus == FormzSubmissionStatus.success &&
                state.checkout != null &&
                !_checkoutHandled) {
              _checkoutHandled = true;
              _onCheckoutReady(state.checkout!);
            }
            if (state.checkoutStatus == FormzSubmissionStatus.failure) {
              _snack(
                state.error?.errorMessage ?? 'To\'lov boshlanmadi',
                color: Colors.red,
              );
            }
            if (state.confirmStatus == FormzSubmissionStatus.failure) {
              _snack(
                state.error?.errorMessage ?? 'Tasdiqlash amalga oshmadi',
                color: Colors.red,
              );
            }
            if (state.blacklistPayStatus == FormzSubmissionStatus.success) {
              _snack(
                'Siz qora ro\'yxatdan chiqdingiz',
                color: const Color(0xFF10B981),
              );
            }
            if (state.blacklistPayStatus == FormzSubmissionStatus.failure) {
              _snack(
                state.error?.errorCode == 402
                    ? 'Balans yetarli emas — avval to\'ldiring'
                    : (state.error?.errorMessage ?? 'Xatolik yuz berdi'),
                color: Colors.red,
              );
            }
            final pay = state.payment;
            if (_waiting && pay != null) {
              if (pay.isPaid) {
                _onPaid();
              } else if (pay.isFailed) {
                _onFailed();
              }
            }
          },
          child: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  _buildHeader(),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      20,
                      20,
                      MediaQuery.of(context).padding.bottom + 110,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        if (!widget.isEmployer) _buildBlacklistBanner(),
                        if (widget.isEmployer) _buildInvoiceBanner(),
                        _sectionTitle('Summa'),
                        const SizedBox(height: 10),
                        _buildPresets(),
                        const SizedBox(height: 12),
                        _buildManualField(),
                        const SizedBox(height: 24),
                        _sectionTitle('To\'lov tizimi'),
                        const SizedBox(height: 10),
                        _buildPaymentSystems(),
                      ]),
                    ),
                  ),
                ],
              ),
              _buildBottomBar(),
              if (_waiting) _buildWaitingOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 14,
          left: 20,
          right: 20,
          bottom: 8,
        ),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                JBCircleButton(onTap: () => Navigator.pop(context)),
                const SizedBox(width: 14),
                const Text(
                  'Balansni to\'ldirish',
                  style: TextStyle(
                    color: JB_INK,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.zero,
              child: BlocBuilder<BillingBloc, BillingState>(
                buildWhen:
                    (p, c) =>
                        p.balance != c.balance ||
                        p.balanceStatus != c.balanceStatus,
                builder: (context, state) {
                  final balance = state.balance;
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [JB_BLUE_DARK, JB_BLUE],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: JB_BLUE_DARK.withValues(alpha: 0.25),
                          blurRadius: 26,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Joriy balans',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 13.5),
                        ),
                        const SizedBox(height: 6),
                        if (state.balanceStatus ==
                                FormzSubmissionStatus.inProgress &&
                            balance == null)
                          const SizedBox(
                            height: 28,
                            width: 28,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        else
                          Text(
                            balance?.balanceDisplay ?? formatSom(0),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 15.5,
      fontWeight: FontWeight.w800,
      color: JB_INK,
    ),
  );

  // Blacklist banner (spec §6) — seeker only, shown when is_blacklisted.
  Widget _buildBlacklistBanner() {
    return BlocBuilder<BillingBloc, BillingState>(
      buildWhen:
          (p, c) =>
              p.balance != c.balance ||
              p.blacklistPayStatus != c.blacklistPayStatus,
      builder: (context, state) {
        final balance = state.balance;
        if (balance == null || !balance.isBlacklisted) {
          return const SizedBox.shrink();
        }
        final paying =
            state.blacklistPayStatus == FormzSubmissionStatus.inProgress;
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFFECACA)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.block, color: Color(0xFFDC2626), size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Siz qora ro\'yxatdasiz',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF991B1B),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                balance.blacklistReason?.isNotEmpty == true
                    ? balance.blacklistReason!
                    : 'Vakansiyalar ko\'rinmaydi va ariza yubora olmaysiz.',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF7F1D1D),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed:
                      paying
                          ? null
                          : () => context.read<BillingBloc>().add(
                            const PayBlacklistEvent(),
                          ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFFCA5A5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      paying
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                          : Text(
                            'Qora ro\'yxatdan chiqish · ${balance.blacklistFeeDisplay}',
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
      },
    );
  }

  Widget _buildInvoiceBanner() {
    return BlocBuilder<BillingBloc, BillingState>(
      buildWhen: (p, c) => p.pendingInvoice != c.pendingInvoice,
      builder: (context, state) {
        final pending = state.pendingInvoice;
        if (pending == null) return const SizedBox.shrink();
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E3A5F), Color(0xFF1D4ED8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.receipt_long,
                      color: Colors.white70, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      pending.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      pending.tariffCode?.toUpperCase() ?? 'PREMIUM',
                      style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${_fmtAmount(pending.amount)} so\'m',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Tarifni faollashtirish uchun quyida shu summani to\'lang',
                style: TextStyle(color: Colors.white60, fontSize: 12),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedAmount = pending.amount;
                    _amountCtrl.clear();
                  });
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text(
                      'Summani avtomatik kiritish',
                      style: TextStyle(
                          color: PRIMARY_BLUE,
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static String _fmtAmount(int amount) {
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

  Widget _buildPresets() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children:
          _presets.map((amount) {
            final selected = _selectedAmount == amount;
            return GestureDetector(
              onTap:
                  () => setState(() {
                    _selectedAmount = amount;
                    _amountCtrl.clear();
                  }),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: selected ? PRIMARY_BLUE : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected ? PRIMARY_BLUE : const Color(0xFFE5E7EB),
                  ),
                ),
                child: Text(
                  formatSom(amount),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : DARK_NAVY,
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildManualField() {
    return TextField(
      controller: _amountCtrl,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: (_) => setState(() => _selectedAmount = null),
      style: const TextStyle(
        fontSize: 16,
        color: DARK_NAVY,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: 'Boshqa summa',
        hintStyle: const TextStyle(color: GRAY_TEXT),
        suffixText: "so'm",
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: PRIMARY_BLUE, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildPaymentSystems() {
    return BlocBuilder<BillingBloc, BillingState>(
      buildWhen:
          (p, c) =>
              p.paymentSystems != c.paymentSystems ||
              p.systemsStatus != c.systemsStatus,
      builder: (context, state) {
        if (state.systemsStatus == FormzSubmissionStatus.inProgress &&
            state.paymentSystems.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: CircularProgressIndicator(
                color: PRIMARY_BLUE,
                strokeWidth: 2,
              ),
            ),
          );
        }
        if (state.paymentSystems.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: const Text(
              'Aktiv to\'lov tizimi topilmadi',
              style: TextStyle(color: GRAY_TEXT, fontSize: 13),
            ),
          );
        }
        return Column(
          children:
              state.paymentSystems.map((s) => _buildSystemTile(s)).toList(),
        );
      },
    );
  }

  Widget _buildSystemTile(PaymentSystemModel system) {
    final selected = _selectedSystemId == system.id;
    final color = _systemColor(system.code);
    return GestureDetector(
      onTap: () => setState(() => _selectedSystemId = system.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? PRIMARY_BLUE : const Color(0xFFE5E7EB),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  system.name.isNotEmpty ? system.name[0].toUpperCase() : '?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    system.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: DARK_NAVY,
                    ),
                  ),
                  if (system.isTest)
                    const Text(
                      'Sinov rejimi',
                      style: TextStyle(fontSize: 11, color: Color(0xFFF59E0B)),
                    ),
                ],
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? PRIMARY_BLUE : const Color(0xFFCBD5E1),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Color _systemColor(String code) {
    switch (code) {
      case 'payme':
        return const Color(0xFF0EA5E9);
      case 'click':
        return const Color(0xFF22C55E);
      case 'paynet':
        return const Color(0xFFEF4444);
      default:
        return PRIMARY_BLUE;
    }
  }

  Widget _buildBottomBar() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          MediaQuery.of(context).padding.bottom + 12,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BlocBuilder<BillingBloc, BillingState>(
          buildWhen:
              (p, c) =>
                  p.checkoutStatus != c.checkoutStatus ||
                  p.paymentSystems != c.paymentSystems,
          builder: (context, state) {
            final loading =
                state.checkoutStatus == FormzSubmissionStatus.inProgress ||
                _waiting;
            final selected = _selectedSystem(state.paymentSystems);
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (selected?.isTest == true) _buildTestNotice(),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: (_canPay && !loading) ? _onPayPressed : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PRIMARY_BLUE,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFFCBD5E1),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child:
                        loading
                            ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                            : Text(
                              _amount != null
                                  ? 'To\'lash · ${formatSom(_amount!)}'
                                  : 'To\'lash',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  PaymentSystemModel? _selectedSystem(List<PaymentSystemModel> systems) {
    for (final s in systems) {
      if (s.id == _selectedSystemId) return s;
    }
    return null;
  }

  Widget _buildTestNotice() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: const Row(
        children: [
          Text('🧪', style: TextStyle(fontSize: 16)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'TEST REJIMI — haqiqiy pul yechilmaydi',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF92400E),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.55),
        alignment: Alignment.center,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: _testMode ? _buildTestWaiting() : _buildRealWaiting(),
        ),
      ),
    );
  }

  Widget _buildRealWaiting() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(color: PRIMARY_BLUE),
        const SizedBox(height: 18),
        const Text(
          'To\'lov kutilmoqda',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: DARK_NAVY,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'To\'lovni yakunlagach bu yerga qayting. Holat avtomatik tekshiriladi.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: GRAY_TEXT),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _stopWaiting,
                style: OutlinedButton.styleFrom(
                  foregroundColor: GRAY_TEXT,
                  side: const BorderSide(color: Color(0xFFD1D5DB)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Bekor qilish'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  final pay = context.read<BillingBloc>().state.payment;
                  if (pay != null) {
                    context.read<BillingBloc>().add(
                      PollPaymentStatusEvent(pay.id),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: PRIMARY_BLUE,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Tekshirish'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTestWaiting() {
    return BlocBuilder<BillingBloc, BillingState>(
      buildWhen: (p, c) => p.confirmStatus != c.confirmStatus,
      builder: (context, state) {
        final confirming =
            state.confirmStatus == FormzSubmissionStatus.inProgress;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🧪', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 10),
            const Text(
              'Test to\'lov',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: DARK_NAVY,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'TEST REJIMI — haqiqiy pul yechilmaydi. Tasdiqlash uchun tugmani bosing.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: GRAY_TEXT),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: confirming ? null : _confirmTestPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFFFCD34D),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child:
                    confirming
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                        : const Text(
                          '🧪 Test to\'lovni tasdiqlash',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
              ),
            ),
            const SizedBox(height: 6),
            TextButton(
              onPressed: confirming ? null : _stopWaiting,
              child: const Text(
                'Bekor qilish',
                style: TextStyle(color: GRAY_TEXT),
              ),
            ),
          ],
        );
      },
    );
  }
}
