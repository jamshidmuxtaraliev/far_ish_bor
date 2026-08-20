import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// ============================================================================
/// Jobup24 semantic palette (light / dark)
/// ----------------------------------------------------------------------------
/// Barcha ekranlar rangni shu yerdan oladi — hech qayerda "qotib qolgan" oq/qora
/// rang bo'lmasligi kerak. Ikki xil kirish nuqtasi bor:
///
///   1. `context.jb`  — `ThemeExtension` orqali (Theme'ga bog'lanadi, eng to'g'ri
///      yo'l; yangi kod shuni ishlatsin).
///   2. `jb`          — global mirror. `BuildContext` yo'q joylarda (static
///      helperlar, model getterlari, `const`siz top-level funksiyalar) ishlatiladi.
///      `ThemeCubit` / `MyApp` uni har doim joriy rejimga moslab turadi.
///
/// Arxitektura al_xorazmiy loyihasidan olindi (ThemeCubit + lightTheme/darkTheme
/// + `PREF_THEME`), ustiga Jobup24 dizayn tokenlari qo'shildi.
/// ============================================================================

@immutable
class JbPalette extends ThemeExtension<JbPalette> {
  final Brightness brightness;

  // ---- Sirtlar (surfaces) ---------------------------------------------------
  /// Scaffold foni.
  final Color bg;

  /// Asosiy karta / oq sirt.
  final Color card;

  /// Ichki (ikkilamchi) sirt — input, inset blok, sekin karta.
  final Color cardAlt;

  /// Neytral chip / ikonka plitkasi foni.
  final Color chipBg;

  /// Ingichka chegara.
  final Color border;

  /// Quyuqroq chegara (tanlangan holat, input outline).
  final Color borderStrong;

  /// Qator ichidagi ajratgich.
  final Color divider;

  /// Modal / bottom-sheet orqa fon qorasi.
  final Color scrim;

  // ---- Matn -----------------------------------------------------------------
  /// Asosiy matn.
  final Color ink;

  /// Ikkilamchi matn.
  final Color gray;

  /// Uchinchi darajali matn / ikonka.
  final Color grayLight;

  /// Brend rang ustidagi matn/ikonka (ko'k tugma ichidagi oq).
  final Color onBrand;

  // ---- Brend ----------------------------------------------------------------
  final Color blue;
  final Color blueDark;
  final Color blueLight;

  /// Ko'k ikonka plitkasi foni (tint).
  final Color blueTint;

  /// Gradient boshlanish rangi (action-card).
  final Color gradientStart;

  // ---- Aksentlar (fg + tint bg juftliklari) ---------------------------------
  final Color green;
  final Color greenBg;
  final Color amber;
  final Color amberBg;
  final Color amberTile;
  final Color red;
  final Color redBg;
  final Color violet;
  final Color violetBg;
  final Color cyan;
  final Color pink;

  /// Premium (tilla) aksent.
  final Color gold;
  final Color goldSoft;

  // ---- Effektlar ------------------------------------------------------------
  final Color shadow;

  const JbPalette({
    required this.brightness,
    required this.bg,
    required this.card,
    required this.cardAlt,
    required this.chipBg,
    required this.border,
    required this.borderStrong,
    required this.divider,
    required this.scrim,
    required this.ink,
    required this.gray,
    required this.grayLight,
    required this.onBrand,
    required this.blue,
    required this.blueDark,
    required this.blueLight,
    required this.blueTint,
    required this.gradientStart,
    required this.green,
    required this.greenBg,
    required this.amber,
    required this.amberBg,
    required this.amberTile,
    required this.red,
    required this.redBg,
    required this.violet,
    required this.violetBg,
    required this.cyan,
    required this.pink,
    required this.gold,
    required this.goldSoft,
    required this.shadow,
  });

  bool get isDark => brightness == Brightness.dark;

  /// Dizayndagi yumshoq karta soyasi.
  List<BoxShadow> get softShadow => [
    BoxShadow(color: shadow, blurRadius: 20, offset: const Offset(0, 6)),
  ];

  /// Kichikroq soya (input, chip, kichik kartalar).
  List<BoxShadow> get subtleShadow => [
    BoxShadow(color: shadow, blurRadius: 8, offset: const Offset(0, 2)),
  ];

