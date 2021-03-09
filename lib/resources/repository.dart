import 'db_provider.dart';
import 'shared_prefs_provider.dart';

class Repository {
  Future<List<Project>> getAllProjects() => DBProvider.db.getAllProjects();

  Future updateProject(Project project) => DBProvider.db.updateProject(project);

  Future addProject(Project project) => DBProvider.db.addProject(project);

  Future deleteProject(Project project) => DBProvider.db.deleteProject(project);

  Future<Project> getMyKanban() => sharedPrefsProvider.getMyKanban();

  void setMyKanban(Project project) => sharedPrefsProvider.setMyKanban(project);
}

final repo = Repository();
