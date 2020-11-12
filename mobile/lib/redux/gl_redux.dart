import 'package:flutter/material.dart';
import 'package:geely_flutter/model/user_info.dart';
import 'locale_redux.dart';
import 'user_redux.dart';

/// Redux 第二步 二分之一  创建 LocaleReducer 自定义reducer 类

/*
Redux 全局 State
*/

/// Redux 第一步，自定义State类
class GLState {
  /// 用户信息
  UserInfo userInfo;

  /// 语言
  Locale locale;

  ///当前手机平台默认语言
  Locale platformLocale;

  /// 构造方法
  GLState({
    this.userInfo,
    this.locale,
  });
}

/// Redux 第二步 生成 appReducer ，并关联自个自定义 reducer 类（与第一步创建的自定义State类一一对应）
GLState appReducer(GLState state, action) {
  return GLState(
    ///通过 userReducer 将 GSYState 内的 userInfo 和 action 关联在一起
    userInfo: userReducer(state.userInfo, action),

    /// 第二步 二分之一 通过 localeReducer 将 GSYState 内的 locale 和 action 关联在一起
    locale: localeReducer(state.locale, action),
  );
}

/// Redux 第三步：在main类中初始化
