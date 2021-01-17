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
  var livedoorhosts = ['blog.livedoor.jp', 'hamusoku.com', 'himasoku.com', 'news4vip.livedoor.biz'];
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
                var modifiedHtml;
                var hostName = Uri.parse(widget.selectedUrl).host;
                if(livedoorhosts.contains(hostName)) {
                  modifiedHtml = arrangeforLivedoorBlog(snapshot.data);
                } else {
                  modifiedHtml = Uri.dataFromString(snapshot.data.outerHtml,
                      mimeType: 'text/html',
                      encoding: Encoding.getByName('UTF-8'))
                      .toString();
                }
                 */
                _controller = webViewController;
                _controller.loadUrl(snapshot.data);
              },
            );
          } else {
            // return Text("データが存在しません");
            return new Center(
              child: new Container(
                margin: const EdgeInsets.only(top: 8.0),
                width: 32.0,
                height: 32.0,
                child: const CircularProgressIndicator(),
              ),
            );
          }
        },
      ),
    );
  }

  void printWrapped(String text) {
    final pattern = RegExp('.{1, 100}'); // 800 is the size of each chunk
    pattern.allMatches(text).forEach((match) => print(match.group(0)));
  }

  Future<dom.Element> getNextPage(String Url, int p) async {
    var nextUrl = Url.replaceFirst('p=2', 'p=' + p.toString());
    var nextBody = await _loadUriDom(nextUrl);
    return nextBody.querySelector('div#article-contents.article-body');
  }

  // https://itnext.io/write-your-first-web-scraper-in-dart-243c7bb4d05
  Future<String> arrangeforLivedoorBlog(dom.Document doc/*String orgHtml*/) async {
    // var doc = parse(orgHtml);

    // arrange header
    var linkstyle = doc.head.querySelectorAll('link[rel="stylesheet"]');
    var orgstyle = doc.head.querySelector('style');
    doc.head.children.clear();
    for (int i = 0; i < linkstyle.length; i++){
      doc.head.children.add(linkstyle[i]);
    }
    if (orgstyle != null) {
      doc.head.children.add(orgstyle);
    }

    // arrange body
    var articleBody = doc.querySelector('div#article-contents.article-body');
    var nextPage = doc.body.querySelector('p.next');
    var pageCount;
    if(nextPage != null) {
      print("doc.body.querySelector('p.age-current'): " + doc.body.querySelector('p.page-current').outerHtml);
      pageCount = int.parse(doc.body.querySelector('p.page-current').text.split('/').last);
    }
    doc.body.querySelector('div.article-body-outer').children.clear();
    doc.body.querySelector('div.article-body-outer').children.add(articleBody);

    if(nextPage != null) {
      //print("doc.body.querySelector('p.age-current'): " + doc.body.querySelector('p.next').outerHtml);
      //var pageCount = int.parse(doc.body.querySelector('p.age-current').text.split('/').last);
      var nextUrl = nextPage.querySelector('a').attributes['href'];
      print("nextUrl: " + nextUrl);
      for (int p = 2; p <= pageCount; p++) {
        var nextBody = await getNextPage(nextUrl, p);
        doc.body.querySelector('div.article-body-outer').children.add(nextBody);
      }
    }

    // doc.body.querySelector('div#f984a').remove();
    // doc.body.querySelector('section').remove();
    var articleHeaders = doc.querySelectorAll('header.section-box');
    var blogTitle = articleHeaders[0];
    var articleTitle = articleHeaders[1];
    var temp = doc.body.querySelector('div.article-body-outer');
    doc.body.querySelector('div.content').children.clear();
    doc.body.querySelector('div.content').children.add(blogTitle);
    doc.body.querySelector('div.content').children.add(articleTitle);
    doc.body.querySelector('div.content').children.add(temp);

    temp = doc.body.querySelector('div.content');
    doc.body.querySelector('div.container-inner').children.clear();
    doc.body.querySelector('div.container-inner').children.add(temp);

    temp = doc.body.querySelector('div.container-inner');
    doc.body.querySelector('div.container').children.clear();
    doc.body.querySelector('div.container').children.add(temp);

    temp = doc.body.querySelector('div.container');
    doc.body.children.clear();
    doc.body.children.add(temp);

    // delete ads From
    var scriptTag;
    // ニュー速クオリティ
    scriptTag = doc.body.querySelectorAll('div#f984a');
    for (int i = 0; i < scriptTag.length; i++) {
      scriptTag[i].remove();
    }
    // doc.body.querySelector('a[target="_blank"]').remove();
    // 暇速
    doc.body.querySelector('div.article_mid_v2').remove();
    doc.body.querySelector('div#article_low_v2').remove();
    scriptTag = doc.body.querySelectorAll('iframe');
    for (int i = 0; i < scriptTag.length; i++) {
      scriptTag[i].remove();
    }
    //VIPPERな俺
    scriptTag = doc.body.querySelectorAll('a[target="_blank"]');
    for (int i = 0; i < scriptTag.length; i++) {
      scriptTag[i].remove();
    }
    // delete ads To

    var modifiedHtml = Uri.dataFromString(
            doc.head.outerHtml + doc.body.outerHtml,
            mimeType: 'text/html',
            encoding: Encoding.getByName('UTF-8'))
        .toString();
    return modifiedHtml;
  }

  Future<String>/*Future<String>*/ _loadUri(loaduri) async {
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
      // print("decoded: ${decoded}");
      // var doc = parse(response.body);

      String modifiedHtml;
      var hostName = Uri.parse(loaduri).host;
      if(livedoorhosts.contains(hostName)) {
        var doc = parse(decoded);
        print("hostName: " + hostName);
        modifiedHtml = await arrangeforLivedoorBlog(doc);
      } else {
        modifiedHtml = Uri.dataFromString(decoded,
            mimeType: 'text/html',
            encoding: Encoding.getByName('UTF-8'))
            .toString();
      }
      return modifiedHtml;
      // return doc.outerHtml;
      // return doc;
    } else {
      throw Exception();
    }
  }

  Future<dom.Document>/*Future<String>*/ _loadUriDom(loaduri) async {
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
      print("_decode_charset: ${_decode_charset}");
      print("response.bodyBytes: ${response.bodyBytes}");
      // print("decoded: ${decoded}");
      // var doc = parse(response.body);
      return parse(decoded);
      // return doc;
      // return doc.outerHtml;
      // return doc;
    } else {
      throw Exception();
    }
  }
}
