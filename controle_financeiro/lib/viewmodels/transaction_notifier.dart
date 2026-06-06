import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction_model.dart';
import '../repositories/sqlite_helper.dart';
import '../services/firebase_service.dart';

// ================================================
// ESTADO DE TRANSAÇÕES (Imutável)
// ================================================

@immutable
class TransactionState {
  final List<TransactionModel> transactions;
  final bool isLoading;
  final String? error;

  const TransactionState({
    this.transactions = const [],
    this.isLoading = false,
    this.error,
  });

  TransactionState copyWith({
    List<TransactionModel>? transactions,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return TransactionState(
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// ================================================
// NOTIFIER DE TRANSAÇÕES (StateNotifier)
// ================================================

class TransactionNotifier extends StateNotifier<TransactionState> {
  final SQLiteHelper _dbHelper;
  final FirebaseService _firebaseService;

  TransactionNotifier(this._dbHelper, this._firebaseService)
      : super(const TransactionState());

  /// Carrega todas as transações do SQLite local.
  Future<void> loadTransactions(int userId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final transactions = await _dbHelper.getTransactions(userId);
      state = state.copyWith(transactions: transactions, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao carregar transações: ${e.toString()}',
      );
    }
  }

  /// Adiciona uma nova transação.
  Future<void> addTransaction({
    required int userId,
    required String title,
    required double amount,
    required String type,
    String category = 'outros',
    String? firebaseUid,
  }) async {
    try {
      final newTransaction = TransactionModel(
        userId: userId,
        title: title,
        amount: amount,
        date: DateTime.now(),
        type: type,
        category: category,
      );

      // 1. Salva no SQLite (sempre funciona)
      await _dbHelper.insertTransaction(newTransaction);

      // 2. Tenta sincronizar com Firebase
      if (firebaseUid != null) {
        _syncToFirebase(firebaseUid, newTransaction);
      }

      // 3. Recarrega a lista
      await loadTransactions(userId);
    } catch (e) {
      state = state.copyWith(
        error: 'Erro ao adicionar transação: ${e.toString()}',
      );
    }
  }

  /// Remove uma transação pelo ID.
  Future<void> removeTransaction(int id, int userId,
      {String? firebaseUid}) async {
    try {
      await _dbHelper.deleteTransaction(id);

      // Tenta remover do Firebase
      if (firebaseUid != null) {
        _deleteFromFirebase(firebaseUid, id);
      }

      await loadTransactions(userId);
    } catch (e) {
      state = state.copyWith(
        error: 'Erro ao remover transação: ${e.toString()}',
      );
    }
  }

  /// Limpa o erro atual.
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  // ---------- FIREBASE SYNC (background) ----------

  Future<void> _syncToFirebase(
      String uid, TransactionModel transaction) async {
    try {
      await _firebaseService.addTransactionToCloud(uid, transaction);
    } catch (_) {
      debugPrint('Sync Firebase falhou — dados salvos localmente');
    }
  }

  Future<void> _deleteFromFirebase(String uid, int transactionId) async {
    try {
      await _firebaseService.deleteTransactionFromCloud(uid, transactionId);
    } catch (_) {
      debugPrint('Delete Firebase falhou — removido apenas localmente');
    }
  }
}
