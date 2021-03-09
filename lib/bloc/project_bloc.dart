import 'package:kanban/resources/db_provider.dart';
import 'package:rxdart/rxdart.dart';

import 'package:kanban/resources/repository.dart';
import 'package:kanban/models/project.dart';

class ProjectBloc {
  final _projectsFetcher = BehaviorSubject<List<Project>>();
  final _currentProjectFetcher = BehaviorSubject<Project>();
  final _kanbanFetcher = BehaviorSubject<Project>();
  final _isKanbanFetcher = BehaviorSubject<bool>();
  final _todoFetcher = BehaviorSubject<List<Task>>();
  final _doingFetcher = BehaviorSubject<List<Task>>();
  final _doneFetcher = BehaviorSubject<List<Task>>();

  bool _isKanban = false;

  Stream<List<Project>> get allProjects => _projectsFetcher.stream;
  Stream<Project> get currentProject => _currentProjectFetcher.stream;
  Stream<Project> get kanban => _kanbanFetcher.stream;
  Stream<bool> get isKanban => _isKanbanFetcher.stream;

  Stream<List<Task>> get allTodo => _todoFetcher.stream;
  Stream<List<Task>> get allDoing => _doingFetcher.stream;
  Stream<List<Task>> get allDone => _doneFetcher.stream;

  List<Project> _allProjects = [];
  Project _currentProject;
  Project _kanban;

  List<Project> get allProjectList => _allProjects;
  Project get currentProjectInstance => _currentProject;

  void fetchAllProjects() async {
    var allProjects = await repo.getAllProjects();
    var kanban = await repo.getMyKanban();

    _kanban = kanban;
    _allProjects = allProjects;
    _currentProject = _kanban;

    _isKanban = true;
    _isKanbanFetcher.sink.add(_isKanban);
    _projectsFetcher.sink.add(_allProjects);
    _currentProjectFetcher.sink.add(_currentProject);
    _todoFetcher.add(_currentProject.tasks.where((t) => t.status == TaskStatus.todo).toList());
    _doingFetcher.add(_currentProject.tasks.where((t) => t.status == TaskStatus.doing).toList());
    _doneFetcher.add(_currentProject.tasks.where((t) => t.status == TaskStatus.done).toList());
  }

  void addProject(Project project) {
    _allProjects.add(project);
    _projectsFetcher.sink.add(_allProjects);
  }

  void getKanban() {
    _currentProject = _kanban;
    _currentProjectFetcher.sink.add(_currentProject);
    _isKanban = true;
    _isKanbanFetcher.sink.add(_isKanban);
    _todoFetcher.add(_currentProject.tasks.where((t) => t.status == TaskStatus.todo).toList());
    _doingFetcher.add(_currentProject.tasks.where((t) => t.status == TaskStatus.doing).toList());
    _doneFetcher.add(_currentProject.tasks.where((t) => t.status == TaskStatus.done).toList());
  }

  void getProjectById(String uid) {
    _currentProject = _allProjects.singleWhere((p) => p.uid == uid, orElse: null);
    if (_currentProject != null) {
      _isKanban = false;
      _isKanbanFetcher.sink.add(_isKanban);
    } else {
      _isKanban = true;
      _isKanbanFetcher.sink.add(_isKanban);
    }
    _currentProjectFetcher.sink.add(_currentProject);
    _todoFetcher.add(_currentProject.tasks.where((t) => t.status == TaskStatus.todo).toList());
    _doingFetcher.add(_currentProject.tasks.where((t) => t.status == TaskStatus.doing).toList());
    _doneFetcher.add(_currentProject.tasks.where((t) => t.status == TaskStatus.done).toList());
  }

  String createProject(String name) {
    var project = Project.create(name: name);
    repo.addProject(project);
    _allProjects.add(project);
    return project.uid;
  }

  void deleteProject(Project project) {
    _allProjects.remove(project);
    _projectsFetcher.sink.add(_allProjects);
    if (_currentProject == project) {
      if (_allProjects.isNotEmpty)
        _currentProject = _allProjects.last;
      else
        _currentProject = _kanban;
    }
    _currentProjectFetcher.sink.add(_currentProject);
    repo.deleteProject(project);
  }

