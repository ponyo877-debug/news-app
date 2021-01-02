import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:html/parser.dart';
import 'package:html/dom.dart' as dom;
import 'package:http/http.dart' as http;
import 'package:charset_converter/charset_converter.dart';
import 'package:flutter_user_agent/flutter_user_agent.dart';

// javascript in jQuery
// https://day-journal.com/memo/try-043/

// VIPPERな俺: delete main ads
// $('.i-amphtml-inabox.i-amphtml-singledoc.i-amphtml-standalone.i-amphtml-iframed').remove()

// add_20201227
// WebViewController _controller;
class MatomeWebView extends StatefulWidget {
  MatomeWebView({Key key, this.title, this.selectedUrl}) : super(key: key);

  final String title;
  final String selectedUrl;

  @override
  _MatomeWebView createState() => _MatomeWebView();
}

class _MatomeWebView extends State<MatomeWebView> {
  // final String title;
  // final String selectedUrl;
  // String outerHtmlstring = 'None';

  // add_20201227
  WebViewController _controller;

  // use to normal webview using initialUrl
  // final Completer<WebViewController> controller = Completer<WebViewController>();
  // MatomeWebView({this.title, this.selectedUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*
        appBar: AppBar(
          title: Text(title),
        ),
       */
      body: FutureBuilder(
        future: _loadUri(widget.selectedUrl),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData) {
            return WebView(
              // initialUrl: widget.selectedUrl,
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (WebViewController webViewController) {
                // controller.complete(webViewController);
                /*
                var orgHtml = Uri.dataFromString(snapshot.data,
                        mimeType: 'text/html',
                        encoding: Encoding.getByName('UTF-8'))
                    .toString();
                 */
                var modifiedHtml = arrangeBlog(snapshot.data);
                _controller = webViewController;
                // print("orgHtml: ${orgHtml}");
                _controller.loadUrl(modifiedHtml);
              },
            );
          } else {
            return Text("データが存在しません");
          }
        },
      ),
    );
  }

  void printWrapped(String text) {
    final pattern = RegExp('.{1, 800}'); // 800 is the size of each chunk
    pattern.allMatches(text).forEach((match) => print(match.group(0)));
  }

  // https://itnext.io/write-your-first-web-scraper-in-dart-243c7bb4d05
  String arrangeBlog(String orgHtml) {
    var document = parse(orgHtml);
    var articleHeaders = document.querySelectorAll('header.section-box');
    var blogTitle = articleHeaders[0].outerHtml;
    var articleTitle = articleHeaders[1].outerHtml;
    var articleBody =
        document.querySelector('div#article-contents.article-body').outerHtml;
    var modifiedHtml = Uri.dataFromString(
            '<html><body>' +
                blogTitle +
                articleTitle +
                articleBody +
                '</body></html>',
            //'<html><body>Dummy_modifiedHtml</body></html>', //snapshot.data,
            mimeType: 'text/html',
            encoding: Encoding.getByName('UTF-8'))
        .toString();
    return modifiedHtml;
  }

  Future<String> _loadUri(loaduri) async {
    String userAgent, _decode_charset;
    try {
      userAgent = await FlutterUserAgent.getPropertyAsync('userAgent');
      print("userAgent: ${userAgent}");
    } on PlatformException {
      userAgent = '<error>';
    }
    var response = await http.Client()
        .get(Uri.parse(loaduri), headers: {'User-Agent': userAgent});
    // headers: {'Content-Type': 'text/html; charset=euc-jp', 'User-Agent': userAgent});
    print("Response status: ${response.statusCode}");
    if (response.statusCode == 200) {
      var _headers = response.headers['content-type'].split('charset=');
      if (_headers.length == 2) {
        _decode_charset = _headers.last;
      } else {
        _decode_charset = 'utf-8';
      }
      print("decoded1: ");
      print("headers: ${_headers.length}");
      // print("Response bodyBytes: ${response.bodyBytes}");
      // var responseBody = utf8.decode(response.bodyBytes);
      // print(EucJP().decode(utf8.decode(response.bodyBytes)));
      String decoded =
          await CharsetConverter.decode(_decode_charset, response.bodyBytes);
      // String decoded = await CharsetConverter.decode("EUC-JP", response.bodyBytes);
      // printWrapped(response.body);
      print("_decode_charset: ${_decode_charset}");
      print("response.bodyBytes: ${response.bodyBytes}");
      print("decoded: ${decoded}");
      // var document = parse(response.body);
      var document = parse(decoded);
      return document.outerHtml;
      // return document;
    } else {
      throw Exception();
    }
  }
}
