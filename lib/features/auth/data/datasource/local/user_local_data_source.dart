import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/constants/constants.dart';
import '../../models/map_item_model.dart';
import '../../models/user_model.dart';

abstract class UserLocalDatasource {
  String getToken();

  Future<void> saveToken(String token);

  String getFcmToken();

  Future<void> setFcmToken(String token);

  UserModel? getCachedUser();

  Future<void> saveUser(UserModel user);

  Future<void> clearCache();

  Future<void> setFirstRun(bool value);

  bool isFirstRun();

  String getLang();

  Future<void> setLang(String locale);

  Future<void> setCurrentAddress(MapItemModel currentAddress);

  MapItemModel? getCurrentAddress();

  Future<bool> setActiveChildId(int id);

  int getActiveChildId();
}

class UserLocalDataSourceImpl implements UserLocalDatasource {
  final SharedPreferences sharedPreferences;

  UserLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<void> clearCache() async {
    await sharedPreferences.clear();
  }

  @override
  Future<void> setCurrentAddress(MapItemModel currentAddress) {
    return sharedPreferences.setString(PREF_LOCATION, jsonEncode(currentAddress.toJson()));
  }

  @override
  MapItemModel? getCurrentAddress() {
    if (sharedPreferences.getString(PREF_LOCATION) == null) {
      return null;
    } else {
      return MapItemModel.fromJson(jsonDecode(sharedPreferences.getString(PREF_LOCATION) ?? ""));
    }
  }

  @override
  Future<void> saveUser(UserModel user) {
    return sharedPreferences.setString(PREF_USER, jsonEncode(user.toJson()));
  }

  @override
  UserModel? getCachedUser() {
    if (sharedPreferences.getString(PREF_USER) == null) {
      return null;
    } else {
      return UserModel.fromJson(jsonDecode(sharedPreferences.getString(PREF_USER) ?? ""));
    }
  }

  @override
  String getToken() {
    String? token = sharedPreferences.getString(PREF_TOKEN);
    return token ?? "";
  }

  @override
  Future<void> saveToken(String token) {
    return sharedPreferences.setString(PREF_TOKEN, token);
  }

  @override
  String getFcmToken() {
    String? token = sharedPreferences.getString(FCM_TOKEN);
    return token ?? "";
  }

  @override
  Future<void> setFcmToken(String token) {
    return sharedPreferences.setString(FCM_TOKEN, token);
  }

  @override
  Future<bool> setFirstRun(bool value) async {
    return sharedPreferences.setBool(FIRST_RUN, value);
  }

  @override
  bool isFirstRun() {
    return sharedPreferences.getBool(FIRST_RUN) ?? true;
  }

  @override
  String getLang() {
    return sharedPreferences.getString(PREF_LANG) ?? 'ru';
  }

  @override
  Future<bool?> setLang(String value) async {
    return sharedPreferences.setString(PREF_LANG, value);
  }

  @override
  Future<bool> setActiveChildId(int id) async {
    return sharedPreferences.setInt(PREF_ACTIVE_CHILD_ID, id);
  }

  @override
  int getActiveChildId() {
    return sharedPreferences.getInt(PREF_ACTIVE_CHILD_ID) ?? -1;
  }
}
