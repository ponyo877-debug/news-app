import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

// import 'contact_page.dart';
import 'screens/models/history_model.dart';
import 'screens/news_list_screen.dart';

// void main() => runApp(MyApp());

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDirectory = await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDirectory.path);
  Hive.registerAdapter(HistoryModelAdapter());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "まとめくん",
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: NewsListScreen(),
    );
  }
}
