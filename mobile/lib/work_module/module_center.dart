import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geely_flutter/common_util/common_constant.dart';
import 'package:geely_flutter/common_util/common_utils.dart';
import 'package:geely_flutter/http/dio_api.dart';
import 'package:geely_flutter/http/dio_factory.dart';
import 'package:geely_flutter/http/method_type.dart';
import 'package:geely_flutter/localizations/localizetion_language.dart';
import 'package:geely_flutter/model/module.dart';
import 'package:geely_flutter/model/module_vo.dart';
import 'package:geely_flutter/model/modules_all.dart';
import 'package:geely_flutter/work_module/module_item.dart';

import 'drag_grid_view.dart';

final int EDITABLE = 0;
final int NOT_EDITABLE = 1;

class ModuleCenter extends StatefulWidget {
  @override
  _ModuleCenterState createState() => _ModuleCenterState();
}

class _ModuleCenterState extends State<ModuleCenter> {
  int status = EDITABLE;
  bool maxAlert = false;

  List<WorkNew> modulesUser = List();
  List<WorkNew> modulesTodo = List();
  List<ModuleVO> WorkNewList = List();

  @override
  void initState() {
    super.initState();
    getModuleData();
  }

  void getModuleData() {
    Future.wait([
      DioFactory().requestList<Module>(
        METHODTYPE.GET,
        DioApi.GET_USER_MODULE,
        success: (data) {
          debugPrint("Module success");
        },
      ),
      DioFactory().requestList<ModulesAll>(
        METHODTYPE.GET,
        DioApi.GET_ALL_MODULE,
        success: (data) {
          debugPrint("ModulesAll success");
        },
      )
    ]).then((value) {
      var moduleUserList = value[0];
      List<ModulesAll> moduleAllList = value[1];

      if (!moduleUserList.isEmpty) {
        moduleUserList.forEach((element) {
          Module module = element;
          if (module.IsTop == 1) {
            WorkNew workNew = WorkNew(ModuleAction.DELETE, element);
            modulesTodo.add(workNew);
          } else {
            WorkNew workNew = WorkNew(ModuleAction.DELETE, element);
            modulesUser.add(workNew);
          }
        });
      }
      WorkNewList.add(ModuleVO(0, "我的待办", "Todo Module", "", modulesTodo));
      WorkNewList.add(ModuleVO(2, "", "", "", modulesTodo));
      WorkNewList.add(ModuleVO(0, "我的模块", "My Module", "", modulesUser));
      WorkNewList.add(ModuleVO(2, "", "", "", modulesUser));
      WorkNewList.add(ModuleVO(3, "", "", "", null));

      moduleAllList
          .sort((left, right) => left.SortNum.compareTo(right.SortNum));
      if (!moduleAllList.isEmpty) {
        for (int i = 0; i < moduleAllList.length; i++) {
          ModulesAll modulesall = moduleAllList[i];
          var list = modulesall.Modules;
          List<WorkNew> modulesAll = new List();
          list.forEach((element) {
            WorkNew workNew = WorkNew(ModuleAction.ADD, element);
            modulesAll.add(workNew);
          });
          WorkNewList.add(ModuleVO(1, modulesall.ModuleTypeNameCN,
              modulesall.ModuleTypeNameEN, "", modulesAll));
          WorkNewList.add(
              ModuleVO(4, "", "", modulesall.ModuleTypeID, modulesAll));
        }
      }

      setState(() {});
    }).catchError((onError) {
      // debugPrint(onError);
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,
        width: CommonConstant.WIDTH,
        height: CommonConstant.HEIGHT,
        allowFontScaling: false);
    return Theme(
      data: new ThemeData(primaryColor: Colors.white),
      child: Container(
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            leading: IconButton(
                icon: Image.asset(
                  'packages/geely_flutter/Images/3.0x/common_back_arrow.png',
                  width: 20.w,
                  height: 20.w,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
            iconTheme: IconThemeData(),
            centerTitle: true,
            title: Text(
              LocalizationsLanguage.i18n(context).moduleTitle,
              style: TextStyle(
                  fontSize: 18.sp,
                  color: Color(0xFF191919)),
            ),
            actions: <Widget>[
              InkWell(
                  onTap: edit,
                  child: Align(
                    alignment: Alignment.center,
                    child:  Text(
                      status == EDITABLE
                          ? LocalizationsLanguage.i18n(context).moduleEdit
                          : LocalizationsLanguage.i18n(context).moduleFinish,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Color(0xFF1D2221),
                      ),
                    ),
                  )

                 ),
              SizedBox(
                width: 10.w,
              )
            ],
          ),
          body: Container(
              color: Colors.white,
              child: ListView.builder(
                itemCount: WorkNewList.length,
                itemBuilder: _listWidget,
              )),
        ),
      ),
    );
  }

  Widget _listWidget(BuildContext context, int indexs) {
    var type = WorkNewList[indexs].type;
    if (0 == type) {
      return myModuleTitle(WorkNewList[indexs], false);
    } else if (1 == type) {
      return myModuleTitle(WorkNewList[indexs], true);
    } else if (2 == type) {
      return myModuleContent(WorkNewList[indexs].list);
    } else if (3 == type) {
      return alertModuleTitle();
    } else {
      return allModuleContent(WorkNewList[indexs].list);
    }
  }

