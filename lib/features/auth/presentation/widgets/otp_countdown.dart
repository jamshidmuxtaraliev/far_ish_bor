import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/jb_palette.dart';

/// Kod ekranidagi orqa sanoq holati.
///
/// Sanoq har doim serverdan kelgan `ttl_seconds` dan boshlanadi — 300 ni
/// qattiq yozib qo'ymaslik kerak. Sanoq 0 ga yetganda "Davom etish" o'chadi,
/// faqat "Qayta yuborish" ishlaydi.
mixin OtpCountdownMixin<T extends StatefulWidget> on State<T> {
  Timer? _otpTimer;
  int otpSecondsLeft = 0;

  /// Kod tasdiqlangan — orqaga qaytib kelinsa qayta SMS so'ralmaydi.
  bool otpVerified = false;

  bool get otpExpired => otpSecondsLeft <= 0;

  void startOtpCountdown(int ttlSeconds) {
    _otpTimer?.cancel();
    setState(() {
      otpSecondsLeft = ttlSeconds;
      otpVerified = false;
    });
    _otpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() => otpSecondsLeft--);
      if (otpSecondsLeft <= 0) timer.cancel();
    });
  }

  /// Kod tasdiqlangach sanoqni to'xtatadi — chipta endi 30 daqiqa amal qiladi.
  void markOtpVerified() {
    _otpTimer?.cancel();
    setState(() => otpVerified = true);
  }

  void stopOtpCountdown() {
    _otpTimer?.cancel();
    if (mounted) setState(() => otpSecondsLeft = 0);
  }

  @override
  void dispose() {
    _otpTimer?.cancel();
    super.dispose();
  }
}

/// Sanoq + "Qayta yuborish" qatori.
class OtpCountdownBar extends StatelessWidget {
  final int secondsLeft;
  final bool verified;
  final bool isUz;
  final bool resendInProgress;
  final VoidCallback onResend;

  const OtpCountdownBar({
    super.key,
    required this.secondsLeft,
    required this.verified,
    required this.isUz,
    required this.onResend,
    this.resendInProgress = false,
  });

  static String format(int seconds) {
    final safe = seconds < 0 ? 0 : seconds;
    final m = (safe ~/ 60).toString();
    final s = (safe % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final expired = secondsLeft <= 0;
    // Oxirgi 30 soniya — qizil ogohlantirish.
    final urgent = !expired && secondsLeft <= 30;

    final Color color;
    final String label;
    if (verified) {
      color = context.jb.green;
      label = isUz ? 'Kod tasdiqlandi' : 'Код подтверждён';
    } else if (expired) {
      color = context.jb.red;
      label = isUz
          ? 'Kod muddati tugadi — yangi kod oling'
          : 'Срок кода истёк — запросите новый';
    } else {
      color = urgent ? context.jb.red : context.jb.gray;
      label = isUz
          ? 'Kod amal qiladi: ${format(secondsLeft)}'
          : 'Код действителен: ${format(secondsLeft)}';
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              verified
                  ? Icons.check_circle_outline
                  : (expired ? Icons.error_outline : Icons.timer_outlined),
              size: 16,
              color: color,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: color,
                  fontWeight: urgent || expired ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        if (!verified)
          TextButton(
            onPressed: resendInProgress ? null : onResend,
            child: Text(
              isUz ? 'Kod kelmadimi? Qayta yuborish' : 'Код не пришёл? Отправить снова',
              style: TextStyle(
                color: resendInProgress ? context.jb.gray : context.jb.blue,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
      ],
    );
  }
}
