import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geely_flutter/common_util/common_utils.dart';
import 'package:geely_flutter/localizations/localizetion_language.dart';
import 'package:geely_flutter/model/module.dart';
import 'package:geely_flutter/model/module_vo.dart';
import 'package:geely_flutter/work_module/module_center.dart';

typedef DealAdd = void Function(WorkNew work);
typedef DealDelete = void Function(WorkNew work);
typedef DealClick = void Function(WorkNew work);

enum ModuleAction { ADD, DELETE, SELECTED }

class ModuleItemView extends StatefulWidget {
  final int status;
  final DealAdd dealAdd;
  final DealDelete dealDelete;
  final DealClick dealClick;
  final WorkNew module;

  const ModuleItemView({Key key, this.module, this.status, this.dealAdd, this.dealDelete, this.dealClick}) : super(key: key);

  @override
  _ModuleItemViewState createState() => _ModuleItemViewState();
}

class _ModuleItemViewState extends State<ModuleItemView> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        InkWell(
          child: Stack(
            children: <Widget>[
              Container(
                alignment: Alignment.topCenter,
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 8.w,
                    ),
                    Stack(
                      alignment: AlignmentDirectional.center,
                      children: <Widget>[
                        Image.network(
                          widget.module.modulesAll.LogoURL,
                          width: 44.w,
                          height: 44.w,
                          fit: BoxFit.cover,
                        ),
                        Offstage(
                          offstage: (widget.module.modulesAll.HasAuth && widget.module.modulesAll.Disabled == 0),
                          child: Container(
                            alignment: Alignment.center,
                            width: 45.w,
                            height: 45.w,
                            color: Color(0xF2FFFFFF),
                            child: Text(
                              LocalizationsLanguage.i18n(context).moduleForbidden,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12.sp, color: Colors.black54),
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 5.w,
                    ),
                    Text(
                      getModuleName(widget.module.modulesAll),
                      style: TextStyle(fontSize: 12.sp, color: Colors.black),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Positioned(
                  right: 4.w,
                  child: Offstage(
                    offstage: widget.status == EDITABLE,
                    child: Image.asset(
                      getActionImg(widget.module.action),
                      width: 14.w,
                      height: 14.w,
                    ),
                  ))
            ],
          ),
          onTap: () {
            if (widget.status == NOT_EDITABLE) {
              changeActionImg(widget.module);
            } else {
              widget.dealClick(widget.module);
            }
          },
        ),
      ],
    );
  }

  String getModuleName(Module module) {
//    Locale locale = StoreProvider.of<GLState>(context).state.locale;
    if (CommonUtils.curLocale == 'en_US') {
      return module.ModuleNameEN;
    } else {
      return module.ModuleNameCN;
    }
  }

  void changeActionImg(WorkNew work) {
    setState(() {
      var action = work.action;
      switch (action) {
        case ModuleAction.ADD:
          widget.dealAdd(work);
          break;
        case ModuleAction.DELETE:
          widget.dealDelete(work);
          break;
      }
    });
  }
}

String getActionImg(ModuleAction action) {
  switch (action) {
    case ModuleAction.ADD:
      return "packages/geely_flutter/Images/add_float_center.png";
    case ModuleAction.DELETE:
      return "packages/geely_flutter/Images/delete_float_center.png";
    case ModuleAction.SELECTED:
      return "packages/geely_flutter/Images/active_float_center.png";
  }
}
