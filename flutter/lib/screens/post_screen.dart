import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'news_card.dart';
import 'dart:async';
import 'dart:convert';

class PostScreen extends StatefulWidget {
  PostScreen();

  @override
  _PostScreen createState() => _PostScreen();
}

// https://qiita.com/taki4227/items/e3c7e640b7986a80b2f9
// https://qiita.com/najeira/items/454462c794c35b3b600a
class _PostScreen extends State<PostScreen> with AutomaticKeepAliveClientMixin {
  Map<String, dynamic> data;
  List newsPost = [];
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
              "${newsPost[index]["title"]}",
              "${newsPost[index]["publishedAt"]}",
              "${newsPost[index]["sitetitle"]}",
              "${newsPost[index]["image"]}",
              "${newsPost[index]["url"]}",
              // "${newsPost[index]["id"]}",
              "${newsPost[index]["_id"]}",
            );
          },
        ),
      ),
    );
  }

  Future _getInitPost() async {
    var getPostURL = baseURL + "/mongo/old?from=0";
    http.Response response = await http.get(getPostURL);
    data = json.decode(response.body);
    if (mounted) {
      setState(() {
        newsPost = data["data"];
      });
    }
  }

  Future _getPost(int updateCount) async {
    int fromPostNum = 15 * updateCount;
    // var getPostURL = baseURL + "/old?from=" + fromPostNum.toString();
    var getPostURL = baseURL + "/mongo/old?from=" + fromPostNum.toString();
    debugPrint(getPostURL);
    http.Response response = await http.get(getPostURL);
    data = json.decode(response.body);
    if (mounted) {
      setState(() {
        newsPost.addAll(data["data"]);
      });
    }
  }
}
