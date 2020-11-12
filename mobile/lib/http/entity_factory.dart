import 'package:geely_flutter/model/module.dart';
import 'package:geely_flutter/model/modules_all.dart';

class EntityFactory {
  static T generateOBJ<T>(json) {
    if (json == null) {
      return null;
    }
//可以在这里加入任何需要并且可以转换的类型，例如下面
   else if (T.toString() == "ModulesAll") {
     return ModulesAll.fromMap(json) as T;
   }
    else if (T.toString() == "Module") {
      return Module.fromMap(json) as T;
    }
    else {
      return json as T;
    }
  }
}