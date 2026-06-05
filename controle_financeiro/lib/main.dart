import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Novo import
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'views/auth_view.dart';
import 'views/dashboard_view.dart';
import 'views/analysis_view.dart';

void main() {
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }
  
  runApp(
    // ProviderScope é o motor do Riverpod que gerencia todas as injeções
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
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00B4D8)),
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthView(),
        '/dashboard': (context) => const DashboardView(),
        '/analysis': (context) => const AnalysisView(),
      },
    );
  }
}