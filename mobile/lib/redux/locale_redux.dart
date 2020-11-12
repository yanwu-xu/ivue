import 'package:flutter/material.dart';
import 'package:redux/redux.dart';

// 通过 locale_redux 的 combineReducers 与 TypedReducer
// 将 RefreshLocaleAction 类 和 _refresh 方法绑定起来，最终会返回一个 Locale 实例。
// 也就是说：用户每次发出一个 RefreshLocaleAction ，最终都会触发 _refresh 方法，
// 然后更新 GLState 中的 locale

///通过 locale_redux 的 combineReducers，创建 Reducer<State>
final localeReducer = combineReducers<Locale>([
  ///将Action，处理Action动作的方法，State绑定
  TypedReducer<Locale, RefreshLocaleAction>(_refresh),
]);

///定义处理 Action 行为的方法，返回新的 State
Locale _refresh(Locale locale, RefreshLocaleAction action) {
  locale = action.locale;
  return locale;
}

///定义一个 Action 类
///将该 Action 在 Reducer 中与处理该Action的方法绑定
class RefreshLocaleAction {
  final Locale locale;
  RefreshLocaleAction(this.locale);
}
