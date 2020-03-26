import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:kanban/models/project.dart';

const String kanbanKey = "kanbanKey";

class SharedPrefsProvider {
  Future<SharedPreferences> get sharedPreferences async {
    if (_sharedPreferences == null) {
      _sharedPreferences = await SharedPreferences.getInstance();

      if (_sharedPreferences.containsKey(kanbanKey) == false) {
        var project = Project.create(name: "My Kanban");
        project.tasks.add(Task.create(title: "My first item"));

        var json = jsonEncode(project.toMap());

        _sharedPreferences.setString(kanbanKey, json);
      }
    }
    return _sharedPreferences;
  }

  SharedPreferences _sharedPreferences;

  Future<Project> getMyKanban() async {
    var prefs = await sharedPreferences;
    var json = prefs.getString(kanbanKey);
    var project = Project.fromMap(jsonDecode(json));


    return project;
  }

  void setMyKanban(Project project) async {
    var prefs = await sharedPreferences;
    var json = jsonEncode(project.toMap());
    prefs.setString(kanbanKey, json);
  }
}

final sharedPrefsProvider = SharedPrefsProvider();
