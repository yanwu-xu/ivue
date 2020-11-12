import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_boost/flutter_boost.dart';
import 'package:geely_flutter/model/language_statu.dart';
import 'package:geely_flutter/model/user_info.dart';

class PageRouter {
  static const String OPEN_EDIT_MAIL = "basis/bhs_open_workbench_for_edit_email";
  static const String WORKITEM = "workbench/bhs_workbench_click_item";
  static const String USER_SETTING = "basis/bhs_open_user_setting";
  static const String SCAN = "basis/bhs_open_scan";
  static const String HOME_REFRESH = "workbench/refresh_data";
  static const String CHANGE_LANGUAGE = "basis/native_language_changed";
  static const String LANGUAGE_STATU = "basis/bhs_language_status";
  static const String USER_INFO = "basis/bhs_user_info";
  static const String OPEN_LOGIN = "basis/bhs_open_login";
  static const String OPEN_WORKBENCH =
      "workbench/bhs_open_workbench_for_portal";
  static const String LOGIN_SUCCESS = "basis/bhs_login_success";
  static const String OPEN_WEBVIEW = "basis/bhs_open_webView";
  static const String OPEN_NATIVE_DIALOG = "basis/bhs_open_dialog";
  static const String MYHOMEPAGE = "geely/myhomepage";
  static const String MODULECENTER = "geely/modulecenter";

  static const String GetOauthToken = "basis/bhs_oauth_token";

  static const String ABOUT = "geely/about";
  static const String WEBVIEWBROWSER = "geely/webview_browser";

  static const String ONEACTIVITY = "OneActivity";

  static const String CHANNEL = "com.sammbo.fmeeting/route";
  static MethodChannel methodChannel = MethodChannel(PageRouter.CHANNEL);

  static void openPageByUrl(String url, Map params) {
    switch (url) {
      case OPEN_EDIT_MAIL:
        openEditMail();
        break;
      case WORKITEM:
        dealWorkItem(params);
        break;
      case USER_SETTING:
        dealUserSetting(params);
        break;
      case SCAN:
        dealScan();
        break;
      case ABOUT:
        FlutterBoost.singleton.open(ABOUT);
        break;
      case WEBVIEWBROWSER:
        FlutterBoost.singleton.open(WEBVIEWBROWSER, urlParams: params);
        break;
    }
  }



  ///工作台点击事件
  static void dealWorkItem(Map<String, dynamic> params) {
    debugPrint('dealWorkItem ${params.toString()}');
    try {
      if (params['callUri'] == null) {
        params['callUri'] = params['SettingURL'];
        params['belong'] = 1;
        // params['callWay'] = 0;
        if (params['SettingURL'] == 'thunbu://app/todo') {
          params['callWay'] = 1;
        }
      }
      PageRouter.methodChannel.invokeMethod(WORKITEM, params);
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  ///跳转到webview； params 中要带一个url的key 传入跳转链接
  // ignore: non_constant_identifier_names
  static void open_webview(Map<String, dynamic> params) {
    debugPrint('open_webview ${params.toString()}');
    try {
      if (params['url'] != null) {
        PageRouter.methodChannel.invokeMethod(OPEN_WEBVIEW, params);
      }
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  /// 打开原生弹窗
  static void openNativeDialog() {
    try {
      PageRouter.methodChannel.invokeMethod(OPEN_NATIVE_DIALOG);
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  ///跳转个人主⻚
  static void dealUserSetting(Map params) {
    try {
      PageRouter.methodChannel.invokeMethod(USER_SETTING, params);
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  ///跳转写邮件
  static void openEditMail() {
    try {
      PageRouter.methodChannel.invokeMethod(OPEN_EDIT_MAIL);
    } on PlatformException catch (e) {
      print(e.message);
    }
  }
  ///跳转扫一扫
  static void dealScan() {
    try {
      PageRouter.methodChannel.invokeMethod(SCAN);
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  ///弹出域账号登录授权
  static void openLogin() {
    try {
      print('$OPEN_LOGIN');
      PageRouter.methodChannel.invokeMethod(OPEN_LOGIN);
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  ///更多打开工作台
  static void openWorkbench() {
    try {
      PageRouter.methodChannel.invokeMethod(OPEN_WORKBENCH);
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  static Future<dynamic> getTile() async {
    try {
      final String result =
          await PageRouter.methodChannel.invokeMethod('getPlatformVersion');
      return result;
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  ///获取用户信息
  static Future<UserInfo> getUserInfo() async {
    try {
      final Map result = await PageRouter.methodChannel.invokeMethod(USER_INFO);
      //var decode = json.decode(result);
      bool success = result["success"] as bool;
      if (success) {
        var userInfo = UserInfo.fromMap(result);
        return userInfo;
      } else {
        return UserInfo();
      }
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  ///获取用户信息
  static Future<String> getOauthToken() async {
    try {
      final Map result =
          await PageRouter.methodChannel.invokeMethod(GetOauthToken);
      bool success = result["success"] as bool;
      if (success) {
        var oauthToken = result['data'];
        return oauthToken;
      }
    } on PlatformException catch (e) {
      print(e.message);
    }

    print(
        '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!  获取二次token失败 !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! ');
    openLogin();
    return null;
  }

  ///获取中英文状态
  static Future<LanguageStatu> getLanguage() async {
    try {
      final Map result =
          await PageRouter.methodChannel.invokeMethod(LANGUAGE_STATU);
      print('getLanguage:$result');
      //var decode = json.decode(result);
      bool success = result["success"] as bool;
      if (success) {
        var languageStatu = LanguageStatu.fromMap(result);
        return languageStatu;
      } else {
        return LanguageStatu();
      }
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  ///原生调用Flutter
  static Future<dynamic> platformCallHandler(MethodCall methodCall) async {
    switch (methodCall.method) {
      //中英文状态切换通知
      case PageRouter.CHANGE_LANGUAGE:
        debugPrint(
            'platformCallHandler  =  CHANGE_LANGUAGE：== arguments：${methodCall.arguments.toString()}');
        //CommonUtils.changeLocale(methodCall.arguments.toString());
        break;
      //主动刷新
      case PageRouter.HOME_REFRESH:
        debugPrint('platformCallHandler  = HOME_REFRESH：');
        break;
      //登录成功
      case PageRouter.LOGIN_SUCCESS:
        debugPrint('platformCallHandler  = LOGIN_SUCCESS：');
        break;
    }
  }
}
