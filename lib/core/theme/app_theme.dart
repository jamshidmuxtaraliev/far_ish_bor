import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/colors.dart';

ThemeData lightTheme() => ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: LIGHT_BACKGROUND_COLOR,
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontFamily: "GothamPro", fontWeight: FontWeight.w900, fontSize: 32, color: TEXT_COLOR),
    displayMedium: TextStyle(fontFamily: "GothamPro", fontWeight: FontWeight.w700, fontSize: 28, color: TEXT_COLOR),
    headlineLarge: TextStyle(fontFamily: "Montserrat", fontWeight: FontWeight.w600, fontSize: 24, color: TEXT_COLOR),
    headlineMedium: TextStyle(fontFamily: "Montserrat", fontWeight: FontWeight.w500, fontSize: 20, color: TEXT_COLOR),
    bodyLarge: TextStyle(fontFamily: "Montserrat", fontWeight: FontWeight.w400, fontSize: 16, color: TEXT_COLOR),
    bodyMedium: TextStyle(fontFamily: "Montserrat", fontWeight: FontWeight.w300, fontSize: 14, color: TEXT_COLOR),
    labelLarge: TextStyle(fontFamily: "Montserrat", fontWeight: FontWeight.w500, fontSize: 14, color: TEXT_COLOR),
  ),
  appBarTheme: const AppBarTheme(
    elevation: 0,
    scrolledUnderElevation: 0,
    backgroundColor: WHITE,
    systemOverlayStyle: SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarContrastEnforced: false,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(backgroundColor: WHITE),
  colorScheme: const ColorScheme.light(
    primaryContainer: WHITE,
    secondaryContainer: LIGHT_MENU_BUTTON_COLOR,
    tertiaryContainer: LIGHT_TERTIARY_CONTAINER_COLOR,
    tertiary: LIGHT_CHART_LINE_COLOR,
  ),
  dividerColor: DIVIDER_COLOR,
  visualDensity: VisualDensity.adaptivePlatformDensity,
);

//==================================================================================================================================================//
//==============================   D A R K    T H E M E   ==========================================================================================//
//==================================================================================================================================================//

ThemeData darkTheme() => ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: DARK_BACKGROUND_COLOR,
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontFamily: "GothamPro", fontWeight: FontWeight.w900, fontSize: 32, color: DARK_TEXT_COLOR),
    displayMedium: TextStyle(fontFamily: "GothamPro", fontWeight: FontWeight.w700, fontSize: 28, color: DARK_TEXT_COLOR),
    headlineLarge: TextStyle(fontFamily: "Montserrat", fontWeight: FontWeight.w600, fontSize: 24, color: DARK_TEXT_COLOR),
    headlineMedium: TextStyle(fontFamily: "Montserrat", fontWeight: FontWeight.w500, fontSize: 20, color: DARK_TEXT_COLOR),
    bodyLarge: TextStyle(fontFamily: "Montserrat", fontWeight: FontWeight.w400, fontSize: 16, color: DARK_TEXT_COLOR),
    bodyMedium: TextStyle(fontFamily: "Montserrat", fontWeight: FontWeight.w300, fontSize: 14, color: DARK_TEXT_COLOR),
    labelLarge: TextStyle(fontFamily: "Montserrat", fontWeight: FontWeight.w500, fontSize: 14, color: DARK_TEXT_COLOR),
  ),
  appBarTheme: const AppBarTheme(
    elevation: 0,
    scrolledUnderElevation: 0,
    backgroundColor: DARK_APPBAR_COLOR,
    iconTheme: IconThemeData(color: WHITE),
    systemOverlayStyle: SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarContrastEnforced: false,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(backgroundColor: DARK_APPBAR_COLOR),
  colorScheme: const ColorScheme.dark(
    primaryContainer: DARK_PRIMARY_CONTAINER_COLOR,
    secondaryContainer: DARK_MENU_BUTTON_COLOR,
    tertiaryContainer: DARK_TERTIARY_CONTAINER_COLOR,
    tertiary: DARK_CHART_LINE_COLOR,
  ),
  dividerColor: DARK_DIVIDER_COLOR,
  visualDensity: VisualDensity.adaptivePlatformDensity,
);
