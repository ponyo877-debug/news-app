import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'news_card.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class PostScreen extends StatefulWidget {
  PostScreen();

  @override
  _PostScreen createState() => _PostScreen();
}

// https://qiita.com/taki4227/items/e3c7e640b7986a80b2f9
// https://qiita.com/najeira/items/454462c794c35b3b600a
class _PostScreen extends State<PostScreen> with AutomaticKeepAliveClientMixin {
  static const String kFileName = 'mySkipIDs.csv';
  File _filePath;
  bool _fileExists = false;

  Map<String, dynamic> data;
  List newsPost = [];
  String lastpublished = "";
  int updateCount = 0;
  String baseURL = "http://gitouhon-juku-k8s2.ga";

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _getInitPost();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          updateCount = 0;
          await _getInitPost();
        },
        child: ListView.builder(
          physics: AlwaysScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            if (index == newsPost.length) {
              updateCount++;
              _getPost(updateCount);
              return new Center(
                child: new Container(
                  margin: const EdgeInsets.only(top: 8.0),
                  width: 32.0,
                  height: 32.0,
                  child: const CircularProgressIndicator(),
                ),
              );
            } else if (index > newsPost.length) {
              return null;
            }
            return NewsCard(
              "${newsPost[index]["_id"]}",
              "${newsPost[index]["image"]}",
              "${newsPost[index]["publishedAt"]}",
              "${newsPost[index]["siteID"]}",
              "${newsPost[index]["sitetitle"]}",
              "${newsPost[index]["titles"]}",
              "${newsPost[index]["url"]}",
            );
          },
        ),
      ),
    );
  }

  // https://qiita.com/kenichiro-yamato/items/12d7199cb2d7812ac0ce
  Future _getInitPost() async {
    _filePath = await _localFile;
    _fileExists = await _filePath.exists();
    var _skipIDs = "";
    if (_fileExists) {
      _skipIDs = await _filePath.readAsString();
    }
    var getPostURL = baseURL + "/mongo/get" + "?skipIDs=" + _skipIDs;
    http.Response response = await http.get(getPostURL);
    data = json.decode(response.body);
    if (mounted) {
      setState(() {
        newsPost = data["data"];
        lastpublished = data["lastpublished"];
        // print("lastpublished: " + lastpublished);
      });
    }
  }

  Future _getPost(int updateCount) async {
    int fromPostNum = 15 * updateCount;
    _filePath = await _localFile;
    _fileExists = await _filePath.exists();
    var _skipIDs = "";
    if (_fileExists) {
      _skipIDs = await _filePath.readAsString();
    }
    var getPostURL = baseURL + "/mongo/get?lastpublished=" + lastpublished + "&skipIDs=" + _skipIDs;
    http.Response response = await http.get(getPostURL);
    data = json.decode(response.body);
    if (mounted) {
      setState(() {
        newsPost.addAll(data["data"]);
        lastpublished = data["lastpublished"];
        // print("lastpublished: " + lastpublished);
      });
    }
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/$kFileName');
  }
}
