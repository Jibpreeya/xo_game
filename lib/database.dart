import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'game_history.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE game_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        grid_size INTEGER,
        moves TEXT,
        winner TEXT
      )
    ''');
  }

  Future<int> insertGame(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert('game_history', row);
  }

  Future<List<Map<String, dynamic>>> fetchAllGames() async {
    Database db = await database;
    return await db.query('game_history');
  }
}
