part of 'auth_bloc.dart';

@immutable
abstract class AuthEvent {}

/// SMS yuborishdan oldin raqam bazada bormi — shunga qarab ekran tanlanadi.
class CheckPhoneEvent extends AuthEvent {
  final String phone;
  CheckPhoneEvent(this.phone);
}

class SendCodeEvent extends AuthEvent {
  final String phone;
  final String? channel;
  SendCodeEvent(this.phone, {this.channel});
}

/// Kod kiritilgan zahoti tekshiriladi; muvaffaqiyatda 30 daqiqalik
/// `reg_token` olinadi va keyingi qadamlarda `sms_code` o'rniga ishlatiladi.
class VerifyCodeEvent extends AuthEvent {
  final String phone;
  final String smsCode;
  VerifyCodeEvent(this.phone, this.smsCode);
}

/// "Qayta yuborish"da yoki telefon o'zgarganda eski chiptani tashlaydi.
class ClearRegTokenEvent extends AuthEvent {}

class RegisterEvent extends AuthEvent {
  final Map<String, dynamic> data;
  RegisterEvent(this.data);
}

class LoginEvent extends AuthEvent {
  final String phone;
  final String? smsCode;

  /// Berilgan bo'lsa `sms_code` o'rniga shu yuboriladi.
  final String? regToken;
  LoginEvent(this.phone, {this.smsCode, this.regToken});
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

/// Rezyume tugmasining holatini aniqlash uchun `/mobile/anketa/resume`.
class LoadResumeInfoEvent extends AuthEvent {}

/// Yangi havola olib, PDF'ni qurilmaga saqlaydi.
class DownloadResumeEvent extends AuthEvent {}

/// Yuklab olish foizini yangilash uchun ichki hodisa.
class ResumeProgressEvent extends AuthEvent {
  final double progress;
  ResumeProgressEvent(this.progress);
}
