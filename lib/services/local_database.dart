import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static final _dbname = 'jingaDatabase';
  static final _dbversion = 1;
  static final _columnId = '_id';
  static final settingsTb = 'userSettings';
  static final dataTb = 'userData';
  static final colName = 'name';
  static final colValue = 'value';
  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initiateDatabase();
    return _database;
  }

  _initiateDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, _dbname);
    return await openDatabase(path, version: _dbversion, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) {
    db.execute('''
      CREATE TABLE $settingsTb
      ($_columnId INTEGER PRIMARY KEY, $colName TEXT NOT NULL, $colValue TEXT NOT NULL)
      ''');
    db.execute('''
      CREATE TABLE $dataTb
      ($_columnId INTEGER PRIMARY KEY, $colName TEXT NOT NULL, $colValue TEXT NOT NULL)
      ''');
  }

  Future<int> insert(String tb, Map<String, dynamic> row) async {
    Database db = await instance.database;
    return db.insert(tb, row);
  }

  Future<List<Map<String, dynamic>>> queryAll(String tb) async {
    Database db = await instance.database;
    return await db.query(tb);
  }

  Future<List<Map<String, dynamic>>> query(String tb, String field) async {
    Database db = await instance.database;
    return await db.query(tb, where: '$colName = ?', whereArgs: [field]);
  }

  Future update(String tb, Map<String, dynamic> row, String field) async {
    Database db = await instance.database;
    return db.update(tb, row, where: '$colName = ?', whereArgs: [field]);
  }

  Future<int> delete(String tb, String field) async {
    Database db = await instance.database;
    return await db
        .delete(settingsTb, where: '$colName = ?', whereArgs: [field]);
  }
}
