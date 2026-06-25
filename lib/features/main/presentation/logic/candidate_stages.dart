import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';

/// Nomzod jarayoni bosqichlari (PROMPT_MOS_NOMZODLAR_MOBILE.md §2, §5).
/// '' = matched (biriktirilmagan mos nomzod).

/// Kanban ustunlari tartibi.
const List<String> kanbanColumns = [
  '',
  'suhbatga_yozildi',
  'suhbatga_bordi',
  'bormadi',
  'qabul_qilindi',
  'mos_kelmadi',
];

/// Faqat ruxsat etilgan ketma-ket o'tishlar (§5).
const Map<String, List<String>> nextStages = {
  '': ['suhbatga_yozildi'],
  'suhbatga_yozildi': ['suhbatga_bordi', 'bormadi'],
  'suhbatga_bordi': ['qabul_qilindi', 'mos_kelmadi'],
  'bormadi': ['suhbatga_yozildi', 'mos_kelmadi'],
  'qabul_qilindi': [],
  'mos_kelmadi': [],
};

/// Ustun sarlavhasi (§2.1).
String columnTitle(String status) => switch (status) {
      '' => 'Mos nomzodlar',
      'suhbatga_yozildi' => 'Suhbat vaqti',
      'suhbatga_bordi' => 'Suhbatga bordi',
      'bormadi' => 'Bormadi',
      'qabul_qilindi' => 'Qabul qilindi',
      'mos_kelmadi' => 'Mos kelmadi',
      _ => status,
    };

/// Bosqichni keyingisiga o'tkazadigan tugma matni.
String stageActionLabel(String toStatus) => switch (toStatus) {
      'suhbatga_yozildi' => 'Suhbatga chaqirish',
      'suhbatga_bordi' => 'Suhbatga bordi',
      'bormadi' => 'Bormadi',
      'qabul_qilindi' => 'Qabul qilindi',
      'mos_kelmadi' => 'Mos kelmadi',
      _ => toStatus,
    };

/// Bosqich rangi (§2.1: binafsha/pushti/emerald/qizil/teal/kulrang).
Color stageColor(String status) => switch (status) {
      '' => VIOLET,
      'suhbatga_yozildi' => const Color(0xFFEC4899), // pink
      'suhbatga_bordi' => const Color(0xFF10B981), // emerald
      'bormadi' => RED_COLOR,
      'qabul_qilindi' => const Color(0xFF14B8A6), // teal
      'mos_kelmadi' => GRAY_TEXT,
      _ => GRAY_TEXT,
    };

/// Nomzod javobi badge (§2.4): pending | accepted | declined.
({String label, Color color, IconData icon})? candidateResponseBadge(
    String response) {
  return switch (response) {
    'accepted' => (label: 'Boraman', color: GREEN_COLOR, icon: Icons.check),
    'declined' => (label: 'Bormayman', color: RED_COLOR, icon: Icons.close),
    'pending' => (
        label: 'Javob kutilmoqda',
        color: GRAY_TEXT,
        icon: Icons.schedule
      ),
    _ => null,
  };
}
