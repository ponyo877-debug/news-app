import 'package:flutter/material.dart';
import 'webview.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';
import 'package:hive/hive.dart';
import 'models/history_model.dart';

class NewsCard extends StatefulWidget {
  String _id;
  String image;
  String publishedAt;
  String siteID;
  String sitetitle;
  String titles;
  String url;
  bool colorChange = true;
  static const String placeholderImg = 'assets/images/no_image_square.jpg';

  NewsCard(
      this._id, this.image, this.publishedAt, this.siteID, this.sitetitle, this.titles, this.url);

  @override
  _NewsCard createState() => _NewsCard();
}

class _NewsCard extends State<NewsCard>{

  Future _addHistory(HistoryModel historyModel) async {
    final historyBox = await Hive.openBox<HistoryModel>('history');
    historyBox.add(historyModel);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          new Container(
            child: ListTile(
              leading: thumbnail(widget.image),
              title: title(widget.titles, widget.colorChange?Colors.white:Colors.grey),
              subtitle: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    subtitle(widget.publishedAt, widget.colorChange?Colors.white:Colors.grey),
                    subtitle(widget.sitetitle, widget.colorChange?Colors.red[200]:Colors.grey),
                  ]),
              onTap: () {
                final newHistory = HistoryModel
                  (widget._id, widget.image, widget.publishedAt, widget.siteID, widget.sitetitle, widget.titles, widget.url); // int.parse(_age));
                _addHistory(newHistory);
                _incrViewCount(widget._id);
                setState(() => widget.colorChange = false);
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => MatomeWebView(
                      title: widget.titles,
                      selectedUrl: widget.url,
                    )));
              },
            ),
          ),
        ],
      ),
    );
  }

  title(title, color) {
    return Text(
      title,
      style: TextStyle(fontSize: 15.0, color: color, fontWeight: FontWeight.w500),
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
  NewsRankingCard(String _id, String image, String publishedAt, String siteID, String sitetitle, String titles, String url)
      : super(_id, image, publishedAt, siteID, sitetitle, titles, url);

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
