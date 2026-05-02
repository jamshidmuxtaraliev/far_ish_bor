import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/constants.dart';

class LocaleCubit extends Cubit<Locale> {
  final SharedPreferences _prefs;

  LocaleCubit(this._prefs) : super(_loadInitial(_prefs));

  static Locale _loadInitial(SharedPreferences prefs) {
    final saved = prefs.getString(PREF_LANG);
    return Locale(saved ?? DEFAULT_LANG_KEY);
  }

  void setLocale(Locale locale) {
    _prefs.setString(PREF_LANG, locale.languageCode);
    emit(locale);
  }
}
