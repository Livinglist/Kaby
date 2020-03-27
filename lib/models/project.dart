import 'dart:convert';

import 'package:uuid/uuid.dart';

import 'task.dart';

export 'task.dart';

const String projectNameKey = "name";
const String projectTasksKey = "tasks";
const String uidKey = "uuid";
const String iconKey = "icon";

class Project {
  int id;
  String uid;
  String name;
  String icon;
  List<Task> tasks = [];

  Project({this.tasks, this.name});

  Project.create({this.name, this.icon = "list"}) : uid = Uuid().v1();

  Project.fromMap(Map<String, dynamic> map) {
    id = map[idKey];
    uid = map[uidKey];
    icon = map[iconKey];
    name = map[projectNameKey];
    tasks = (jsonDecode(map[projectTasksKey]) as List).map((taskString) => Task.fromMap(jsonDecode(taskString))).toList();
  }

  Map<String, dynamic> toMap() =>
      {idKey: id, uidKey: uid, iconKey: icon, projectNameKey: name, projectTasksKey: jsonEncode(tasks.map((t) => jsonEncode(t.toMap())).toList())};

  @override
  String toString() {
    return "Project:\n\ttitle:$name\n\t${tasks.map((t) => t.toString()).toList()}";
  }
}
