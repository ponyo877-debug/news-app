import 'package:flutter/material.dart';
import 'news_card.dart';
import 'dart:async';
import 'package:hive/hive.dart';
import 'models/history_model.dart';

class HistoryPostScreen extends StatefulWidget {
  HistoryPostScreen();

  @override
  _HistoryPostScreen createState() => _HistoryPostScreen();
}

// https://gist.github.com/tomasbaran/f6726922bfa59ffcf07fa8c1663f2efc
class _HistoryPostScreen extends State<HistoryPostScreen>
    with AutomaticKeepAliveClientMixin {
  String baseURL = "http://gitouhon-juku-k8s2.ga";
  List<HistoryModel> historyItems = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _getHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await _getHistory();
        },
        child: ListView.builder(
          physics: AlwaysScrollableScrollPhysics(),
          itemCount: historyItems == null ? 0 : historyItems.length,
          itemBuilder: (BuildContext context, int index) {
            var rindex = historyItems.length - index - 1;
            return NewsCard(
              "${historyItems[rindex].id}", // "_id" is not available, so use "id"
              "${historyItems[rindex].image}",
              "${historyItems[rindex].publishedAt}",
              "${historyItems[rindex].siteID}",
              "${historyItems[rindex].sitetitle}",
              "${historyItems[rindex].titles}",
              "${historyItems[rindex].url}",
            );
          },
        ),
      ),
    );
  }

  Future _getHistory() async {
    final historyBox = await Hive.openBox<HistoryModel>('history');
    if (mounted) {
      setState(() {
        historyItems = historyBox.values.toList();
      });
    }
  }
}
