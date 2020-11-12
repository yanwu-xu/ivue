import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:geely_flutter/common_util/common_utils.dart';
import 'package:geely_flutter/common_util/page_router.dart';
import 'package:geely_flutter/common_widget/PopupMenuItem1.dart';
import 'package:geely_flutter/localizations/localizetion_language.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HeaderAppBarScopedModel extends Model {
  // 第一步 创建 model
  int _alphaBg = 0;

  int get alphaBg => _alphaBg;

  HeaderAppBarScopedModel(this._alphaBg);

  void changeAlpha(int changeAlphaBg) {
    _alphaBg = changeAlphaBg;
    notifyListeners();
  }
}

class HeaderAppBar extends StatelessWidget {
  final HeaderAppBarScopedModel scopedModel;

  HeaderAppBar(this.scopedModel);

  static double statusBarHeight =
      MediaQueryData.fromWindow(WidgetsBinding.instance.window).padding.top;

  ///总高度 = appbar 高度 +  statusBar 高度
  static double containerHeight = kToolbarHeight + statusBarHeight;

  @override
  Widget build(BuildContext context) {
    // var color = Theme.of(context).primaryColor.withAlpha(alphaBg);

    return Material(
        color: Colors.transparent,
        child: new Container(
            alignment: Alignment.centerLeft,
            height: containerHeight,
            child: ScopedModel(
              model: scopedModel,
              child: ScopedModelDescendant<HeaderAppBarScopedModel>(
                  builder: (context, child, model) {
                var color =
                    Theme.of(context).primaryColor.withAlpha(model._alphaBg);
                return new Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    ///撑满状态栏颜色
                    new Container(
                      height: statusBarHeight,
                      color: color,
                    ),
                    new Container(
                      color: color,
                      height: kToolbarHeight,
                      child: new Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new Container(
                            alignment: Alignment.center,
                            margin: EdgeInsets.only(left: 16.0),
                            child: InkWell(
                              onTap: () {
                                PageRouter.dealUserSetting(
                                    CommonUtils.user.toJson());
                              },
                              child: ClipRRect(
                                // 添加图片的时候，要切圆角
                                borderRadius: BorderRadius.circular(22.0),
                                child: Image(
                                  image: CachedNetworkImageProvider(
                                      CommonUtils.user.avatar),
                                  fit: BoxFit.cover,
                                  width: 30,
                                  height: 30,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(right: 1, left: 8),
                              child: Text(
                                CommonUtils.user.company,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700, // 字体粗细
                                  // letterSpacing: 3.0, // 字间距
                                ),
                              ),
                            ),
                          ),
                          new Container(
                              padding: EdgeInsets.only(left: 10, right: 13.w),
                              child: InkWell(
                                child: Image.asset(
                                  "packages/geely_flutter/Images/scan_icon.png",
                                  width: 22.w,
                                  height: 22.w,
                                ),
                                onTap: () {
                                  PageRouter.dealScan();
                                },
                              )),
                          new Container(
                              padding: EdgeInsets.only(left: 10, right: 16.w),
                              child: InkWell(
                                child: Image.asset(
                                  "packages/geely_flutter/Images/shortcuts_icon.png",
                                  width: 22.w,
                                  height: 22.w,
                                ),
                                onTap: () {
                                  _showPop(context);
                                },
                              )),
                        ],
                      ),
                    ),
                  ],
                );
              }),
            )));
  }

  void _showPop(BuildContext context) async {
    var result = await showMenu(
        color: Color(0xE6000000),
        context: context,
        position: RelativeRect.fromLTRB(100.0.w, containerHeight, 16.0.w, 0.0.w),
        items: <PopupMenuEntry<String>>[
          new PopupMenuItem1(
              value: "mail",
              child: new Row(children: <Widget>[
                Image.asset(
                  "packages/geely_flutter/Images/mail_icon.png",
                  width: 20.w,
                  height: 20.w,
                ),
                SizedBox(
                  width: 10.w,
                ),
                new Text(LocalizationsLanguage.i18n(context).quickMail,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 15.sp)),
              ])),
          new PopupMenuItem1(
            height: 2,
            child: Container(
              height: 0.5,
              color: Colors.white38,
            ),
          ),
          new PopupMenuItem1(
              value: "lacation",
              child: new Row(children: <Widget>[
                Image.asset(
                  "packages/geely_flutter/Images/lacation_icon.png",
                  width: 20.w,
                  height: 20.w,
                ),
                SizedBox(
                  width: 10.w,
                ),
                new Text(LocalizationsLanguage.i18n(context).quickLocation,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 15.sp)),
              ]))
        ]).then((value) => dealResult(value));
  }

  dealResult(String value) {
    debugPrint(value);
    if (value == "mail") {
      PageRouter.openPageByUrl(PageRouter.OPEN_EDIT_MAIL, null);
    } else if (value == "lacation") {
      Map<String, dynamic> params = {
        "callWay": 1,
        "callUri": "thunbu://app/punchIn",
      };
      PageRouter.openPageByUrl(PageRouter.WORKITEM, params);
    }
  }
}
