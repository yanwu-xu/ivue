import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import '../result_data.dart';
import 'package:geely_flutter/common_util/common_utils.dart';

/// 网络编码
class NetWorkCode {
  ///网络错误
  static const NETWORK_ERROR = -1;

  ///网络超时
  static const NETWORK_TIMEOUT = -2;

  ///网络返回数据格式化一次
  static const NETWORK_JSON_EXCEPTION = -3;

  ///网络返回错误相应
  static const NETWORK_ERROR_RESPONSE = -4;

  ///网络返回错误相应
  static const NETWORK_UserInfo_ERROR = -5;

  static const SUCCESS = 200;

  static errorHandleFunction(code, message, noTip) {
    if (noTip) {
      CommonUtils.toastShow(message);
      return message;
    }
    return message;
  }
}

class ErrorInterceptors extends InterceptorsWrapper {
  // ignore: unused_field
  final Dio _dio;

  ErrorInterceptors(this._dio);

  @override
  onRequest(RequestOptions options) async {
    var connectivityResult = await (new Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      return _dio.resolve(
          new ResultData(null, false, NetWorkCode.NETWORK_ERROR, '网络错误'));
    }
    return options;
  }
}
