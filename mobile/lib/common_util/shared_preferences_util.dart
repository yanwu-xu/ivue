import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Config {
  static bool DEBUG = true;

  /// //////////////////////////////////////常量////////////////////////////////////// ///
  static const API_TOKEN = "4d65e2a5626103f92a71867d7b49fea0";
  static const TOKEN_KEY = "token";
  static const USER_NAME_KEY = "user-name";
  static const PW_KEY = "user-pw";
  static const USER_BASIC_CODE = "user-basic-code";
  static const USER_INFO = "user-info";
  static const LANGUAGE_SELECT = "language-select";
  static const LANGUAGE_SELECT_NAME = "language-select-name";
  static const REFRESH_LANGUAGE = "refreshLanguageApp";
  static const THEME_COLOR = "theme-color";
  static const LOCALE = "locale";
}

class SPManager {
  static Future<dynamic> getForKey(String key, [dynamic replace]) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var data = prefs.get(key);
    return data ?? replace ?? null;
  }

  static get(String key, [dynamic replace]) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var data = prefs.get(key);
    return data ?? replace ?? null;
  }

  static remove(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
  }

  static removeAll() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  static set(String key, value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    void saveFail(bool success) {
      if (!success) {
        print('保存失败 key:$key ');
      } else {
        debugPrint('保存成功 key:$key ');
      }
    }

    if (value is String) {
      prefs.setString(key, value).then((value) => saveFail(value));
    } else if (value is num) {
      prefs.setInt(key, value).then((value) => saveFail(value));
    } else if (value is double) {
      prefs.setDouble(key, value).then((value) => saveFail(value));
    } else if (value is bool) {
      prefs.setBool(key, value).then((value) => saveFail(value));
    } else if (value is List) {
      prefs
          .setStringList(key, value.cast<String>())
          .then((value) => saveFail(value));
    }
  }
}
