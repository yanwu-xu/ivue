import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:geely_flutter/http/base_entity.dart';
import 'package:geely_flutter/http/dio_factory.dart';

class DioApi {
  static final BASEAPI = "http://10.190.65.88";
  static final GET_ALL_MODULE = "/Portal/MyModule/GetAllModulesForAPP";
  static final GET_USER_MODULE = "/Portal/MyModule/GetUserModulesForAPP";
  static final SAVE_USER_MODULE = "/Portal/MyModule/SavePostionForAPP";
}
