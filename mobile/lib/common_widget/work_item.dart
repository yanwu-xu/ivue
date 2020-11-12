import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geely_flutter/HomeListView/model/listcard_model.dart';
import 'package:geely_flutter/common_util/common_utils.dart';

import '../common_util/page_router.dart';

// ignore: must_be_immutable
class WorkItemWidget extends StatefulWidget {
  ListCardModel model;
  double itemWidth;
  WorkItemWidget(this.model, {this.itemWidth});

  @override
  WorkItemWidgetState createState() => WorkItemWidgetState();
}

class WorkItemWidgetState extends State<WorkItemWidget> {
  @override
  Widget build(BuildContext context) {
    double itemWidth = 68.w;
    if (widget.itemWidth != null) {
      itemWidth = widget.itemWidth;
    }

    double itemHeight = 72.w;
    final widthImage = 38.w;

    String _title = widget.model.appName;
    if (CommonUtils.curLocale == 'en_US') {
      _title = widget.model.appEngName.toString();
    }

    Image getImage(String logoUrl) {
      if (logoUrl == 'more') {
        return Image.asset(
          'packages/geely_flutter/Images/more_indexIcon@2x.png',
          width: widthImage,
          height: widthImage,
        );
      } else {
        return Image(
          image: CachedNetworkImageProvider(logoUrl),
          width: widthImage,
          height: widthImage,
        );
      }
    }

    return InkWell(
      splashColor: Colors.grey.withOpacity(0.1),
      child: Container(
        alignment: Alignment.centerLeft,
        width: itemWidth,
        height: itemHeight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(widthImage / 2),
                child: getImage(widget.model.logoUri),
              ),
              width: widthImage,
              height: widthImage,
            ),
            Container(
              alignment: Alignment.center,
              child: Text(
                _title,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.black,
                ),
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis, // ellipsis 省略号； fade 渐隐； clip 剪裁
                textAlign: TextAlign.center,
              ),
              width: itemWidth,
              height: itemHeight - widthImage,
            ),
          ],
        ),
      ),
      onTap: () {
        debugPrint('点击 $_title');
        if (widget.model.logoUri == 'more') {
          PageRouter.openWorkbench();
        } else {
          PageRouter.dealWorkItem(widget.model.toJson());
        }
      },
    );
  }
}
