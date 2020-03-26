const String idKey = "id";
const String titleKey = "title";
const String descriptionKey = "description";
const String createdDateKey = "createdDate";
const String finishedDateKey = "finishedDate";
const String dueDateKey = "dueDate";
const String statusKey = "status";

enum TaskStatus { todo, doing, done, aborted }

class Task {
  ///Used for SQLite.
  int id;

  String title;
  String description;

  ///Stored in UTC format.
  final DateTime createdDate;

  ///Stored in UTC format.
  DateTime finishedDate;

  ///Stored in UTC format.
  DateTime dueDate;
  TaskStatus status = TaskStatus.todo;

  Task({this.title, this.description, this.createdDate, this.finishedDate, this.dueDate, this.status});

  Task.create({this.title, this.description, this.dueDate}) : this.createdDate = DateTime.now().toUtc();

  Task.fromMap(Map map) : this.createdDate = map[createdDateKey] == "null" ? null : DateTime.parse(map[createdDateKey]) {
    this.id = map[idKey];
    this.title = map[titleKey];
    this.description = map[descriptionKey];
    this.finishedDate = map[finishedDateKey] == "null" ? null : DateTime.parse(map[finishedDateKey]);
    this.dueDate = map[dueDateKey] == "null" ? null : DateTime.parse(map[dueDateKey]);
    this.status = TaskStatus.values.elementAt(map[statusKey]);
    print("from map in task");
  }

  Map toMap() => {
        idKey: this.id,
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
}
