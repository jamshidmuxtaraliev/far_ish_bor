import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/constants/constants.dart';
import '../../models/user_model.dart';

abstract class UserLocalDatasource {
  String getToken();
  Future<void> saveToken(String token);

  String getRole();
  Future<void> saveRole(String role);

  String getLang();
  Future<void> setLang(String locale);

  UserModel? getCachedUser();
  Future<void> saveUser(UserModel user);

  bool isFirstRun();
  Future<void> setFirstRun(bool value);

  Future<void> clearCache();
}

class UserLocalDataSourceImpl implements UserLocalDatasource {
  final SharedPreferences sharedPreferences;

  UserLocalDataSourceImpl(this.sharedPreferences);

  @override
  String getToken() => sharedPreferences.getString(PREF_TOKEN) ?? '';

  @override
  Future<void> saveToken(String token) =>
      sharedPreferences.setString(PREF_TOKEN, token);

  @override
  String getRole() => sharedPreferences.getString(PREF_ROLE) ?? '';

  @override
  Future<void> saveRole(String role) =>
      sharedPreferences.setString(PREF_ROLE, role);

  @override
  String getLang() => sharedPreferences.getString(PREF_LANG) ?? UZ_LANG_KEY;

  @override
  Future<void> setLang(String value) =>
      sharedPreferences.setString(PREF_LANG, value);

  @override
  UserModel? getCachedUser() {
    final str = sharedPreferences.getString(PREF_USER);
    if (str == null) return null;
    return UserModel.fromJson(jsonDecode(str));
  }

  @override
  Future<void> saveUser(UserModel user) =>
      sharedPreferences.setString(PREF_USER, jsonEncode(user.toJson()));

  @override
  bool isFirstRun() => sharedPreferences.getBool(FIRST_RUN) ?? true;

  @override
  Future<void> setFirstRun(bool value) =>
      sharedPreferences.setBool(FIRST_RUN, value);

  @override
  Future<void> clearCache() => sharedPreferences.clear();
}
