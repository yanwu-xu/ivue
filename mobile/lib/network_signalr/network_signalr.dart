import 'package:flutter/material.dart';
import 'package:geely_flutter/common_util/common_utils.dart';
import 'package:geely_flutter/eventbus/eventbus.dart';
import 'package:logging/logging.dart';
import 'package:signalr_client/signalr_client.dart';

final hubProtLogger = Logger("SignalR - hub");
final transportProtLogger = Logger("SignalR - transport");
final httpOptions = new HttpConnectionOptions(logger: transportProtLogger);
const SERVER_URL = "http://10.190.65.88:8055/todoListHub";
const SEND_METHOD = "UserSign";
const RECEIVE_METHOD = "ReceiveTodoCount";

class SignalrConnect {
  SignalrConnect._internal() {
    initSignalR();
  }

  static SignalrConnect _singleton = new SignalrConnect._internal();

  factory SignalrConnect() => _singleton;

  /// 初始化
  final hubConnection = HubConnectionBuilder()
      .withUrl(SERVER_URL, options: httpOptions)
      .configureLogging(hubProtLogger)
      .build();

  /// 连接
  Future initSignalR() async {
    try {
      debugPrint("[SignalR] 准备连接");
      hubConnection
          .onclose((error) => debugPrint("[SignalR] Connection Closed"));
      if (hubConnection.state != HubConnectionState.Connected) {
        debugPrint("[SignalR] 检测到没有连接上，去连接");
        await hubConnection.start();
      }
      debugPrint("[SignalR] 准备接受数据");
      hubConnection.off(RECEIVE_METHOD);
      hubConnection.on(RECEIVE_METHOD, (e) {
        receiveMessage(e);
      });

      debugPrint("[SignalR] 连接成功");
      // 连接成功后发送消息
      sendMsg();
    } catch (error) {
      debugPrint("[SignalR] 连接失败" + error.toString());
    }
  }

  /// 接受消息
  void receiveMessage(List<dynamic> message) {
    message.forEach((element) {
      debugPrint('[SignalR] receiveMessage：' + element.toString());
      bus.emit(REFRESHTODO, element);
    });
  }

  /// 发送消息
  Future<String> sendMsg() async {
    var oauthToken = CommonUtils.user.oauthToken;
    if (!oauthToken.isEmpty) {
      final result =
          await hubConnection.invoke(SEND_METHOD, args: <Object>[oauthToken]);
      debugPrint('[SignalR] sendMsg $result  $oauthToken');
    } else {
      debugPrint('[SignalR] sendMsg oauthToken.isEmpty');
    }
  }

  /// 停止连接
  void stopConnection() async {
    hubConnection.stop();
  }

  /// 重连
  void reconnection() {
    if (hubConnection.state == HubConnectionState.Connected) {
      /// 已连接
      debugPrint("[SignalR] 重连，先断开链接");
      stopConnection();
    }
    debugPrint("[SignalR] 开始重连");
    initSignalR();
  }
}
