import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../viewmodels/providers.dart';
import '../widgets/skeleton_widgets.dart';
import '../widgets/error_widgets.dart';
import '../widgets/page_transitions.dart';

/// Dashboard principal com saldo, notícias financeiras e histórico.
class DashboardView extends ConsumerStatefulWidget {
  const DashboardView({super.key});

  @override
  ConsumerState<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends ConsumerState<DashboardView>
    with SingleTickerProviderStateMixin {
  late AnimationController _entryController;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  void _showTransactionModal(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    String type = 'saida';
    String category = 'outros';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 16,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Handle bar
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Nova Transação',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF03045E),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Tipo (Receita/Despesa) — chips
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  setModalState(() => type = 'entrada'),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: type == 'entrada'
                                      ? const Color(0xFF2E7D32).withOpacity(0.1)
                                      : Colors.grey[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: type == 'entrada'
                                        ? const Color(0xFF2E7D32)
                                        : Colors.grey[200]!,
                                    width: type == 'entrada' ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.arrow_upward_rounded,
                                      color: type == 'entrada'
                                          ? const Color(0xFF2E7D32)
                                          : Colors.grey[400],
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Receita',
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w600,
                                        color: type == 'entrada'
                                            ? const Color(0xFF2E7D32)
                                            : Colors.grey[400],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setModalState(() => type = 'saida'),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: type == 'saida'
                                      ? Colors.redAccent.withOpacity(0.1)
                                      : Colors.grey[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: type == 'saida'
                                        ? Colors.redAccent
                                        : Colors.grey[200]!,
                                    width: type == 'saida' ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.arrow_downward_rounded,
                                      color: type == 'saida'
                                          ? Colors.redAccent
                                          : Colors.grey[400],
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Despesa',
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w600,
                                        color: type == 'saida'
                                            ? Colors.redAccent
                                            : Colors.grey[400],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Título
                      TextFormField(
                        controller: titleCtrl,
                        style: GoogleFonts.inter(),
                        decoration: InputDecoration(
                          labelText: 'Título (ex: Supermercado)',
                          labelStyle: GoogleFonts.inter(color: Colors.grey[400]),
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: Colors.grey[200]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: Colors.grey[200]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                                color: Color(0xFF0077B6), width: 1.5),
                          ),
                        ),
                        validator: (val) =>
                            val!.isEmpty ? 'Informe o título' : null,
                      ),
                      const SizedBox(height: 16),

                      // Valor
                      TextFormField(
                        controller: amountCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        style: GoogleFonts.inter(),
                        decoration: InputDecoration(
                          labelText: 'Valor (R\$)',
                          labelStyle: GoogleFonts.inter(color: Colors.grey[400]),
                          prefixText: 'R\$ ',
                          prefixStyle: GoogleFonts.inter(
                              color: const Color(0xFF03045E),
                              fontWeight: FontWeight.w600),
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: Colors.grey[200]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: Colors.grey[200]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                                color: Color(0xFF0077B6), width: 1.5),
                          ),
                        ),
                        validator: (val) =>
                            val!.isEmpty ? 'Informe o valor' : null,
                      ),
                      const SizedBox(height: 16),

