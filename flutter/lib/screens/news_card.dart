import 'package:flutter/material.dart';
import 'webview.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

class NewsCard extends StatelessWidget {
  final String _image;
  final String _name;
  final String _date;
  final String _site;
  final String _url;
  final String _id;
  static const String placeholderImg = 'assets/images/no_image_square.jpg';
  static const String kFileName = 'myJsonFile.json';

  NewsCard(
      this._name, this._date, this._site, this._image, this._url, this._id);

  bool _fileExists = false;
  File _filePath;

  // First initialization of _json (if there is no json in the file)
  // Map<String, dynamic> _json = {"data"};
  List _json = [];

  // Map<String, dynamic> _json = {};
  String _jsonString;

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/$kFileName');
  }

  void _writeJson(Map<String, dynamic> _newJson) async {
    // Initialize the local _filePath
    _filePath = await _localFile;
    var _oldJson;

    //1. Create _newJson<Map> from input<TextField>
    // print('1.(_writeJson) _newJson: $_newJson');
    _fileExists = await _filePath.exists();

    if (!_fileExists) {
      // print('create new file because of file is not found: ${_json.last}');
      _filePath.writeAsString('');
    } else {
      //2. Update _json by adding _newJson<Map> -> _json<Map>
      _jsonString = await _filePath.readAsString();
      if (_jsonString != "") {
        _oldJson = json.decode(_jsonString);
        _json = _oldJson;
      }
    }
    /*
    // _json.add(_oldJson);
    if (_oldJson.length != 0) {
      _json = _oldJson;
    } else {
      _json.add(_oldJson);
    }
     */
    // _json = json.decode(_jsonString);
    // print('2.(ここが更新されていてほしい) _json(updated): $_json');
    _json.add(_newJson);
    // print('2.(_writeJson) _json(updated): $_json');
    print('Tail of List: ${_json.last}');
    //3. Convert _json ->_jsonString
    _jsonString = json.encode(_json);
    // print('3.(_writeJson) _jsonString: $_jsonString\n - \n');

    //4. Write _jsonString to the _filePath
    _filePath.writeAsString(_jsonString);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          new Container(
            /*
            decoration: new BoxDecoration(
                // color: Colors.red
                image: DecorationImage(
                    fit: BoxFit.fill,
                    image: NetworkImage(_image)
                )
            ),
             */
            child: ListTile(
              leading: thumbnail(_image),
              title: title(_name),
              subtitle: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    subtitle(_date, Colors.white),
                    subtitle(_site, Colors.red[200]),
                  ]),
              onTap: () {
                var _newJson = {
                  "name": this._name,
                  "publishedAt": this._date,
                  "sitetitle": this._site,
                  "image": this._image,
                  "url": this._url,
                  "id": this._id,
                };
                _incrViewCount(_id);
                _writeJson(_newJson);
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => MatomeWebView(
                          title: _name,
                          selectedUrl: _url,
                        )));
              },
            ),
          ),
        ],
      ),
    );
  }

  title(title) {
    return Text(
      title,
      style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  subtitle(subTitle, color) {
    return Text(
      subTitle,
      style:
          TextStyle(fontSize: 12.5, color: color, fontWeight: FontWeight.w100),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  thumbnail(imageUrl) {
    return Padding(
      padding: EdgeInsets.only(left: 15.0),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        placeholder: (context, url) => Icon(Icons.error),
        //=> Image.asset(placeholderImg),
        errorWidget: (context, url, error) => Icon(Icons.error),
        // errorImage
        height: 50,
        width: 50,
        alignment: Alignment.center,
        fit: BoxFit.fill,
      ),
    );
  }

  Future _incrViewCount(String id) async {
    var _incrViewCountURL = "http://gitouhon-juku-k8s2.ga/redis/put/";
    await http.get(_incrViewCountURL + id);
  }
}

class NewsRankingCard extends NewsCard {
  NewsRankingCard(String _name, String _date, String _site, String _image,
      String _url, String _id)
      : super(_name, _date, _site, _image, _url, _id);

  @override
  thumbnail(title) {
    return Text(
      title,
      style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.w500),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}
