import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:html/parser.dart';
import 'package:html/dom.dart' as dom;
import 'package:http/http.dart' as http;
import 'package:charset_converter/charset_converter.dart';
import 'package:flutter_user_agent/flutter_user_agent.dart';

// WebViewController _controller;
class MatomeWebView extends StatefulWidget {
  MatomeWebView({Key key, this.title, this.selectedUrl}) : super(key: key);

  final String title;
  final String selectedUrl;

  @override
  _MatomeWebView createState() => _MatomeWebView();
}

class _MatomeWebView extends State<MatomeWebView> {
  var livedoorhosts = [
    'blog.livedoor.jp',
    'hamusoku.com',
    'himasoku.com',
    'news4vip.livedoor.biz'
  ];
  // add_20201227
  WebViewController _controller;

  // use to normal webview using initialUrl
  // final Completer<WebViewController> controller = Completer<WebViewController>();
  // MatomeWebView({this.title, this.selectedUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder(
        future: _loadUri(widget.selectedUrl),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData) {
            return WebView(
              // initialUrl: widget.selectedUrl,
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (WebViewController webViewController) {
                // controller.complete(webViewController);
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
  Future<String> arrangeforLivedoorBlog(
      dom.Document doc /*String orgHtml*/, String hostName) async {
    // var doc = parse(orgHtml);

    // arrange header
    var linkstyle = doc.head.querySelectorAll('link[rel="stylesheet"]');
    var orgstyle = doc.head.querySelector('style');
    var viewport = doc.head.querySelector('meta[name="viewport"]');
    doc.head.children.clear();
    for (int i = 0; i < linkstyle.length; i++) {
      doc.head.children.add(linkstyle[i]);
    }
    if (orgstyle != null) {
      doc.head.children.add(orgstyle);
    }
    if (viewport != null) {
      doc.head.children.add(viewport);
    }

    // arrange body
    var articleBody = doc.querySelector('div#article-contents.article-body');
    var nextPage = doc.body.querySelector('p.next');
    var pageCount;
    if (nextPage != null) {
      print("doc.body.querySelector('p.age-current'): " +
          doc.body.querySelector('p.page-current').outerHtml);
      pageCount = int.parse(
          doc.body.querySelector('p.page-current').text.split('/').last);
    }
    doc.body.querySelector('div.article-body-outer').children.clear();
    doc.body.querySelector('div.article-body-outer').children.add(articleBody);

    if (nextPage != null) {
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
    temp = doc.body.querySelector(
        'script[src="https://blogroll.livedoor.net/js/blogroll.js"]');
    if (temp != null) {
      temp.remove();
    }
    scriptTag = doc.body.querySelectorAll('div#f984a');
    for (int i = 0; i < scriptTag.length; i++) {
      scriptTag[i].remove();
    }
    // doc.body.querySelector('a[target="_blank"]').remove();
    // 暇速
    temp = doc.body.querySelector('div.article_mid_v2');
    if (temp != null) {
      temp.remove();
    }
    temp = doc.body.querySelector('div#article_low_v2');
    if (temp != null) {
      temp.remove();
    }
    scriptTag = doc.body.querySelectorAll('iframe');
    for (int i = 0; i < scriptTag.length; i++) {
      scriptTag[i].remove();
    }
    //VIPPERな俺
    if (hostName == "blog.livedoor.jp") {
      /*
    scriptTag = doc.body.querySelectorAll('a[target="_blank"]');
    for (int i = 0; i < scriptTag.length; i++) {
      scriptTag[i].remove();
    }
    */
      // scriptTag = doc.body.querySelectorAll('a[href*="http://blog.livedoor.jp/news23vip/archives"]');
      scriptTag = doc.body.querySelectorAll('a');
      var scriptTagwithBR = doc.body.querySelectorAll('br');
      var allbrcount = scriptTagwithBR.length;
      ;
      for (int i = 0; i < scriptTag.length; i++) {
        // scriptTag[i].remove();
        var hrefurl = scriptTag[i].attributes['href'];
        if (hrefurl.startsWith('http://blog.livedoor.jp/news23vip/archives/')) {
          doc.body.querySelector('a[href="$hrefurl"]').remove();
          scriptTagwithBR[allbrcount - (i + 1)].remove();
        }
      }
    }
    // delete ads To

    var modifiedHtml = Uri.dataFromString(
            doc.head.outerHtml + doc.body.outerHtml,
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
    // print("response status: ${response.statusCode}");
    // print("response.headers: ${response.headers['content-type']}");

    // int response_length = response.bodyBytes.length;
    // String decoded = await CharsetConverter.decode("UTF-8", response.bodyBytes);
    String decoded =
        Utf8Decoder(allowMalformed: true).convert(response.bodyBytes);

    if (response.statusCode == 200) {
      var _headers = response.headers['content-type'].split('charset=');
      print("response.headers: " + response.headers['content-type']);


      if (_headers.length == 2) {
        _decode_charset = _headers.last;
      } else {
        _decode_charset = 'utf-8';
      }
      print("headers: ${_headers.length}");

      String modifiedHtml;
      var doc = parse(decoded);
      var hostName = Uri.parse(loaduri).host;
      // modifiedHtml = await arrangeforLivedoorBlog(doc, hostName);
      // print("modifiedHtml: ${modifiedHtml}");
      // print("hostName: " + hostName);
      if (livedoorhosts.contains(hostName)) {
        var doc = parse(decoded);
        print("hostName: " + hostName);
        modifiedHtml = await arrangeforLivedoorBlog(doc, hostName);
      } else {
        modifiedHtml = Uri.dataFromString(decoded,
                mimeType: 'text/html', encoding: Encoding.getByName('UTF-8'))
            .toString();
      }
      return modifiedHtml;
    } else {
      throw Exception();
    }
  }

  Future<dom.Document> _loadUriDom(loaduri) async {
    String userAgent, _decode_charset;
    try {
      userAgent = await FlutterUserAgent.getPropertyAsync('userAgent');
      print("userAgent: ${userAgent}");
    } on PlatformException {
      userAgent = '<error>';
    }
    var response = await http.Client()
        .get(Uri.parse(loaduri), headers: {'User-Agent': userAgent});
    print("Response status: ${response.statusCode}");
    if (response.statusCode == 200) {
      var _headers = response.headers['content-type'].split('charset=');
      if (_headers.length == 2) {
        _decode_charset = _headers.last;
      } else {
        _decode_charset = 'utf-8';
      }
      print("headers: ${_headers.length}");
      String decoded =
          Utf8Decoder(allowMalformed: true).convert(response.bodyBytes);
      print("_decode_charset: ${_decode_charset}");
      print("response.bodyBytes: ${response.bodyBytes}");
      return parse(decoded);
    } else {
      throw Exception();
    }
  }
}
