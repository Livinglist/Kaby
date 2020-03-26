import 'package:flutter/material.dart';

import 'ui/home_page.dart';
import 'bloc/task_bloc.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kanban',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {"/home_page": (_) => HomePageWrapper()},
      home: HomePageWrapper(),
    );
  }
}
