import 'package:flutter/material.dart';
import 'post_screen.dart';
import 'ranking_post_screen.dart';
import 'search_post_screen.dart';
import 'history_post_screen.dart';
import 'setting_screen.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';


class NewsListScreen extends StatefulWidget {
  @override
  _NewsListScreenState createState() => _NewsListScreenState();
}

class TabInfo {
  IconData icon;
  String title;
  Widget widget;
  TabInfo(this.icon, this.title, this.widget);
}

class _NewsListScreenState extends State<NewsListScreen>{
    //with TickerProviderStateMixin {
  //TabController _tabController;
  Map<String, dynamic> data;

  final List<TabInfo> _tabs = [
    TabInfo(Icons.format_list_numbered, 'Ranking', RankingPostScreen()),
    TabInfo(Icons.search, 'Search', SearchPostScreen()),
    TabInfo(Icons.home, 'Home', PostScreen()),
    TabInfo(Icons.history, 'History', HistoryPostScreen()),
    TabInfo(Icons.settings, 'Setting', SettingScreen()),
  ];

  @override
  void initState() {
    super.initState();
    //_tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    //_tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      initialIndex: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("まとめくん"),
          centerTitle: true,
          //backgroundColor: Colors.blueGrey,
        ),
        bottomNavigationBar: SafeArea(
          child: ConvexAppBar(
            style: TabStyle.reactCircle,
            backgroundColor: Colors.blueGrey,
            color: Colors.white,
            //activeColor: Colors.blue,
            items: <TabItem>[
              for (final entry in _tabs)
                TabItem(icon: entry.icon, title: entry.title),
            ],
            //initialActiveIndex: 2,
            //onTap: (int i) => print('click index=$i'),
          ),
        ),
        body: TabBarView(
          // physics: NeverScrollableScrollPhysics(),
          //controller: _tabController,
          children: _tabs.map((tab) => tab.widget).toList(),
        )),
    );
  }
}
