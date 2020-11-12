import 'package:geely_flutter/redux/gl_redux.dart';
import 'package:redux/redux.dart';
import 'package:rxdart/rxdart.dart';

import 'package:geely_flutter/model/user_info.dart';

/**
 * 用户相关Redux
 * Created by guoshuyu
 * Date: 2018-07-16
 */

/// redux 的 combineReducers, 通过 TypedReducer 将 UpdateUserAction 与 reducers 关联起来
final userReducer = combineReducers<UserInfo>([
  TypedReducer<UserInfo, UpdateUserAction>(_updateLoaded),
]);

/// 如果有 UpdateUserAction 发起一个请求时
/// 就会调用到 _updateLoaded
/// _updateLoaded 这里接受一个新的userInfo，并返回
UserInfo _updateLoaded(UserInfo user, action) {
  user = action.userInfo;
  return user;
}

///定一个 UpdateUserAction ，用于发起 userInfo 的的改变
///类名随你喜欢定义，只要通过上面TypedReducer绑定就好
class UpdateUserAction {
  final UserInfo userInfo;

  UpdateUserAction(this.userInfo);
}

class FetchUserAction {}

class UserInfoMiddleware implements MiddlewareClass<GLState> {
  @override
  void call(Store<GLState> store, dynamic action, NextDispatcher next) {
    if (action is UpdateUserAction) {
      print("*********** UserInfoMiddleware *********** ");
    }
    // Make sure to forward actions to the next middleware in the chain!
    next(action);
  }
}

// Stream<dynamic> userInfoEpic(
//     Stream<dynamic> actions, EpicStore<GLState> store) {
//   // Use the async* function to make easier
//   Stream<dynamic> _loadUserInfo() async* {
//     print("*********** userInfoEpic _loadUserInfo ***********");
//     var res = await UserDao.getUserInfo(null);
//     yield UpdateUserAction(res.data);
//   }

//   return actions
//       // to UpdateUserAction actions
//       .whereType<FetchUserAction>()
//       // Don't start  until the 10ms
//       .debounce(((_) => TimerStream(true, const Duration(milliseconds: 10))))
//       .switchMap((action) => _loadUserInfo());
// }
