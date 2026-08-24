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


  final List<InvoiceModel> invoices;
  final InvoiceModel? pendingInvoice;
  final FormzSubmissionStatus invoicesStatus;

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
    this.invoices = const [],
    this.pendingInvoice,
    this.invoicesStatus = FormzSubmissionStatus.initial,
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
    List<InvoiceModel>? invoices,
    InvoiceModel? pendingInvoice,
    FormzSubmissionStatus? invoicesStatus,
    ErrorModel? error,
    bool clearCheckout = false,
    bool clearPayment = false,
    bool clearPendingInvoice = false,
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
      invoices: invoices ?? this.invoices,
      pendingInvoice: clearPendingInvoice ? null : (pendingInvoice ?? this.pendingInvoice),
      invoicesStatus: invoicesStatus ?? this.invoicesStatus,
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
    invoices,
    pendingInvoice,
    invoicesStatus,
    error,
  ];
}
