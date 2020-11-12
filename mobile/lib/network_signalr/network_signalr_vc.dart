import 'package:flutter/material.dart';
import 'package:signalr_client/signalr_client.dart';
import 'package:logging/logging.dart';
import 'dart:io';

// // 服务器地址
// final serverUrl = '192.168.10.50:51001';
// // 通过使用HubConnectionBuilder创建连接
// final hubConnection = HubConnectionBuilder().withUrl(serverUrl).build();
// //当连接关闭时，打印一条消息到控制台
// final hubConnection.OnClose( (error) => debugPrint('Connection Closed'));

// If you want only to log out the message for the higer level hub protocol:
final hubProtLogger = Logger("SignalR - hub");
// If youn want to also to log out transport messages:
final transportProtLogger = Logger("SignalR - transport");

final connectionOptions = HttpConnectionOptions;
final httpOptions = new HttpConnectionOptions(logger: transportProtLogger);


class WebSocketRoute extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return _WebSocketRouteState();
  }
}

class _WebSocketRouteState extends State<WebSocketRoute> {
  int _counter = 0;

  var _msg = "等待消息";
  var _conState = "等待";

  _WebSocketRouteState() {
    _initSignalR();
  }

  // The location of the SignalR Server.
  // static final serverUrl = "http://10.200.144.228:8020/chathub";
  static final serverUrl = "http://10.200.144.228:8025/todoListHub";

  // SignalR Connection
  // final hubConnection = HubConnectionBuilder().withUrl(serverUrl).build();
  final hubConnection = HubConnectionBuilder()
      .withUrl(serverUrl, options: httpOptions)
      .configureLogging(hubProtLogger)
      .build();

  // Msg List
  List<String> ltMsg = ["测试1", "测试2"];

  // Msg
  final TextEditingController _controllerMsg = new TextEditingController();

  // Name
  final TextEditingController _controllerName = new TextEditingController();

  //初始化连接
  void _initSignalR() async {
    debugPrint("[SignalR] Begin Connection");
    debugPrint(serverUrl);

    try {
      debugPrint("[SignalR] 准备连接");
      hubConnection.onclose((error) => debugPrint("Connection Closed"));
      // ignore: unrelated_type_equality_checks
      if (hubConnection.start != HubConnectionState.Connected) {
        debugPrint("[SignalR] 检测到没有连接上，去连接");
        await hubConnection.start();
      }
      debugPrint("[SignalR] 准备接受数据");
      hubConnection.on("ReceiveTodoCount", (e) {

        receiveMessage(e);
      });

      _conState = "成功";
      debugPrint("[SignalR] 连接成功");
    } catch (error) {
      _conState = "失败";
      debugPrint("[SignalR] 连接失败" + error.toString());
    }
  }

  // 接受消息
  void receiveMessage(List<dynamic> message) {
    message.forEach((element) {debugPrint('[SignalR] 收到的消息：'+element.toString()); });
    setState(() {
      // debugPrint('[SignalR] 收到的消息：$message');
      // ltMsg.add("ReceiveTodoCount: " + message);
    });
  }

  // 发送消息
  void sendMsg() async {
    final result = await hubConnection
        .invoke("UserSign", args: <Object>['aef768251dae4cfea4ef3669e4f2e9d8']);
    debugPrint('[SignalR] 发送消息 $result');
  }

  // 计数器
  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  // 获取列表数据
  _getListData() {
    List<Widget> widgets = [];
    for (int i = 0; i < ltMsg.length; i++) {
      widgets.add(new Padding(
          padding: new EdgeInsets.all(10.0), child: new Text(ltMsg[i])));
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Signal Demo'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                textDirection: TextDirection.ltr,
                children: <Widget>[
                  RaisedButton(
                    color: Colors.red,
                    child: Text("重新连接SignalR"),
                    textColor: Colors.white,
                    onPressed: _initSignalR,
                  ),
                  Spacer(
                    flex: 1,
                  ),
                  Text(
                    "SignalR状态:",
                    style: TextStyle(fontSize: 20),
                  ),
                  Text(
                    _conState,
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
              Container(
                height: 300,
                child: ListView(children: _getListData()),
              ),
              Text(
                '点击计数:',
                style: TextStyle(fontSize: 30),
              ),
              Text(
                '当前点击数量:$_counter',
                style: TextStyle(fontSize: 20),
              ),
              Column(
                children: <Widget>[
                  new TextField(
                    controller: _controllerName,
                    decoration: new InputDecoration(
                      hintText: '昵称',
                    ),
                  ),
                  new TextField(
                    controller: _controllerMsg,
                    decoration: new InputDecoration(
                      hintText: '消息',
                    ),
                  ),
                  new MaterialButton(
                    color: Colors.blueAccent,
                    minWidth: double.infinity,
                    height: 50,
                    onPressed: () {
                      sendMsg();
                      _incrementCounter();
                    },
                    child: new Text('发送'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
