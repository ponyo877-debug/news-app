import 'package:flutter/material.dart';
import 'post_screen.dart';
import 'ranking_post_screen.dart';
import 'search_post_screen.dart';
import 'history_post_screen.dart';
import 'setting_screen.dart';

class NewsListScreen extends StatefulWidget {
  @override
  _NewsListScreenState createState() => _NewsListScreenState();
}

class TabInfo {
  Widget icon;
  String title;
  Widget widget;
  TabInfo(this.icon, this.title, this.widget);
}

class _NewsListScreenState extends State<NewsListScreen>
    with TickerProviderStateMixin {
  TabController _tabController;
  Map<String, dynamic> data;

  final List<TabInfo> _tabs = [
    TabInfo(Icon(Icons.my_location), 'LATEST', PostScreen()),
    TabInfo(Icon(Icons.my_location), 'RANKING', RankingPostScreen()),
    TabInfo(Icon(Icons.my_location), 'SEARCH', SearchPostScreen()),
    TabInfo(Icon(Icons.my_location), 'HISTORY', HistoryPostScreen()),
    TabInfo(Icon(Icons.my_location), 'SETTING', SettingScreen()),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("まとめくん"),
          centerTitle: true,
        ),
        bottomNavigationBar: SafeArea(
          child: TabBar(
            labelStyle: TextStyle(fontSize: 10.5),
            tabs: _tabs.map((TabInfo tab) {
              return Tab(icon: tab.icon, text: tab.title);
            }).toList(),
            controller: _tabController,
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(color: Colors.redAccent, width: 5),
              insets: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 70),
            ),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorWeight: 2,
            indicatorPadding:
                EdgeInsets.symmetric(horizontal: 18.0, vertical: 8),
            labelColor: Colors.black,
          ),
        ),
        body: TabBarView(
          // physics: NeverScrollableScrollPhysics(),
          controller: _tabController,
          children: _tabs.map((tab) => tab.widget).toList(),
        ));
  }
}
