import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';


// javascript in jQuery
// https://day-journal.com/memo/try-043/

// VIPPERな俺: delete main ads
// $('.i-amphtml-inabox.i-amphtml-singledoc.i-amphtml-standalone.i-amphtml-iframed').remove()
class MatomeWebView extends StatelessWidget {
    final String title;
  final String selectedUrl;

  final Completer<WebViewController> controller =
      Completer<WebViewController>();

  MatomeWebView({this.title, this.selectedUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: WebView(
          initialUrl: selectedUrl,
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController webViewController) {
            controller.complete(webViewController);
          },
        ));
  }
}
