import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todoapp_live/task.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._instance();
  static Database? _db;

  DatabaseHelper._instance();

  String taskTable = 'task_table';
  String colId = 'id';
  String colTitle = 'title';
  String colDate = 'date';
  String colPriority = 'priority';
  String colStatus = 'status';

  // Task tables
  //  Id  |  Title | Date | Priority | Status
  //  0     vfddf     High
  //  1

  Future<Database?> get db async => _db ??= await _initDb();

  Future<Database> _initDb() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = dir.path + 'todo_list.db';
    final todoListDb =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return todoListDb;
  }

  void _createDb(Database db, int version) async {
    await db.execute('CREATE TABLE $taskTable('
        '$colId INTEGER PRIMARY KEY AUTOINCREMENT, '
        '$colTitle TEXT, '
        '$colDate TEXT, '
        '$colPriority TEXT,'
        '$colStatus INTEGER)');
  }

  Future<List<Map<String, dynamic>>?> getTaskMapList(
      bool orderByDate, bool filterByStatus) async {
    Database? db = await this.db;
    dynamic query = await db?.query(taskTable);

    if (orderByDate && filterByStatus)
      query = await db?.query(taskTable,
          orderBy: '$colDate ASC', where: '$colStatus = 1');
    else if (orderByDate)
      query = await db?.query(taskTable, orderBy: '$colDate ASC');
    else if (filterByStatus)
      query = await db?.query(taskTable, where: '$colStatus = 1');
    else
      query = await db?.query(taskTable);

    final List<Map<String, Object?>>? result = query;
    return result;
  }

  Future<List<Task>> getTaskList(bool orderByDate, bool filterByStatus) async {
    final List<Map<String, dynamic>>? taskMapList =
        await getTaskMapList(orderByDate, filterByStatus);
    final List<Task> taskList = [];
    taskMapList?.forEach((taskMap) {
      taskList.add(Task.fromMap(taskMap));
    });
    return taskList;
  }

  Future<int?> insertTask(Task task) async {
    Database? db = await this.db;
    final int? result = await db?.insert(taskTable, task.toMap());
    return result;
  }

  Future<int?> updateTask(Task task) async {
    Database? db = await this.db;
    final int? result = await db?.update(taskTable, task.toMap(),
        where: '$colId = ?', whereArgs: [task.id]);
    return result;
  }

  Future<int?> deleteTask(int? id) async {
    Database? db = await this.db;
    final int? result = await db?.delete(
      taskTable,
      where: '$colId = ?',
      whereArgs: [id],
    );
    return result;
  }
}
