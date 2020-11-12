import 'package:flutter/material.dart';
import 'package:geely_flutter/HomeListView/model/listcard_model.dart';
import 'package:geely_flutter/HomeListView/model/usermodules_scopedModel.dart';
import 'package:geely_flutter/common_util/common_utils.dart';
import 'package:geely_flutter/common_widget/work_item.dart';
import 'package:geely_flutter/network/api_manage.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

// ignore: must_be_immutable
class ListCardWidget extends StatefulWidget {
  Datum model;
  List<ListCardModel> listModel = [];

  ListCardWidget({Key key, this.model, this.listModel}) : super(key: key);

  @override
  _ListCardWidgetState createState() => _ListCardWidgetState();
}

class _ListCardWidgetState extends State<ListCardWidget> {
  @override
  Widget build(BuildContext context) {
    double windowWidth = MediaQuery.of(context).size.width;
    // windowWidth = 320;
    double spaceWidth = 8.w;
    int number = 5;
    double wellWidth =
        (windowWidth - ((CommonUtils.homeLeftPad + spaceWidth) * 2)) / number;
    if (wellWidth <= 60) {
      number = 4;
      wellWidth =
          (windowWidth - ((CommonUtils.homeLeftPad + spaceWidth) * 2)) / number;
    }

    if (widget.listModel is List<ListCardModel> &&
        widget.listModel.length > 1) {
      return buidlUI(windowWidth, spaceWidth, wellWidth);
    }
    return FutureBuilder(
        // 根据future返回的结果，创建小部件，注意请求状态，第一次请求会返回null
        future: ApiManage.getAllApply(widget.model.appurl),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          debugPrint(
              'date:${snapshot.data}'); // snapshot.data 包含了 future 对应的请求结果数据
          debugPrint(
              'connectionState:${snapshot.connectionState}'); // snapshot.connectionState 请求状态

          if (snapshot.connectionState == ConnectionState.waiting) {
            return CommonUtils.setLoading();
          } else if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data is List<ListCardModel>) {
              widget.listModel = snapshot.data;
            }
            if (widget.listModel == null) {
              widget.listModel = [];
            }

            if (number == 5 && widget.listModel.length >= 14) {
              widget.listModel.removeRange(14, widget.listModel.length);
            } else if (number == 4 && widget.listModel.length >= 12) {
              widget.listModel.removeRange(11, widget.listModel.length);
            }
            widget.listModel.add(ListCardModel(
                appName: '更多', appEngName: 'more', logoUri: 'more'));
          }
          return buidlUI(windowWidth, spaceWidth, wellWidth);
        });
  }

  buidlUI(double windowWidth, double spaceWidth, double wellWidth) {
    return Container(
      width: windowWidth,
      padding: CommonUtils.homeModelsPad,
      child: Container(
        decoration: CommonUtils.getBoxShadow(),
        padding: EdgeInsets.only(
            top: 20,
            left: spaceWidth,
            right: spaceWidth,
            bottom: CommonUtils.homeTopPad),
        child: new Wrap(
          spacing: 0, //主轴上子控件的间距
          runSpacing: 16, //交叉轴上子控件之间的间距
          alignment: WrapAlignment.start,
          children: widget.listModel.map((ListCardModel model) {
            return WorkItemWidget(
              model,
              itemWidth: wellWidth,
            );
          }).toList(),
        ),
      ),
    );
  }
}
