import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:flutter/foundation.dart'; 
import 'package:path/path.dart';
import '../models/user_model.dart';
import '../models/transaction_model.dart';

class SQLiteHelper {
  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
      return await openDatabase(
        'finance_app.db',
        version: 1,
        onCreate: _createTables,
      );
    }
    
    String path = join(await getDatabasesPath(), 'finance_app.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT, email TEXT UNIQUE, password TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER, title TEXT, amount REAL,
        date TEXT, type TEXT,
        FOREIGN KEY(userId) REFERENCES users(id)
      )
    ''');
  }

  Future<UserModel?> login(String email, String password) async {
    final db = await database;
    var result = await db.query('users', where: 'email = ? AND password = ?', whereArgs: [email, password]);
    if (result.isNotEmpty) return UserModel.fromMap(result.first);
    return null;
  }

  Future<bool> registerUser(UserModel user) async {
    final db = await database;
    try {
      await db.insert('users', user.toMap());
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<int> insertTransaction(TransactionModel transaction) async {
    final db = await database;
    return await db.insert('transactions', transaction.toMap());
  }

  Future<List<TransactionModel>> getTransactions(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions', where: 'userId = ?', whereArgs: [userId], orderBy: 'date DESC'
    );
    return List.generate(maps.length, (i) => TransactionModel.fromMap(maps[i]));
  }

  Future<void> deleteTransaction(int id) async {
    final db = await database;
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }
}