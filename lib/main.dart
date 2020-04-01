import 'package:flutter/material.dart';
import 'package:kanban/resources/db_provider.dart';

import 'ui/home_page.dart';
import 'bloc/task_bloc.dart';

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
        textTheme: TextTheme(body1: TextStyle(color: Colors.white), body2: TextStyle(color: Colors.white))
      ),
      debugShowCheckedModeBanner: false,
      title: 'Kanban',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        canvasColor: Colors.transparent
      ),
      routes: {"/home_page": (_) => HomePageWrapper()},
      home: HomePageWrapper(),
    );
  }
}
