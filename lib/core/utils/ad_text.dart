/// `ad_campaigns.text_content` — Telegram kanaliga yuborilgan e'lon matni:
/// emoji, `**qalin**` belgilar va "Maosh: Kelishiladi" ko'rinishidagi
/// qatorlardan iborat. Uni bannerda shundayligicha kesib ko'rsatilsa odam
/// hech qanday aniq ma'lumot ko'rmaydi.
///
/// Bu fayl — ommaviy saytdagi [public-site/src/utils/adText.js] ning Dart
/// ko'chirmasi. ⚠ Ikkalasi bir xil natija berishi kerak: yorliq ro'yxati
/// yoki "footer" qoidasi o'zgarsa IKKALASI ham yangilanadi.
library;

/// Emoji va variatsiya belgilari (yorliqni tanishdan oldin olib tashlanadi).
final RegExp _emojiRe = RegExp(
  r'[\u{1F000}-\u{1FAFF}\u{2190}-\u{2BFF}\u{FE0F}\u{20E3}\u{2600}-\u{27BF}]',
  unicode: true,
);

final RegExp _boldRe = RegExp(r'\*\*(.+?)\*\*');
final RegExp _underRe = RegExp(r'__(.+?)__');
final RegExp _marksRe = RegExp(r'[*_`]');
final RegExp _spacesRe = RegExp(r'\s{2,}');

/// "Yorliq: qiymat" — yorliq 2–34 belgi, ichida nuqta/vergul yo'q.
final RegExp _factRe = RegExp(r'^([^:：.,!?]{2,34})\s*[:：]\s*(.+)$');

/// Platformaning o'z "footer" qatorlari (`adPublisher` har bir e'lon oxiriga
/// qo'shadi) — ilovaning O'ZIDA ularni qayta ko'rsatish ma'nosiz.
final RegExp _boilerplateRe = RegExp(r'jobup24|@farishbor|t\.me/', caseSensitive: false);

/// Yorliq → ikonka kaliti. Kalit so'z qatorda UCHRASHI yetarli.
/// Tartib MUHIM: yuqoridagisi birinchi tekshiriladi.
const List<({String icon, List<String> words})> _labels = [
  (icon: 'building', words: ['ish beruvchi', 'иш берувчи', 'kompaniya', 'компания', 'работодатель', 'tashkilot']),
  (icon: 'user', words: ['mutaxassis', 'мутахассис', 'lavozim', 'лавозим', 'kasb', 'касб', 'должность', 'специалист']),
  (icon: 'users', words: ['xodim soni', 'ходим сони', 'ishchi soni', 'ишчи сони', 'soni', 'сони', 'количество', 'kerak', 'керак']),
  (icon: 'wallet', words: ['maosh', 'маош', 'oylik', 'ойлик', 'ish haqi', 'иш ҳақи', 'зарплата', 'оклад']),
  (icon: 'pin', words: ['manzil', 'манзил', 'hudud', 'ҳудуд', 'адрес', 'joylashuv']),
  (icon: 'clock', words: ['ish vaqti', 'иш вақти', 'grafik', 'график', 'ish tartibi', 'смена']),
  (icon: 'phone', words: ['telefon', 'телефон', 'aloqa', 'алоқа', 'тел']),
  (icon: 'age', words: ['yosh', 'ёш', 'возраст']),
  (icon: 'check', words: ['talab', 'талаб', 'требовани', 'shart', 'шарт']),
];

String _iconFor(String label) {
  final l = label.toLowerCase();
  for (final entry in _labels) {
    if (entry.words.any(l.contains)) return entry.icon;
  }
  return 'dot';
}

/// Markdown belgilari va emojilarni tozalab, bo'sh joylarni siqadi.
String cleanAdLine(String s) => s
    .replaceAllMapped(_boldRe, (m) => m[1]!)
    .replaceAllMapped(_underRe, (m) => m[1]!)
    .replaceAll(_marksRe, '')
    .replaceAll(_emojiRe, ' ')
    .replaceAll(_spacesRe, ' ')
    .trim();

class AdFact {
  /// [_labels] dagi kalit — chizishda ikonkaga aylantiriladi.
  final String icon;
  final String label;
  final String value;

  const AdFact({required this.icon, required this.label, required this.value});
}

class ParsedAd {
  /// Birinchi qisqa yorliqsiz qator ("OSHPAZ KERAK").
  final String title;

  /// "Yorliq: qiymat" qatorlari.
  final List<AdFact> facts;

  /// Qolgan erkin matn (vazifalar, shartlar…).
  final List<String> body;

  const ParsedAd({required this.title, required this.facts, required this.body});

  bool get isEmpty => title.isEmpty && facts.isEmpty && body.isEmpty;
}

/// Telegram e'lon matnini `{title, facts, body}` ga ajratadi.
/// Yorliq topilmagan qator `body` ga tushadi — hech narsa yo'qolmaydi.
ParsedAd parseAdText(String? text) {
  final raw = text ?? '';
  if (raw.trim().isEmpty) {
    return const ParsedAd(title: '', facts: [], body: []);
  }

  final lines = raw.split(RegExp(r'\r?\n+')).map((s) => s.trim()).where((s) => s.isNotEmpty);

  var title = '';
  final facts = <AdFact>[];
  final body = <String>[];
  final seen = <String>{};

  for (final line in lines) {
    if (_boilerplateRe.hasMatch(line)) continue;
    final clean = cleanAdLine(line);
    if (clean.isEmpty) continue;

    final m = _factRe.firstMatch(clean);
    if (m != null) {
      final label = m[1]!.trim();
      final value = m[2]!.trim();
      // Havola ("//…") yorliq emas
      if (value.isNotEmpty && !value.startsWith('//')) {
        final key = label.toLowerCase();
        if (seen.add(key)) {
          facts.add(AdFact(icon: _iconFor(label), label: label, value: value));
        }
        continue;
      }
    }

    // Yorliqsiz qator: birinchi qisqasi — sarlavha, qolgani — tavsif
    if (title.isEmpty && clean.length <= 90) {
      title = clean;
    } else {
      body.add(clean);
    }
  }

  return ParsedAd(title: title, facts: facts, body: body);
}
