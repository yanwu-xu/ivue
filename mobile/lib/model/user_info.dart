/// data : {"token":"","user_id":"","oauthToken":"","avatar":"","is_geely_user":""}
/// message : ""
/// success : true

class UserInfo {
  DataBean data;
  String message;
  bool success;

  static UserInfo fromMap(Map map) {
    if (map == null) return null;
    UserInfo userInfoBean = UserInfo();
    userInfoBean.data = DataBean.fromMap(map['data']);
    userInfoBean.message = map['message'];
    userInfoBean.success = map['success'];
    return userInfoBean;
  }

  Map toJson() => {
        "data": data,
        "message": message,
        "success": success,
      };
}

/// token : ""
/// user_id : ""
/// oauthToken : ""
/// avatar : ""
/// is_geely_user : ""

class DataBean {
  String token;
  String userId;
  String geelyUserId;
  String oauthToken;
  String corpId;
  String company;
  String avatar;
  String isGeelyUser;

  static DataBean fromMap(Map map) {
    if (map == null) return null;
    DataBean dataBean = DataBean();
    dataBean.token = map['token'];
    dataBean.userId = map['userId'];
    dataBean.geelyUserId = map['geelyUserId'];
    dataBean.oauthToken = map['oauthToken'];
    dataBean.corpId = map['corpId'];
    dataBean.company = map['company'];
    dataBean.avatar = map['avatar'];
    dataBean.isGeelyUser = map['is_geely_user'];
    return dataBean;
  }

  Map toJson() => {
        "token": token,
        "userId": userId,
        "geelyUserId": geelyUserId,
        "oauthToken": oauthToken,
        "corpId": corpId,
        "company": company,
        "avatar": avatar,
        "is_geely_user": isGeelyUser,
      };
}
