import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';

import '../../../../core/error/error_model.dart';
import '../../data/datasource/remote/billing_remote_data_source.dart';
import '../../data/models/balance_model.dart';
import '../../data/models/online_payment_model.dart';
import '../../data/models/payment_system_model.dart';
import '../../data/models/premium_tariff_model.dart';

part 'billing_event.dart';
part 'billing_state.dart';

class BillingBloc extends Bloc<BillingEvent, BillingState> {
  final BillingRemoteDataSource dataSource;

  BillingBloc(this.dataSource) : super(const BillingState()) {
    on<LoadBalanceEvent>(_onLoadBalance);
    on<LoadPaymentSystemsEvent>(_onLoadPaymentSystems);
    on<CreateCheckoutEvent>(_onCreateCheckout);
    on<PollPaymentStatusEvent>(_onPollPaymentStatus);
    on<ConfirmTestPaymentEvent>(_onConfirmTestPayment);
    on<TestTopupEvent>(_onTestTopup);
    on<PayBlacklistEvent>(_onPayBlacklist);
    on<LoadPremiumTariffsEvent>(_onLoadPremiumTariffs);
    on<BuyPremiumEvent>(_onBuyPremium);
    on<ResetCheckoutEvent>(_onResetCheckout);
  }

  Future<void> _onLoadBalance(
    LoadBalanceEvent event,
    Emitter<BillingState> emit,
  ) async {
    emit(state.copyWith(balanceStatus: FormzSubmissionStatus.inProgress));
    final result = await dataSource.getBalance(isEmployer: event.isEmployer);
    result.fold(
      (failure) => emit(
        state.copyWith(
          balanceStatus: FormzSubmissionStatus.failure,
          error: failure,
        ),
      ),
      (balance) => emit(
        state.copyWith(
          balanceStatus: FormzSubmissionStatus.success,
          balance: balance,
        ),
      ),
    );
  }

  Future<void> _onLoadPaymentSystems(
    LoadPaymentSystemsEvent event,
    Emitter<BillingState> emit,
  ) async {
    emit(state.copyWith(systemsStatus: FormzSubmissionStatus.inProgress));
    final result = await dataSource.getActivePaymentSystems();
    result.fold(
      (failure) => emit(
        state.copyWith(
          systemsStatus: FormzSubmissionStatus.failure,
          error: failure,
        ),
      ),
      (list) => emit(
        state.copyWith(
          systemsStatus: FormzSubmissionStatus.success,
          paymentSystems: list,
        ),
      ),
    );
  }

