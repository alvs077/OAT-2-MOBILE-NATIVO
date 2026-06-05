import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import do Riverpod
import '../viewmodels/finance_provider.dart';

// Agora a tela é um ConsumerWidget
class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  // Passamos o WidgetRef para dentro do Modal para ele conseguir ler o banco
  void _showTransactionModal(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    String type = 'saida';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16, right: 16, top: 24,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Nova Transação', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextFormField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Título (ex: Supermercado)'),
                  validator: (val) => val!.isEmpty ? 'Informe o título' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: amountCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Valor (R\$)'),
                  validator: (val) => val!.isEmpty ? 'Informe o valor' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: type,
                  items: const [
                    DropdownMenuItem(value: 'entrada', child: Text('Receita (Entrada)')),
                    DropdownMenuItem(value: 'saida', child: Text('Despesa (Saída)')),
                  ],
                  onChanged: (val) => type = val!,
                  decoration: const InputDecoration(labelText: 'Tipo'),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final amount = double.tryParse(amountCtrl.text.replaceAll(',', '.')) ?? 0;
                      await ref.read(financeProvider).addTransaction(titleCtrl.text, amount, type);
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                  style: FilledButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                  child: const Text('SALVAR'),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  // O build agora recebe o WidgetRef (o espião do Riverpod)
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.watch fica olhando as atualizações em tempo real
    final provider = ref.watch(financeProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Olá, ${provider.currentUser?.name ?? "Usuário"}!'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () => Navigator.pushNamed(context, '/analysis'),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () {
              ref.read(financeProvider).logout();
              Navigator.pushReplacementNamed(context, '/');
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF03045E), Color(0xFF0077B6)]),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Saldo Atual', style: TextStyle(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(
                    'R\$ ${provider.totalBalance.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text('Histórico', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: provider.transactions.isEmpty
                  ? const Center(child: Text('Nenhuma transação cadastrada ainda.'))
                  : ListView.builder(
                      itemCount: provider.transactions.length,
                      itemBuilder: (context, index) {
                        final transacao = provider.transactions[index];
                        final isEntrada = transacao.type == 'entrada';
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isEntrada ? Colors.green[100] : Colors.red[100],
                              child: Icon(
                                isEntrada ? Icons.arrow_upward : Icons.arrow_downward,
                                color: isEntrada ? Colors.green : Colors.red,
                              ),
                            ),
                            title: Text(transacao.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('${transacao.date.day.toString().padLeft(2, '0')}/${transacao.date.month.toString().padLeft(2, '0')}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${isEntrada ? '+' : '-'} R\$ ${transacao.amount.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: isEntrada ? Colors.green : Colors.redAccent,
                                    fontWeight: FontWeight.bold, fontSize: 16,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.grey),
                                  onPressed: () => ref.read(financeProvider).removeTransaction(transacao.id!),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTransactionModal(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Nova Transação'),
      ),
    );
  }
}