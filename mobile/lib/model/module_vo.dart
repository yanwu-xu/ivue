import 'package:geely_flutter/model/module.dart';
import 'package:geely_flutter/work_module/drag_grid_view.dart';
import 'package:geely_flutter/work_module/module_item.dart';

class WorkNew extends DragBean {
  ModuleAction action;
  Module modulesAll;

  WorkNew(this.action, this.modulesAll);


}

class ModuleVO {

  int type;
  String nameCN;
  String nameEN;
  String ModuleTypeID;
  List<WorkNew> list;

  ModuleVO(this.type, this.nameCN,this.nameEN, this.ModuleTypeID,this.list);
}

