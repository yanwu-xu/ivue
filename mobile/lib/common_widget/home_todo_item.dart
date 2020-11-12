import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geely_flutter/HomeListView/model/usermodules_scopedModel.dart';
import 'package:geely_flutter/common_util/common_utils.dart';
import 'package:geely_flutter/eventbus/eventbus.dart';
import 'package:geely_flutter/network/api_manage.dart';

import '../common_util/page_router.dart';

// ignore: must_be_immutable
// class HomeTodoItem extends StatefulWidget {
//   Datum model;

//   HomeTodoItem({Key key, this.model}) : super(key: key);

//   @override
//   HomeTodoItemState createState() => HomeTodoItemState();
// }

// ignore: must_be_immutable
class HomtTodoItems extends StatefulWidget {
  List<Datum> models = [];
  HomtTodoItems(this.models, {Key key}) : super(key: key);

  @override
  _HomtTodoItemsState createState() => _HomtTodoItemsState();
}

class _HomtTodoItemsState extends State<HomtTodoItems> {
  var dicNum = {};

  @override
  void initState() {
    bus.on("refreshTodo", (arg) {
      Map numCount = jsonDecode(arg);
      // appid 转成小写
      dicNum[numCount['APPID'].toLowerCase()] = numCount['Num'];
      setState(() {
        debugPrint('[SignalR] refreshTodo: $arg');
      });
    });
    for (var i = 0; i < widget.models.length; i++) {
      Datum datum = widget.models[i];
      ApiManage.getCountForAppID(datum.appurl, datum.moduleNameEn)
          .then((result) {
        if (result.Success) {
          // appid 转成小写
          dicNum[datum.moduleNameEn.toLowerCase()] =
              result.Data is String ? int.parse(result.Data) : result.Data;
        }
        setState(() {});
      });
    }

    super.initState();
  }

  @override
  void dispose() {
    bus.off('refreshTodo');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: widget.models.map((Datum choice) {
        return Expanded(
          child: new HomeTodoItem(
            model: choice,
            count: dicNum[choice.moduleNameEn.toLowerCase()] == null
                ? 0
                : dicNum[choice.moduleNameEn.toLowerCase()],
          ),
        );
      }).toList(),
    );
  }
}

// ignore: must_be_immutable
class HomeTodoItem extends StatelessWidget {
  Datum model;
  int count;
  HomeTodoItem({Key key, this.model, this.count = 0}) : super(key: key);

  String title;

  @override
  Widget build(BuildContext context) {
//    Locale locale = StoreProvider.of<GLState>(context).state.locale;

    title = model.moduleNameCn;

    if (CommonUtils.curLocale == 'en_US') {
      title = model.moduleNameEn;
    }

    return InkWell(
      onTap: () {
        debugPrint('点击 $title');
        PageRouter.dealWorkItem(model.toJson());
      },
      child: Container(
        height: 80.w,
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              count > 99 ? "99+" : count.toString(),
              style: TextStyle(fontSize: 32.sp, color: Colors.white),
            ),
            SizedBox(
              height: 5.w,
            ),
            Text(
              title,
              style: TextStyle(fontSize: 14.sp, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class ItemCount extends InheritedWidget {
  final int count;
  final Widget child;

  ItemCount({Key key, this.count, this.child}) : super(key: key, child: child);

  static ItemCount of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ItemCount>();

  @override
  bool updateShouldNotify(InheritedWidget oldWight) {
    debugPrint('判断通知');
    return true;
  }
}
