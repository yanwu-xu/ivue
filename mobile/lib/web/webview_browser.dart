import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewBrowserHtml extends StatefulWidget {
  const WebViewBrowserHtml({Key key, this.url, this.title, this.htmlStr})
      : super(key: key);

  final String url;
  final String title;
  final String htmlStr;

  @override
  _WebViewBrowserHtmlState createState() => _WebViewBrowserHtmlState();
}

class _WebViewBrowserHtmlState extends State<WebViewBrowserHtml> {
  WebViewController _controller;

  // @override
  // void dispose() {
  //   _controller.clearCache();
  //   _controller = null;
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    // _loadHtmlFromAssets();
    return Scaffold(
      appBar: AppBar(
        title: Text('Help'),
        elevation: 0.0,
      ),
      body: WebView(
        initialUrl: '',
        onWebViewCreated: (WebViewController webViewController) {
          _controller = webViewController;
          _loadHtmlFromAssets();
        },
      ),
    );
  }

  _loadHtmlFromAssets() async {
    String fileText = await widget.htmlStr;
    _controller.loadUrl(Uri.dataFromString(fileText,
        mimeType: 'text/html ',
        encoding: Encoding.getByName('utf-8'),
        parameters: {'User-agent': 'Geely C3'}).toString());
  }
}

// 根据url打开网页，比如 https://www.baidu.com
class WebViewBrowser extends StatelessWidget {
  const WebViewBrowser({Key key, this.url, this.title}) : super(key: key);

  final String url;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        elevation: 0.0,
      ),
      body: SafeArea(
          child: WebView(
        initialUrl: url,
        javascriptMode: JavascriptMode.unrestricted,
      )),
    );
  }
}
