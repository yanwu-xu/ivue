// To parse this JSON data, do
//
//     final carouselModel = carouselModelFromJson(jsonString);

import 'dart:convert';

CarouselModel carouselModelFromJson(String str) =>
    CarouselModel.fromJson(json.decode(str));

String carouselModelToJson(CarouselModel data) => json.encode(data.toJson());

class CarouselModel {
  CarouselModel({
    this.rotationChartId,
    this.tenantId,
    this.tenantName,
    this.title,
    this.previewUrl,
    this.ossKey,
    this.fileName,
    this.redirectUrl,
    this.onTime,
    this.offTime,
    this.sortNum,
    this.clientSource,
    this.defaultStatus,
    this.createTime,
    this.updateTime,
    this.createUserId,
    this.updateUserId,
  });

  String rotationChartId;
  String tenantId;
  dynamic tenantName;
  String title;
  String previewUrl;
  String ossKey;
  String fileName;
  String redirectUrl;
  DateTime onTime;
  DateTime offTime;
  int sortNum;
  int clientSource;
  int defaultStatus;
  DateTime createTime;
  DateTime updateTime;
  String createUserId;
  String updateUserId;

  factory CarouselModel.fromJson(Map<String, dynamic> json) => CarouselModel(
        rotationChartId: json["RotationChartId"],
        tenantId: json["TenantId"],
        tenantName: json["TenantName"],
        title: json["Title"],
        previewUrl: json["PreviewUrl"],
        ossKey: json["OSSKey"],
        fileName: json["FileName"],
        redirectUrl: json["RedirectUrl"],
        onTime: DateTime.parse(json["OnTime"]),
        offTime: DateTime.parse(json["OffTime"]),
        sortNum: json["SortNum"],
        clientSource: json["ClientSource"],
        defaultStatus: json["DefaultStatus"],
        createTime: DateTime.parse(json["CreateTime"]),
        updateTime: DateTime.parse(json["UpdateTime"]),
        createUserId: json["CreateUserId"],
        updateUserId: json["UpdateUserId"],
      );

  Map<String, dynamic> toJson() => {
        "RotationChartId": rotationChartId,
        "TenantId": tenantId,
        "TenantName": tenantName,
        "Title": title,
        "PreviewUrl": previewUrl,
        "OSSKey": ossKey,
        "FileName": fileName,
        "RedirectUrl": redirectUrl,
        "OnTime": onTime.toIso8601String(),
        "OffTime": offTime.toIso8601String(),
        "SortNum": sortNum,
        "ClientSource": clientSource,
        "DefaultStatus": defaultStatus,
        "CreateTime": createTime.toIso8601String(),
        "UpdateTime": updateTime.toIso8601String(),
        "CreateUserId": createUserId,
        "UpdateUserId": updateUserId,
      };
}
