// To parse this JSON data, do
//
//     final studyModel = studyModelFromJson(jsonString);

import 'dart:convert';

StudyModel studyModelFromJson(String str) =>
    StudyModel.fromJson(json.decode(str));

String studyModelToJson(StudyModel data) => json.encode(data.toJson());

class StudyModel {
  StudyModel({
    this.id,
    this.sortNum,
    this.learnName,
    this.learnNameEn,
    this.learnDescribe,
    this.learnDescribeEn,
    this.learnNumber,
    this.iconUrl,
    this.touchUrl,
  });

  String id;
  int sortNum;
  String learnName;
  String learnNameEn;
  String learnDescribe;
  String learnDescribeEn;
  String learnNumber;
  String iconUrl;
  String touchUrl;

  factory StudyModel.fromJson(Map<String, dynamic> json) => StudyModel(
        id: json["Id"],
        sortNum: json["SortNum"],
        learnName: json["LearnName"],
        learnNameEn: json["LearnNameEn"],
        learnDescribe: json["LearnDescribe"],
        learnDescribeEn: json["LearnDescribeEn"],
        learnNumber: json["LearnNumber"],
        iconUrl: json["IconUrl"],
        touchUrl: json["TouchUrl"],
      );

  Map<String, dynamic> toJson() => {
        "Id": id,
        "SortNum": sortNum,
        "LearnName": learnName,
        "LearnNameEn": learnNameEn,
        "LearnDescribe": learnDescribe,
        "LearnDescribeEn": learnDescribeEn,
        "LearnNumber": learnNumber,
        "IconUrl": iconUrl,
        "TouchUrl": touchUrl,
      };
}
