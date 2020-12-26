import 'package:flutter/material.dart';
import 'webview.dart';

class SettingScreen extends StatelessWidget {
  // final String contactURL = "https://forms.gle/PBs2r2YBbzzdQZd29";
  final String contactURL =
      "https://docs.google.com/forms/d/e/1FAIpQLSd-fuupDifDoJQ1uTkdyUCgzEiNvfUzdJe0YOhPfdSC3U2Erw/viewform?usp=sf_link";
  final String PPURL = "http://gitouhon-juku-k8s2.ga/privacy_policy/";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "SETTING",
      home: Scaffold(
        body: ListView(
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.my_location),
              title: Text(
                'CONTACT',
              ),
              trailing: Icon(Icons.keyboard_arrow_right),
              onTap: () {
                print(contactURL);
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => MatomeWebView(
                          title: "CONTACT",
                          selectedUrl: contactURL,
                        )));
              },
            ),
            ListTile(
              leading: Icon(Icons.my_location),
              title: Text(
                'PRIVACY POLICY',
              ),
              trailing: Icon(Icons.keyboard_arrow_right),
              onTap: () {
                print(PPURL);
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => MatomeWebView(
                          title: "PRIVACY POLICY",
                          selectedUrl: PPURL,
                        )));
              },
            ),
          ],
        ),
      ),
    );
  }
}
