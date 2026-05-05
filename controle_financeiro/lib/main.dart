import 'package:flutter/material.dart';
import 'views/auth_view.dart';
import 'views/dashboard_view.dart';
import 'views/analysis_view.dart';

void main() {
  runApp(const FinanceApp());
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
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00B4D8), // Um azul/ciano moderno
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
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