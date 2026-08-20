import 'package:flutter/material.dart';

import 'jb_palette.dart';

/// Ikkala rejim ham bitta manbadan quriladi: [JbPalette]. Yangi rang kerak
/// bo'lsa — palitraga token qo'shiladi, bu yerga emas.
ThemeData lightTheme() => _buildTheme(kJbLight);

ThemeData darkTheme() => _buildTheme(kJbDark);

ThemeData _buildTheme(JbPalette p) {
  final isDark = p.isDark;

  TextStyle t(double size, FontWeight weight, {Color? color}) => TextStyle(
    fontFamily: 'Poppins',
    fontWeight: weight,
    fontSize: size,
    color: color ?? p.ink,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: p.brightness,
    fontFamily: 'Poppins',
    scaffoldBackgroundColor: p.bg,
    canvasColor: p.bg,
    primaryColor: p.blue,
    dividerColor: p.border,
    shadowColor: p.shadow,
    splashFactory: InkRipple.splashFactory,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    extensions: <ThemeExtension<dynamic>>[p],

    colorScheme: ColorScheme(
      brightness: p.brightness,
      primary: p.blue,
      onPrimary: p.onBrand,
      primaryContainer: p.card,
      onPrimaryContainer: p.ink,
      secondary: p.blueLight,
      onSecondary: p.onBrand,
      secondaryContainer: p.blueTint,
      onSecondaryContainer: p.blue,
      tertiary: p.violet,
      onTertiary: p.onBrand,
      tertiaryContainer: p.chipBg,
      onTertiaryContainer: p.ink,
      error: p.red,
      onError: p.onBrand,
      errorContainer: p.redBg,
      onErrorContainer: p.red,
      surface: p.card,
      onSurface: p.ink,
      surfaceContainerLowest: p.bg,
      surfaceContainerLow: p.cardAlt,
      surfaceContainer: p.card,
      surfaceContainerHigh: p.cardAlt,
      surfaceContainerHighest: p.chipBg,
      onSurfaceVariant: p.gray,
      outline: p.border,
      outlineVariant: p.borderStrong,
      shadow: p.shadow,
      scrim: p.scrim,
      inverseSurface: p.ink,
      onInverseSurface: p.card,
      inversePrimary: p.blueLight,
    ),

    textTheme: TextTheme(
      displayLarge: t(32, FontWeight.w800),
      displayMedium: t(28, FontWeight.w800),
      headlineLarge: t(24, FontWeight.w800),
      headlineMedium: t(20, FontWeight.w700),
      titleLarge: t(16, FontWeight.w700),
      titleMedium: t(15, FontWeight.w600),
      bodyLarge: t(16, FontWeight.w400),
      bodyMedium: t(14, FontWeight.w400),
      bodySmall: t(13, FontWeight.w400, color: p.gray),
      labelLarge: t(14, FontWeight.w600),
      labelMedium: t(13, FontWeight.w500, color: p.gray),
      labelSmall: t(12, FontWeight.w500, color: p.grayLight),
    ),

    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: p.card,
      foregroundColor: p.ink,
      surfaceTintColor: Colors.transparent,
      iconTheme: IconThemeData(color: p.ink),
      titleTextStyle: t(19, FontWeight.w800),
      systemOverlayStyle: p.overlay,
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: p.card,
      selectedItemColor: p.blue,
      unselectedItemColor: p.grayLight,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: p.card,
      indicatorColor: p.blueTint,
      surfaceTintColor: Colors.transparent,
    ),

    cardTheme: CardThemeData(
      color: p.card,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: p.card,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: t(18, FontWeight.w700),
      contentTextStyle: t(14, FontWeight.w400, color: p.gray),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),

    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: p.card,
      surfaceTintColor: Colors.transparent,
      modalBackgroundColor: p.card,
      modalBarrierColor: p.scrim,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),

    popupMenuTheme: PopupMenuThemeData(
      color: p.card,
      surfaceTintColor: Colors.transparent,
      textStyle: t(14, FontWeight.w500),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: isDark ? p.cardAlt : p.card,
      hintStyle: t(14, FontWeight.w400, color: p.grayLight),
      labelStyle: t(14, FontWeight.w500, color: p.gray),
      prefixIconColor: p.grayLight,
      suffixIconColor: p.grayLight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: p.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: p.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: p.blue, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: p.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: p.red, width: 1.5),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: p.blue,
        foregroundColor: p.onBrand,
        disabledBackgroundColor: p.chipBg,
        disabledForegroundColor: p.grayLight,
        elevation: 0,
        textStyle: t(15, FontWeight.w700, color: p.onBrand),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: p.ink,
        side: BorderSide(color: p.border, width: 1.5),
        textStyle: t(15, FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: p.blue,
        textStyle: t(14, FontWeight.w600, color: p.blue),
      ),
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: p.blue,
      foregroundColor: p.onBrand,
    ),

    iconTheme: IconThemeData(color: p.ink),
    primaryIconTheme: IconThemeData(color: p.onBrand),

    chipTheme: ChipThemeData(
      backgroundColor: p.chipBg,
      selectedColor: p.blue,
      disabledColor: p.chipBg,
      labelStyle: t(13, FontWeight.w600),
      side: BorderSide(color: p.border),
      shape: const StadiumBorder(),
    ),

    dividerTheme: DividerThemeData(color: p.divider, thickness: 1, space: 1),

    listTileTheme: ListTileThemeData(
      iconColor: p.gray,
      textColor: p.ink,
      titleTextStyle: t(15, FontWeight.w600),
      subtitleTextStyle: t(13, FontWeight.w400, color: p.gray),
    ),

    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? p.onBrand : p.card,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? p.blue : p.chipBg,
      ),
      trackOutlineColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? p.blue : p.borderStrong,
      ),
    ),

    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? p.blue : Colors.transparent,
      ),
      checkColor: WidgetStatePropertyAll(p.onBrand),
      side: BorderSide(color: p.borderStrong, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    ),

    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? p.blue : p.borderStrong,
      ),
    ),

    sliderTheme: SliderThemeData(
      activeTrackColor: p.blue,
      inactiveTrackColor: p.chipBg,
      thumbColor: p.blue,
      overlayColor: p.blue.withValues(alpha: 0.12),
    ),

    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: p.blue,
      linearTrackColor: p.chipBg,
      circularTrackColor: p.chipBg,
    ),

    tabBarTheme: TabBarThemeData(
      labelColor: p.blue,
      unselectedLabelColor: p.gray,
      indicatorColor: p.blue,
      dividerColor: Colors.transparent,
      labelStyle: t(14, FontWeight.w700, color: p.blue),
      unselectedLabelStyle: t(14, FontWeight.w500, color: p.gray),
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: isDark ? p.cardAlt : p.ink,
      contentTextStyle: t(14, FontWeight.w500, color: isDark ? p.ink : p.card),
      actionTextColor: p.blueLight,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),

    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: isDark ? p.cardAlt : p.ink,
        borderRadius: BorderRadius.circular(10),
      ),
      textStyle: t(12, FontWeight.w500, color: isDark ? p.ink : p.card),
    ),

    timePickerTheme: TimePickerThemeData(
      backgroundColor: p.card,
      dialBackgroundColor: p.chipBg,
      hourMinuteColor: p.chipBg,
      hourMinuteTextColor: p.ink,
      dayPeriodTextColor: p.ink,
    ),

    datePickerTheme: DatePickerThemeData(
      backgroundColor: p.card,
      surfaceTintColor: Colors.transparent,
      headerBackgroundColor: p.blue,
      headerForegroundColor: p.onBrand,
      todayForegroundColor: WidgetStatePropertyAll(p.blue),
    ),

    drawerTheme: DrawerThemeData(
      backgroundColor: p.card,
      surfaceTintColor: Colors.transparent,
    ),
  );
}
