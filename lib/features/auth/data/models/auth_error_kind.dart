import '../../../../core/error/error_model.dart';

/// Backend xato konvertini ekran qaror qabul qila oladigan holatga o'giradi.
///
/// Xatolarda ham HTTP status 200 keladi (haqiqiy status `error_code` ichida),
/// yagona istisno — rate-limit (haqiqiy HTTP 429). Shuning uchun tekshiruv
/// `error_code` va `message` ustidan ketadi.
enum AuthErrorKind {
  /// `/register` 409 — raqam allaqachon ro'yxatdan o'tgan. Kirishga o'tkaz.
  phoneAlreadyRegistered,

  /// `/login` 404 — bunday foydalanuvchi yo'q. Ro'yxatdan o'tishga o'tkaz.
  userNotFound,

  /// `reg_token` eskirgan/yaroqsiz/boshqa raqamniki. Kod qadamiga qaytar.
  regTokenInvalid,

  /// Kod muddati tugagan yoki umuman yuborilmagan.
  codeExpired,

  /// Kod noto'g'ri kiritildi.
  codeWrong,

  /// Bitta kodga 5 marta xato — faqat "Qayta yuborish" qoladi.
  tooManyAttempts,

  /// HTTP 429 — so'rovlar limiti.
  rateLimited,

  /// SMS provayderi ishlamadi — Telegram muqobilini taklif qil.
  smsGatewayDown,

  other,
}

extension AuthErrorKindX on ErrorModel {
  AuthErrorKind get kind {
    final message = errorMessage.toLowerCase();
    switch (errorCode) {
      case 409:
        return AuthErrorKind.phoneAlreadyRegistered;
      case 404:
        return AuthErrorKind.userNotFound;
      case 429:
        return AuthErrorKind.rateLimited;
      case 502:
        return AuthErrorKind.smsGatewayDown;
    }
    if (message.contains('tasdiqlash muddati tugadi') ||
        message.contains('tasdiqlash tokeni')) {
      return AuthErrorKind.regTokenInvalid;
    }
    if (message.contains('juda ko\'p urinish')) {
      return AuthErrorKind.tooManyAttempts;
    }
    if (message.contains('juda ko\'p so\'rov')) {
      return AuthErrorKind.rateLimited;
    }
    if (message.contains('muddati tugagan') || message.contains('kod topilmadi')) {
      return AuthErrorKind.codeExpired;
    }
    if (message.contains('kod noto\'g\'ri')) {
      return AuthErrorKind.codeWrong;
    }
    return AuthErrorKind.other;
  }

  /// Kod qadamiga qaytib, yangi kod so'rash kerak bo'lgan holatlar.
  bool get needsFreshCode {
    const kinds = {
      AuthErrorKind.regTokenInvalid,
      AuthErrorKind.codeExpired,
      AuthErrorKind.tooManyAttempts,
    };
    return kinds.contains(kind);
  }
}
