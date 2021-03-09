import 'package:flutter/material.dart';

import 'ui/home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    //DBProvider.db.initDatabase();
    return MaterialApp(
      darkTheme: ThemeData(
          canvasColor: Colors.transparent,
          textTheme: TextTheme(bodyText2: TextStyle(color: Colors.white), bodyText1: TextStyle(color: Colors.white))),
      debugShowCheckedModeBanner: false,
      title: 'Kanban',
      theme: ThemeData(primarySwatch: Colors.blue, canvasColor: Colors.transparent),
      routes: {"/home_page": (_) => HomePage()},
      home: HomePage(),
    );
  }
}