  Widget allModuleContent(List<WorkNew> list) {
    return Offstage(
      offstage: null == list || list.isEmpty,
      child: GridView.builder(
        padding: EdgeInsets.only(left: 16, right: 16),
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: list.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisSpacing: 0,
          crossAxisCount: 5,
          mainAxisSpacing: 0,
          childAspectRatio: 0.85,
        ),
        itemBuilder: (context, index) {
          return ModuleItemView(
            module: list[index],
            status: status,
            dealAdd: (WorkNew work) {
              dealAdd(list, work);
            },
          );
        },
      ),
    );
  }

  Widget alertModuleTitle() {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(top: 15.w, bottom: 20.w),
          child: Text(
            !maxAlert
                ? LocalizationsLanguage.i18n(context).moduleUserAlert1
                : LocalizationsLanguage.i18n(context).moduleUserAlert2,
            style: TextStyle(fontSize: 12.sp, color: Color(0xFF999999)),
          ),
        ),
        Container(
          color: Color(0xFFF5F5F5),
          height: 10.w,
        ),
      ],
    );
  }

  String getModuleTitleName(ModuleVO moduleVO) {
    if (CommonUtils.curLocale == 'en_US') {
      return moduleVO.nameEN;
    } else {
      return moduleVO.nameCN;
    }
  }

  Widget myModuleContent(List<WorkNew> list) {
    return DragGridView(
      list,
      draggable: !(status == EDITABLE),
      margin: EdgeInsets.only(left: 16.w, right: 16.w),
      onDragFinishListener: (List<DragBean> data) {
        modulesUser = data;
      },
      itemBuilder: (BuildContext context, int index) {
        return ModuleItemView(
          module: list[index],
          status: status,
          dealDelete: (WorkNew work) {
            dealDelete(list, work);
          },
        );
      },
    );
  }

  Widget myModuleTitle(ModuleVO module, bool hide) {
    var list = module.list;
    if (hide) {
      return Offstage(
        offstage: null == list || list.isEmpty,
        child: Container(
          padding: EdgeInsets.only(top: 16.w, bottom: 8.w, left: 16.w),
          child: Text(
            getModuleTitleName(module),
            style: TextStyle(fontSize: 17.sp, color: Color(0xFF191919)),
          ),
        ),
      );
    } else {
      return Container(
        padding: EdgeInsets.only(top: 16.w, bottom: 8.w, left: 16.w),
        child: Text(
          getModuleTitleName(module),
          style: TextStyle(fontSize: 17.sp, color: Color(0xFF191919)),
        ),
      );
    }
  }

  void dealAdd(List<WorkNew> list, WorkNew work) {
    var module = work.modulesAll;
    if (module.IsTop == 0) {
      // 我的模块
      if (modulesUser.length > 14) {
        // 我的模块数量大于14
        debugPrint("[module]我的模块数量不能大于15");
        Fluttertoast.showToast(
            msg: LocalizationsLanguage.i18n(context).moduleUserAlert3);
      } else {
        work.action = ModuleAction.DELETE;
        modulesUser.add(work);
        list.remove(work);
      }
    } else {
      // 待办模块
      if (modulesTodo.length > 3) {
        debugPrint("[module]待办模块数量不能大于4");
        Fluttertoast.showToast(
            msg: LocalizationsLanguage.i18n(context).moduleTodoAlert2);
      } else {
        work.action = ModuleAction.DELETE;
        modulesTodo.add(work);
        list.remove(work);
      }
    }

    setState(() {});
  }

  void dealDelete(List<WorkNew> list, WorkNew work) {
    var module = work.modulesAll;
    if (module.Disabled == 0 && module.HasAuth) {
      //有权限 且 未禁用
      if (module.IsTop == 0) {
        // 我的模块
        list.remove(work);
        work.action = ModuleAction.ADD;
        addModuleByType(work);
      } else {
        // 待办模块
        if (list.length > 1) {
          // 待办模块数量>1
          list.remove(work);
          work.action = ModuleAction.ADD;
          addModuleByType(work);
        } else {
          debugPrint("[module] 待办数量不能小于1");
          Fluttertoast.showToast(
              msg: LocalizationsLanguage.i18n(context).moduleTodoAlert1);
        }
      }
    } else {
      list.remove(work);
    }
    setState(() {});
  }

  void addModuleByType(WorkNew work) {
    String workTypeID = work.modulesAll.ModuleTypeID;
    if (null == workTypeID || workTypeID.isEmpty) return;
    WorkNewList.forEach((element) {
      ModuleVO moduleVO = element;
      var moduleTypeID = moduleVO.ModuleTypeID;
      if (moduleTypeID.isNotEmpty && workTypeID.isNotEmpty) {
        if (workTypeID == moduleTypeID) {
          moduleVO.list.add(work);
          return;
        }
      }
    });
  }

  edit() {
    setState(() {
      if (status == EDITABLE) {
        status = NOT_EDITABLE;
      } else {
        status = EDITABLE;
        saveModule();
      }
    });
  }

  void saveModule() {
    List<Module> modules = List();
    modulesTodo.forEach((element) {
      var module = element.modulesAll;
      modules.add(module);
    });
    modulesUser.forEach((element) {
      var module = element.modulesAll;
      modules.add(module);
    });

    DioFactory().request(METHODTYPE.POST, DioApi.SAVE_USER_MODULE,
        data: modules, error: (error) {
      debugPrint("error code = ${error.Code}, massage = ${error.Message}");
    }, success: (data) {
      debugPrint("saveModule success");
    });
  }
}
