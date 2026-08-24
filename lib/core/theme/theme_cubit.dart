import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/constants.dart';
import 'jb_palette.dart';

/// Mavzu (light / dark) boshqaruvi.
///
/// Tizim (`system`) rejimi qo'llab-quvvatlanmaydi — foydalanuvchi faqat
/// yorug' yoki tungi rejimni tanlaydi.
///
/// Tanlov `PREF_THEME` kalitida saqlanadi — al_xorazmiy'dagi kabi. Farqi:
/// bu yerda emit qilishdan oldin global [jb] palitrasi ham yangilanadi, shunda
/// `BuildContext`siz kod (model getterlari, static helperlar) ham to'g'ri
/// rangni ko'radi.
class ThemeCubit extends Cubit<ThemeMode> {
  final SharedPreferences _prefs;

  ThemeCubit(this._prefs) : super(_loadInitial(_prefs)) {
    syncJbPalette(resolveBrightness(state));
  }

  static ThemeMode _loadInitial(SharedPreferences prefs) {
    final saved = prefs.getString(PREF_THEME);
    // Eski o'rnatishlarda `system` saqlangan bo'lishi mumkin — uni yorug'ga
    // tushiramiz, chunki endi faqat light/dark tanlanadi.
    return saved == ThemeMode.dark.name ? ThemeMode.dark : ThemeMode.light;
  }

  /// `ThemeMode`ni haqiqiy yorqinlikka aylantiradi.
  static Brightness resolveBrightness(ThemeMode mode) =>
      mode == ThemeMode.dark ? Brightness.dark : Brightness.light;

  /// Faqat [ThemeMode.light] yoki [ThemeMode.dark] qabul qilinadi; boshqa
  /// qiymat yorug' rejimga tushiriladi.
  void setTheme(ThemeMode mode) {
    final resolved = mode == ThemeMode.dark ? ThemeMode.dark : ThemeMode.light;
    _prefs.setString(PREF_THEME, resolved.name);
    syncJbPalette(resolveBrightness(resolved));
    emit(resolved);
  }

  void setDark(bool dark) =>
      setTheme(dark ? ThemeMode.dark : ThemeMode.light);

  void toggle() => setTheme(isDark ? ThemeMode.light : ThemeMode.dark);

  bool get isDark => resolveBrightness(state) == Brightness.dark;
}
