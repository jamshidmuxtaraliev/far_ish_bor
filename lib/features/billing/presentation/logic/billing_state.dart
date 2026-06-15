part of 'billing_bloc.dart';

class BillingState extends Equatable {
  final BalanceModel? balance;
  final FormzSubmissionStatus balanceStatus;

  final List<PaymentSystemModel> paymentSystems;
  final FormzSubmissionStatus systemsStatus;

  final CheckoutResponse? checkout;
  final FormzSubmissionStatus checkoutStatus;

  final OnlinePaymentModel? payment;

  final FormzSubmissionStatus topupStatus;

  final FormzSubmissionStatus confirmStatus;

  final FormzSubmissionStatus blacklistPayStatus;

  final List<PremiumTariffModel> premiumTariffs;
  final FormzSubmissionStatus premiumStatus;
  final FormzSubmissionStatus buyPremiumStatus;

  final ErrorModel? error;

  const BillingState({
    this.balance,
    this.balanceStatus = FormzSubmissionStatus.initial,
    this.paymentSystems = const [],
    this.systemsStatus = FormzSubmissionStatus.initial,
    this.checkout,
    this.checkoutStatus = FormzSubmissionStatus.initial,
    this.payment,
    this.topupStatus = FormzSubmissionStatus.initial,
    this.confirmStatus = FormzSubmissionStatus.initial,
    this.blacklistPayStatus = FormzSubmissionStatus.initial,
    this.premiumTariffs = const [],
    this.premiumStatus = FormzSubmissionStatus.initial,
    this.buyPremiumStatus = FormzSubmissionStatus.initial,
    this.error,
  });

  BillingState copyWith({
    BalanceModel? balance,
    FormzSubmissionStatus? balanceStatus,
    List<PaymentSystemModel>? paymentSystems,
    FormzSubmissionStatus? systemsStatus,
    CheckoutResponse? checkout,
    FormzSubmissionStatus? checkoutStatus,
    OnlinePaymentModel? payment,
    FormzSubmissionStatus? topupStatus,
    FormzSubmissionStatus? confirmStatus,
    FormzSubmissionStatus? blacklistPayStatus,
    List<PremiumTariffModel>? premiumTariffs,
    FormzSubmissionStatus? premiumStatus,
    FormzSubmissionStatus? buyPremiumStatus,
    ErrorModel? error,
    bool clearCheckout = false,
    bool clearPayment = false,
  }) {
    return BillingState(
      balance: balance ?? this.balance,
      balanceStatus: balanceStatus ?? this.balanceStatus,
      paymentSystems: paymentSystems ?? this.paymentSystems,
      systemsStatus: systemsStatus ?? this.systemsStatus,
      checkout: clearCheckout ? checkout : (checkout ?? this.checkout),
      checkoutStatus: checkoutStatus ?? this.checkoutStatus,
      payment: clearPayment ? null : (payment ?? this.payment),
      topupStatus: topupStatus ?? this.topupStatus,
      confirmStatus: confirmStatus ?? this.confirmStatus,
      blacklistPayStatus: blacklistPayStatus ?? this.blacklistPayStatus,
      premiumTariffs: premiumTariffs ?? this.premiumTariffs,
      premiumStatus: premiumStatus ?? this.premiumStatus,
      buyPremiumStatus: buyPremiumStatus ?? this.buyPremiumStatus,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
    balance,
    balanceStatus,
    paymentSystems,
    systemsStatus,
    checkout,
    checkoutStatus,
    payment,
    topupStatus,
    confirmStatus,
    blacklistPayStatus,
    premiumTariffs,
    premiumStatus,
    buyPremiumStatus,
    error,
  ];
}
