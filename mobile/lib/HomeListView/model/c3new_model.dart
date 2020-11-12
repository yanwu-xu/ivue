// To parse this JSON data, do
//
//     final c3NewModel = c3NewModelFromJson(jsonString);

import 'dart:convert';

C3NewModel c3NewModelFromJson(String str) =>
    C3NewModel.fromJson(json.decode(str));

String c3NewModelToJson(C3NewModel data) => json.encode(data.toJson());

class C3NewModel {
  C3NewModel({
    this.typeName,
    this.id,
    this.typeEnName,
    this.title,
    this.picUrl,
    this.link,
    this.date,
  });

  String typeName;
  String id;
  String typeEnName;
  String title;
  String picUrl;
  String link;
  String date;

  factory C3NewModel.fromJson(Map<String, dynamic> json) => C3NewModel(
        typeName: json["typeName"],
        id: json["id"],
        typeEnName: json["typeEnName"],
        title: json["title"],
        picUrl: json["picUrl"],
        link: json["link"],
        date: json["date"],
      );

  Map<String, dynamic> toJson() => {
        "typeName": typeName,
        "id": id,
        "typeEnName": typeEnName,
        "title": title,
        "picUrl": picUrl,
        "link": link,
        "date": date,
      };
}
