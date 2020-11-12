import 'package:dio/dio.dart';
import 'package:geely_flutter/HomeListView/model/c3new_model.dart';
import 'package:geely_flutter/HomeListView/model/carousel_model.dart';
import 'package:geely_flutter/HomeListView/model/listcard_model.dart';
import 'package:geely_flutter/HomeListView/model/study_model.dart';
import 'package:geely_flutter/HomeListView/model/usermodules_scopedModel.dart';
import 'package:geely_flutter/common_util/common_utils.dart';
import 'package:geely_flutter/common_util/page_router.dart';
import 'package:geely_flutter/network/http_manage.dart';

String geelyUserId = '943402';
String geelyToken = '5bc6b141-cb50-4a28-99e6-e07573574055';

class ApiManage {
  /// 获取首页模块
  // ignore: non_constant_identifier_names
  static Future GetUserModulesForAPP() async {
    var res = await httpManager.netRequest(
      '/Portal/MyModule/GetUserModulesForAPP',
    );

    if (res != null && res.Success) {
      print('请求成功 ');

      List<Datum> list =
          List<Datum>.from(res.Data.map((x) => Datum.fromJson(x)));

      return list;
    } else {
      print('请求失败');
    }

    return res;
  }

  /// 获取轮播图
  static Future getOnShelf(String urlStr) async {
    if (urlStr == null || urlStr.isEmpty) {
      return;
    }
    var res = await httpManager.netRequestLocation(
      urlStr,
      params: {
        'clientSource': 2,
      },
      options: Options(method: 'POST'),
    );

    if (res != null && res.Success) {
      print('请求成功 ');

      List<CarouselModel> list = List<CarouselModel>.from(
          res.Data.map((x) => CarouselModel.fromJson(x)));
      return list;
    } else {
      print('请求失败');
    }

    return res;
  }

  /// 获取我的学习模块
  static Future getStudyList(String urlStr) async {
    if (urlStr == null || urlStr.isEmpty) {
      return;
    }
    var res = await httpManager.netRequestLocation(urlStr);

    if (res != null && res.Success) {
      print('请求成功 ');

      List<StudyModel> list =
          List<StudyModel>.from(res.Data.map((x) => StudyModel.fromJson(x)));
      return list;
    } else {
      print('请求失败');
    }

    return res;
  }

  /// 根据geely token 转 闪布 token
  static Future getAccTokenByGeelyToken(String appid, String token) async {
    String urlStr = aipGetAccTokenByGeelyToken;
    print("---BBB----$appid----$token");
    if ((appid == null || appid.isEmpty) && (token == null || token.isEmpty)) {
      return;
    }
    var res = await httpManager
        .netRequestShanBu(urlStr, params: {'appId': appid, 'token': token});
    print("---CCC----${res.Data}----}");
    if (res != null && res.Success) {
      print('请求成功 ');
      return res.Data;
    } else {
      print('请求失败');
    }

    return res;
  }

  /// 根据oauthToken 转 闪布 token
  static Future getAccTokenByAuthToken() async {
    var authToken = await PageRouter.getOauthToken();

    print("---BBB----$authToken");
    if (authToken == null || authToken.isEmpty) {
      return;
    }

    String urlStr = apiGetSammboToken;

    var res = await httpManager
        .netRequestShanBu(urlStr, params: {'authToken': authToken});
    print("---CCC----${res.Data}----}");
    if (res != null && res.Success) {
      print('请求成功 ');
      return res.Data;
    } else {
      print('请求失败');
    }

    return res;
  }

  /// 获取用户信息
  static Future userCenterTokenLogin() async {
    var res = await httpManager.netRequestLocation(
      apiUserCenterTokenLogin,
    );

    if (res != null && res.Success) {
      print('请求成功 ');
      if (res.Data != null && res.Data is Map) {
        CommonUtils.user.geelyUserId = res.Data['UserId'];
      }
      return res;
    } else {
      print('请求失败');
    }

    return res;
  }

  /// 获取常用应用列表
  /// 闪布的接口
  static Future getAllApply(String urlStr) async {
    if (urlStr == null || urlStr.isEmpty) {
      return;
    }
    var res = await httpManager.netRequestShanBu(
      urlStr,
      params: {
        'accToken': CommonUtils.user.oauthToken,
        'corpId': CommonUtils.user.corpId,
        'userId': CommonUtils.user.userId,
        'client': 0,
      },
    );

    if (res != null && res.Success) {
      print('请求成功 ');

      List<ListCardModel> list = List<ListCardModel>.from(
          res.Data['customAppList'].map((x) => ListCardModel.fromJson(x)));
      return list;
    } else {
      print('请求失败');
    }

    return res;
  }

  /// 续accToken,times 单位：秒
  /// 闪布的接口
  static Future extendToken(int times) async {
    var res = await httpManager.netRequestShanBu(
      apiExtendToken,
      params: {
        'expireTime': times,
        'accToken': CommonUtils.user.oauthToken,
      },
      options: Options(method: 'POST'),
    );

    return res;
  }

  /// 获取AppId的未读数
  static Future getCountForAppID(String urlStr, String appId) async {
    if (urlStr == null || urlStr.isEmpty) {
      return;
    }
    var res = await httpManager.netRequestLocation(urlStr,
        header: {'token': CommonUtils.user.token},
        params: {'APPID': appId == null ? '' : appId});

    if (res != null && res.Success) {
      print('请求成功 getCountForAppID: $res');
      // return res;
    } else {
      print('请求失败 getCountForAppID: $res');
    }

    return res;
  }

  /// 获取C3的新闻
  static Future getC3News(String urlStr) async {
    if (urlStr == null || urlStr.isEmpty) {
      return;
    }

    // if (CommonUtils.user.geelyUserId == null ||
    //     CommonUtils.user.geelyUserId.isEmpty) {
    //   var getGeelyUserId = await userCenterTokenLogin();
    //   if (CommonUtils.user.geelyUserId != null &&
    //       CommonUtils.user.geelyUserId.isNotEmpty) {
    //     geelyUserId = CommonUtils.user.geelyUserId;
    //   }
    // }

    var res = await httpManager.netRequestOther(urlStr, params: {
//      'userId': CommonUtils.user.geelyUserId,
      'userId': geelyUserId,
    }, header: {
//      'token': CommonUtils.user.token
      'token': geelyToken
    });
    if (res != null &&
        res.data['code'] != null &&
        res.data['code'] == 'success') {
      print('请求成功 ');

      List<C3NewModel> list = List<C3NewModel>.from(
          res.data['data']['bannerInfo'].map((x) => C3NewModel.fromJson(x)));
      return list;
    } else {
      print('请求失败');
    }

    return res;
  }

// 登录
  static Future loginApp() async {
    var res = await httpManager.netRequest(
      '/Portal/Login/LoginAPP',
    );
    if (res != null && res.Success) {
      print('请求成功 ');

      List<CarouselModel> list = List<CarouselModel>.from(
          res.Data.map((x) => CarouselModel.fromJson(x)));
      return list;
    } else {
      print('请求失败');
    }

    return res;
  }
}
