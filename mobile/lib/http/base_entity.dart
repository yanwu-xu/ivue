import 'package:geely_flutter/http/entity_factory.dart';

class BaseEntity<T> {
  int Code;
  bool Success;
  String Message;
  T Data;

  BaseEntity({this.Code,this.Success, this.Message, this.Data});

  factory BaseEntity.fromJson(json) {
    return BaseEntity(
      Code: json["Code"],
      Message: json["Message"],
      Success: json["Success"],
      // data值需要经过工厂转换为我们传进来的类型
      Data: EntityFactory.generateOBJ<T>(json["Data"]),
    );
  }
}
