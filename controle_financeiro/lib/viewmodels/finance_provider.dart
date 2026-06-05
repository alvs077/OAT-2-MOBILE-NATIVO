import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction_model.dart';
import '../models/user_model.dart';
import '../repositories/sqlite_helper.dart';

final sqliteHelperProvider = Provider<SQLiteHelper>((ref) => SQLiteHelper());

final financeProvider = ChangeNotifierProvider<FinanceController>((ref) {
  final db = ref.read(sqliteHelperProvider);
  return FinanceController(db);
});

class FinanceController extends ChangeNotifier {
  final SQLiteHelper _dbHelper;
  
  FinanceController(this._dbHelper);

  UserModel? _currentUser;
  List<TransactionModel> _transactions = [];

  UserModel? get currentUser => _currentUser;
  List<TransactionModel> get transactions => _transactions;

  double get totalBalance {
    return _transactions.fold(0.0, (sum, item) => 
      item.type == 'entrada' ? sum + item.amount : sum - item.amount
    );
  }

  Future<bool> login(String email, String password) async {
    _currentUser = await _dbHelper.login(email, password);
    if (_currentUser != null) {
      await loadTransactions();
      return true;
    }
    return false;
  }

  Future<bool> register(String name, String email, String password) async {
    UserModel newUser = UserModel(name: name, email: email, password: password);
    return await _dbHelper.registerUser(newUser);
  }

  void logout() {
    _currentUser = null;
    _transactions = [];
    notifyListeners();
  }

  Future<void> loadTransactions() async {
    if (_currentUser != null) {
      _transactions = await _dbHelper.getTransactions(_currentUser!.id!);
      notifyListeners();
    }
  }

  Future<void> addTransaction(String title, double amount, String type) async {
    if (_currentUser == null) return;
    
    final newTransaction = TransactionModel(
      userId: _currentUser!.id!,
      title: title,
      amount: amount,
      date: DateTime.now(),
      type: type,
    );
    
    await _dbHelper.insertTransaction(newTransaction);
    await loadTransactions();
  }

  Future<void> removeTransaction(int id) async {
    await _dbHelper.deleteTransaction(id);
    await loadTransactions();
  }
  // Provedor da API
final newsServiceProvider = Provider<ApiService>((ref) => ApiService());

// Provedor que busca as notícias (usando FutureProvider para gerenciar o carregamento)
final newsProvider = FutureProvider<List<dynamic>>((ref) async {
  return ref.read(newsServiceProvider).fetchNews();
});
}
