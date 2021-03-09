import 'package:rxdart/rxdart.dart';

import 'package:kanban/models/task.dart';

class TaskBloc {
  final _tasksFetcher = BehaviorSubject<List<Task>>();

  Stream<List<Task>> get allTasks => _tasksFetcher.stream;

  List<Task> _allTasks = [];

  List<Task> get allTaskList => _allTasks;

  void fetchAllTasks() async {
    //_allTasks = await repo.getAllTasks();
    _allTasks.addAll([
      Task.create(title: "my first item", description: "debug"),
      Task.create(title: "my second item", description: "debug"),
      Task(title: "Title", status: TaskStatus.doing),
      Task(title: "done", status: TaskStatus.done)
    ]);
    _tasksFetcher.sink.add(_allTasks);
  }

  void addTask(Task task) {
    _allTasks.add(task);
    _tasksFetcher.sink.add(_allTasks);
  }

  void deleteTask(Task task) {
    _allTasks.remove(task);
    _tasksFetcher.sink.add(_allTasks);
  }

  void updateTask(Task task) {}

  void dispose() {
    _tasksFetcher.close();
  }
}

final taskBloc = TaskBloc();
