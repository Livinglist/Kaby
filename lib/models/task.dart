import 'package:uuid/uuid.dart';

const String idKey = "id";
const String uidKey = "uid";
const String titleKey = "title";
const String descriptionKey = "description";
const String createdDateKey = "createdDate";
const String finishedDateKey = "finishedDate";
const String dueDateKey = "dueDate";
const String statusKey = "status";

enum TaskStatus { todo, doing, done, aborted }

class Task extends Comparable{
  ///Used for SQLite.
  int id;

  String uid;

  String title;
  String description;

  ///Stored in UTC format.
  final DateTime createdDate;

  ///Stored in UTC format.
  DateTime finishedDate;

  ///Stored in UTC format.
  DateTime dueDate;
  TaskStatus status = TaskStatus.todo;

  bool get isDone => status == TaskStatus.done;
  bool get isDoing => status == TaskStatus.doing;
  bool get isTodo => status == TaskStatus.todo;

  Task({this.title, this.description, this.createdDate, this.finishedDate, this.dueDate, this.status});

  Task.create({this.title, this.description, DateTime dueDate})
      : this.dueDate = dueDate?.toUtc() ?? null,
        this.createdDate = DateTime.now().toUtc(), this.uid = Uuid().v1();

  Task.fromMap(Map map) : this.createdDate = map[createdDateKey] == "null" ? null : DateTime.parse(map[createdDateKey]) {
    this.id = map[idKey];
    this.uid = map[uidKey];
    this.title = map[titleKey];
    this.description = map[descriptionKey];
    this.finishedDate = map[finishedDateKey] == "null" ? null : DateTime.parse(map[finishedDateKey]);
    this.dueDate = map[dueDateKey] == "null" ? null : DateTime.parse(map[dueDateKey]);
    this.status = TaskStatus.values.elementAt(map[statusKey]);
    print("from map in task");
  }

  Map toMap() => {
        idKey: this.id,
        uidKey: this.uid,
        titleKey: this.title,
        descriptionKey: this.description,
        createdDateKey: this.createdDate.toString(),
        finishedDateKey: this.finishedDate.toString(),
        dueDateKey: this.dueDate.toString(),
        statusKey: this.status.index
      };

  @override
  String toString() {
    return "Task: $status, $title";
  }

  @override
  int compareTo(other) {
    if(this.uid == other.uid) return 0;
    return 1;
  }
}
