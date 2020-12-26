import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'news_card.dart';
import 'package:flutter/material.dart';

class SearchPostScreen extends StatefulWidget {
  @override
  _SearchPostScreen createState() => _SearchPostScreen();
}

class _SearchPostScreen extends State<SearchPostScreen> {
  TextEditingController _searchController = TextEditingController();

  Map<String, dynamic> data;
  String baseURL = "http://gitouhon-juku-k8s2.ga";
  List newsPost = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    searchResultsList();
  }

  _onSearchChanged() {
    searchResultsList();
  }

  Future searchResultsList() async {
    String searchwords = _searchController.text;
    var getPostURL = baseURL + "/elastic/get?words=" + searchwords;
    debugPrint(getPostURL);
    http.Response response = await http.get(getPostURL);
    data = json.decode(response.body);
    setState(() {
      newsPost = data["data"];
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding:
                  const EdgeInsets.only(left: 30.0, right: 30.0, bottom: 30.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(prefixIcon: Icon(Icons.search)),
              ),
            ),
            Expanded(
              child: ListView.builder(
                // physics: AlwaysScrollableScrollPhysics(),
                itemCount: newsPost == null ? 0 : newsPost.length,
                itemBuilder: (BuildContext context, int index) {
                  return NewsCard(
                    "${newsPost[index]["titles"]}",
                    "${newsPost[index]["publishedAt"]}",
                    newsPost[index].containsKey('sitetitle')? "${newsPost[index]["sitetitle"]}": "NA",
                    "${newsPost[index]["image"]}",
                    "${newsPost[index]["url"]}",
                    "${newsPost[index]["id"]}",
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
