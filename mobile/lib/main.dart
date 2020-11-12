import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_boost/flutter_boost.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geely_flutter/common_util/page_router.dart';
import 'package:geely_flutter/localizations/localizetion_language.dart';
import 'package:geely_flutter/model/language_statu.dart';
import 'package:geely_flutter/network/api_manage.dart';
import 'package:geely_flutter/web/webview_browser.dart';
import 'package:geely_flutter/work_module/module_center.dart';

import 'HomeListView/HomeListView.dart';
import 'common_util/common_constant.dart';
import 'common_util/common_utils.dart';

/// 国际化
import 'localizations/localizetion_language_delegate.dart';
import 'model/user_info.dart';
import 'network_signalr/network_signalr_vc.dart';

import 'package:geely_flutter/network_signalr/network_signalr.dart';
import 'package:connectivity/connectivity.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    debugPrint('initState');

    /// 初始化 flutterBoost 信息
    FlutterBoost.singleton.registerPageBuilders({
      PageRouter.MYHOMEPAGE: (pageName, params, _) {
        return MyHomePage(userInfo: params);
      },
      PageRouter.MODULECENTER: (pageName, params, _) {
        return ModuleCenter();
      },
      PageRouter.ABOUT: (pageName, params, _) {
        return WebSocketRoute();
      },
      PageRouter.WEBVIEWBROWSER: (pageName, params, _) {
        return WebViewBrowser(
          title: params['title'],
          url: params['url'],
        );
      },
    });

    FlutterBoost.singleton
        .addBoostNavigatorObserver(TestBoostNavigatorObserver());

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: Locale('zh', 'CH'),
      supportedLocales: [Locale('zh', 'CH')],
      // 国际化配置
      localizationsDelegates: [
        LocalizationsLanguageDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],

      title: 'Flutter Demo',
      builder: FlutterBoost.init(postPush: _onRoutePushed),
      debugShowCheckedModeBanner: false,
      home: Center(),
      theme: ThemeData(
        highlightColor: Color.fromRGBO(255, 255, 255, 0.5),
        splashColor: Colors.white70,
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }

  void _onRoutePushed(
    String pageName,
    String uniqueId,
    Map<dynamic, dynamic> params,
    Route<dynamic> route,
    Future<dynamic> _,
  ) {}
}

class TestBoostNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic> previousRoute) {
    debugPrint('flutterboost#didPush');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic> previousRoute) {
    debugPrint('flutterboost#didPop');
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic> previousRoute) {
    debugPrint('flutterboost#didRemove');
  }

  @override
  void didReplace({Route<dynamic> newRoute, Route<dynamic> oldRoute}) {
    debugPrint('flutterboost#didReplace');
  }
}

// ignore: must_be_immutable
class MyHomePage extends StatefulWidget {
  var userInfo;

  MyHomePage({Key key, this.userInfo}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  /// 网络环境变化的监听
  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    print('网络环境变化 $result ');
    //
    switch (result) {
      case ConnectivityResult.wifi:
        SignalrConnect().reconnection();
        updateHome();
        break;
      case ConnectivityResult.mobile:
        SignalrConnect().reconnection();
        updateHome();
        break;
      case ConnectivityResult.none:
        break;
      default:
        break;
    }
  }

  updateHome({bool refresh = false}) {
    if (CommonUtils.user == null ||
        CommonUtils.user.token == null ||
        CommonUtils.user.token.isEmpty ||
        CommonUtils.user.oauthToken == null ||
        CommonUtils.user.oauthToken.isEmpty) {
      refresh = true;
    }
    if (refresh) {
      setState(() {
        debugPrint('刷新main首页');
      });
    }
  }

  ///原生调用Flutter
  Future<dynamic> platformCallHandler(MethodCall methodCall) async {
    switch (methodCall.method) {
      //中英文状态切换通知
      case PageRouter.CHANGE_LANGUAGE:
        debugPrint('platformCallHandler  =  CHANGE_LANGUAGE：');
//          CommonUtils.changeLocale(CommonUtils.store, methodCall.arguments.toString());
        CommonUtils.curLocale = methodCall.arguments.toString();
        updateHome(refresh: true);
        break;
      //主动刷新
      case PageRouter.HOME_REFRESH:
        debugPrint('platformCallHandler  = HOME_REFRESH：');

        updateHome();

        break;
      //登录成功
      case PageRouter.LOGIN_SUCCESS:
        debugPrint('platformCallHandler  = LOGIN_SUCCESS 3-1 ');
        CommonUtils.getUserInfo().then((value) {
          debugPrint('PageRouter.LOGIN_SUCCESS 3-2 :${CommonUtils.user.token}');
          setState(() {
            debugPrint('PageRouter LOGIN_SUCCESS 3-3 刷新首页');
          });
        });
        break;
    }
  }

