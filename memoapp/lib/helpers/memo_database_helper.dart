import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:memoapp/models/memo.dart';

class MemoDatabaseHelper {
  static final MemoDatabaseHelper _instance = MemoDatabaseHelper._internal();

  factory MemoDatabaseHelper() => _instance;

  MemoDatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = await getDatabasesPath();
    final databasePath = join(path, 'memos.db');

    return await openDatabase(databasePath, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''
        CREATE TABLE memos(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT,
          content TEXT,
          createdAt TEXT,
          lastModifiedAt TEXT
        )
      ''');
    });
  }

  Future<int> insertMemo(Memo memo) async {
    final db = await database;
    // Omit the 'id' field when inserting
    return await db.insert('memos', {
      'title': memo.title,
      'content': memo.content,
      'createdAt': memo.createdAt.toIso8601String(),
      'lastModifiedAt': memo.lastModifiedAt.toIso8601String(),
    });
  }

  Future<List<Memo>> getMemos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('memos');

    return List.generate(maps.length, (i) {
      return Memo(
        id: maps[i]['id'],
        title: maps[i]['title'],
        content: maps[i]['content'],
        createdAt: DateTime.parse(maps[i]['createdAt']),
        lastModifiedAt: DateTime.parse(maps[i]['lastModifiedAt']),
      );
    });
  }

  Future<int> updateMemo(Memo memo) async {
    final db = await database;
    return await db.update(
      'memos',
      memo.toMap(),
      where: 'id = ?',
      whereArgs: [memo.id],
    );
  }

  Future<void> deleteMemo(int id) async {
    final db = await database;
    await db.delete('memos', where: 'id = ?', whereArgs: [id]);
  }

  // Implement other CRUD operations (update, delete) as needed
}
