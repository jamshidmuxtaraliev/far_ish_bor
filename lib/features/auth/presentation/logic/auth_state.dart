part of 'auth_bloc.dart';

@immutable
class AuthState extends Equatable {
  final FormzSubmissionStatus signInStatus;
  final FormzSubmissionStatus getUserStatus;

  // final UserEntity? user;
  final ErrorModel? error;

  const AuthState({
    this.signInStatus = FormzSubmissionStatus.initial,
    this.getUserStatus = FormzSubmissionStatus.initial,

    // this.user,
    this.error,
  });

  AuthState copyWidth({
    FormzSubmissionStatus? signInStatus,
    FormzSubmissionStatus? getUserStatus,
    UserModel? user,
    ErrorModel? error,
  }) {
    return AuthState(
      signInStatus: signInStatus ?? this.signInStatus,
      getUserStatus: getUserStatus ?? this.getUserStatus,
      // user: user ?? this.user,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
    signInStatus,
    getUserStatus,
    // user,
    error,
  ];
}
