import 'db_provider.dart';

class Repository{
  Future<List<Task>> getAllTasks() => DBProvider.db.getAllTasks();
}

final repo = Repository();

