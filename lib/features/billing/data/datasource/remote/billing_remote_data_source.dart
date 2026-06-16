import 'package:dartz/dartz.dart';

import '../../../../../core/error/error_model.dart';
import '../../../../../core/network/dio_client.dart';
import '../../../../../core/network/dio_response_extension.dart';
import '../../models/balance_model.dart';
import '../../models/invoice_model.dart';
import '../../models/online_payment_model.dart';
import '../../models/payment_system_model.dart';
import '../../models/premium_tariff_model.dart';

abstract class BillingRemoteDataSource {
  Future<Either<ErrorModel, BalanceModel>> getBalance({
    required bool isEmployer,
  });
  Future<Either<ErrorModel, List<PaymentSystemModel>>>
  getActivePaymentSystems();
  Future<Either<ErrorModel, CheckoutResponse>> createCheckout({
    required int paymentSystemId,
    int? amount,
    int? tariffId,
  });
  Future<Either<ErrorModel, OnlinePaymentModel>> getPaymentStatus(int id);

  /// Confirms a test-mode payment (is_test=true). Server simulates the provider
  /// and marks it paid — no real money. Returns 403 if the system isn't test.
  Future<Either<ErrorModel, bool>> confirmTestPayment(int id);

  /// Dev/test only: server adds amount to balance immediately (no real money).
  Future<Either<ErrorModel, bool>> topupTest({
    required bool isEmployer,
    required int amount,
  });

  /// Seeker: pays `blacklist_fee` from balance to leave the blacklist. 402 if insufficient.
  Future<Either<ErrorModel, bool>> payBlacklist();

  /// Employer 50% invoices — pending + history.
  Future<Either<ErrorModel, InvoiceListResponse>> getEmployerInvoices();

  /// Active premium tariffs (public).
  Future<Either<ErrorModel, List<PremiumTariffModel>>> getPremiumTariffs();

  /// Buys a premium tariff from balance. 402 if insufficient.
  Future<Either<ErrorModel, bool>> buyPremium(int tariffId);
}

class BillingRemoteDataSourceImpl implements BillingRemoteDataSource {
  final DioClient dioClient;

  BillingRemoteDataSourceImpl(this.dioClient);

  @override
  Future<Either<ErrorModel, BalanceModel>> getBalance({
    required bool isEmployer,
  }) {
    final path = isEmployer ? 'mobile/employer/balance' : 'mobile/balance';
    return dioClient.dio.wrapResponse<BalanceModel>(
      () => dioClient.dio.get(path),
      (json) => BalanceModel.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<Either<ErrorModel, List<PaymentSystemModel>>>
  getActivePaymentSystems() {
    return dioClient.dio.wrapResponse<List<PaymentSystemModel>>(
      () => dioClient.dio.get('payment-systems/active'),
      (json) =>
          (json as List)
              .map(
                (e) => PaymentSystemModel.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
    );
  }

  @override
  Future<Either<ErrorModel, CheckoutResponse>> createCheckout({
    required int paymentSystemId,
    int? amount,
    int? tariffId,
  }) {
    final data = <String, dynamic>{'payment_system_id': paymentSystemId};
    if (tariffId != null) {
      data['tariff_id'] = tariffId;
    } else if (amount != null) {
      data['amount'] = amount;
    }
    return dioClient.dio.wrapResponse<CheckoutResponse>(
      () => dioClient.dio.post('mobile/payments/checkout', data: data),
      (json) => CheckoutResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<Either<ErrorModel, OnlinePaymentModel>> getPaymentStatus(int id) {
    return dioClient.dio.wrapResponse<OnlinePaymentModel>(
      () => dioClient.dio.get('mobile/payments/$id'),
      (json) => OnlinePaymentModel.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<Either<ErrorModel, bool>> confirmTestPayment(int id) {
    return dioClient.dio.wrapResponse<bool>(
      () => dioClient.dio.post('mobile/payments/$id/test-confirm'),
      (_) => true,
    );
  }

  @override
  Future<Either<ErrorModel, bool>> topupTest({
    required bool isEmployer,
    required int amount,
  }) {
    final path =
        isEmployer ? 'mobile/employer/balance/topup' : 'mobile/balance/topup';
    return dioClient.dio.wrapResponse<bool>(
      () => dioClient.dio.post(path, data: {'amount': amount}),
      (_) => true,
    );
  }

  @override
  Future<Either<ErrorModel, bool>> payBlacklist() {
    return dioClient.dio.wrapResponse<bool>(
      () => dioClient.dio.post('mobile/blacklist/pay'),
      (_) => true,
    );
  }

  @override
  Future<Either<ErrorModel, InvoiceListResponse>> getEmployerInvoices() {
    return dioClient.dio.wrapResponse<InvoiceListResponse>(
      () => dioClient.dio.get('mobile/employer/invoices'),
      (json) => InvoiceListResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<Either<ErrorModel, List<PremiumTariffModel>>> getPremiumTariffs() {
    return dioClient.dio.wrapResponse<List<PremiumTariffModel>>(
      () => dioClient.dio.get('premium-tariffs/active'),
      (json) =>
          (json as List)
              .map(
                (e) => PremiumTariffModel.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
    );
  }

  @override
  Future<Either<ErrorModel, bool>> buyPremium(int tariffId) {
    return dioClient.dio.wrapResponse<bool>(
      () => dioClient.dio.post(
        'mobile/premium/buy',
        data: {'tariff_id': tariffId},
      ),
      (_) => true,
    );
  }
}
