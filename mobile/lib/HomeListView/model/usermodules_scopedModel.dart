import 'package:geely_flutter/HomeListView/model/study_model.dart';
import 'package:geely_flutter/common_util/common_utils.dart';
import 'package:geely_flutter/network/api_manage.dart';
import 'package:scoped_model/scoped_model.dart';
import 'dart:convert';

class UserModulesScopedModel extends Model {
  // 第一步 创建 model
  List<Datum> _userModilesList;
  UserModulesScopedModel(this._userModilesList, this._dicURLData);
  List<Datum> get userModilesList => _userModilesList;

  Map _dicURLData = {}; // 获取url下的数据
  Map get dicURLData => _dicURLData;

  void updateUserModules() {
    ApiManage.GetUserModulesForAPP().then((value) {
      if (value is List<Datum>) {
        print('获取用户模块成功');
        if (_userModilesList.length == value.length) {
          for (var i = 0; i < _userModilesList.length; i++) {
            String appurl = _userModilesList[0].appurl;
            String appurl1 = value[0].appurl;
            if (appurl != appurl1) {
              _userModilesList = value;
              sendNotifyListeners();
            }
          }
        } else {
          _userModilesList = value;
          sendNotifyListeners();
        }
      } else {
        print('获取用户模块失败');
        sendNotifyListeners();
      }
    });
  }

  sendNotifyListeners() {
    notifyListeners();
  }
}

// To parse this JSON data, do
//
//     final userHomeModule = userHomeModuleFromJson(jsonString);

UserHomeModule userHomeModuleFromJson(String str) =>
    UserHomeModule.fromJson(json.decode(str));

String userHomeModuleToJson(UserHomeModule data) => json.encode(data.toJson());

class UserHomeModule {
  UserHomeModule({
    this.success,
    this.code,
    this.message,
    this.data,
    this.pageInfo,
  });

  bool success;
  int code;
  String message;
  List<Datum> data;
  dynamic pageInfo;

  factory UserHomeModule.fromJson(Map<String, dynamic> json) => UserHomeModule(
        success: json["Success"],
        code: json["Code"],
        message: json["Message"],
        data: List<Datum>.from(json["Data"].map((x) => Datum.fromJson(x))),
        pageInfo: json["PageInfo"],
      );

  Map<String, dynamic> toJson() => {
        "Success": success,
        "Code": code,
        "Message": message,
        "Data": List<dynamic>.from(data.map((x) => x.toJson())),
        "PageInfo": pageInfo,
      };
}

class Datum {
  Datum({
    this.tenantModuleId,
    this.tenantId,
    this.moduleId,
    this.clientId,
    this.moduleTypeId,
    this.moduleNameCn,
    this.moduleNameEn,
    this.disabled,
    this.hasAuth,
    this.sortNum,
    this.height,
    this.width,
    this.appurl,
    this.hasTitleBorder,
    this.moreUrl,
    this.logoUrl,
    this.settingUrl,
    this.styleId,
    this.styleTypeId,
    this.positionX,
    this.positionY,
    this.isSaved,
    this.isTop,
  });

  String tenantModuleId;
  String tenantId;
  String moduleId;
  int clientId;
  String moduleTypeId;
  String moduleNameCn;
  String moduleNameEn;
  int disabled;

  /// 模块是否被管理员禁用
  bool hasAuth;

  /// HasAuth 用户是否有该模块权限
  int sortNum;
  dynamic height;
  dynamic width;
  String appurl;
  int hasTitleBorder;
  String moreUrl;
  String logoUrl;
  dynamic settingUrl;
  String styleId;
  String styleTypeId;
  String positionX;
  String positionY;
  int isSaved;
  int isTop;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        tenantModuleId: json["TenantModuleID"],
        tenantId: json["TenantID"],
        moduleId: json["ModuleID"],
        clientId: json["ClientID"],
        moduleTypeId:
            json["ModuleTypeID"] == null ? null : json["ModuleTypeID"],
        moduleNameCn: json["ModuleName_CN"],
        moduleNameEn: json["ModuleName_EN"],
        disabled: json["Disabled"],
        hasAuth: json["HasAuth"],
        sortNum: json["SortNum"],
        height: json["Height"],
        width: json["Width"],
        appurl: json["APPURL"],
        hasTitleBorder: json["HasTitleBorder"],
        moreUrl: json["MoreURL"] == null ? null : json["MoreURL"],
        logoUrl: json["LogoURL"],
        settingUrl: json["SettingURL"],
        styleId: json["StyleID"],
        styleTypeId: json["StyleTypeID"],
        positionX: json["PositionX"],
        positionY: json["PositionY"],
        isSaved: json["IsSaved"],
        isTop: json["IsTop"],
      );

  Map<String, dynamic> toJson() => {
        "TenantModuleID": tenantModuleId,
        "TenantID": tenantId,
        "ModuleID": moduleId,
        "ClientID": clientId,
        "ModuleTypeID": moduleTypeId == null ? null : moduleTypeId,
        "ModuleName_CN": moduleNameCn,
        "ModuleName_EN": moduleNameEn,
        "Disabled": disabled,
        "HasAuth": hasAuth,
        "SortNum": sortNum,
        "Height": height,
        "Width": width,
        "APPURL": appurl,
        "HasTitleBorder": hasTitleBorder,
        "MoreURL": moreUrl == null ? null : moreUrl,
        "LogoURL": logoUrl,
        "SettingURL": settingUrl,
        "StyleID": styleId,
        "StyleTypeID": styleTypeId,
        "PositionX": positionX,
        "PositionY": positionY,
        "IsSaved": isSaved,
        "IsTop": isTop,
      };
}
