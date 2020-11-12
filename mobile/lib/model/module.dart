/// TenantModuleID : "0586e5dc-b5a4-423c-a7f3-1933ed3cda74"
/// TenantID : "2341971941469350916"
/// ModuleID : "692c6147-cbfe-4084-aaac-ca15ae7214ef"
/// ClientID : 0
/// ModuleTypeID : "a44e35e9-9858-457f-a6b5-0c8210139764"
/// ModuleName_CN : "app轮播"
/// ModuleName_EN : "lunbo"
/// Disabled : 0
/// HasAuth : true
/// SortNum : 0
/// Height : null
/// Width : null
/// APPURL : "http://www.baidu.com"
/// HasTitleBorder : 0
/// MoreURL : "http://www.baidu.com"
/// LogoURL : "https://oss01-zb01-hz-internal.test.geely.com/GEELY_OAPortal_Bucket/GeelyOAPortal/202009/644687270.png?AWSAccessKeyId=U1PPMSBH5A5SMHJ957G3&Expires=4724184927&Signature=AYx9ERFstNO205naceIkXT3QwPQ%3D"
/// SettingURL : null
/// StyleID : "1"
/// StyleTypeID : "2"
/// PositionX : null
/// PositionY : null
/// IsSaved : 0

class Module {
  String TenantModuleID;
  String TenantID;
  String ModuleID;
  int ClientID;
  String ModuleTypeID;
  String ModuleNameCN;
  String ModuleNameEN;
  int Disabled;
  bool HasAuth;
  int SortNum;
  dynamic Height;
  dynamic Width;
  String APPURL;
  int HasTitleBorder;
  String MoreURL;
  String LogoURL;
  dynamic SettingURL;
  String StyleID;
  String StyleTypeID;
  dynamic PositionX;
  dynamic PositionY;
  int IsSaved;
  int IsTop;

  static Module fromMap(Map<String, dynamic> map) {
    if (map == null) return null;
    Module modulesAllBean = Module();
    modulesAllBean.TenantModuleID = map['TenantModuleID'];
    modulesAllBean.TenantID = map['TenantID'];
    modulesAllBean.ModuleID = map['ModuleID'];
    modulesAllBean.ClientID = map['ClientID'];
    modulesAllBean.ModuleTypeID = map['ModuleTypeID'];
    modulesAllBean.ModuleNameCN = map['ModuleName_CN'];
    modulesAllBean.ModuleNameEN = map['ModuleName_EN'];
    modulesAllBean.Disabled = map['Disabled'];
    modulesAllBean.HasAuth = map['HasAuth'];
    modulesAllBean.SortNum = map['SortNum'];
    modulesAllBean.Height = map['Height'];
    modulesAllBean.Width = map['Width'];
    modulesAllBean.APPURL = map['APPURL'];
    modulesAllBean.HasTitleBorder = map['HasTitleBorder'];
    modulesAllBean.MoreURL = map['MoreURL'];
    modulesAllBean.LogoURL = map['LogoURL'];
    modulesAllBean.SettingURL = map['SettingURL'];
    modulesAllBean.StyleID = map['StyleID'];
    modulesAllBean.StyleTypeID = map['StyleTypeID'];
    modulesAllBean.PositionX = map['PositionX'];
    modulesAllBean.PositionY = map['PositionY'];
    modulesAllBean.IsSaved = map['IsSaved'];
    modulesAllBean.IsTop = map['IsTop'];
    return modulesAllBean;
  }

  Map toJson() => {
    "TenantModuleID": TenantModuleID,
    "TenantID": TenantID,
    "ModuleID": ModuleID,
    "ClientID": ClientID,
    "ModuleTypeID": ModuleTypeID,
    "ModuleName_CN": ModuleNameCN,
    "ModuleName_EN": ModuleNameEN,
    "Disabled": Disabled,
    "HasAuth": HasAuth,
    "SortNum": SortNum,
    "Height": Height,
    "Width": Width,
    "APPURL": APPURL,
    "HasTitleBorder": HasTitleBorder,
    "MoreURL": MoreURL,
    "LogoURL": LogoURL,
    "SettingURL": SettingURL,
    "StyleID": StyleID,
    "StyleTypeID": StyleTypeID,
    "PositionX": PositionX,
    "PositionY": PositionY,
    "IsSaved": IsSaved,
    "IsTop": IsTop,
  };
}