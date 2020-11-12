import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_boost/flutter_boost.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geely_flutter/common_util/common_utils.dart';
import 'package:geely_flutter/common_widget/home_swiper/home_swiper_widget.dart';
import 'package:geely_flutter/common_widget/home_todo_item.dart';
import 'package:geely_flutter/localizations/localizetion_language.dart';

import '../localizations/localizetion_language.dart';
import '../network/api_manage.dart';
import 'model/usermodules_scopedModel.dart';
import 'widget/NewWidget.dart';
import 'widget/header_appbar.dart';
import 'widget/learnwidget.dart';
import 'widget/listcardwidget.dart';

class HomeListView extends StatefulWidget {
  @override
  _HomeListViewState createState() => _HomeListViewState();
}

class _HomeListViewState extends State<HomeListView> {
// 监听和控制滑动
  ScrollController _scrollController = new ScrollController();

  ///记录滚动距离
  double _scrollPix = 0;

  // 导航栏的透明度
  HeaderAppBarScopedModel headerAppBarScopedModel = HeaderAppBarScopedModel(0);

// 完整的模块数据
  List<Datum> _models = [];

  // 待办模块筛选
  List<Datum> _listModels = [];

  // 置顶模块塞选
  Datum _fristDatum;

  // 其他应用排序
  List<Datum> _listOtherModels = [];

// flutterBoost 监听页面展示
  VoidCallback flutterBoostLifeCycleObserver;

  Timer timer;
  @override
  void initState() {
    getUIData();

    flutterBoostLifeCycleObserver = FlutterBoost.singleton
        .addBoostContainerLifeCycleObserver((state, settings) {
      if (state == ContainerLifeCycle.Appear) {
        getUIData();
      }
    });

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    _scrollController.addListener(() {
      // debugPrint(
      //     '_scrollController.offset:' + _scrollController.offset.toString());

      var curAlpha = 0;

      /// 区分出轮播图的偏移
      double scrollPix = _scrollController.offset;
      if (scrollPix <= 0) {
        curAlpha = ((scrollPix / 70) * 255).toInt().abs();
      } else {
        curAlpha = ((scrollPix / 70) * 255).toInt();
      }
      if (curAlpha > 255) {
        curAlpha = 255;
      }
      headerAppBarScopedModel.changeAlpha(curAlpha);

      _scrollPix = scrollPix;

      if (timer != null) {
        timer.cancel();
      }

      timer = Timer(Duration(milliseconds: 200), () {
        _moveOffset();
      });
    });
    // });

    super.initState();
  }

  @override
  void dispose() {
    //为了避免内存泄露，需要调用 _scrollController.dispose
    timer.cancel();
    _scrollController.dispose();
    flutterBoostLifeCycleObserver();
    super.dispose();
  }

  _moveOffset() {
    print('scrolling = ${_scrollController.position.activity.isScrolling}');
    if (_scrollController.position.activity.isScrolling == false) {
      if (_scrollPix > 25 && _scrollPix < 80) {
        _scrollController.animateTo(85.0,
            duration: Duration(milliseconds: 200), curve: Curves.linear);
      }
    }
  }

  getUIData() {
    ApiManage.GetUserModulesForAPP().then((value) {
      updateData() {
        _models = value;
        for (var i = 0; i < _models.length; i++) {
          Datum datum = _models[i];
          if (datum.hasAuth == true && datum.disabled == 0) {
            if (_listModels.length < 4 && datum.isTop == 1) {
              _listModels.add(datum);
            }
            if (datum.isTop == 0) {
              if (_fristDatum == null) {
                _fristDatum = datum;
              } else {
                _listOtherModels.add(datum);
              }
            }
          }
        }
        setState(() {
          debugPrint('刷新HomeList页面');
        });
      }

      if (value is List<Datum>) {
        print('获取用户模块成功');
        if (_models.length == value.length) {
          for (var i = 0; i < _models.length; i++) {
            String appurl = _models[0].appurl;
            String appurl1 = value[0].appurl;
            if (appurl != appurl1) {
              updateData();
              return;
            }
          }
        } else {
          updateData();
        }
      }
    });
  }

