import 'package:flutter/material.dart';
import 'webview.dart';
import 'select_sites.dart';

class SettingInfo {
  IconData icon;
  String title;
  Widget widget;
  SettingInfo(this.icon, this.title, this.widget);
}

class SettingScreen extends StatelessWidget {
  SettingScreen._internal();
  String _contactURL;
  String _PPURL;
  List<SettingInfo> _settingTabs;

  factory SettingScreen() {
    SettingScreen _settingScreen = SettingScreen._internal();
    _settingScreen._contactURL =
        "https://docs.google.com/forms/d/e/1FAIpQLSd-fuupDifDoJQ1uTkdyUCgzEiNvfUzdJe0YOhPfdSC3U2Erw/viewform?usp=sf_link";
    _settingScreen._PPURL = "http://gitouhon-juku-k8s2.ga/privacy_policy/";

    _settingScreen._settingTabs = [
      SettingInfo(Icons.select_all, 'Select Site', SelectSites()),
      SettingInfo(
          Icons.email_outlined,
          'Contact Us',
          MatomeWebView(
            title: "Contact Us",
            selectedUrl: _settingScreen._contactURL,
          )),
      SettingInfo(
          Icons.privacy_tip_outlined,
          'Privacy Policy',
          MatomeWebView(
            title: "Privacy Policy",
            selectedUrl: _settingScreen._PPURL,
          )),
    ];
    return _settingScreen;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.separated(
        itemCount: _settingTabs.length,
        separatorBuilder: (BuildContext context, int index) =>
            Divider(color: Colors.white),
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            leading: Icon(_settingTabs[index].icon),
            title: Text(
              _settingTabs[index].title,
              style: TextStyle(fontSize: 20),
            ),
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: () async {
              await Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => _settingTabs[index].widget));
            },
          );
        },
      ),
    );
  }
}
