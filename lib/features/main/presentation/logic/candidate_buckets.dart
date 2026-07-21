import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';

/// PROMPT_NOMZODLAR_3TAB_MOBILE.md §3 — "Nomzodlar" ekranining yuragi.
///
/// Backendda `Yangi/Jarayonda/Suhbat/Arxiv` degan maydon YO'Q. Backend faqat
/// granular statusni beradi, ilova ularni 4 ta "kova"ga (bucket) yig'adi.
/// Ikki xil status tizimi bor:
///   • Tab 1 (Ishga topshirgan) → `mobile_application.status` (12 qiymat)
///   • Tab 2/3 (Tavsiya · Mos)  → `anketa_assignment.status` (5 qiymat, null = biriktirilmagan)
enum Bucket { yangi, jarayonda, suhbat, arxiv }

/// Segmentda ko'rinadigan kovalar — `arxiv` alohida tugmada (§8).
const List<Bucket> kSegmentBuckets = [
  Bucket.yangi,
  Bucket.jarayonda,
  Bucket.suhbat,
];

String bucketLabel(Bucket b) => switch (b) {
      Bucket.yangi => 'Yangi',
      Bucket.jarayonda => 'Jarayonda',
      Bucket.suhbat => 'Suhbat',
      Bucket.arxiv => 'Arxiv',
    };

/// Tab 1 — ariza statusidan (§3.1).
Bucket bucketFromApplication(String s) => switch (s) {
      'pending' => Bucket.yangi,
      'viewed' || 'invited' || 'accepted' || 'probation' => Bucket.jarayonda,
      'scheduled' || 'confirmed' || 'on_way' || 'arrived' => Bucket.suhbat,
      'hired' || 'missed' || 'rejected' => Bucket.arxiv,
      _ => Bucket.jarayonda,
    };

/// Tab 2 / Tab 3 — biriktirish statusidan (§3.2). `null` = biriktirilmagan.
Bucket bucketFromAssignment(String? s) => switch (s) {
      null || '' => Bucket.yangi,
      'bormadi' => Bucket.jarayonda,
      'suhbatga_yozildi' || 'suhbatga_bordi' => Bucket.suhbat,
      'qabul_qilindi' || 'mos_kelmadi' => Bucket.arxiv,
      _ => Bucket.yangi,
    };

// ── Ariza statusi (mobile_application.status) — §14 lug'ati ──────────────────

String applicationStatusLabel(String s) => switch (s) {
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
      _ => s,
    };

/// Ish beruvchi qo'ya oladigan statuslar (§4.3 `EMPLOYER_ALLOWED_STATUSES`).
/// Tartib — real oqim bo'yicha.
const List<String> kEmployerAllowedStatuses = [
  'viewed',
  'invited',
  'scheduled',
  'arrived',
  'accepted',
  'probation',
  'hired',
  'missed',
  'rejected',
];

/// Status o'zgartirish sheet'idagi tugma matni (buyruq shaklida).
String applicationActionLabel(String s) => switch (s) {
      'viewed' => "Ko'rildi deb belgilash",
      'invited' => 'Suhbatga taklif qilish',
      'scheduled' => 'Suhbat vaqtini belgilash',
      'arrived' => "Suhbat bo'ldi",
      'accepted' => 'Maqul keldi',
      'probation' => 'Sinov davriga olish',
      'hired' => 'Ishga olish',
      'missed' => 'Kelmadi deb belgilash',
      'rejected' => 'Rad etish',
      _ => applicationStatusLabel(s),
    };

IconData applicationActionIcon(String s) => switch (s) {
      'viewed' => Icons.visibility_outlined,
      'invited' => Icons.mail_outline_rounded,
      'scheduled' => Icons.event_available_rounded,
      'arrived' => Icons.how_to_reg_rounded,
      'accepted' => Icons.thumb_up_outlined,
      'probation' => Icons.timelapse_rounded,
      'hired' => Icons.verified_rounded,
      'missed' => Icons.person_off_outlined,
      'rejected' => Icons.cancel_outlined,
      _ => Icons.arrow_forward_rounded,
    };

/// Status badge ranglari (JB tokenlari bilan).
({Color bg, Color fg}) statusTone(String status) => switch (status) {
      'hired' || 'accepted' || 'probation' => (bg: JB_GREEN_BG, fg: JB_GREEN_FG),
      'rejected' => (bg: JB_RED_BG, fg: JB_RED_FG),
      'missed' => (bg: JB_AMBER_BG, fg: JB_AMBER_FG),
      'invited' ||
      'scheduled' ||
      'confirmed' ||
      'on_way' ||
      'arrived' =>
        (bg: JB_AMBER_BG, fg: JB_AMBER_FG),
      'viewed' => (bg: JB_INDIGO_TINT, fg: JB_BLUE),
      _ => (bg: JB_CHIP_BG, fg: JB_GRAY),
    };

/// Biriktirish statusi badge ranglari.
({Color bg, Color fg}) assignmentTone(String? status) => switch (status) {
      'suhbatga_yozildi' || 'suhbatga_bordi' => (bg: JB_AMBER_BG, fg: JB_AMBER_FG),
      'bormadi' => (bg: JB_RED_BG, fg: JB_RED_FG),
      'qabul_qilindi' => (bg: JB_GREEN_BG, fg: JB_GREEN_FG),
      'mos_kelmadi' => (bg: JB_CHIP_BG, fg: JB_GRAY),
      _ => (bg: JB_INDIGO_TINT, fg: JB_BLUE),
    };

/// Biriktirish statusi matni (§14).
String assignmentStatusLabel(String? s) => switch (s) {
      null || '' => 'Yangi',
      'suhbatga_yozildi' => 'Suhbat vaqti',
      'suhbatga_bordi' => 'Suhbatga bordi',
      'bormadi' => 'Bormadi',
      'qabul_qilindi' => 'Qabul qilindi',
      'mos_kelmadi' => 'Mos kelmadi',
      _ => s,
    };
