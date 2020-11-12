import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:geely_flutter/common_util/common_utils.dart';
import 'package:geely_flutter/http/base_entity.dart';
import 'package:geely_flutter/http/baselist_entity.dart';
import 'package:geely_flutter/http/dio_api.dart';
import 'package:geely_flutter/http/error_entity.dart';
import 'package:geely_flutter/http/method_type.dart';

class DioFactory {
  static const int CONNECT_TIMEOUT = 30000;
  static const int RECEIVE_TIMEOUT = 30000;

  static const PROXY_ENABLE = false;

  factory DioFactory() => _getInstance();
  Dio _dio;

  static DioFactory get instance => _getInstance();
  static DioFactory _instance;

  static DioFactory _getInstance() {
    if (_instance == null) {
      _instance = new DioFactory._internal();
    }
    return _instance;
  }

  DioFactory._internal() {
    if (null == _dio) {
      BaseOptions baseOptions = new BaseOptions(
          baseUrl: DioApi.BASEAPI,
          connectTimeout: CONNECT_TIMEOUT,
          receiveTimeout: RECEIVE_TIMEOUT);
      _dio = new Dio(baseOptions);
      // ..httpClientAdapter = (DefaultHttpClientAdapter()
      //   ..onHttpClientCreate = (HttpClient client) {
      //     client.findProxy = (Uri uri) {
      //       return 'PROXY 10.200.45.132:8888';
      //     };
      //     client.badCertificateCallback =
      //         (X509Certificate cert, String host, int port) {
      //       return true;
      //     };
      //   });
    }
  }

  Future<T> request<T>(METHODTYPE method, String path,
      {data,
      Map params,
      Function(T) success,
      Function(ErrorEntity) error}) async {
    var header = {
      "SammboToken": CommonUtils.user.oauthToken,
      "TenantId": CommonUtils.user.corpId
    };
    try {
      Response response = await _dio.request(path,
          data: data,
          options: Options(headers: header, method: MethodValues[method]));
      if (response != null) {
        debugPrint("response != null");
        BaseEntity entity = BaseEntity<T>.fromJson(response.data);
        if (entity.Code == 200) {
          debugPrint("request success");
          success(entity.Data);
          return entity.Data;
        } else {
          debugPrint("request error");
          error(ErrorEntity(Code: entity.Code, Message: entity.Message));
        }
      } else {
        debugPrint("response == null ");
        error(ErrorEntity(Code: -1, Message: "未知错误"));
      }
    } on DioError catch (e) {
      print(e);
      error(ErrorEntity(Code: -1, Message: "DioError"));
    }
  }

  Future<List<T>> requestList<T>(METHODTYPE method, String path,
      {Map<String, dynamic> params,
      Function(List) success,
      Function(ErrorEntity) error}) async {
    var header = {
      "SammboToken": CommonUtils.user.oauthToken,
      "TenantId": CommonUtils.user.corpId
    };
    try {
      Response response = await _dio.request(path,
          queryParameters: params,
          options: Options(headers: header, method: MethodValues[method]));
      if (response != null) {
        BaseListEntity entity = BaseListEntity<T>.fromJson(response.data);
        if (entity.Code == 200) {
          success(entity.Data);
          return entity.Data;
        } else {
          error(ErrorEntity(Code: entity.Code, Message: entity.Message));
        }
      } else {
        error(ErrorEntity(Code: -1, Message: "未知错误"));
      }
    } on DioError catch (e) {
      print(e);
      error(ErrorEntity(Code: -1, Message: "DioError"));
    }
  }
}