  /// Status bar / navigation bar rejimi — har bir ekrandagi `AnnotatedRegion`
  /// shuni ishlatadi, shunda tungi rejimda ikonkalar oqarib ko'rinadi.
  SystemUiOverlayStyle get overlay => SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
    systemNavigationBarColor: card,
    systemNavigationBarDividerColor: Colors.transparent,
    systemNavigationBarContrastEnforced: false,
    systemNavigationBarIconBrightness:
        isDark ? Brightness.light : Brightness.dark,
  );

  /// Brend rangli (ko'k gradient) header ustidagi ekranlar uchun — ikonkalar
  /// har doim oq bo'lishi kerak.
  SystemUiOverlayStyle get overlayOnBrand => SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: card,
    systemNavigationBarDividerColor: Colors.transparent,
    systemNavigationBarContrastEnforced: false,
    systemNavigationBarIconBrightness:
        isDark ? Brightness.light : Brightness.dark,
  );

  /// Rasm/xarita ustidagi oq panel kabi joylar uchun.
  Color get onImage => isDark ? ink : Colors.white;

  @override
  JbPalette copyWith({
    Brightness? brightness,
    Color? bg,
    Color? card,
    Color? cardAlt,
    Color? chipBg,
    Color? border,
    Color? borderStrong,
    Color? divider,
    Color? scrim,
    Color? ink,
    Color? gray,
    Color? grayLight,
    Color? onBrand,
    Color? blue,
    Color? blueDark,
    Color? blueLight,
    Color? blueTint,
    Color? gradientStart,
    Color? green,
    Color? greenBg,
    Color? amber,
    Color? amberBg,
    Color? amberTile,
    Color? red,
    Color? redBg,
    Color? violet,
    Color? violetBg,
    Color? cyan,
    Color? pink,
    Color? gold,
    Color? goldSoft,
    Color? shadow,
  }) {
    return JbPalette(
      brightness: brightness ?? this.brightness,
      bg: bg ?? this.bg,
      card: card ?? this.card,
      cardAlt: cardAlt ?? this.cardAlt,
      chipBg: chipBg ?? this.chipBg,
      border: border ?? this.border,
      borderStrong: borderStrong ?? this.borderStrong,
      divider: divider ?? this.divider,
      scrim: scrim ?? this.scrim,
      ink: ink ?? this.ink,
      gray: gray ?? this.gray,
      grayLight: grayLight ?? this.grayLight,
      onBrand: onBrand ?? this.onBrand,
      blue: blue ?? this.blue,
      blueDark: blueDark ?? this.blueDark,
      blueLight: blueLight ?? this.blueLight,
      blueTint: blueTint ?? this.blueTint,
      gradientStart: gradientStart ?? this.gradientStart,
      green: green ?? this.green,
      greenBg: greenBg ?? this.greenBg,
      amber: amber ?? this.amber,
      amberBg: amberBg ?? this.amberBg,
      amberTile: amberTile ?? this.amberTile,
      red: red ?? this.red,
      redBg: redBg ?? this.redBg,
      violet: violet ?? this.violet,
      violetBg: violetBg ?? this.violetBg,
      cyan: cyan ?? this.cyan,
      pink: pink ?? this.pink,
      gold: gold ?? this.gold,
      goldSoft: goldSoft ?? this.goldSoft,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  JbPalette lerp(ThemeExtension<JbPalette>? other, double t) {
    if (other is! JbPalette) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return JbPalette(
      brightness: t < 0.5 ? brightness : other.brightness,
      bg: c(bg, other.bg),
      card: c(card, other.card),
      cardAlt: c(cardAlt, other.cardAlt),
      chipBg: c(chipBg, other.chipBg),
      border: c(border, other.border),
      borderStrong: c(borderStrong, other.borderStrong),
      divider: c(divider, other.divider),
      scrim: c(scrim, other.scrim),
      ink: c(ink, other.ink),
      gray: c(gray, other.gray),
      grayLight: c(grayLight, other.grayLight),
      onBrand: c(onBrand, other.onBrand),
      blue: c(blue, other.blue),
      blueDark: c(blueDark, other.blueDark),
      blueLight: c(blueLight, other.blueLight),
      blueTint: c(blueTint, other.blueTint),
      gradientStart: c(gradientStart, other.gradientStart),
      green: c(green, other.green),
      greenBg: c(greenBg, other.greenBg),
      amber: c(amber, other.amber),
      amberBg: c(amberBg, other.amberBg),
      amberTile: c(amberTile, other.amberTile),
      red: c(red, other.red),
      redBg: c(redBg, other.redBg),
      violet: c(violet, other.violet),
      violetBg: c(violetBg, other.violetBg),
      cyan: c(cyan, other.cyan),
      pink: c(pink, other.pink),
      gold: c(gold, other.gold),
      goldSoft: c(goldSoft, other.goldSoft),
      shadow: c(shadow, other.shadow),
    );
  }
}

/// ---------------------------------------------------------------------------
/// L I G H T  —  mavjud Jobup24 dizayni (o'zgarmadi).
/// ---------------------------------------------------------------------------
const JbPalette kJbLight = JbPalette(
  brightness: Brightness.light,
  bg: Color(0xFFF5F6FA),
  card: Color(0xFFFFFFFF),
  cardAlt: Color(0xFFF8FAFC),
  chipBg: Color(0xFFF5F6FA),
  border: Color(0xFFE7EAF0),
  borderStrong: Color(0xFFD7DCE5),
  divider: Color(0xFFF0F1F5),
  scrim: Color(0x8C0B1020),
  ink: Color(0xFF14161A),
  gray: Color(0xFF6B7280),
  grayLight: Color(0xFF9CA3AF),
  onBrand: Color(0xFFFFFFFF),
  blue: Color(0xFF2A5BFF),
  blueDark: Color(0xFF1846D6),
  blueLight: Color(0xFF5B8DFF),
  blueTint: Color(0xFFEEF2FF),
  gradientStart: Color(0xFF3D6BFF),
  green: Color(0xFF16A34A),
  greenBg: Color(0xFFDCFCE7),
  amber: Color(0xFFD97706),
  amberBg: Color(0xFFFEF3C7),
  amberTile: Color(0xFFFFF1DE),
  red: Color(0xFFDC2626),
  redBg: Color(0xFFFEE2E2),
  violet: Color(0xFF7C3AED),
  violetBg: Color(0xFFF3EEFF),
  cyan: Color(0xFF0891B2),
  pink: Color(0xFFEC4899),
  gold: Color(0xFFB57C32),
  goldSoft: Color(0xFFE8C46C),
  shadow: Color(0x0D141E3C),
);

/// ---------------------------------------------------------------------------
/// D A R K  —  "graphite + vivid" zamonaviy tungi palitra.
/// Fon sof qora emas, ko'kimtir-grafit; aksentlar bir pog'ona yorqinroq olindi,
/// shunda quyuq fonda kontrast AA darajasida bo'ladi.
/// ---------------------------------------------------------------------------
const JbPalette kJbDark = JbPalette(
  brightness: Brightness.dark,
  bg: Color(0xFF0D1117),
  card: Color(0xFF161B22),
  cardAlt: Color(0xFF1C222B),
  chipBg: Color(0xFF1E2530),
  border: Color(0xFF2A313C),
  borderStrong: Color(0xFF3A424F),
  divider: Color(0xFF232A34),
  scrim: Color(0xB3000000),
  ink: Color(0xFFE8ECF2),
  gray: Color(0xFF9BA6B4),
  grayLight: Color(0xFF707B8A),
  onBrand: Color(0xFFFFFFFF),
  blue: Color(0xFF5B8DFF),
  blueDark: Color(0xFF3D6BFF),
  blueLight: Color(0xFF8AAEFF),
  blueTint: Color(0xFF1B2440),
  gradientStart: Color(0xFF4C7BFF),
  green: Color(0xFF34D399),
  greenBg: Color(0xFF122E22),
  amber: Color(0xFFFBBF24),
  amberBg: Color(0xFF2E2312),
  amberTile: Color(0xFF33280F),
  red: Color(0xFFF87171),
  redBg: Color(0xFF33191B),
  violet: Color(0xFFA78BFA),
  violetBg: Color(0xFF241E3D),
  cyan: Color(0xFF22D3EE),
  pink: Color(0xFFF472B6),
  gold: Color(0xFFE8C46C),
  goldSoft: Color(0xFFB57C32),
  shadow: Color(0x66000000),
);

/// Global mirror — `BuildContext` yo'q joylar uchun.
///
/// Faqat [syncJbPalette] orqali o'zgaradi (ThemeCubit va MyApp chaqiradi),
/// shuning uchun widget'lar qayta qurilishidan oldin doim to'g'ri qiymatda
/// bo'ladi.
JbPalette jb = kJbLight;

/// Global [jb] ni joriy rejimga moslaydi.
void syncJbPalette(Brightness brightness) {
  jb = brightness == Brightness.dark ? kJbDark : kJbLight;
}

/// `context.jb.card` ko'rinishidagi qisqa kirish (Theme'ga bog'lanadi).
extension JbPaletteContext on BuildContext {
  JbPalette get jb =>
      Theme.of(this).extension<JbPalette>() ??
      (Theme.of(this).brightness == Brightness.dark ? kJbDark : kJbLight);

  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}