                      // Categoria
                      DropdownButtonFormField<String>(
                        initialValue: category,
                        style: GoogleFonts.inter(
                            color: const Color(0xFF03045E), fontSize: 15),
                        decoration: InputDecoration(
                          labelText: 'Categoria',
                          labelStyle: GoogleFonts.inter(color: Colors.grey[400]),
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: Colors.grey[200]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: Colors.grey[200]!),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: 'alimentacao', child: Text('🍽️ Alimentação')),
                          DropdownMenuItem(
                              value: 'transporte', child: Text('🚗 Transporte')),
                          DropdownMenuItem(
                              value: 'lazer', child: Text('🎮 Lazer')),
                          DropdownMenuItem(
                              value: 'salario', child: Text('💰 Salário')),
                          DropdownMenuItem(
                              value: 'outros', child: Text('📦 Outros')),
                        ],
                        onChanged: (val) => category = val!,
                      ),
                      const SizedBox(height: 28),

                      // Botão Salvar
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0077B6), Color(0xFF00B4D8)],
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: ElevatedButton(
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                final amount = double.tryParse(
                                        amountCtrl.text.replaceAll(',', '.')) ??
                                    0;
                                final user = ref.read(authProvider).user;
                                if (user != null) {
                                  await ref
                                      .read(transactionProvider.notifier)
                                      .addTransaction(
                                        userId: user.id!,
                                        title: titleCtrl.text,
                                        amount: amount,
                                        type: type,
                                        category: category,
                                        firebaseUid: user.firebaseUid,
                                      );
                                }
                                if (context.mounted) Navigator.pop(context);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(
                              'SALVAR',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final transactionState = ref.watch(transactionProvider);
    final balance = ref.watch(totalBalanceProvider);
    final newsAsync = ref.watch(newsProvider);
    final userName = authState.user?.name ?? 'Usuário';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          // App Bar com gradiente
          SliverAppBar(
            expandedHeight: 0,
            floating: true,
            backgroundColor: const Color(0xFF03045E),
            foregroundColor: Colors.white,
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Olá, $userName!',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        DateFormat('EEEE, d MMM', 'pt_BR').format(DateTime.now()),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.white60,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.analytics_outlined, size: 22),
                onPressed: () => Navigator.pushNamed(context, '/analysis'),
                tooltip: 'Análise',
              ),
              IconButton(
                icon: const Icon(Icons.logout_rounded,
                    color: Colors.redAccent, size: 22),
                onPressed: () {
                  ref.read(authProvider.notifier).logout();
                  Navigator.pushReplacementNamed(context, '/');
                },
                tooltip: 'Sair',
              ),
              const SizedBox(width: 4),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ===== CARD DE SALDO =====
                  AnimatedEntrance(
                    delay: 100,
                    child: _buildBalanceCard(balance, transactionState),
                  ),
                  const SizedBox(height: 24),

                  // ===== SEÇÃO DE NOTÍCIAS =====
                  AnimatedEntrance(
                    delay: 250,
                    child: _buildNewsSection(newsAsync, ref),
                  ),
                  const SizedBox(height: 24),

                  // ===== HISTÓRICO DE TRANSAÇÕES =====
                  AnimatedEntrance(
                    delay: 400,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Histórico',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF03045E),
                          ),
                        ),
                        Text(
                          '${transactionState.transactions.length} transações',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // Lista de transações
          transactionState.isLoading
              ? SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TransactionListSkeleton(),
                  ),
                )
              : transactionState.transactions.isEmpty
                  ? SliverToBoxAdapter(
                      child: AnimatedEntrance(
                        delay: 500,
                        child: const EmptyStateWidget(
                          title: 'Nenhuma transação ainda',
                          subtitle:
                              'Toque no botão + para adicionar\nsua primeira transação.',
                          icon: Icons.receipt_long_rounded,
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final transacao =
                                transactionState.transactions[index];
                            final isEntrada = transacao.type == 'entrada';

                            return AnimatedEntrance(
                              delay: 500 + (index * 50),
                              child: Dismissible(
                                key: Key(transacao.id.toString()),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 24),
                                  margin: const EdgeInsets.only(bottom: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(Icons.delete_rounded,
                                      color: Colors.white),
                                ),
                                onDismissed: (_) {
                                  final user = ref.read(authProvider).user;
                                  ref
                                      .read(transactionProvider.notifier)
                                      .removeTransaction(
                                        transacao.id!,
                                        user!.id!,
                                        firebaseUid: user.firebaseUid,
                                      );
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 10),
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
                                  child: ListTile(
                                    contentPadding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                    leading: Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: isEntrada
                                            ? const Color(0xFF2E7D32)
                                                .withOpacity(0.1)
                                            : Colors.redAccent
                                                .withOpacity(0.1),
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        isEntrada
                                            ? Icons.arrow_upward_rounded
                                            : Icons.arrow_downward_rounded,
                                        color: isEntrada
                                            ? const Color(0xFF2E7D32)
                                            : Colors.redAccent,
                                        size: 22,
                                      ),
                                    ),
                                    title: Text(
                                      transacao.title,
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                        color: const Color(0xFF1A1A2E),
                                      ),
                                    ),
                                    subtitle: Text(
                                      '${_getCategoryEmoji(transacao.category)} ${DateFormat('dd/MM/yyyy').format(transacao.date)}',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                    trailing: Text(
                                      '${isEntrada ? '+' : '-'} R\$ ${transacao.amount.toStringAsFixed(2)}',
                                      style: GoogleFonts.inter(
                                        color: isEntrada
                                            ? const Color(0xFF2E7D32)
                                            : Colors.redAccent,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                          childCount: transactionState.transactions.length,
                        ),
                      ),
                    ),

          // Padding inferior
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0077B6), Color(0xFF00B4D8)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0077B6).withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => _showTransactionModal(context, ref),
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: Text(
            'Nova Transação',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // ===== CARD DE SALDO COM GLASSMORPHISM =====
  Widget _buildBalanceCard(double balance, transactionState) {
    if (transactionState.isLoading) {
      return const BalanceCardSkeleton();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF03045E), Color(0xFF023E8A), Color(0xFF0077B6)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF03045E).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.account_balance_wallet_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Saldo Atual',
                style: GoogleFonts.inter(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AnimatedCounter(
            value: balance,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w700,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 16),
          // Receita/Despesa resumo
          Row(
            children: [
              _buildMiniStat(
                  'Receitas',
                  ref.watch(totalReceitasProvider),
                  Icons.arrow_upward_rounded,
                  const Color(0xFF4CAF50)),
              const SizedBox(width: 24),
              _buildMiniStat(
                  'Despesas',
                  ref.watch(totalDespesasProvider),
                  Icons.arrow_downward_rounded,
                  Colors.redAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(
      String label, double value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(color: Colors.white60, fontSize: 11),
            ),
            Text(
              'R\$ ${value.toStringAsFixed(2)}',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ===== SEÇÃO DE NOTÍCIAS FINANCEIRAS =====
  Widget _buildNewsSection(AsyncValue newsAsync, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.newspaper_rounded,
                    color: Color(0xFF0077B6), size: 22),
                const SizedBox(width: 8),
                Text(
                  'Notícias Financeiras',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF03045E),
                  ),
                ),
              ],
            ),
            // Botão refresh
            newsAsync.when(
              data: (_) => IconButton(
                icon: const Icon(Icons.refresh_rounded,
                    color: Color(0xFF0077B6), size: 20),
                onPressed: () => ref.invalidate(newsProvider),
                tooltip: 'Atualizar',
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
        const SizedBox(height: 12),
        newsAsync.when(
          loading: () => const NewsCardSkeleton(),
          error: (error, _) => SizedBox(
            height: 120,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cloud_off_rounded,
                      color: Colors.grey[400], size: 32),
                  const SizedBox(height: 8),
                  Text(
                    'Não foi possível carregar notícias',
                    style: GoogleFonts.inter(
                        color: Colors.grey[500], fontSize: 13),
                  ),
                  TextButton(
                    onPressed: () => ref.invalidate(newsProvider),
                    child: Text(
                      'Tentar novamente',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF0077B6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          data: (articles) {
            if (articles.isEmpty) {
              return SizedBox(
                height: 80,
                child: Center(
                  child: Text(
                    'Nenhuma notícia disponível no momento.',
                    style: GoogleFonts.inter(
                        color: Colors.grey[500], fontSize: 13),
                  ),
                ),
              );
            }

            return SizedBox(
              height: 185,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: articles.length > 10 ? 10 : articles.length,
                itemBuilder: (context, index) {
                  final article = articles[index];
                  return GestureDetector(
                    onTap: () async {
                      if (article.url != null) {
                        final uri = Uri.parse(article.url!);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri,
                              mode: LaunchMode.externalApplication);
                        }
                      }
                    },
                    child: Container(
                      width: 260,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Imagem
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16)),
                            child: article.imageUrl != null
                                ? Image.network(
                                    article.imageUrl!,
                                    height: 100,
                                    width: 260,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        _newsPlaceholder(),
                                  )
                                : _newsPlaceholder(),
                          ),
                          // Texto
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      article.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF1A1A2E),
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    article.source,
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      color: const Color(0xFF0077B6),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _newsPlaceholder() {
    return Container(
      height: 100,
      width: 260,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF03045E), Color(0xFF0077B6)],
        ),
      ),
      child: const Center(
        child: Icon(Icons.article_rounded, color: Colors.white54, size: 36),
      ),
    );
  }

  String _getCategoryEmoji(String category) {
    switch (category) {
      case 'alimentacao':
        return '🍽️';
      case 'transporte':
        return '🚗';
      case 'lazer':
        return '🎮';
      case 'salario':
        return '💰';
      default:
        return '📦';
    }
  }
}