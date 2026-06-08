import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:meta/meta.dart';

import '../../../../core/error/error_model.dart';
import '../../../../core/services/get_it.dart';
import '../../data/datasource/local/user_local_data_source.dart';
import '../../data/models/anketa_models.dart';
import '../../data/models/user_model.dart';
import '../../domain/auth_repository/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;

  AuthBloc(this.repository) : super(const AuthState()) {
    on<SendCodeEvent>(_onSendCode);
    on<RegisterEvent>(_onRegister);
    on<LoginEvent>(_onLogin);
    on<GetMeEvent>(_onGetMe);
    on<LoadAnketaEvent>(_onLoadAnketa);
    on<UpdateAnketaEvent>(_onUpdateAnketa);
    on<LoadRegionsEvent>(_onLoadRegions);
    on<LoadJobTypesEvent>(_onLoadJobTypes);
    on<LoadLanguagesEvent>(_onLoadLanguages);
  }

  Future<void> _onSendCode(SendCodeEvent event, Emitter<AuthState> emit) async {
    emit(state.copyWith(sendCodeStatus: FormzSubmissionStatus.inProgress));
    final result = await repository.sendCode(event.phone);
    result.fold(
      (failure) => emit(state.copyWith(sendCodeStatus: FormzSubmissionStatus.failure, error: failure)),
      (_) => emit(state.copyWith(sendCodeStatus: FormzSubmissionStatus.success)),
    );
    emit(state.copyWith(sendCodeStatus: FormzSubmissionStatus.initial));
  }

  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(state.copyWith(registerStatus: FormzSubmissionStatus.inProgress));
    final result = await repository.register(event.data);
    result.fold(
      (failure) => emit(state.copyWith(registerStatus: FormzSubmissionStatus.failure, error: failure)),
      (response) {
        getIt<UserLocalDatasource>().saveToken(response.token);
        getIt<UserLocalDatasource>().saveRole(response.role);
        emit(state.copyWith(registerStatus: FormzSubmissionStatus.success, user: response.user));
      },
    );
    emit(state.copyWith(registerStatus: FormzSubmissionStatus.initial));
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(state.copyWith(loginStatus: FormzSubmissionStatus.inProgress));
    final result = await repository.login(event.phone, event.smsCode);
    result.fold(
      (failure) => emit(state.copyWith(loginStatus: FormzSubmissionStatus.failure, error: failure)),
      (response) {
        getIt<UserLocalDatasource>().saveToken(response.token);
        getIt<UserLocalDatasource>().saveRole(response.role);
        emit(state.copyWith(loginStatus: FormzSubmissionStatus.success, user: response.user));
      },
    );
    emit(state.copyWith(loginStatus: FormzSubmissionStatus.initial));
  }

  Future<void> _onGetMe(GetMeEvent event, Emitter<AuthState> emit) async {
    emit(state.copyWith(getMeStatus: FormzSubmissionStatus.inProgress));
    final result = await repository.getMe();
    result.fold(
      (failure) => emit(state.copyWith(getMeStatus: FormzSubmissionStatus.failure, error: failure)),
      (user) => emit(state.copyWith(getMeStatus: FormzSubmissionStatus.success, user: user)),
    );
    emit(state.copyWith(getMeStatus: FormzSubmissionStatus.initial));
  }

  Future<void> _onLoadAnketa(LoadAnketaEvent event, Emitter<AuthState> emit) async {
    emit(state.copyWith(anketaStatus: FormzSubmissionStatus.inProgress));
    final result = await repository.getAnketa();
    result.fold(
      (failure) => emit(state.copyWith(anketaStatus: FormzSubmissionStatus.failure, error: failure)),
      (anketa) => emit(state.copyWith(anketaStatus: FormzSubmissionStatus.success, anketa: anketa)),
    );
    emit(state.copyWith(anketaStatus: FormzSubmissionStatus.initial));
  }

  Future<void> _onUpdateAnketa(UpdateAnketaEvent event, Emitter<AuthState> emit) async {
    emit(state.copyWith(updateAnketaStatus: FormzSubmissionStatus.inProgress));
    final result = await repository.updateAnketa(event.data);
    result.fold(
      (failure) => emit(state.copyWith(updateAnketaStatus: FormzSubmissionStatus.failure, error: failure)),
      (_) async {
        emit(state.copyWith(updateAnketaStatus: FormzSubmissionStatus.success));
        final refresh = await repository.getAnketa();
        refresh.fold((_) {}, (anketa) => emit(state.copyWith(anketa: anketa)));
        final meRefresh = await repository.getMe();
        meRefresh.fold((_) {}, (user) => emit(state.copyWith(user: user)));
      },
    );
    emit(state.copyWith(updateAnketaStatus: FormzSubmissionStatus.initial));
  }

  Future<void> _onLoadRegions(LoadRegionsEvent event, Emitter<AuthState> emit) async {
    if (state.regions.isNotEmpty) return;
    emit(state.copyWith(regionsStatus: FormzSubmissionStatus.inProgress));
    final result = await repository.getRegions();
    result.fold(
      (failure) => emit(state.copyWith(regionsStatus: FormzSubmissionStatus.failure, error: failure)),
      (list) => emit(state.copyWith(regionsStatus: FormzSubmissionStatus.success, regions: list)),
    );
    emit(state.copyWith(regionsStatus: FormzSubmissionStatus.initial));
  }

  Future<void> _onLoadJobTypes(LoadJobTypesEvent event, Emitter<AuthState> emit) async {
    emit(state.copyWith(jobTypesStatus: FormzSubmissionStatus.inProgress));
    final result = await repository.getJobTypes(text: event.text);
    result.fold(
      (failure) => emit(state.copyWith(jobTypesStatus: FormzSubmissionStatus.failure, error: failure)),
      (list) => emit(state.copyWith(jobTypesStatus: FormzSubmissionStatus.success, jobTypes: list)),
    );
    emit(state.copyWith(jobTypesStatus: FormzSubmissionStatus.initial));
  }

  Future<void> _onLoadLanguages(LoadLanguagesEvent event, Emitter<AuthState> emit) async {
    if (state.languages.isNotEmpty) return;
    emit(state.copyWith(languagesStatus: FormzSubmissionStatus.inProgress));
    final result = await repository.getLanguages();
    result.fold(
      (failure) => emit(state.copyWith(languagesStatus: FormzSubmissionStatus.failure, error: failure)),
      (list) => emit(state.copyWith(languagesStatus: FormzSubmissionStatus.success, languages: list)),
    );
    emit(state.copyWith(languagesStatus: FormzSubmissionStatus.initial));
  }
}
