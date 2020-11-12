import 'dart:collection';

import 'package:dio/dio.dart';
import 'package:geely_flutter/common_util/common_utils.dart';
import './interceptor/error_interceptor.dart';
import 'result_data.dart';
import 'interceptor/log_interceptor.dart';

String apiHost = 'http://10.190.65.88';
String aipGetAccTokenByGeelyToken =
    'http://10.190.66.94:8102/sammboMgr/oauth2/getAccTokenByGeelyToken';
String apiExtendToken =
    'http://10.190.66.94:8102/sammboMgr/center/oauth2/extendToken';
String apiGetSammboToken = 'http://10.190.65.88/Portal/Login/GetSammboToken';

String apiUserCenterTokenLogin =
    'http://10.190.65.91:8050/Portal/Login/UserCenterTokenLogin';

/// 选择数据源的dio
Dio _dioChoose({DIO_TYPE number = DIO_TYPE.DIO_TYPE_DEFAULT}) {
  BaseOptions options = new BaseOptions(); //配置一个 `options`来创建dio实例
  options.connectTimeout = 30000; // 30s
  options.receiveTimeout = 30000; // 30s
  // options.headers = {HttpHeaders.userAgentHeader: 'flutter_dio', 'api': '1.0.0'};

  switch (number) {
    case DIO_TYPE.DIO_TYPE_Other:
      // options.baseUrl = 'http://10.190.65.91:8053'; // 其他数据源
      break;
    default:
      options.baseUrl = apiHost; // 默认数据源
  }

  Dio getDio = new Dio(options);

  getDio.interceptors.add(new ErrorInterceptors(getDio));
  getDio.interceptors.add(new LogsInterceptors());

  return getDio;
}

enum DIO_TYPE { DIO_TYPE_DEFAULT /* 默认Dio */, DIO_TYPE_Other /* 本地 服务器 */ }

class HttpManager {
  static Dio dio({DIO_TYPE number = DIO_TYPE.DIO_TYPE_DEFAULT}) {
    return _dioChoose(number: number);
  }

  /// 统一的错误处理，待完善
  static resultError(DioError e, {noTip = false}) {
    Response errorResponse;
    String message = "发生错误";

    if (e.response != null) {
      errorResponse = e.response;
    } else {
      errorResponse = new Response(
          statusCode: NetWorkCode.NETWORK_ERROR_RESPONSE,
          data: {'Message': message});
    }
    if (e.type == DioErrorType.CONNECT_TIMEOUT ||
        e.type == DioErrorType.RECEIVE_TIMEOUT) {
      errorResponse.statusCode = NetWorkCode.NETWORK_TIMEOUT;
    } else if (e.type == DioErrorType.RESPONSE ||
        e.response.statusCode == 401) {
      CommonUtils.removeToken();
    }
    if (errorResponse.data is Map<String, String>) {
      message = errorResponse.data['Message'].toString();
    }

    return new ResultData(
        NetWorkCode.errorHandleFunction(
            errorResponse.statusCode, e.message, noTip),
        false,
        errorResponse.statusCode,
        message);
  }

  /// dioDefault下的http请求
  ///[ url] 请求url
  ///[ params] 请求参数
  ///[ header] 外加头
  ///[ option] 配置 比如POST请求：Options(method: 'POST')
  ///[ noTip] 是否toast提示
  Future<ResultData> netRequest(url,
      {params,
      Map<String, dynamic> header,
      Options options,
      noTip = false}) async {
    return netRequestBase(dioDefault, url,
        params: params, header: header, options: options, noTip: noTip);
  }

  /// dioOther 下的http请求
  ///[ url] 请求url
  ///[ params] 请求参数
  ///[ header] 外加头
  ///[ option] 配置 比如POST请求：Options(method: 'POST')
  ///[ noTip] 是否toast提示
  Future<ResultData> netRequestLocation(url,
      {params, Map<String, dynamic> header, Options options, noTip = false}) {
    return netRequestBase(dioOther, url,
        params: params, header: header, options: options, noTip: noTip);
  }