  void updateIcon(Project project, String iconString) {
    project.icon = iconString;
    repo.updateProject(project);
    _currentProjectFetcher.sink.add(_currentProject);
    _projectsFetcher.sink.add(_allProjects);
  }

  void updateProject(Project project) {
    print("upate the project the name now is ${project.name}");
    repo.updateProject(project);
    _projectsFetcher.sink.add(_allProjects);
    if (project.uid == currentProjectInstance.uid) _currentProjectFetcher.sink.add(project);
  }

  void changeNameById(String name, String uid) {
    assert(_isKanban == false);
    _allProjects.singleWhere((p) => p.uid == uid, orElse: null)?.name = name;
    _projectsFetcher.sink.add(_allProjects);
  }

  void addTask(Task task) {
    _currentProject.tasks.add(task);
    _currentProjectFetcher.sink.add(_currentProject);
    _todoFetcher.add(_currentProject.tasks.where((t) => t.status == TaskStatus.todo).toList());

    if (_isKanban) {
      repo.setMyKanban(_currentProject);
    } else {
      repo.updateProject(_currentProject);
    }
  }

  void removeTask(Task task) {
    _currentProject.tasks.remove(task);
    _currentProjectFetcher.sink.add(_currentProject);
    _todoFetcher.add(_currentProject.tasks.where((t) => t.status == TaskStatus.todo).toList());
    _doingFetcher.add(_currentProject.tasks.where((t) => t.status == TaskStatus.doing).toList());
    _doneFetcher.add(_currentProject.tasks.where((t) => t.status == TaskStatus.done).toList());

    if (_isKanban) {
      repo.setMyKanban(_currentProject);
    } else {
      repo.updateProject(_currentProject);
    }
  }

  void removeAllTasks() {
    _currentProject.tasks.clear();
    _currentProjectFetcher.sink.add(_currentProject);
    _todoFetcher.drain();
    _doingFetcher.drain();
    _doneFetcher.drain();

    if (_isKanban) {
      repo.setMyKanban(_currentProject);
    } else {
      repo.updateProject(_currentProject);
    }
  }

  void updateTaskStatus(Task task){
    print("id is ${task.id}");
    print(_currentProject.tasks.where((t) => t.uid == task.uid));
    var t = _currentProject.tasks.singleWhere((t) => t.uid == task.uid, orElse: ()=>null);
    switch(task.status){
      case TaskStatus.todo:
        t.status = TaskStatus.doing;
        break;
      case TaskStatus.doing:
        t.status = TaskStatus.done;
        break;
      case TaskStatus.done:
        break;
      default:
        break;
    }

    _currentProject.tasks.remove(task);
    _currentProject.tasks.add(t);

    if (_isKanban) {
      repo.setMyKanban(_currentProject);
    } else {
      repo.updateProject(_currentProject);
    }
    _currentProjectFetcher.sink.add(_currentProject);
    _todoFetcher.add(_currentProject.tasks.where((t) => t.status == TaskStatus.todo).toList());
    _doingFetcher.add(_currentProject.tasks.where((t) => t.status == TaskStatus.doing).toList());
    _doneFetcher.add(_currentProject.tasks.where((t) => t.status == TaskStatus.done).toList());
  }

  void updateCurrent() {
    _currentProjectFetcher.sink.add(_currentProject);
    _todoFetcher.add(_currentProject.tasks.where((t) => t.status == TaskStatus.todo).toList());
    _doingFetcher.add(_currentProject.tasks.where((t) => t.status == TaskStatus.doing).toList());
    _doneFetcher.add(_currentProject.tasks.where((t) => t.status == TaskStatus.done).toList());

    if (_isKanban) {
      repo.setMyKanban(_currentProject);
    } else {
      repo.updateProject(_currentProject);
    }
  }

  void dispose() {
    _projectsFetcher.close();
    _currentProjectFetcher.close();
    _kanbanFetcher.close();
    _isKanbanFetcher.close();
  }
}

final projectBloc = ProjectBloc();
