import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geely_flutter/HomeListView/model/c3new_model.dart';
import 'package:geely_flutter/HomeListView/model/usermodules_scopedModel.dart';
import 'package:geely_flutter/common_util/common_utils.dart';
import 'package:geely_flutter/common_util/page_router.dart';
import 'package:geely_flutter/localizations/localizetion_language.dart';
import 'package:geely_flutter/network/api_manage.dart';

import 'morewidget.dart';

// ignore: must_be_immutable
class NewWidget extends StatelessWidget {
  Datum model;
  List<C3NewModel> listModel = [];

  NewWidget({Key key, this.model, this.listModel}) : super(key: key);

  void _newMore() {
    debugPrint('点击more');

    for (var model in listModel) {
      if (model.typeEnName == 'News') {
        String link = model.link;

        int index = link.indexOf('list=');
        int indexEnd = link.indexOf('&itemID');

        String moreLink = 'https://oa.geely.com/SitePages/mobile_iList.aspx?' +
            link.substring(index, indexEnd) +
            '&token=${CommonUtils.user.token}';

        // https://oa.geely.com/SitePages/mobile_iList.aspx?list=7fde3ffd-6e2b-499c-94a3-417ada003ec5&token=708d9264-d1ec-4892-9b2c-006c2ace77b8&Accept-Language=zh-cn

        Map params = new Map<String, dynamic>.from(
            {'title': model.typeName, 'url': moreLink});
//        PageRouter.openPageByUrl(PageRouter.WEBVIEWBROWSER, params);
        PageRouter.open_webview(params);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (listModel != null &&
        listModel is List<C3NewModel> &&
        listModel.length > 0) {
      return buildUI(context);
    }
    return FutureBuilder(
        // 根据future返回的结果，创建小部件，注意请求状态，第一次请求会返回null
        future: ApiManage.getC3News(model.appurl),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          debugPrint(
              'date:${snapshot.data}'); // snapshot.data 包含了 future 对应的请求结果数据
          debugPrint(
              'connectionState:${snapshot.connectionState}'); // snapshot.connectionState 请求状态

          if (snapshot.connectionState == ConnectionState.waiting) {
            return CommonUtils.setLoading();
          } else if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data != null && snapshot.data is List<C3NewModel>) {
              listModel = snapshot.data;
            } else {
              return Center();
            }
          }

          return buildUI(context);
        });
  }

  buildUI(BuildContext context) {
    return Container(
      decoration: CommonUtils.getBoxShadow(),
      // padding: EdgeInsets.all(CommonUtils.homeLeftPad),
      child: Column(
        children: <Widget>[
          MoreWidget(LocalizationsLanguage.i18n(context).companyNews, _newMore),
          Container(
            child: Column(
              children: listModel.map((C3NewModel model) {
                return NewListWidgt(model);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class NewListWidgt extends StatelessWidget {
  final C3NewModel model;
  NewListWidgt(this.model);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 16, right: 12, left: 12),
      child: InkWell(
        onTap: () {
          String urlStr = model.link;
          if (urlStr != null && urlStr.contains('sns.geely.com')) {
            int index = urlStr.indexOf('#');
            // urlStr = urlStr.substring(0, index) +
            //     '?token=${CommonUtils.user.token}&Accept-Language=zh-cn' +
            //     urlStr.substring(index, urlStr.length);

            urlStr = urlStr.substring(0, index) +
                '?token=$geelyToken&Accept-Language=zh-cn' +
                urlStr.substring(index, urlStr.length);

            // urlStr = urlStr + '&token=338d0374-a7e8-4290-9161-08c9b78882b6';
          } else {
            urlStr = urlStr + '?token=${CommonUtils.user.token}';
          }
          // https://sns.geely.com/feed/?token=60453bb6-2eea-45af-944f-b1abec0c7932&token=708d9264-d1ec-4892-9b2c-006c2ace77b8&Accept-Language=zh-cn#/groups/13/posts/10678?post_id=10678
          // https://oa.geely.com/SitePages/mobile_iList.aspx?list=7fde3ffd-6e2b-499c-94a3-417ada003ec5&token=708d9264-d1ec-4892-9b2c-006c2ace77b8&Accept-Language=zh-cn
          Map params = new Map<String, dynamic>.from(
              {'title': model.title, 'url': urlStr});
          // PageRouter.openPageByUrl(PageRouter.WEBVIEWBROWSER, params);
          PageRouter.open_webview(params);
        },
        child: Row(
          children: <Widget>[
            Expanded(
              child: Stack(
                children: <Widget>[
                  SizedBox(
                    height: 100.0,
                  ),
                  Positioned(
                      child: Padding(
                    padding: EdgeInsets.only(right: 5, top: 5),
                    child: Text(model.title,
                        maxLines: 3,
                        textAlign: TextAlign.start,
                        overflow: TextOverflow
                            .ellipsis, // ellipsis 省略号； fade 渐隐； clip 剪裁
                        style: TextStyle(
                            // fontWeight: FontWeight.w500,
                            fontSize: 16.sp,
                            color: Color(0xff191919))),
                  )),
                  Positioned(
                    child: Text(model.date.toString(),
                        style: TextStyle(
                            fontSize: 12.sp, color: Color(0xff9A9E9E))),
                    bottom: 3,
                  ),
                ],
              ),
              flex: 2,
            ),
            Expanded(
              child: ClipRRect(
                // 添加图片的时候，要切圆角
                borderRadius: BorderRadius.circular(4.0),
                child: AspectRatio(
                  // 创建组合常见绘画、定位和大小调整小部件的
                  aspectRatio: 4 / 3,
                  child: Image.network(
                    model.picUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
