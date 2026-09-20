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

  // ── Otklik do'koni ──
  final OtklikShopModel? otklik;
  final FormzSubmissionStatus otklikStatus;

  final SubscriptionTariffsModel? tariffs;
  final FormzSubmissionStatus tariffsStatus;

  /// Oxirgi sotib olish natijasi (to'lov havolasi / darhol faollashgani).
  final PurchaseResult? purchase;
  final FormzSubmissionStatus purchaseStatus;

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
    this.otklik,
    this.otklikStatus = FormzSubmissionStatus.initial,
    this.tariffs,
    this.tariffsStatus = FormzSubmissionStatus.initial,
    this.purchase,
    this.purchaseStatus = FormzSubmissionStatus.initial,
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
    OtklikShopModel? otklik,
    FormzSubmissionStatus? otklikStatus,
    SubscriptionTariffsModel? tariffs,
    FormzSubmissionStatus? tariffsStatus,
    PurchaseResult? purchase,
    FormzSubmissionStatus? purchaseStatus,
    ErrorModel? error,
    bool clearCheckout = false,
    bool clearPayment = false,
    bool clearPendingInvoice = false,
    bool clearPurchase = false,
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
      otklik: otklik ?? this.otklik,
      otklikStatus: otklikStatus ?? this.otklikStatus,
      tariffs: tariffs ?? this.tariffs,
      tariffsStatus: tariffsStatus ?? this.tariffsStatus,
      purchase: clearPurchase ? null : (purchase ?? this.purchase),
      purchaseStatus: purchaseStatus ?? this.purchaseStatus,
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
    otklik,
    otklikStatus,
    tariffs,
    tariffsStatus,
    purchase,
    purchaseStatus,
    error,
  ];
}
