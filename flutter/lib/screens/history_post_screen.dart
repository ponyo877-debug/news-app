import 'package:flutter/material.dart';
import 'news_card.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class HistoryPostScreen extends StatefulWidget {
  HistoryPostScreen();

  @override
  _HistoryPostScreen createState() => _HistoryPostScreen();
}

// https://gist.github.com/tomasbaran/f6726922bfa59ffcf07fa8c1663f2efc
class _HistoryPostScreen extends State<HistoryPostScreen>
    with AutomaticKeepAliveClientMixin {
  Map<String, dynamic> data;
  List newsPost = [];
  String baseURL = "http://gitouhon-juku-k8s2.ga";
  static const String kFileName = 'myJsonFile.json';
  bool _fileExists = false;
  File _filePath;
  List _json = [];
  String _jsonString;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _readJson();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await _readJson();
        },
        child: ListView.builder(
          physics: AlwaysScrollableScrollPhysics(),
          itemCount: _json == null ? 0 : _json.length,
          itemBuilder: (BuildContext context, int index) {
            print(_json);
            print(_json.length);
            var revercedindex = _json.length - index - 1;
            return NewsCard(
              "${_json[revercedindex]["name"]}",
              "${_json[revercedindex]["publishedAt"]}",
              "${_json[revercedindex]["sitetitle"]}",
              "${_json[revercedindex]["image"]}",
              "${_json[revercedindex]["url"]}",
              "${_json[revercedindex]["id"]}",
            );
          },
        ),
      ),
    );
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/$kFileName');
  }

  Future _readJson() async {
    _filePath = await _localFile;
    _fileExists = await _filePath.exists();
    if (_fileExists) {
      _jsonString = await _filePath.readAsString();
      if (mounted) {
        setState(() {
          _json = json.decode(_jsonString);
        });
      }
      // print('2.(_readJson) _json: ${_json.last} \n - \n');
      // print('2.(_readJson) _json: ${_json} \n - \n');
    }
  }
}
