import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/finance_provider.dart';

class AnalysisView extends ConsumerWidget {
  const AnalysisView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Usamos ref.watch aqui também
    final provider = ref.watch(financeProvider);
    
    double totalReceitas = provider.transactions
        .where((t) => t.type == 'entrada')
        .fold(0, (sum, t) => sum + t.amount);
        
    double totalDespesas = provider.transactions
        .where((t) => t.type == 'saida')
        .fold(0, (sum, t) => sum + t.amount);

    double maxAmount = (totalReceitas > totalDespesas ? totalReceitas : totalDespesas);
    if (maxAmount == 0) maxAmount = 1;

    return Scaffold(
      appBar: AppBar(title: const Text('Análise de Orçamento')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Resumo Financeiro', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            _buildBar(context, 'Receitas', totalReceitas, totalReceitas / maxAmount, Colors.green),
            const SizedBox(height: 24),
            _buildBar(context, 'Despesas', totalDespesas, totalDespesas / maxAmount, Colors.redAccent),
          ],
        ),
      ),
    );
  }

  Widget _buildBar(BuildContext context, String label, double amount, double widthFactor, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: R\$ ${amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          height: 20,
          width: double.infinity,
          decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: widthFactor.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }
}