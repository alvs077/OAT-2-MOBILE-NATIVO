import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/transaction_model.dart';

/// Serviço de integração com Firebase (Auth + Firestore).
/// Gerencia autenticação e sincronização de dados com a nuvem.
class FirebaseService {
  // Inicialização segura - só instancia se o Firebase foi inicializado
  FirebaseAuth? get _auth => Firebase.apps.isNotEmpty ? FirebaseAuth.instance : null;
  FirebaseFirestore? get _firestore => Firebase.apps.isNotEmpty ? FirebaseFirestore.instance : null;

  /// Retorna o usuário Firebase atual.
  User? get currentFirebaseUser => _auth?.currentUser;

  /// Verifica se o usuário está autenticado no Firebase.
  bool get isAuthenticated => _auth?.currentUser != null;

  // ==========================================
  // AUTENTICAÇÃO
  // ==========================================

  /// Login com Firebase Auth.
  /// Retorna o UID do Firebase ou null em caso de erro ou Firebase inativo.
  Future<String?> signIn(String email, String password) async {
    if (_auth == null) return null;
    try {
      final credential = await _auth!.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user?.uid;
    } on FirebaseAuthException catch (e) {
      throw _mapAuthException(e);
    }
  }

  /// Cadastro com Firebase Auth + Perfil no Firestore.
  Future<String?> signUp(String name, String email, String password) async {
    if (_auth == null || _firestore == null) return null;
    try {
      final credential = await _auth!.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user?.uid;
      if (uid != null) {
        // Salva perfil no Firestore
        await _firestore!.collection('users').doc(uid).set({
          'name': name,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Atualiza displayName no Firebase Auth
        await credential.user?.updateDisplayName(name);
      }

      return uid;
    } on FirebaseAuthException catch (e) {
      throw _mapAuthException(e);
    }
  }

  /// Logout do Firebase.
  Future<void> signOut() async {
    await _auth?.signOut();
  }

  // ==========================================
  // FIRESTORE — TRANSAÇÕES
  // ==========================================

  /// Sincroniza transações locais para o Firestore.
  Future<void> syncTransactionsToCloud(
      String uid, List<TransactionModel> transactions) async {
    if (_firestore == null) return;
    
    final batch = _firestore!.batch();
    final collectionRef =
        _firestore!.collection('users').doc(uid).collection('transactions');

    for (final transaction in transactions) {
      final docRef = collectionRef.doc(transaction.id.toString());
      batch.set(docRef, {
        'title': transaction.title,
        'amount': transaction.amount,
        'date': transaction.date.toIso8601String(),
        'type': transaction.type,
        'category': transaction.category,
      });
    }

    await batch.commit();
  }

  /// Busca transações do Firestore.
  Future<List<TransactionModel>> getTransactionsFromCloud(
      String uid, int localUserId) async {
    if (_firestore == null) return [];
    
    final snapshot = await _firestore!
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return TransactionModel(
        userId: localUserId,
        title: data['title'] ?? '',
        amount: (data['amount'] as num).toDouble(),
        date: DateTime.parse(data['date']),
        type: data['type'] ?? 'saida',
        category: data['category'] ?? 'outros',
      );
    }).toList();
  }

  /// Adiciona uma transação ao Firestore.
  Future<void> addTransactionToCloud(
      String uid, TransactionModel transaction) async {
    if (_firestore == null) return;
    
    await _firestore!
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .add({
      'title': transaction.title,
      'amount': transaction.amount,
      'date': transaction.date.toIso8601String(),
      'type': transaction.type,
      'category': transaction.category,
    });
  }

  /// Remove uma transação do Firestore.
  Future<void> deleteTransactionFromCloud(String uid, int transactionId) async {
    if (_firestore == null) return;
    
    await _firestore!
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .doc(transactionId.toString())
        .delete();
  }

  // ==========================================
  // UTILITÁRIOS
  // ==========================================

  /// Mapeia exceções Firebase para mensagens amigáveis em pt-BR.
  String _mapAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Usuário não encontrado.';
      case 'wrong-password':
        return 'Senha incorreta.';
      case 'email-already-in-use':
        return 'Este e-mail já está cadastrado.';
      case 'weak-password':
        return 'A senha é muito fraca. Use pelo menos 6 caracteres.';
      case 'invalid-email':
        return 'E-mail inválido.';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente novamente mais tarde.';
      default:
        return 'Erro de autenticação: ${e.message}';
    }
  }
}
