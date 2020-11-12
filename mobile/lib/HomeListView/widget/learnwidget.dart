import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geely_flutter/HomeListView/model/study_model.dart';
import 'package:geely_flutter/HomeListView/model/usermodules_scopedModel.dart';
import 'package:geely_flutter/common_util/common_utils.dart';
import 'package:geely_flutter/common_util/page_router.dart';
import 'package:geely_flutter/localizations/localizetion_language.dart';
import 'package:geely_flutter/network/api_manage.dart';

import 'morewidget.dart';

final widthWindow = window.physicalSize.width;
// final heightWindow = window.physicalSize.height;

//我的课程
// ignore: non_constant_identifier_names
final Learn_course = "https://elearning.geely.com/oa/#/course";
//我的培训班
// ignore: non_constant_identifier_names
final Learn_mineTrain = "https://elearning.geely.com/oa/#/mineTrain";
//我的考试
// ignore: non_constant_identifier_names
final Learn_examCenter = "https://elearning.geely.com/oa/#/examCenter";
//我的问卷
// ignore: non_constant_identifier_names
final Learn_mineQuestion = "https://elearning.geely.com/oa/#/mineQuestion";

// ignore: must_be_immutable
class LearnWidget extends StatelessWidget {
  Datum model;
  List<StudyModel> listModel = [];

  LearnWidget({Key key, this.model, this.listModel}) : super(key: key);

  void _learnMore() {
    debugPrint('点击_learnMore');
    Future launch = CommonUtils.launchURL('geelygke://',
        otherUrl: 'https://elearning.geely.com/app/download.html');
    launch.then((value) {});
  }

  @override
  Widget build(BuildContext context) {
    buildUI() {
      return Container(
        decoration: CommonUtils.getBoxShadow(),
        child: Column(
          children: <Widget>[
            MoreWidget(
                LocalizationsLanguage.i18n(context).myStudies, _learnMore),
            Container(
                padding: EdgeInsets.only(top: 1),
                color: Color(0xFFF2F3F5),
                child: Wrap(
                  spacing: 1, //主轴上子控件的间距
                  runSpacing: 1, //交叉轴上子控件之间的间距
                  alignment: WrapAlignment.center,

                  children: listModel.map((StudyModel model) {
                    return LearnItem(model);
                  }).toList(),
                )),
          ],
        ),
      );
    }

    if (listModel is List<StudyModel>) {
      return buildUI();
    }

    return Container(
      decoration: CommonUtils.getBoxShadow(),
      child: Column(
        children: <Widget>[
          MoreWidget(LocalizationsLanguage.i18n(context).myStudies, _learnMore),
          FutureBuilder(
              // 根据future返回的结果，创建小部件，注意请求状态，第一次请求会返回null
              future: ApiManage.getStudyList(model.appurl),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                debugPrint(
                    'date:${snapshot.data}'); // snapshot.data 包含了 future 对应的请求结果数据
                debugPrint(
                    'connectionState:${snapshot.connectionState}'); // snapshot.connectionState 请求状态

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CommonUtils.setLoading();
                } else if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.data is List<StudyModel>) {
                    listModel = snapshot.data;
                  } else {
                    listModel = [];
                  }
                }

                return Container(
                    padding: EdgeInsets.only(top: 1),
                    color: Color(0xFFF2F3F5),
                    child: Wrap(
                      spacing: 1, //主轴上子控件的间距
                      runSpacing: 1, //交叉轴上子控件之间的间距
                      alignment: WrapAlignment.center,

                      children: listModel.map((StudyModel model) {
                        return LearnItem(model);
                      }).toList(),
                    ));
              }),
        ],
      ),
    );
  }
}

class LearnItem extends StatelessWidget {
  final StudyModel model;

  LearnItem(this.model);

  @override
  Widget build(BuildContext context) {
    ///大概是屏幕 3 分之一的宽度 + 整体边距和主轴间距
    ///

    double itemLeftPad = 8;
    double itemHeight = 90;

    double itemWidth = (MediaQuery.of(context).size.width -
            CommonUtils.homeLeftPad * 2 -
            itemLeftPad * 2) /
        2;
    String token = CommonUtils.user.token;
//    Locale locale = StoreProvider.of<GLState>(context).state.locale;
    String language = 'zh-cn';

    String name = model.learnName;
    String describe = model.learnDescribe;
    String strNumber = model.learnNumber;
    int intNumber = int.parse(strNumber);
    if (intNumber > 99) {
      strNumber = '99+';
    } else if (intNumber == 0) {
      strNumber = '';
    }

    if (CommonUtils.curLocale == 'en_US') {
      language = 'en';
      name = model.learnNameEn;
      describe = model.learnDescribeEn;
    }

    return InkWell(
      onTap: () {
        Map params = new Map<String, dynamic>.from({
          'title': name,
          'url': model.touchUrl + '?token=$token&Accept-Language=$language'
        });
//        PageRouter.openPageByUrl(PageRouter.WEBVIEWBROWSER, params);
        PageRouter.open_webview(params);
        // Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
        //   return new WebViewBrowser(
        //     url: urlStr + '?token=$token&Accept-Language=$language',
        //     title: title,
        //   );
        // }));
      },
      splashColor: Colors.grey.withOpacity(0.1),
      child: Stack(
        children: <Widget>[
          Container(
            color: Colors.white,
            width: itemWidth,
            height: itemHeight,
          ),
          Positioned(
            child: Container(
              padding: EdgeInsets.only(left: itemLeftPad),
              alignment: Alignment.centerLeft,
              width: itemWidth - 50,
              height: itemHeight,
              child: RichText(
                  text: TextSpan(
                      text: '$name\n',
                      style: TextStyle(
                        color: Color(0xFF191919),
                        fontSize: 18.0,
                      ),
                      children: [
                    TextSpan(
                      text: '$describe ',
                      style: TextStyle(
                        color: Color(0xFF9A9E9E),
                        fontSize: 14.0,
                      ),
                    ),
                    TextSpan(
                      text: '  $strNumber  ',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14.0,
                      ),
                    ),
                  ])),
            ),
            // top: 5,
            // right: 10,
          ),
          Positioned(
            child: Container(
              width: 30,
              height: itemHeight,
              child: Image.network(
                model.iconUrl,
                width: 24,
                height: 24,
              ),
            ),
            right: 10,
          ),
        ],
      ),
    );
  }
}