  final Connectivity _connectivity = Connectivity();
  VoidCallback flutterBoostLifeCycleObserver;
  @override
  void initState() {
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

//    CommonUtils.store = store;
    _getLanguage();

    UserInfo userInfo = UserInfo.fromMap(widget.userInfo);

    CommonUtils.saveUserInfo(userInfo);

    PageRouter.methodChannel.setMethodCallHandler(platformCallHandler);

    flutterBoostLifeCycleObserver = FlutterBoost.singleton
        .addBoostContainerLifeCycleObserver((state, settings) {
      if (state == ContainerLifeCycle.Appear) {
        updateHome();
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    flutterBoostLifeCycleObserver();
    super.dispose();
  }

  /// 获取当前语言
  void _getLanguage() {
    /// 获取当前语言
    PageRouter.getLanguage().then((value) {
      if (value is LanguageStatu) {
        LanguageStatu state = value;
//        CommonUtils.changeLocale(store, state.data);
        CommonUtils.curLocale = state.data;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,
        width: CommonConstant.WIDTH,
        height: CommonConstant.HEIGHT,
        allowFontScaling: false);
    Future<dynamic> future;
    // 判断是否有geelyToken
    if (CommonUtils.user.token == null || CommonUtils.user.token.isEmpty) {
      // 没有geelyToken 且 是geely用户的: 域账号认证
      if (CommonUtils.user.isGeelyUser == '1') {
        return isGeelyuserNoToken();
      }
      // 没有geelyToken 且 不是geely用户的: 二次token认证 拿acctoken
      future = ApiManage.getAccTokenByAuthToken();
    } else {
      // 有geelyToken ，根据geelyToken拿acctoken
      future = ApiManage.getAccTokenByGeelyToken(
        CommonUtils.user.corpId,
        CommonUtils.user.token,
      );
    }

    return FutureBuilder(
        // 根据future返回的结果，创建小部件，注意请求状态，第一次请求会返回null
        future: future,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CommonUtils.setLoading(loading: true);
          } else if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data != null && snapshot.data is String) {
              CommonUtils.changeUserOauthToken(snapshot.data);

              // ApiManage.loginApp(); // 初始化数据
              int times = 24 * 60 * 60; // 续1天
              ApiManage.extendToken(times);

              ApiManage.userCenterTokenLogin();
            }
          }
          return Scaffold(
            body: Container(child: HomeListView()),
          );
        });
  }

  // 是吉利用户且没有geelyToken时展示
  isGeelyuserNoToken() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Image.asset(
          'packages/geely_flutter/Images/emptyGeelyToken_icon@2x.png',
          width: 200.w,
          height: 110.h,
        ),
        SizedBox(
          height: 12.0.h,
        ),
        Text(
          LocalizationsLanguage.i18n(context).loginAlert,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF3F4342),
            fontSize: 16.0,
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.none,
          ),
        ),
        SizedBox(
          height: 30.0.h,
        ),
        Theme(
          // data: ThemeData(), // 单独设置当前小部件的主题
          data: Theme.of(context).copyWith(
            buttonColor: Theme.of(context).accentColor,
            buttonTheme: ButtonThemeData(
                textTheme: ButtonTextTheme.primary,
                // shape: BeveledRectangleBorder(
                //   borderRadius: BorderRadius.circular(15.0), // 菱形角度
                // )
                shape: StadiumBorder() // 圆角
                ),
          ),
          child: OutlineButton(
            onPressed: () {
              print('openLogin');
              PageRouter.openLogin();
            },
            child: Text(
              LocalizationsLanguage.i18n(context).loginButtonText,
              style: TextStyle(
                color: Color(0xFF1D2221),
                fontSize: 14.0,
              ),
            ),
            // splashColor: Colors.red, // 点击后的填充色
            textColor: Colors.black,
            highlightedBorderColor: Color(0xFFBEBEBF), // 高亮时的描边颜色
          ),
        )
      ],
    );
  }
}