  /// http请求
  ///[ url] 请求url
  ///[ params] 请求参数
  ///[ header] 外加头
  ///[ option] 配置 比如POST请求：Options(method: 'POST')
  ///[ noTip] 是否toast提示
  static Future<ResultData> netRequestBase(dio, url,
      {params,
      Map<String, dynamic> header,
      Options options,
      noTip = false}) async {
    if (url == null) {
      return new ResultData('数据错误 - 无url ： $url', false, -1, '数据错误- 无url ');
    }
    Map<String, dynamic> headers = new HashMap();
    if (CommonUtils.user == null) {
      CommonUtils.getUserInfo();
      return ResultData(
          NetWorkCode.errorHandleFunction(
              NetWorkCode.NETWORK_UserInfo_ERROR, '用户信息获取失败', noTip),
          false,
          NetWorkCode.NETWORK_UserInfo_ERROR,
          '用户信息获取失败');
    }
    headers.addAll({
      'UserCenterToken':
          CommonUtils.user.token == null ? '' : CommonUtils.user.token,
      'SammboToken': CommonUtils.user.oauthToken == null
          ? ''
          : CommonUtils.user.oauthToken,
      'TenantId': CommonUtils.user.corpId == null ? '' : CommonUtils.user.corpId
    });
    if (header != null) {
      headers.addAll(header);
    }

    if (options != null) {
      options.headers = headers;
    } else {
      options = new Options(method: "get");
      options.headers = headers;
    }

    Response response = Response();
    try {
      response = await dio.request(url,
          data: params, queryParameters: params, options: options);
    } on DioError catch (e) {
      return resultError(e);
    }
    if (response.data is DioError) {
      return resultError(response.data);
    }

    if (response.data is Map) {
      ResultData resultData = new ResultData(
        response.data['Data'] == null ? [] : response.data['Data'],
        response.data['Success'] == null ? '' : response.data['Success'],
        response.data['Code'] == null ? -1 : response.data['Code'],
        response.data['Message'] == null ? '' : response.data['Message'],
        PageInfo:
            response.data['PageInfo'] == null ? [] : response.data['PageInfo'],
      );

      return resultData;
    }

    return new ResultData('数据错误 $url', false, -1, '数据错误');
  }

  /// dioOther下的http请求
  ///[ url] 请求url
  ///[ params] 请求参数
  ///[ header] 外加头
  ///[ option] 配置 比如POST请求：Options(method: 'POST')
  ///[ noTip] 是否toast提示
  Future<ResultData> netRequestShanBu(url,
      {params,
      Map<String, dynamic> header,
      Options options,
      noTip = false}) async {
    if (url == null) {
      return new ResultData('数据错误 - 无url ： $url', false, -1, '数据错误- 无url ');
    }
    Map<String, dynamic> headers = new HashMap();
    headers.addAll({
      'UserCenterToken': CommonUtils.user.token,
      'accToken': CommonUtils.user.oauthToken,
      'TenantId': CommonUtils.user.corpId
    });
    if (header != null) {
      headers.addAll(header);
    }

    if (options != null) {
      options.headers = headers;
    } else {
      options = new Options(method: "get");
      options.headers = headers;
    }

    Response response;
    try {
      response = await dioOther.request(url,
          data: params, queryParameters: params, options: options);
    } on DioError catch (e) {
      return resultError(e);
    }
    if (response.data is DioError) {
      return resultError(response.data);
    }

    if (response.data is Map) {
      ResultData resultData = new ResultData(
        response.data['data'] == null ? [] : response.data['data'],
        response.data['success'] == null ? '' : response.data['success'],
        response.data['code'] == null ? -1 : response.data['code'],
        response.data['message'] == null ? '' : response.data['message'],
      );

      return resultData;
    }

    return new ResultData('数据错误 $url', false, -1, '数据错误');
  }

  /// dioOther下的http请求
  ///[ url] 请求url
  ///[ params] 请求参数
  ///[ header] 外加头
  ///[ option] 配置 比如POST请求：Options(method: 'POST')
  ///[ noTip] 是否toast提示
  Future<Response> netRequestOther(url,
      {params,
      Map<String, dynamic> header,
      Options options,
      noTip = false}) async {
    if (url == null) {
      return Response();
    }
    Map<String, dynamic> headers = new HashMap();

    if (header != null) {
      headers.addAll(header);
    }

    if (options != null) {
      options.headers = headers;
    } else {
      options = new Options(method: "get");
      options.headers = headers;
    }

    Response response;
    try {
      response = await dioOther.request(url,
          data: params, queryParameters: params, options: options);
    } on DioError catch (e) {
      return resultError(e);
    }
    if (response.data is DioError) {
      return resultError(response.data);
    }

    return response;
  }
}

final HttpManager httpManager = new HttpManager();
// 默认数据源的dio
var dioDefault = HttpManager.dio();
// 默认数据源的dio
var dioOther = HttpManager.dio(number: DIO_TYPE.DIO_TYPE_Other);
