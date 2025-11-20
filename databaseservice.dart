import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseService {
  static final dbmname = "data.db";
  static final dversion = 1;

  static final tablename = "activities";
  static final columid = "columid";
  static final type = "type";
  static final data = "data";
  static final date = "date";

  // Singleton
  DatabaseService._privateConstructor();
  static final DatabaseService instance = DatabaseService._privateConstructor();

  // Database instance
  static Database? _database;

  Future<Database?> get db async {
    if (_database != null) return _database;
    _database = await initializeDatabase();
    return _database;
  }

  // Initialize database
  Future<Database> initializeDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, dbmname);
    return await openDatabase(path, version: dversion, onCreate: createTable);
  }

  // Create table
  Future<void> createTable(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tablename (
        $columid INTEGER PRIMARY KEY AUTOINCREMENT,
        $type TEXT NOT NULL,
        $data REAL NOT NULL,
        $date TEXT NOT NULL
      )
    ''');
    if (kDebugMode) {
      print("Table created");
    }
  }

  // Insert activity
  Future<int> addActivity(Map<String, dynamic> row) async {
    // ignore: no_leading_underscores_for_local_identifiers
    Database? _db = await db;
    return await _db!.insert(tablename, row);
  }

  // Get activities
  Future<List<Map<String, Object?>>> getActivities(String category) async {
    // ignore: no_leading_underscores_for_local_identifiers
    Database? _db = await db;
    if (category.toLowerCase() == "all") {
      return await _db!.query(tablename, orderBy: "$columid DESC");
    } else {
      return await _db!.query(
        tablename,
        where: "$type = ?",
        whereArgs: [category.toLowerCase()],
        orderBy: "$columid DESC",
      );
    }
  }

  // Delete activity by id
  Future<int> deleteActivity(int? id) async {
    if (id == null) return 0;
    // ignore: no_leading_underscores_for_local_identifiers
    Database? _db = await db;
    return await _db!.delete(tablename, where: "$columid = ?", whereArgs: [id]);
  }
}
