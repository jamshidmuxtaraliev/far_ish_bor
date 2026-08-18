import 'balance_model.dart';

/// online_payments.state oqimi: created → pending → paid (yoki cancelled / failed)
class OnlinePaymentModel {
  final int id;
  final String state;
  final int amount;
  final DateTime? paidAt;
  final bool isTest;

  const OnlinePaymentModel({
    required this.id,
    required this.state,
    this.amount = 0,
    this.paidAt,
    this.isTest = false,
  });

  factory OnlinePaymentModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      try {
        return DateTime.parse(v as String);
      } catch (_) {
        return null;
      }
    }

    return OnlinePaymentModel(
      id: json['id'] as int? ?? 0,
      state: json['state'] as String? ?? 'created',
      amount: parseAmount(json['amount']),
      paidAt: parseDate(json['paid_at']),
      isTest: json['is_test'] as bool? ?? false,
    );
  }

  bool get isPaid => state == 'paid';
  bool get isPending => state == 'created' || state == 'pending';
  bool get isFailed => state == 'cancelled' || state == 'failed';
}

/// Response of POST mobile/payments/checkout → { payment, checkoutUrl }
class CheckoutResponse {
  final OnlinePaymentModel payment;
  final String? checkoutUrl;
  final bool isTest;
  final String? testConfirmUrl;

  /// Dev simulyatsiyasi: server to'lovni o'zi yakunlagan va balansni to'ldirgan
  /// (PROMPT_OTKLIK_MOBILE.md §5.2 B-varianti). Prod'da hech qachon kelmaydi.
  final bool testCompleted;
  final int? balance;

  const CheckoutResponse({
    required this.payment,
    this.checkoutUrl,
    this.isTest = false,
    this.testConfirmUrl,
    this.testCompleted = false,
    this.balance,
  });

  factory CheckoutResponse.fromJson(Map<String, dynamic> json) {
    return CheckoutResponse(
      payment: OnlinePaymentModel.fromJson(
        json['payment'] as Map<String, dynamic>? ?? const {},
      ),
      checkoutUrl:
          json['checkoutUrl'] as String? ?? json['checkout_url'] as String?,
      isTest: json['is_test'] as bool? ?? false,
      testConfirmUrl: json['test_confirm_url'] as String?,
      testCompleted: json['test_completed'] as bool? ?? false,
      balance: parseAmount(json['balance']) == 0 ? null : parseAmount(json['balance']),
    );
  }

  /// True when the payment must be confirmed in-app (test provider, no WebView).
  bool get needsTestConfirm =>
      !testCompleted &&
      (isTest || (checkoutUrl == null || checkoutUrl!.isEmpty));
}
