import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../repositories/sqlite_helper.dart';
import '../services/firebase_service.dart';

// ================================================
// ESTADO DE AUTENTICAÇÃO (Imutável)
// ================================================

@immutable
class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;
  final bool isFirebaseAvailable;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isFirebaseAvailable = false,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
    bool? isFirebaseAvailable,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isFirebaseAvailable: isFirebaseAvailable ?? this.isFirebaseAvailable,
    );
  }
}

// ================================================
// NOTIFIER DE AUTENTICAÇÃO (StateNotifier)
// ================================================

class AuthNotifier extends StateNotifier<AuthState> {
  final SQLiteHelper _dbHelper;
  final FirebaseService _firebaseService;

  AuthNotifier(this._dbHelper, this._firebaseService)
      : super(const AuthState());

  /// Login: tenta SQLite local (sempre disponível).
  /// Se Firebase estiver configurado, tenta também login Firebase.
  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      // 1. Login local SQLite (fonte primária)
      final localUser = await _dbHelper.login(email, password);

      if (localUser == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'E-mail ou senha incorretos.',
        );
        return false;
      }

      // 2. Tenta login Firebase em background (não bloqueia)
      _tryFirebaseLogin(email, password, localUser.id!);

      state = state.copyWith(user: localUser, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao fazer login: ${e.toString()}',
      );
      return false;
    }
  }

  /// Registro: salva no SQLite e tenta Firebase.
  Future<bool> register(
      String name, String email, String password, {String? phone}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      // 1. Registro local SQLite
      final newUser = UserModel(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );

      final success = await _dbHelper.registerUser(newUser);
      if (!success) {
        state = state.copyWith(
          isLoading: false,
          error: 'Este e-mail já está cadastrado.',
        );
        return false;
      }

      // 2. Tenta registro Firebase em background
      _tryFirebaseRegister(name, email, password);

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao cadastrar: ${e.toString()}',
      );
      return false;
    }
  }

  /// Logout: limpa sessão local e Firebase.
  void logout() {
    try {
      _firebaseService.signOut();
    } catch (_) {
      // Firebase pode não estar disponível
    }
    state = const AuthState();
  }

  /// Limpa o erro atual.
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  // ---------- FIREBASE HELPERS (background) ----------

  Future<void> _tryFirebaseLogin(
      String email, String password, int localUserId) async {
    try {
      final uid = await _firebaseService.signIn(email, password);
      if (uid != null) {
        await _dbHelper.updateFirebaseUid(localUserId, uid);
        state = state.copyWith(isFirebaseAvailable: true);
      }
    } catch (_) {
      // Firebase não disponível — app continua normalmente com SQLite
      debugPrint('Firebase login falhou — usando modo offline');
    }
  }

  Future<void> _tryFirebaseRegister(
      String name, String email, String password) async {
    try {
      await _firebaseService.signUp(name, email, password);
      state = state.copyWith(isFirebaseAvailable: true);
    } catch (_) {
      debugPrint('Firebase register falhou — usando modo offline');
    }
  }
}