  /// ------------------------------------------ 正文 --------------------
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Scaffold(
          backgroundColor: Colors.grey[200],
          body: MediaQuery.removePadding(
              context: context,
              removeLeft: true,
              removeTop: true,
              removeRight: true,
              removeBottom: false,
              child: Container(
                  child: NotificationListener(
                onNotification: (ScrollNotification notification) {
                  return false;
                },
                child: ListView.builder(
                  itemCount:
                      (_listOtherModels.length == 0 && _fristDatum == null)
                          ? 2
                          : _listOtherModels.length + 1,
                  physics: ClampingScrollPhysics(), // 边缘的物理动画
                  controller: _scrollController,
                  itemBuilder: (BuildContext context, int index) {
                    if (index == 0) {
                      return buildHeader(_listModels, _fristDatum,
                          MediaQuery.of(context).size.width);
                    } else {
                      if (_listOtherModels.length == 0 && _fristDatum == null) {
                        return getEmptyWidgt(context);
                      }
                      Datum datum = _listOtherModels[index - 1];
                      return getWidgetForModel(
                          datum, MediaQuery.of(context).size.width, []);
                    }
                  },
                ),
              ))),
        ),
        HeaderAppBar(headerAppBarScopedModel),
      ],
    );
  }
}

/// 空空如也
getEmptyWidgt(BuildContext context) {
  return new Column(
    children: <Widget>[
      Image.asset(
        'packages/geely_flutter/Images/empty_icon@2x.png',
        width: 180.w,
        height: 180.h,
      ),
      Text(
        LocalizationsLanguage.i18n(context).emptyTitle,
        style: TextStyle(
          color: Color(0xFF191919),
          fontSize: 16.0,
        ),
      )
    ],
  );
}

/// 常用应用列表和顶部应用
buildHeader(List<Datum> models, Datum fristDatum, double width) {
  ///状态栏高度
  double statusBarHeight =
      MediaQueryData.fromWindow(WidgetsBinding.instance.window).padding.top;

  ///头部信息框高度
  double headerRectHeight = 60;

  return Container(
      decoration: BoxDecoration(
        image: new DecorationImage(
            image: AssetImage('packages/geely_flutter/Images/home_bg@2x.png'),
            fit: BoxFit.cover),
      ),
      child: Column(
        children: <Widget>[
          Padding(
              padding:
                  EdgeInsets.only(top: statusBarHeight + headerRectHeight)),
          Padding(
              padding: EdgeInsets.only(left: 12.0, right: 12.0),
              child: models.length > 0 ? HomtTodoItems(models) : Center()),
          getWidgetForModel(fristDatum, width, []),
        ],
      ));
}

/// 根据 model 类型选择 widget
getWidgetForModel(Datum model, double width, var data) {
  if (model == null) {
    return Container(
      height: 260,
    );
  }

  switch (int.parse(model.styleTypeId == null ? '0' : model.styleTypeId)) {
    case 1:

      /// 待办
      return Center(); //多余的占位图
      break;
    case 2:

      /// 轮播图模块
      return Padding(
          padding: CommonUtils.homeModelsPad,
          child: HomeSwiper(
            model: model,
            // listModel: data,
          ));
      break;
    case 3:

      /// 新闻模块
      return Padding(
        padding: CommonUtils.homeModelsPad,
        child: NewWidget(
          model: model,
          // listModel: data,
        ),
      );
      break;
    case 4:

      /// 我的学习模块
      return Padding(
        padding: CommonUtils.homeModelsPad,
        child: LearnWidget(
          model: model,
          // listModel: data,
        ),
      );
      break;
    case 5:

      /// 常用应用列表模块
      return ListCardWidget(
        model: model,
        // listModel: data,
      );
      break;

    default:
      return new Center(); //多余的占位图
  }
}
