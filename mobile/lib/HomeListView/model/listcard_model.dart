// To parse this JSON data, do
//
//     final listCardModel = listCardModelFromJson(jsonString);

import 'dart:convert';

ListCardModel listCardModelFromJson(String str) =>
    ListCardModel.fromJson(json.decode(str));

String listCardModelToJson(ListCardModel data) => json.encode(data.toJson());

class ListCardModel {
  ListCardModel({
    this.appId,
    this.appName,
    this.appEngName,
    this.appDesc,
    this.appType,
    this.logoUri,
    this.createTime,
    this.createTimeLong,
    this.callWay,
    this.callUri,
    this.belong,
    this.canShare,
    this.shareType,
    this.shareTitle,
    this.shareUrl,
    this.shareDesc,
    this.shareImage,
  });

  String appId;
  String appName;
  String appEngName;
  String appDesc;
  int appType;
  String logoUri;
  String createTime;
  String createTimeLong;
  int callWay;
  String callUri;
  int belong;
  int canShare;
  int shareType;
  String shareTitle;
  String shareUrl;
  String shareDesc;
  String shareImage;

  factory ListCardModel.fromJson(Map<String, dynamic> json) => ListCardModel(
        appId: json["appId"],
        appName: json["appName"],
        appEngName: json["appEngName"],
        appDesc: json["appDesc"],
        appType: json["appType"],
        logoUri: json["logoUri"],
        createTime: json["createTime"],
        createTimeLong: json["createTimeLong"],
        callWay: json["callWay"],
        callUri: json["callUri"],
        belong: json["belong"],
        canShare: json["canShare"],
        shareType: json["shareType"],
        shareTitle: json["shareTitle"],
        shareUrl: json["shareUrl"],
        shareDesc: json["shareDesc"],
        shareImage: json["shareImage"],
      );

  get url => null;

  Map<String, dynamic> toJson() => {
        "appId": appId,
        "appName": appName,
        "appEngName": appEngName,
        "appDesc": appDesc,
        "appType": appType,
        "logoUri": logoUri,
        "createTime": createTime,
        "createTimeLong": createTimeLong,
        "callWay": callWay,
        "callUri": callUri,
        "belong": belong,
        "canShare": canShare,
        "shareType": shareType,
        "shareTitle": shareTitle,
        "shareUrl": shareUrl,
        "shareDesc": shareDesc,
        "shareImage": shareImage,
      };
}
