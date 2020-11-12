import 'package:geely_flutter/http/entity_factory.dart';

class BaseListEntity<T> {
  int Code;
  bool Success;
  String Message;
  List<T> Data;

  BaseListEntity({this.Code, this.Success, this.Message, this.Data});

  factory BaseListEntity.fromJson(json) {
    List<T> mData = List();
    if (json['Data'] != null) {
      //遍历data并转换为我们传进来的类型
      (json['Data'] as List).forEach((v) {
        mData.add(EntityFactory.generateOBJ<T>(v));
      });
    }

    return BaseListEntity(
      Code: json["Code"],
      Message: json["Message"],
      Success: json["Success"],
      Data: mData,
    );
  }
}