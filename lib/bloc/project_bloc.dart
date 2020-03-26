import 'package:kanban/resources/db_provider.dart';
import 'package:kanban/resources/shared_prefs_provider.dart';
import 'package:rxdart/rxdart.dart';

import 'package:kanban/resources/repository.dart';
import 'package:kanban/models/project.dart';

class ProjectBloc {
  final _projectsFetcher = BehaviorSubject<List<Project>>();
  final _currentProjectFetcher = BehaviorSubject<Project>();
  final _kanbanFetcher = BehaviorSubject<Project>();

  bool _isKanban = false;

  Stream<List<Project>> get allProjects => _projectsFetcher.stream;
  Stream<Project> get currentProject => _currentProjectFetcher.stream;
  Stream<Project> get kanban => _kanbanFetcher.stream;

  List<Project> _allProjects = [];
  Project _currentProject;
  Project _kanban;

  List<Project> get allProjectList => _allProjects;
  Project get currentProjectInstance => _currentProject;

  void fetchAllProjects() async {
    var allProjects = await repo.getAllProjects();
    var kanban = await repo.getMyKanban();

    print(kanban);

    _kanban = kanban;
    _allProjects = allProjects;
    _currentProject = _kanban;

    _isKanban = true;
    _projectsFetcher.sink.add(_allProjects);
    _currentProjectFetcher.sink.add(_currentProject);
  }

  void addProject(Project project) {
    _allProjects.add(project);
    _projectsFetcher.sink.add(_allProjects);
  }

  void getKanban() {
    _currentProject = _kanban;
    _currentProjectFetcher.sink.add(_currentProject);
    _isKanban = true;
  }

  void getProjectById(String uid) {
    _currentProject = _allProjects.singleWhere((p) => p.uid == uid, orElse: null);
    if (_currentProject != null) {
      _isKanban = false;
    }
    _currentProjectFetcher.sink.add(_currentProject);
  }

  void createProject(String name) {
    _currentProject = Project.create(name: name);
    repo.addProject(_currentProject);
    _allProjects.add(_currentProject);
    _currentProjectFetcher.sink.add(_currentProject);
    _projectsFetcher.sink.add(_allProjects);
  }

  void deleteProject(Project project) {
    _allProjects.remove(project);
    _projectsFetcher.sink.add(_allProjects);
    if(_currentProject == project){
      _currentProject = _allProjects.last;
    }
    _currentProjectFetcher.sink.add(_currentProject);
    repo.deleteProject(project);
  }

  void updateProject(Project project) {
    if (_isKanban) {
      _kanban = project;
      _currentProject = _kanban;
      repo.setMyKanban(project);
    } else {
      repo.updateProject(project);
      _projectsFetcher.sink.add(_allProjects);
    }
  }

  void addTask(Task task) {
    _currentProject.tasks.add(task);
    _currentProjectFetcher.sink.add(_currentProject);

    if (_isKanban) {
      repo.setMyKanban(_currentProject);
    } else {
      repo.updateProject(_currentProject);
    }
  }

  void removeTask(Task task) {
    _currentProject.tasks.remove(task);
    _currentProjectFetcher.sink.add(_currentProject);

    if (_isKanban) {
      repo.setMyKanban(_currentProject);
    } else {
      repo.updateProject(_currentProject);
    }
  }

  void updateCurrent() {
    _currentProjectFetcher.sink.add(_currentProject);

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
  }
}

final projectBloc = ProjectBloc();
