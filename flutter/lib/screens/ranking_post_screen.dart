import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'news_card.dart';
import 'dart:async';
import 'dart:convert';

class RankingPostScreen extends StatefulWidget {
  RankingPostScreen();

  @override
  _RankingPostScreen createState() => _RankingPostScreen();
}

class _RankingPostScreen extends State<RankingPostScreen>
    with AutomaticKeepAliveClientMixin {
  Map<String, dynamic> data;
  List newsPost = [];
  String baseURL = "http://gitouhon-juku-k8s2.ga";

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _getPost();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await _getPost();
        },
        child: ListView.builder(
          physics: AlwaysScrollableScrollPhysics(),
          itemCount: newsPost == null ? 0 : newsPost.length,
          itemBuilder: (BuildContext context, int index) {
            return NewsRankingCard(
              "${newsPost[index]["titles"]}",
              "${newsPost[index]["publishedAt"]}",
              "${newsPost[index]["sitetitle"]}",
              "${index + 1}",
              "${newsPost[index]["url"]}",
              "${newsPost[index]["id"]}",
            );
          },
        ),
      ),
    );
  }

  Future _getPost() async {
    var getPostURL = baseURL + "/ranking";
    http.Response response = await http.get(getPostURL);
    data = json.decode(response.body);
    if (mounted) {
      setState(() {
        newsPost = data["data"];
      });
    }
  }
}
