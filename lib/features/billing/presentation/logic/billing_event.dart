part of 'billing_bloc.dart';

sealed class BillingEvent extends Equatable {
  const BillingEvent();

  @override
  List<Object?> get props => [];
}

class LoadBalanceEvent extends BillingEvent {
  final bool isEmployer;
  const LoadBalanceEvent(this.isEmployer);

  @override
  List<Object?> get props => [isEmployer];
}

class LoadPaymentSystemsEvent extends BillingEvent {
  const LoadPaymentSystemsEvent();
}

class CreateCheckoutEvent extends BillingEvent {
  final int paymentSystemId;
  final int? amount;

  const CreateCheckoutEvent({
    required this.paymentSystemId,
    this.amount,
  });

  @override
  List<Object?> get props => [paymentSystemId, amount];
}

class PollPaymentStatusEvent extends BillingEvent {
  final int id;
  const PollPaymentStatusEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class ConfirmTestPaymentEvent extends BillingEvent {
  final int id;
  final bool isEmployer;
  const ConfirmTestPaymentEvent({required this.id, required this.isEmployer});

  @override
  List<Object?> get props => [id, isEmployer];
}

class TestTopupEvent extends BillingEvent {
  final bool isEmployer;
  final int amount;
  const TestTopupEvent({required this.isEmployer, required this.amount});

  @override
  List<Object?> get props => [isEmployer, amount];
}

/// Seeker: pay the blacklist fee from balance to leave the blacklist.
class PayBlacklistEvent extends BillingEvent {
  const PayBlacklistEvent();
}

class ResetCheckoutEvent extends BillingEvent {
  const ResetCheckoutEvent();
}

class LoadEmployerInvoicesEvent extends BillingEvent {
  const LoadEmployerInvoicesEvent();
}

/// `GET /mobile/employer/otklik` — kvota + paketlar + balans.
class LoadOtklikShopEvent extends BillingEvent {
  const LoadOtklikShopEvent();
}

/// `GET /mobile/employer/subscription` — otklik obuna tariflari.
class LoadSubscriptionTariffsEvent extends BillingEvent {
  const LoadSubscriptionTariffsEvent();
}

class BuyOtklikPackageEvent extends BillingEvent {
  final int packageId;

  /// `link` — to'lov ilovasi (standart) · `balance` — hisobdan yechiladi.
  final String payMethod;

  const BuyOtklikPackageEvent(this.packageId, {this.payMethod = 'link'});

  @override
  List<Object?> get props => [packageId, payMethod];
}

class BuySubscriptionEvent extends BillingEvent {
  final int tariffId;
  final int months;
  final String payMethod;

  const BuySubscriptionEvent({
    required this.tariffId,
    required this.months,
    this.payMethod = 'link',
  });

  @override
  List<Object?> get props => [tariffId, months, payMethod];
}

class ResetPurchaseEvent extends BillingEvent {
  const ResetPurchaseEvent();
}
