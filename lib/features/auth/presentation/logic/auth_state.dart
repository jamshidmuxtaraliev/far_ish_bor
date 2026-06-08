part of 'auth_bloc.dart';

@immutable
class AuthState extends Equatable {
  final FormzSubmissionStatus sendCodeStatus;
  final FormzSubmissionStatus registerStatus;
  final FormzSubmissionStatus loginStatus;
  final FormzSubmissionStatus getMeStatus;
  final FormzSubmissionStatus anketaStatus;
  final FormzSubmissionStatus updateAnketaStatus;
  final FormzSubmissionStatus regionsStatus;
  final FormzSubmissionStatus jobTypesStatus;
  final FormzSubmissionStatus languagesStatus;
  final ErrorModel? error;
  final UserModel? user;
  final AnketaModel? anketa;
  final List<RegionModel> regions;
  final List<JobTypeModel> jobTypes;
  final List<LanguageModel> languages;

  const AuthState({
    this.sendCodeStatus = FormzSubmissionStatus.initial,
    this.registerStatus = FormzSubmissionStatus.initial,
    this.loginStatus = FormzSubmissionStatus.initial,
    this.getMeStatus = FormzSubmissionStatus.initial,
    this.anketaStatus = FormzSubmissionStatus.initial,
    this.updateAnketaStatus = FormzSubmissionStatus.initial,
    this.regionsStatus = FormzSubmissionStatus.initial,
    this.jobTypesStatus = FormzSubmissionStatus.initial,
    this.languagesStatus = FormzSubmissionStatus.initial,
    this.error,
    this.user,
    this.anketa,
    this.regions = const [],
    this.jobTypes = const [],
    this.languages = const [],
  });

  AuthState copyWith({
    FormzSubmissionStatus? sendCodeStatus,
    FormzSubmissionStatus? registerStatus,
    FormzSubmissionStatus? loginStatus,
    FormzSubmissionStatus? getMeStatus,
    FormzSubmissionStatus? anketaStatus,
    FormzSubmissionStatus? updateAnketaStatus,
    FormzSubmissionStatus? regionsStatus,
    FormzSubmissionStatus? jobTypesStatus,
    FormzSubmissionStatus? languagesStatus,
    ErrorModel? error,
    UserModel? user,
    AnketaModel? anketa,
    List<RegionModel>? regions,
    List<JobTypeModel>? jobTypes,
    List<LanguageModel>? languages,
  }) {
    return AuthState(
      sendCodeStatus: sendCodeStatus ?? this.sendCodeStatus,
      registerStatus: registerStatus ?? this.registerStatus,
      loginStatus: loginStatus ?? this.loginStatus,
      getMeStatus: getMeStatus ?? this.getMeStatus,
      anketaStatus: anketaStatus ?? this.anketaStatus,
      updateAnketaStatus: updateAnketaStatus ?? this.updateAnketaStatus,
      regionsStatus: regionsStatus ?? this.regionsStatus,
      jobTypesStatus: jobTypesStatus ?? this.jobTypesStatus,
      languagesStatus: languagesStatus ?? this.languagesStatus,
      error: error ?? this.error,
      user: user ?? this.user,
      anketa: anketa ?? this.anketa,
      regions: regions ?? this.regions,
      jobTypes: jobTypes ?? this.jobTypes,
      languages: languages ?? this.languages,
    );
  }

  @override
  List<Object?> get props => [
        sendCodeStatus, registerStatus, loginStatus, getMeStatus,
        anketaStatus, updateAnketaStatus, regionsStatus, jobTypesStatus, languagesStatus,
        error, user, anketa, regions, jobTypes, languages,
      ];
}
