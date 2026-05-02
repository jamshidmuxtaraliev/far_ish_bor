part of 'auth_bloc.dart';

@immutable
abstract class AuthEvent {}

class SignInEvent extends AuthEvent {
  final SignInParams params;

  SignInEvent(this.params);
}

class GetUserEvent extends AuthEvent {
  final String fcmToken;

  GetUserEvent(this.fcmToken);
}

