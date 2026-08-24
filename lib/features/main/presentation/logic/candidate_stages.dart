import 'package:flutter/material.dart';

import '../../../../core/theme/jb_palette.dart';

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
      'bormadi' => 'Kelmadi',
      'qabul_qilindi' => 'Qabul qilindi',
      'mos_kelmadi' => 'Mos kelmadi',
      _ => status,
    };

/// Bosqichni keyingisiga o'tkazadigan tugma matni.
String stageActionLabel(String toStatus) => switch (toStatus) {
      'suhbatga_yozildi' => 'Suhbatga chaqirish',
      'suhbatga_bordi' => 'Suhbatga bordi',
      'bormadi' => 'Kelmadi',
      'qabul_qilindi' => 'Qabul qilindi',
      'mos_kelmadi' => 'Mos kelmadi',
      _ => toStatus,
    };

/// Bosqich rangi (§2.1: binafsha/pushti/emerald/qizil/teal/kulrang).
Color stageColor(String status) => switch (status) {
      '' => jb.violet,
      'suhbatga_yozildi' => jb.pink, // pink
      'suhbatga_bordi' => jb.green, // emerald
      'bormadi' => jb.red,
      'qabul_qilindi' => jb.cyan, // teal
      'mos_kelmadi' => jb.gray,
      _ => jb.gray,
    };

/// Nomzod javobi badge (§2.4): pending | accepted | declined.
({String label, Color color, IconData icon})? candidateResponseBadge(
    String response) {
  return switch (response) {
    'accepted' => (label: 'Boraman', color: jb.green, icon: Icons.check),
    'declined' => (label: 'Bormayman', color: jb.red, icon: Icons.close),
    'pending' => (
        label: 'Javob kutilmoqda',
        color: jb.gray,
        icon: Icons.schedule
      ),
    _ => null,
  };
}
