import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/sqlite_helper.dart';
import '../services/api_service.dart';
import '../services/firebase_service.dart';
import '../models/news_article_model.dart';
import 'auth_notifier.dart';
import 'transaction_notifier.dart';

// ================================================
// INJEÇÃO DE DEPENDÊNCIA CENTRALIZADA (Riverpod)
// ================================================
// Todos os provedores são declarados aqui para facilitar
// a manutenção e garantir o desacoplamento entre camadas.
// ================================================

// ---------- CAMADA DE DADOS (Singleton) ----------

/// Provedor do banco de dados SQLite local.
final sqliteHelperProvider = Provider<SQLiteHelper>((ref) => SQLiteHelper());

/// Provedor do serviço de API de notícias.
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

/// Provedor do serviço Firebase (Auth + Firestore).
final firebaseServiceProvider =
    Provider<FirebaseService>((ref) => FirebaseService());

// ---------- CAMADA DE ESTADO (StateNotifier) ----------

/// Provedor de autenticação — gerencia login, registro e sessão do usuário.
/// Usa StateNotifier para estado imutável e reativo.
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final db = ref.read(sqliteHelperProvider);
  final firebase = ref.read(firebaseServiceProvider);
  return AuthNotifier(db, firebase);
});

/// Provedor de transações — gerencia CRUD de transações financeiras.
final transactionProvider =
    StateNotifierProvider<TransactionNotifier, TransactionState>((ref) {
  final db = ref.read(sqliteHelperProvider);
  final firebase = ref.read(firebaseServiceProvider);
  return TransactionNotifier(db, firebase);
});

// ---------- CAMADA DE DADOS REMOTOS ----------

/// Provedor de notícias financeiras — FutureProvider com auto-dispose.
/// Usa .autoDispose para liberar recursos quando a tela sai do escopo.
final newsProvider =
    FutureProvider.autoDispose<List<NewsArticle>>((ref) async {
  final apiService = ref.read(apiServiceProvider);
  return apiService.fetchNews();
});

// ---------- PROVEDORES DERIVADOS ----------

/// Saldo total calculado a partir das transações.
final totalBalanceProvider = Provider<double>((ref) {
  final state = ref.watch(transactionProvider);
  return state.transactions.fold(0.0, (sum, item) {
    return item.type == 'entrada' ? sum + item.amount : sum - item.amount;
  });
});

/// Total de receitas.
final totalReceitasProvider = Provider<double>((ref) {
  final state = ref.watch(transactionProvider);
  return state.transactions
      .where((t) => t.type == 'entrada')
      .fold(0.0, (sum, t) => sum + t.amount);
});

/// Total de despesas.
final totalDespesasProvider = Provider<double>((ref) {
  final state = ref.watch(transactionProvider);
  return state.transactions
      .where((t) => t.type == 'saida')
      .fold(0.0, (sum, t) => sum + t.amount);
});

/// Gastos por categoria (apenas saídas).
final categoryTotalsProvider = Provider<Map<String, double>>((ref) {
  final state = ref.watch(transactionProvider);
  final Map<String, double> totals = {};
  for (final t in state.transactions.where((t) => t.type == 'saida')) {
    totals[t.category] = (totals[t.category] ?? 0) + t.amount;
  }
  return totals;
});
