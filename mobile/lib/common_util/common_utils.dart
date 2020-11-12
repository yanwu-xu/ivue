import 'dart:async';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geely_flutter/HomeListView/model/usermodules_scopedModel.dart';
import 'package:geely_flutter/common_util/page_router.dart';
import 'package:geely_flutter/common_util/shared_preferences_util.dart';
import 'package:geely_flutter/model/user_info.dart';
import 'package:geely_flutter/network/api_manage.dart';
import 'package:geely_flutter/network_signalr/network_signalr.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

/*
 * 通用逻辑
 */
class CommonUtils {
  // 保存当前用户信息
  static DataBean user;

  // 当前的store
//  static Store<GLState> store;

  static UserModulesScopedModel homeListScopedModels;

  static final double MILLIS_LIMIT = 1000.0;

  static final double SECONDS_LIMIT = 60 * MILLIS_LIMIT;

  static final double MINUTES_LIMIT = 60 * SECONDS_LIMIT;

  static final double HOURS_LIMIT = 24 * MINUTES_LIMIT;

  static final double DAYS_LIMIT = 30 * HOURS_LIMIT;

  static double homeLeftPad = 16;

  static double homeTopPad = 10;

  static String curLocale;

  static EdgeInsetsGeometry homeModelsPad = EdgeInsets.only(
      bottom: CommonUtils.homeTopPad,
      left: CommonUtils.homeLeftPad,
      right: CommonUtils.homeLeftPad);

  /// 打开第三方应用
  /// 如：
  /// 打电话 tel://
  /// 打开吉时学 geelygke://
  static launchURL(String urlStr, {String otherUrl}) async {
    if (await canLaunch(urlStr)) {
      await launch(urlStr);
      return true;
    } else {
      if (otherUrl != null && otherUrl.isNotEmpty) {
        launchURL(otherUrl);
      }
      return false;
    }
  }

  /// toast 提示
  static toastShow(String msg) {
    Fluttertoast.showToast(msg: msg);
  }

  /// 获取用户信息
  static Future getUserInfo() async {
    /// 获取用户信息
    var value = await PageRouter.getUserInfo();
    saveUserInfo(value);
    var acctokenValue;
    if (CommonUtils.user.token == null || CommonUtils.user.token.isEmpty) {
      acctokenValue = await ApiManage.getAccTokenByAuthToken();
    } else {
      acctokenValue = await ApiManage.getAccTokenByGeelyToken(
          CommonUtils.user.corpId, CommonUtils.user.token);
    }

    if (acctokenValue != null && acctokenValue is String) {
      user.oauthToken = acctokenValue;
    }
    return '刷新';
  }

  /// 保存用户信息
  static saveUserInfo(value) {
    debugPrint("[SignalR] saveUserInfo");
    if (value is UserInfo && value.success) {
      print("------AAA----${value.data.corpId}------${value.data.token}");

//      store.state.userInfo = value;
      if (value.data.oauthToken != null && value.data.oauthToken.isNotEmpty) {
        debugPrint("[SignalR] value.data ${value.data.oauthToken}");
        user = value.data;
        if (user != null && user.oauthToken != null) {
          debugPrint("[SignalR] SignalrConnect");
          SignalrConnect signalrConnect = new SignalrConnect();
          // 当token变了，需要重新发送新消息
        }
      }
      debugPrint("[SignalR] jsonUser");

      // String jsonUser = json.encode(value);
      // SPManager.set(Config.USER_INFO, jsonUser);
    }
  }

  /// 改变用户信息下的oauthToken
  static changeUserOauthToken(String oauthToken) {
    if (oauthToken != null && oauthToken.isNotEmpty) {
      user.oauthToken = oauthToken;
    }
  }

  /// 在报401错误时，删除用户token
  static removeToken() {
    CommonUtils.user.token = null;
    CommonUtils.user.oauthToken = null;
    CommonUtils.getUserInfo();
  }

  /*
   * 切换语言;
   * language: zh_CN || en_US
   */
  // static changeLocale(Store<GLState> store, String language) {
//    if (curLocale == language) {
//      debugPrint('同一语言');
//      return;
//    }
//    // Store<GLState> store1 = StoreProvider.of<GLState>(CommonUtils().context);
//    // Locale locale1 = store1.state.platformLocale;
//    // debugPrint('当前语言1' + locale1.toString());
//
//    Locale locale = store.state.locale;
//    // Locale locale2 = store.state.platformLocale;
//    // Locale locale1 = WidgetsBinding.instance.window.locale;
//
//    debugPrint('当前语言' + locale.toString() + '切换到' + language);
//
//    if (language == 'en_US') {
//      locale = Locale('en', 'US');
//    } else {
//      locale = Locale('zh', 'CH');
//    }
//
//    curLocale = language;
  //  store.dispatch(RefreshLocaleAction(curLocale));
  // }

