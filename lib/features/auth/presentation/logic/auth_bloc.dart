import 'package:far_ish_bor/features/auth/data/models/user_model.dart';
import 'package:far_ish_bor/features/auth/domain/auth_repository/auth_repository.dart';
import 'package:bloc/bloc.dart';

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:formz/formz.dart';

import '../../../../core/error/error_model.dart';
import '../../../../core/services/get_it.dart';
import '../../data/datasource/local/user_local_data_source.dart';
import '../../data/models/signin_params.dart';

part 'auth_event.dart';

part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;

  AuthBloc(this.repository) : super(AuthState()) {
    on<SignInEvent>(_onSignIn);
    on<GetUserEvent>(_getUser);
  }

  void _onSignIn(SignInEvent event, Emitter<AuthState> emit) async {
    emit(state.copyWidth(signInStatus: FormzSubmissionStatus.inProgress));

    final result = await repository.signIn(event.params);
    result.fold(
      (failure) {
        emit(state.copyWidth(error: failure, signInStatus: FormzSubmissionStatus.failure));
      },
      (result) {
         getIt<UserLocalDatasource>().saveUser(result);
         getIt<UserLocalDatasource>().saveToken(result.token ?? '');
        emit(state.copyWidth(signInStatus: FormzSubmissionStatus.success));
      },
    );

    emit(state.copyWidth(signInStatus: FormzSubmissionStatus.initial));
  }

  void _getUser(GetUserEvent event, Emitter<AuthState> emit) async {
    emit(state.copyWidth(getUserStatus: FormzSubmissionStatus.inProgress));

    final result = await repository.getUser(event.fcmToken);
    result.fold(
      (failure) {
        emit(state.copyWidth(error: failure, getUserStatus: FormzSubmissionStatus.failure));
      },
      (result)  {
         getIt<UserLocalDatasource>().saveUser(result);
        emit(state.copyWidth(getUserStatus: FormzSubmissionStatus.success));
      },
    );

    emit(state.copyWidth(getUserStatus: FormzSubmissionStatus.initial));
  }
}
