import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:logger/logger.dart';

final Logger logger = Logger();

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();

  factory DatabaseService() => _instance;

  static Database? _database;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'com.example', 'andmed.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // When the database is first created, create a table to store numbers
  Future<void> _onCreate(Database db, int version) async {
    // Run the CREATE {numbers} TABLE statement on the database.
    await db.execute(
      'CREATE TABLE numbers(id INTEGER PRIMARY KEY, number INT, description TEXT)',
    );
    await db.execute(
      'CREATE TABLE users(id INTEGER PRIMARY KEY, username TEXT, email TEXT)',
    );
  }

  Future<void> insertDog(int number, String description) async {
    final db = await database;
    await db.insert('numbers', {'number': number, 'description': description});
  }

  Future<List<Map<String, dynamic>>> getNumbers() async {
    final db = await database;
    return await db.query('numbers');
  }

  Future<void> addUser(String username, String email) async {
    try {
      final db = await database;

      // Check if the username already exists
      List<Map<String, dynamic>> existingUsers = await db.query(
        'users',
        where: 'username = ?',
        whereArgs: [username],
      );

      // If there are existing users with the same username, handle accordingly
      if (existingUsers.isNotEmpty) {
        logger.w('Username $username already exists');
        // Handle the case where the username already exists, e.g., show an error message to the user
        return;
      }

      // If the username doesn't exist, proceed with adding the new user
      await db.insert('users', {'username': username, 'email': email});
      logger.d("Inserted and created");
    } catch (e) {
      logger.e("Error adding user: $e");
      // Handle the error accordingly, e.g., show an error message to the user
    }
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    try {
      final db = await database;

      return await db.query('users');
    } catch (e) {
      logger.e("Error fetching users: $e");
      return []; // Return an empty list in case of error
      // Alternatively, you can rethrow the exception if you want to handle it elsewhere
    }
  }

  Future<void> deleteDatabase() async {
    try {
      // Get the directory where the database file is located
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      //String dbPath = documentsDirectory.path;

      //Directory documentsDirectory = await getApplicationDocumentsDirectory();
      String path = join(documentsDirectory.path, 'com.example', 'andmed.db');

      // Specify the name of your database file
      //String dbName = 'andmed.db';

      // Combine the directory path and database file name to get the full path
      String fullPath = '$path';

      // Check if the database file exists
      bool exists = await File(fullPath).exists();

      // If the database file exists, delete it
      if (exists) {
        await File(fullPath).delete();
      } else {
        print('Database file does not exist.');
      }
    } catch (e) {
      print('Error deleting database: $e');
    }
  }
}
