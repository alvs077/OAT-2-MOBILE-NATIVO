import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';
import '../models/transaction_model.dart';

/// Helper para gerenciamento do banco de dados SQLite local.
/// Suporta categorias de transação e campo firebaseUid para sincronização.
class SQLiteHelper {
  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'finance_app.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createTables,
      onUpgrade: _onUpgrade,
    );
  }

  /// Cria as tabelas na primeira inicialização.
  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        phone TEXT,
        firebaseUid TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        type TEXT NOT NULL,
        category TEXT DEFAULT 'outros',
        FOREIGN KEY(userId) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
  }

  /// Migration: adiciona campos novos se atualizando da versão 1.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Adiciona coluna category na tabela transactions
      await db.execute(
          'ALTER TABLE transactions ADD COLUMN category TEXT DEFAULT \'outros\'');
      // Adiciona colunas phone e firebaseUid na tabela users
      await db.execute('ALTER TABLE users ADD COLUMN phone TEXT');
      await db.execute('ALTER TABLE users ADD COLUMN firebaseUid TEXT');
    }
  }

  // ==========================================
  // USUÁRIOS
  // ==========================================

  /// Login: busca usuário por email e senha.
  Future<UserModel?> login(String email, String password) async {
    final db = await database;
    var result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (result.isNotEmpty) return UserModel.fromMap(result.first);
    return null;
  }

  /// Registra um novo usuário.
  Future<bool> registerUser(UserModel user) async {
    final db = await database;
    try {
      await db.insert('users', user.toMap());
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Atualiza o firebaseUid de um usuário.
  Future<void> updateFirebaseUid(int userId, String firebaseUid) async {
    final db = await database;
    await db.update(
      'users',
      {'firebaseUid': firebaseUid},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  /// Busca usuário por firebaseUid.
  Future<UserModel?> getUserByFirebaseUid(String uid) async {
    final db = await database;
    var result = await db.query(
      'users',
      where: 'firebaseUid = ?',
      whereArgs: [uid],
    );
    if (result.isNotEmpty) return UserModel.fromMap(result.first);
    return null;
  }

  // ==========================================
  // TRANSAÇÕES
  // ==========================================

  /// Insere uma nova transação.
  Future<int> insertTransaction(TransactionModel transaction) async {
    final db = await database;
    return await db.insert('transactions', transaction.toMap());
  }

  /// Busca todas as transações de um usuário, ordenadas por data (recente primeiro).
  Future<List<TransactionModel>> getTransactions(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
    return List.generate(
        maps.length, (i) => TransactionModel.fromMap(maps[i]));
  }

  /// Busca transações por categoria.
  Future<List<TransactionModel>> getTransactionsByCategory(
      int userId, String category) async {
    final db = await database;
    final maps = await db.query(
      'transactions',
      where: 'userId = ? AND category = ?',
      whereArgs: [userId, category],
      orderBy: 'date DESC',
    );
    return maps.map((m) => TransactionModel.fromMap(m)).toList();
  }

  /// Retorna o total gasto por categoria para um usuário.
  Future<Map<String, double>> getCategoryTotals(int userId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT category, SUM(amount) as total
      FROM transactions
      WHERE userId = ? AND type = 'saida'
      GROUP BY category
    ''', [userId]);

    final Map<String, double> totals = {};
    for (final row in result) {
      totals[row['category'] as String] = (row['total'] as num).toDouble();
    }
    return totals;
  }

  /// Remove uma transação.
  Future<void> deleteTransaction(int id) async {
    final db = await database;
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  /// Remove todas as transações de um usuário (para re-sync).
  Future<void> deleteAllTransactions(int userId) async {
    final db = await database;
    await db
        .delete('transactions', where: 'userId = ?', whereArgs: [userId]);
  }
}