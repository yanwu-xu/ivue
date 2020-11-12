import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:geely_flutter/HomeListView/model/carousel_model.dart';
import 'package:geely_flutter/HomeListView/model/usermodules_scopedModel.dart';
import 'package:geely_flutter/common_util/common_utils.dart';
import 'package:geely_flutter/common_util/page_router.dart';
import 'package:geely_flutter/common_widget/home_swiper/flutter_page_indicator.dart';
import 'package:geely_flutter/network/api_manage.dart';

// ignore: must_be_immutable
class HomeSwiper extends StatefulWidget {
  Datum model;
  List<CarouselModel> listModel = [];

  HomeSwiper({Key key, this.model, this.listModel}) : super(key: key);

  @override
  HomeSwiperState createState() => HomeSwiperState();
}

class HomeSwiperState extends State<HomeSwiper> {
  /// 判断图片生成方式
  Image getImage(CarouselModel model) {
    if (model.previewUrl.isEmpty || model.previewUrl.length <= 0) {
      return Image.asset(
        'packages/geely_flutter/Images/carousel_default@2x.png',
        fit: BoxFit.cover,
      );
    } else {
      return Image(
        image: CachedNetworkImageProvider(
          model.previewUrl,
        ),
        fit: BoxFit.cover,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.listModel is List<CarouselModel> &&
        widget.listModel.length > 0) {
      return buildUI();
    }

    return FutureBuilder(
        // 根据future返回的结果，创建小部件，注意请求状态，第一次请求会返回null
        future: ApiManage.getOnShelf(widget.model.appurl),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          debugPrint(
              'date:${snapshot.data}'); // snapshot.data 包含了 future 对应的请求结果数据
          debugPrint(
              'connectionState:${snapshot.connectionState}'); // snapshot.connectionState 请求状态

          if (snapshot.connectionState == ConnectionState.waiting) {
            return CommonUtils.setLoading();
          } else if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data is List<CarouselModel>) {
              widget.listModel = snapshot.data;
            }
          }

          return buildUI();
        });
  }

  buildUI() {
    if (widget.listModel == null ||
        widget.listModel.isEmpty ||
        widget.listModel.length <= 0) {
      List<CarouselModel> defaultList = [CarouselModel(previewUrl: '')];
      widget.listModel = defaultList;
    }

    /// 轮播图模块
    double itemWidth =
        (MediaQuery.of(context).size.width - CommonUtils.homeLeftPad * 2);
    double heightWidth = itemWidth * 176 / 702;
    return Container(
      height: heightWidth,
      child: Swiper(
        onTap: (index) {
          debugPrint('点击轮播图');
//        CommonUtils.launchURL(widget.listModel[index].redirectUrl);
          PageRouter.open_webview({"url": widget.listModel[index].redirectUrl});
        },
        itemBuilder: (BuildContext context, int index) {
          return new ClipRRect(
            borderRadius: BorderRadius.circular(6.0),
            child: getImage(widget.listModel[index]),
          );
        },
        pagination: new SwiperPagination(
            margin: EdgeInsets.all(5),
            builder: SwiperCustomPagination(
                builder: (BuildContext context, SwiperPluginConfig config) {
              return Container(
                alignment: Alignment.bottomCenter,
                height: 5,
                child: PageIndicator(
                  layout: PageIndicatorLayout.LINE,
                  size: 10.0,
                  space: 4.0,
                  color: Color(0xFFD8D8D8),
                  activeColor: Color(0xFF2288EE),
                  count: widget.listModel.length,
                  controller: config.pageController,
                ),
              );
            })),
        // outer: true,
        itemCount: widget.listModel.length,
        autoplay: true,
        autoplayDelay: 5000,
      ),
    );
  }
}
