import 'package:flutter/material.dart';

import '../../../../core/theme/jb_palette.dart';

/// Otklik (ariza) bosqichlari — PROMPT_VAKANSIYA_OTKLIKLARI_MOBILE.md §6.
///
/// ⚠️ Ko'rsatiladigan matn har doim serverdan kelgan `status_label` bo'lishi
/// kerak. Bu yerdagi nomlar faqat "keyingi bosqich" tugmalarida ishlatiladi —
/// ular hali serverdan kelmagan statuslar.

/// §6.1 — ish beruvchi qo'ya oladigan o'tishlar.
/// `confirmed` va `on_way` faqat nomzodning o'zida (§7), shuning uchun bu
/// xaritada ish beruvchiga taklif qilinmaydi.
const Map<String, List<String>> nextApplicationStatuses = {
  'pending': ['viewed', 'invited', 'rejected'],
  'viewed': ['invited', 'rejected'],
  'invited': ['scheduled', 'rejected'],
  'scheduled': ['arrived', 'missed', 'rejected'],
  'confirmed': ['arrived', 'missed', 'rejected'],
  'on_way': ['arrived', 'missed'],
  'arrived': ['accepted', 'rejected'],
  'accepted': ['probation', 'hired', 'rejected'],
  'probation': ['hired', 'rejected'],
  'missed': ['invited', 'rejected'],
  'hired': [],
  'rejected': [],
};

List<String> nextStatusesFor(String status) =>
    nextApplicationStatuses[status] ?? const [];

bool isFinalApplicationStatus(String status) => nextStatusesFor(status).isEmpty;

/// §6.2 jadvalidagi ranglar.
Color applicationStatusColor(String status) => switch (status) {
      'viewed' => jb.blueLight,
      'invited' => jb.blue,
      'scheduled' || 'confirmed' => jb.amber,
      'on_way' => jb.violet,
      'arrived' || 'accepted' => jb.green,
      'probation' => jb.cyan,
      'hired' => jb.green,
      'missed' || 'rejected' => jb.red,
      _ => jb.gray, // pending
    };

/// Badge foni + matni. `hired` — yakuniy holat, to'ldirilgan ko'rinishda.
({Color color, Color bg}) applicationStatusTone(String status) {
  final color = applicationStatusColor(status);
  return (
    color: color,
    bg: color.withValues(alpha: status == 'hired' ? 0.2 : 0.12),
  );
}

/// Faqat "keyingi bosqich" tugmalari uchun zaxira matn (§6.2 jadvali).
String applicationStatusFallbackLabel(String status) => switch (status) {
      'pending' => 'Yuborildi',
      'viewed' => "Ko'rildi",
      'invited' => 'Suhbatga taklif',
      'scheduled' => 'Vaqt belgilandi',
      'confirmed' => 'Suhbat tasdiqlandi',
      'on_way' => "Yo'lda",
      'arrived' => "Suhbat bo'ldi",
      'accepted' => 'Maqul keldi',
      'probation' => 'Sinov davrida',
      'hired' => 'Ishga kirdi',
      'missed' => 'Kelmadi',
      'rejected' => 'Rad etildi',
      _ => status,
    };

IconData applicationStatusIcon(String status) => switch (status) {
      'viewed' => Icons.visibility_outlined,
      'invited' => Icons.mail_outline_rounded,
      'scheduled' => Icons.event_outlined,
      'confirmed' => Icons.event_available_outlined,
      'on_way' => Icons.directions_walk_rounded,
      'arrived' => Icons.how_to_reg_outlined,
      'accepted' => Icons.thumb_up_outlined,
      'probation' => Icons.timelapse_rounded,
      'hired' => Icons.check_circle_rounded,
      'missed' => Icons.event_busy_outlined,
      'rejected' => Icons.cancel_outlined,
      _ => Icons.send_outlined, // pending
    };
