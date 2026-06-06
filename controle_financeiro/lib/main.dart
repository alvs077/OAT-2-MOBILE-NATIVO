import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';

// Firebase — inicialização condicional
import 'package:firebase_core/firebase_core.dart';

import 'views/auth_view.dart';
import 'views/dashboard_view.dart';
import 'views/analysis_view.dart';
import 'widgets/page_transitions.dart';

/// Flag global que indica se o Firebase foi inicializado com sucesso.
/// Usado para ativar/desativar features que dependem do Firebase.
bool isFirebaseInitialized = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa locale pt_BR para formatação de datas
  await initializeDateFormatting('pt_BR', null);

  // Tenta inicializar Firebase (não bloqueia se falhar)
  try {
    await Firebase.initializeApp();
    isFirebaseInitialized = true;
    debugPrint('✅ Firebase inicializado com sucesso');
  } catch (e) {
    isFirebaseInitialized = false;
    debugPrint('⚠️ Firebase não configurado — modo offline ativo: $e');
  }

  runApp(
    const ProviderScope(
      child: FinanceApp(),
    ),
  );
}

class FinanceApp extends StatelessWidget {
  const FinanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Controle Financeiro',
      debugShowCheckedModeBanner: false,

      // ===== TEMA PREMIUM =====
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0077B6),
          primary: const Color(0xFF0077B6),
          secondary: const Color(0xFF00B4D8),
          surface: const Color(0xFFF5F7FA),
        ),
        textTheme: GoogleFonts.interTextTheme(),
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: const Color(0xFF03045E),
          foregroundColor: Colors.white,
          titleTextStyle: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
        ),
      ),

      // ===== ROTAS COM TRANSIÇÕES CUSTOMIZADAS =====
      initialRoute: '/',
      onGenerateRoute: (settings) {
        Widget page;
        switch (settings.name) {
          case '/':
            page = const AuthView();
            return FadePageRoute(page: page);
          case '/dashboard':
            page = const DashboardView();
            return SlidePageRoute(page: page);
          case '/analysis':
            page = const AnalysisView();
            return SlidePageRoute(page: page);
          default:
            page = const AuthView();
            return FadePageRoute(page: page);
        }
      },
    );
  }
}