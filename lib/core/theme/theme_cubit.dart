import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/constants.dart';
import 'jb_palette.dart';

/// Mavzu (light / dark / system) boshqaruvi.
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
    return ThemeMode.values.firstWhere(
      (e) => e.name == saved,
      orElse: () => ThemeMode.light,
    );
  }

  /// `ThemeMode`ni haqiqiy yorqinlikka aylantiradi (`system` uchun qurilma
  /// sozlamasidan o'qiydi).
  static Brightness resolveBrightness(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return Brightness.light;
      case ThemeMode.dark:
        return Brightness.dark;
      case ThemeMode.system:
        return SchedulerBinding.instance.platformDispatcher.platformBrightness;
    }
  }

  void setTheme(ThemeMode mode) {
    _prefs.setString(PREF_THEME, mode.name);
    syncJbPalette(resolveBrightness(mode));
    emit(mode);
  }

  void toggle() => setTheme(isDark ? ThemeMode.light : ThemeMode.dark);

  bool get isDark => resolveBrightness(state) == Brightness.dark;
}