  Future<void> _onCreateCheckout(
    CreateCheckoutEvent event,
    Emitter<BillingState> emit,
  ) async {
    emit(
      state.copyWith(
        checkoutStatus: FormzSubmissionStatus.inProgress,
        clearCheckout: true,
      ),
    );
    final result = await dataSource.createCheckout(
      paymentSystemId: event.paymentSystemId,
      amount: event.amount,
      tariffId: event.tariffId,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          checkoutStatus: FormzSubmissionStatus.failure,
          error: failure,
        ),
      ),
      (checkout) => emit(
        state.copyWith(
          checkoutStatus: FormzSubmissionStatus.success,
          checkout: checkout,
          payment: checkout.payment,
        ),
      ),
    );
  }

  Future<void> _onPollPaymentStatus(
    PollPaymentStatusEvent event,
    Emitter<BillingState> emit,
  ) async {
    final result = await dataSource.getPaymentStatus(event.id);
    result.fold(
      (_) {}, // ignore transient polling errors, keep last known payment
      (payment) => emit(state.copyWith(payment: payment)),
    );
  }

  Future<void> _onConfirmTestPayment(
    ConfirmTestPaymentEvent event,
    Emitter<BillingState> emit,
  ) async {
    emit(state.copyWith(confirmStatus: FormzSubmissionStatus.inProgress));
    final result = await dataSource.confirmTestPayment(event.id);
    await result.fold(
      (failure) async => emit(
        state.copyWith(
          confirmStatus: FormzSubmissionStatus.failure,
          error: failure,
        ),
      ),
      (_) async {
        emit(state.copyWith(confirmStatus: FormzSubmissionStatus.success));
        // Reflect the now-paid state and refreshed balance.
        final status = await dataSource.getPaymentStatus(event.id);
        status.fold(
          (_) {},
          (payment) => emit(state.copyWith(payment: payment)),
        );
        final balance = await dataSource.getBalance(
          isEmployer: event.isEmployer,
        );
        balance.fold((_) {}, (b) => emit(state.copyWith(balance: b)));
      },
    );
    emit(state.copyWith(confirmStatus: FormzSubmissionStatus.initial));
  }

  Future<void> _onTestTopup(
    TestTopupEvent event,
    Emitter<BillingState> emit,
  ) async {
    emit(state.copyWith(topupStatus: FormzSubmissionStatus.inProgress));
    final result = await dataSource.topupTest(
      isEmployer: event.isEmployer,
      amount: event.amount,
    );
    await result.fold(
      (failure) async => emit(
        state.copyWith(
          topupStatus: FormzSubmissionStatus.failure,
          error: failure,
        ),
      ),
      (_) async {
        emit(state.copyWith(topupStatus: FormzSubmissionStatus.success));
        final refresh = await dataSource.getBalance(
          isEmployer: event.isEmployer,
        );
        refresh.fold(
          (_) {},
          (balance) => emit(state.copyWith(balance: balance)),
        );
      },
    );
    emit(state.copyWith(topupStatus: FormzSubmissionStatus.initial));
  }

  Future<void> _onPayBlacklist(
    PayBlacklistEvent event,
    Emitter<BillingState> emit,
  ) async {
    emit(state.copyWith(blacklistPayStatus: FormzSubmissionStatus.inProgress));
    final result = await dataSource.payBlacklist();
    await result.fold(
      (failure) async => emit(
        state.copyWith(
          blacklistPayStatus: FormzSubmissionStatus.failure,
          error: failure,
        ),
      ),
      (_) async {
        emit(state.copyWith(blacklistPayStatus: FormzSubmissionStatus.success));
        // Seeker balance reflects the new (cleared) blacklist state.
        final balance = await dataSource.getBalance(isEmployer: false);
        balance.fold((_) {}, (b) => emit(state.copyWith(balance: b)));
      },
    );
    emit(state.copyWith(blacklistPayStatus: FormzSubmissionStatus.initial));
  }

  Future<void> _onLoadPremiumTariffs(
    LoadPremiumTariffsEvent event,
    Emitter<BillingState> emit,
  ) async {
    emit(state.copyWith(premiumStatus: FormzSubmissionStatus.inProgress));
    final result = await dataSource.getPremiumTariffs();
    result.fold(
      (failure) => emit(
        state.copyWith(
          premiumStatus: FormzSubmissionStatus.failure,
          error: failure,
        ),
      ),
      (list) => emit(
        state.copyWith(
          premiumStatus: FormzSubmissionStatus.success,
          premiumTariffs: list,
        ),
      ),
    );
  }

  Future<void> _onBuyPremium(
    BuyPremiumEvent event,
    Emitter<BillingState> emit,
  ) async {
    emit(state.copyWith(buyPremiumStatus: FormzSubmissionStatus.inProgress));
    final result = await dataSource.buyPremium(event.tariffId);
    await result.fold(
      (failure) async => emit(
        state.copyWith(
          buyPremiumStatus: FormzSubmissionStatus.failure,
          error: failure,
        ),
      ),
      (_) async {
        emit(state.copyWith(buyPremiumStatus: FormzSubmissionStatus.success));
        final balance = await dataSource.getBalance(isEmployer: false);
        balance.fold((_) {}, (b) => emit(state.copyWith(balance: b)));
      },
    );
    emit(state.copyWith(buyPremiumStatus: FormzSubmissionStatus.initial));
  }

  void _onResetCheckout(ResetCheckoutEvent event, Emitter<BillingState> emit) {
    emit(
      state.copyWith(
        checkoutStatus: FormzSubmissionStatus.initial,
        clearCheckout: true,
        clearPayment: true,
      ),
    );
  }
}