  static String getDateStr(DateTime date) {
    if (date == null || date.toString() == null) {
      return "";
    } else if (date.toString().length < 10) {
      return date.toString();
    }
    return date.toString().substring(0, 10);
  }

  static getLocalPath() async {
    Directory appDir;
    if (Platform.isIOS) {
      appDir = await getApplicationDocumentsDirectory();
    } else {
      appDir = await getExternalStorageDirectory();
    }
    PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage);
    if (permission != PermissionStatus.granted) {
      Map<PermissionGroup, PermissionStatus> permissions =
          await PermissionHandler()
              .requestPermissions([PermissionGroup.storage]);
      if (permissions[PermissionGroup.storage] != PermissionStatus.granted) {
        return null;
      }
    }
    String appDocPath = appDir.path + "/gsygithubappflutter";
    Directory appPath = Directory(appDocPath);
    await appPath.create(recursive: true);
    return appPath;
  }

  static saveImage(String url) async {
    Future<String> _findPath(String imageUrl) async {
      final file = await DefaultCacheManager().getSingleFile(url);
      if (file == null) {
        return null;
      }
      Directory localPath = await CommonUtils.getLocalPath();
      if (localPath == null) {
        return null;
      }
      final name = splitFileNameByPath(file.path);
      final result = await file.copy(localPath.path + name);
      return result.path;
    }

    return _findPath(url);
  }

  static splitFileNameByPath(String path) {
    return path.substring(path.lastIndexOf("/"));
  }

  // static pushTheme(Store store, int index) {
  //   ThemeData themeData;
  //   List<Color> colors = getThemeListColor();
  //   themeData = getThemeData(colors[index]);
  //   store.dispatch(new RefreshThemeDataAction(themeData));
  // }

  // static getThemeData(Color color) {
  //   return ThemeData(primarySwatch: color, platform: TargetPlatform.android);
  // }

  ///获取设备信息
  static Future<String> getDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      return "";
    }
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    return iosInfo.model;
  }

  static const IMAGE_END = [".png", ".jpg", ".jpeg", ".gif", ".svg"];

  static isImageEnd(path) {
    bool image = false;
    for (String item in IMAGE_END) {
      if (path.indexOf(item) + item.length == path.length) {
        image = true;
      }
    }
    return image;
  }

  static copy(String data, BuildContext context) {
    Clipboard.setData(new ClipboardData(text: data));
    Fluttertoast.showToast(msg: '拷贝成功');
  }

  /// 获取常用阴影
  static getBoxShadow() {
    return BoxDecoration(
      color: Colors.white,
      shape: BoxShape.rectangle,
      // borderRadius: new BorderRadius.vertical( top: Radius.elliptical(20, 50)), // 也可控件一边圆角大小
      borderRadius: new BorderRadius.circular((5.0)),
      // border: new Border.all(color: Color(0xFFFF0000), width: 0.5), // 边色与边宽度

      // boxShadow: [
      //   // 阴影设置
      //   BoxShadow(
      //     color: Color.fromARGB(18, 0, 0, 0),
      //     offset: Offset(0.0, 2.0),
      //     blurRadius: 8.0,
      //     spreadRadius: 1.0,
      //   ),
      // ],
    );
  }

  /// 设置loading的UI
  static setLoading({bool loading = false}) {
    if (loading) {
      return Center(
        child: Text(
          'loading',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF3F4342),
            fontSize: 16.0,
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.none,
          ),
        ),
      );
    } else {
      return Center();
    }
  }

//--------------------------单例
  // 工厂构造函数
  factory CommonUtils() => _sharedInstance();

// 静态私有成员，没有初始化
  static CommonUtils _instance;

  // 私有构造函数
  CommonUtils._() {
    // 具体初始化代码
  }

  // 静态、同步、私有访问点
  static CommonUtils _sharedInstance() {
    if (_instance == null) {
      _instance = CommonUtils._();
    }
    return _instance;
  }
//--------------------------单例-----------------

}
