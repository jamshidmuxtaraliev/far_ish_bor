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
  final int? tariffId;

  const CreateCheckoutEvent({
    required this.paymentSystemId,
    this.amount,
    this.tariffId,
  });

  @override
  List<Object?> get props => [paymentSystemId, amount, tariffId];
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

class LoadPremiumTariffsEvent extends BillingEvent {
  const LoadPremiumTariffsEvent();
}

class BuyPremiumEvent extends BillingEvent {
  final int tariffId;
  const BuyPremiumEvent(this.tariffId);

  @override
  List<Object?> get props => [tariffId];
}

class ResetCheckoutEvent extends BillingEvent {
  const ResetCheckoutEvent();
}

class LoadEmployerInvoicesEvent extends BillingEvent {
  const LoadEmployerInvoicesEvent();
}
