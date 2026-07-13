part of 'auth_bloc.dart';

@immutable
abstract class AuthEvent {}

class SendCodeEvent extends AuthEvent {
  final String phone;
  SendCodeEvent(this.phone);
}

class RegisterEvent extends AuthEvent {
  final Map<String, dynamic> data;
  RegisterEvent(this.data);
}

class LoginEvent extends AuthEvent {
  final String phone;
  final String smsCode;
  LoginEvent(this.phone, this.smsCode);
}

class GetMeEvent extends AuthEvent {}

class LoadAnketaEvent extends AuthEvent {}

class UpdateAnketaEvent extends AuthEvent {
  final Map<String, dynamic> data;
  UpdateAnketaEvent(this.data);
}

class LoadRegionsEvent extends AuthEvent {}

class LoadJobTypesEvent extends AuthEvent {
  final String? text;
  LoadJobTypesEvent({this.text});
}

class LoadLanguagesEvent extends AuthEvent {}

class LoadEmployerEvent extends AuthEvent {}

class UpdateEmployerEvent extends AuthEvent {
  final Map<String, dynamic> data;
  UpdateEmployerEvent(this.data);
}

class UploadLogoEvent extends AuthEvent {
  final String filePath;
  UploadLogoEvent(this.filePath);
}

class UploadPhotoEvent extends AuthEvent {
  final String filePath;
  UploadPhotoEvent(this.filePath);
}
