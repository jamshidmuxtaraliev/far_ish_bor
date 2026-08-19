import 'package:json_annotation/json_annotation.dart';

part 'auth_flow_models.g.dart';

/// `POST /mobile/check-phone` javobi.
///
/// SMS yuborishdan OLDIN chaqiriladi: raqam bazada bo'lsa ro'yxatdan o'tishga
/// yo'l yo'q, bo'lmasa kirishga yo'l yo'q — foydalanuvchi kerakli ekranga
/// o'tkaziladi va bekorga SMS ketmaydi.
@JsonSerializable(createToJson: false)
class CheckPhoneModel {
  /// To'liq ro'yxatdan o'tgan (`mobile_users` da bor) — Kirish ekraniga o'tkaz.
  final bool registered;

  /// Kirish mumkin. CRM/bot orqali kiritilgan anketa ham hisobga olinadi,
  /// shuning uchun `registered: false, can_login: true` holati normal.
  @JsonKey(name: 'can_login')
  final bool canLogin;

  /// `seeker` | `employer` | `null`
  final String? role;

  const CheckPhoneModel({
    this.registered = false,
    this.canLogin = false,
    this.role,
  });

  factory CheckPhoneModel.fromJson(Map<String, dynamic> json) =>
      _$CheckPhoneModelFromJson(json);
}

/// `POST /mobile/send-code` javobi.
@JsonSerializable(createToJson: false)
class SendCodeModel {
  final bool sent;

  /// `sms` | `telegram` | `none`
  final String? via;

  /// Kod muddati soniyalarda (hozircha 300). Orqa sanoq SHU qiymatdan
  /// boshlanadi — 300 ni qattiq yozib qo'ymang.
  @JsonKey(name: 'ttl_seconds')
  final int ttlSeconds;

  /// `via == "none"` bo'lganda: `not_linked` | `bot_blocked` | `bot_offline`
  final String? reason;

  /// Raqam Telegram botga bog'lanmagan bo'lsa — deep-link.
  @JsonKey(name: 'bot_link')
  final String? botLink;

  /// Faqat test rejimida keladi, prodda yo'q.
  @JsonKey(name: 'debug_code')
  final String? debugCode;

  const SendCodeModel({
    this.sent = false,
    this.via,
    this.ttlSeconds = 300,
    this.reason,
    this.botLink,
    this.debugCode,
  });

  factory SendCodeModel.fromJson(Map<String, dynamic> json) =>
      _$SendCodeModelFromJson(json);
}

/// `POST /mobile/verify-code` javobi.
///
/// Kod shu chaqiruvda "sarflanadi" — o'rniga 30 daqiqalik [regToken] beriladi
/// va `/register`/`/login` ga `sms_code` o'rniga shu yuboriladi.
@JsonSerializable(createToJson: false)
class VerifyCodeModel {
  final bool verified;

  @JsonKey(name: 'reg_token')
  final String? regToken;

  /// Chipta muddati soniyalarda (hozircha 1800).
  @JsonKey(name: 'ttl_seconds')
  final int ttlSeconds;

  /// `true` bo'lsa raqam allaqachon ro'yxatdan o'tgan — `/register` 409 beradi,
  /// foydalanuvchini Kirish ekraniga o'tkazing.
  final bool registered;

  final String? role;

  const VerifyCodeModel({
    this.verified = false,
    this.regToken,
    this.ttlSeconds = 1800,
    this.registered = false,
    this.role,
  });

  factory VerifyCodeModel.fromJson(Map<String, dynamic> json) =>
      _$VerifyCodeModelFromJson(json);
}
