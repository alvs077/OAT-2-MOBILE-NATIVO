import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../viewmodels/providers.dart';
import '../widgets/page_transitions.dart';

/// Tela de análise de orçamento com barras animadas e categorias.
class AnalysisView extends ConsumerWidget {
  const AnalysisView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalReceitas = ref.watch(totalReceitasProvider);
    final totalDespesas = ref.watch(totalDespesasProvider);
    final balance = ref.watch(totalBalanceProvider);
    final categoryTotals = ref.watch(categoryTotalsProvider);

    double maxAmount =
        (totalReceitas > totalDespesas ? totalReceitas : totalDespesas);
    if (maxAmount == 0) maxAmount = 1;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'Análise de Orçamento',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF03045E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== CARDS RESUMO =====
            AnimatedEntrance(
              delay: 100,
              child: Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      'Receitas',
                      totalReceitas,
                      Icons.arrow_upward_rounded,
                      const Color(0xFF2E7D32),
                      const Color(0xFFE8F5E9),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryCard(
                      'Despesas',
                      totalDespesas,
                      Icons.arrow_downward_rounded,
                      Colors.redAccent,
                      const Color(0xFFFFEBEE),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            AnimatedEntrance(
              delay: 200,
              child: _buildSummaryCard(
                'Saldo',
                balance,
                Icons.account_balance_wallet_rounded,
                balance >= 0 ? const Color(0xFF0077B6) : Colors.redAccent,
                balance >= 0
                    ? const Color(0xFFE3F2FD)
                    : const Color(0xFFFFEBEE),
                isFullWidth: true,
              ),
            ),
            const SizedBox(height: 28),

            // ===== RESUMO GERAL =====
            AnimatedEntrance(
              delay: 300,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resumo Geral',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF03045E),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildAnimatedBar(
                    'Receitas',
                    totalReceitas,
                    totalReceitas / maxAmount,
                    const Color(0xFF2E7D32),
                    Icons.trending_up_rounded,
                  ),
                  const SizedBox(height: 16),
                  _buildAnimatedBar(
                    'Despesas',
                    totalDespesas,
                    totalDespesas / maxAmount,
                    Colors.redAccent,
                    Icons.trending_down_rounded,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ===== GASTOS POR CATEGORIA =====
            AnimatedEntrance(
              delay: 450,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gastos por Categoria',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF03045E),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (categoryTotals.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.pie_chart_outline_rounded,
                              color: Colors.grey[300], size: 48),
                          const SizedBox(height: 12),
                          Text(
                            'Nenhuma despesa cadastrada',
                            style: GoogleFonts.inter(
                              color: Colors.grey[500],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...categoryTotals.entries.map((entry) {
                      final maxCat = categoryTotals.values
                          .fold(0.0, (a, b) => a > b ? a : b);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildCategoryBar(
                          entry.key,
                          entry.value,
                          maxCat > 0 ? entry.value / maxCat : 0,
                        ),
                      );
                    }),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ===== DICAS FINANCEIRAS =====
            AnimatedEntrance(
              delay: 600,
              child: _buildTipsCard(balance, totalDespesas, categoryTotals),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ===== CARD RESUMO =====
  Widget _buildSummaryCard(
    String label,
    double amount,
    IconData icon,
    Color color,
    Color bgColor, {
    bool isFullWidth = false,
  }) {
    return Container(
      width: isFullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                AnimatedCounter(
                  value: amount,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===== BARRA ANIMADA GERAL =====
  Widget _buildAnimatedBar(
    String label,
    double amount,
    double widthFactor,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                '$label: R\$ ${amount.toStringAsFixed(2)}',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Stack(
              children: [
                Container(
                  height: 10,
                  width: double.infinity,
                  color: Colors.grey[100],
                ),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: widthFactor.clamp(0.0, 1.0)),
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return FractionallySizedBox(
                      widthFactor: value,
                      child: Container(
                        height: 10,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [color, color.withOpacity(0.7)],
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===== BARRA POR CATEGORIA =====
  Widget _buildCategoryBar(String category, double amount, double factor) {
    final meta = _getCategoryMeta(category);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Ícone
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: meta['color'].withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(meta['emoji'], style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 14),
          // Conteúdo
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      meta['label'],
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: const Color(0xFF1A1A2E),
                      ),
                    ),
                    Text(
                      'R\$ ${amount.toStringAsFixed(2)}',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: meta['color'],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: factor.clamp(0.0, 1.0)),
                    duration: const Duration(milliseconds: 1200),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return LinearProgressIndicator(
                        value: value,
                        backgroundColor: Colors.grey[100],
                        valueColor:
                            AlwaysStoppedAnimation<Color>(meta['color']),
                        minHeight: 6,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===== CARD DE DICAS =====
  Widget _buildTipsCard(
      double balance, double despesas, Map<String, double> categories) {
    String tip;
    IconData tipIcon;
    Color tipColor;

    if (balance < 0) {
      tip =
          '⚠️ Seu saldo está negativo! Considere reduzir gastos com categorias de maior impacto.';
      tipIcon = Icons.warning_rounded;
      tipColor = Colors.orange;
    } else if (despesas > 0 && categories.isNotEmpty) {
      final topCategory =
          categories.entries.reduce((a, b) => a.value > b.value ? a : b);
      final meta = _getCategoryMeta(topCategory.key);
      tip =
          '💡 Sua maior despesa é com ${meta['label']} (R\$ ${topCategory.value.toStringAsFixed(2)}). Analise se é possível otimizar esse gasto.';
      tipIcon = Icons.lightbulb_rounded;
      tipColor = const Color(0xFF0077B6);
    } else {
      tip =
          '🎯 Comece adicionando suas transações para receber dicas personalizadas de economia!';
      tipIcon = Icons.tips_and_updates_rounded;
      tipColor = const Color(0xFF0077B6);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [tipColor.withOpacity(0.08), tipColor.withOpacity(0.03)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tipColor.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: tipColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(tipIcon, color: tipColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dica Financeira',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: tipColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tip,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getCategoryMeta(String category) {
    switch (category) {
      case 'alimentacao':
        return {
          'label': 'Alimentação',
          'emoji': '🍽️',
          'color': const Color(0xFFE65100)
        };
      case 'transporte':
        return {
          'label': 'Transporte',
          'emoji': '🚗',
          'color': const Color(0xFF1565C0)
        };
      case 'lazer':
        return {
          'label': 'Lazer',
          'emoji': '🎮',
          'color': const Color(0xFF7B1FA2)
        };
      case 'salario':
        return {
          'label': 'Salário',
          'emoji': '💰',
          'color': const Color(0xFF2E7D32)
        };
      default:
        return {
          'label': 'Outros',
          'emoji': '📦',
          'color': const Color(0xFF455A64)
        };
    }
  }
}