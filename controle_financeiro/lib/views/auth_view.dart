import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import do Riverpod
import '../viewmodels/finance_provider.dart';

// Agora a tela é um ConsumerStatefulWidget
class AuthView extends ConsumerStatefulWidget {
  const AuthView({super.key});

  @override
  ConsumerState<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends ConsumerState<AuthView> {
  final _formKey = GlobalKey<FormState>();
  bool isLogin = true;

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFF03045E), Color(0xFF00B4D8)]),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.account_balance_wallet_rounded, size: 64, color: Color(0xFF03045E)),
                      const SizedBox(height: 16),
                      Text(
                        isLogin ? 'Login' : 'Criar Conta',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 32),

                      if (!isLogin) ...[
                        TextFormField(
                          controller: _nameCtrl,
                          decoration: InputDecoration(
                            labelText: 'Nome Completo',
                            prefixIcon: const Icon(Icons.person_outline),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          validator: (value) => value!.isEmpty ? 'Preencha seu nome' : null,
                        ),
                        const SizedBox(height: 16),
                      ],

                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'E-mail',
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) => !value!.contains('@') ? 'E-mail inválido' : null,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _passCtrl,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Senha',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) => value!.length < 4 ? 'A senha deve ter 4+ caracteres' : null,
                      ),
                      const SizedBox(height: 24),

                      FilledButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            // Usamos ref.read para ler o provedor e executar a ação
                            final controller = ref.read(financeProvider);
                            bool success;
                            
                            if (isLogin) {
                              success = await controller.login(_emailCtrl.text, _passCtrl.text);
                            } else {
                              success = await controller.register(_nameCtrl.text, _emailCtrl.text, _passCtrl.text);
                              if (success) {
                                success = await controller.login(_emailCtrl.text, _passCtrl.text);
                              }
                            }

                            if (success && context.mounted) {
                              Navigator.pushReplacementNamed(context, '/dashboard');
                            } else if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Erro: E-mail já existe ou senha incorreta!')),
                              );
                            }
                          }
                        },
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: const Color(0xFF0077B6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(isLogin ? 'ENTRAR' : 'CADASTRAR'),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => setState(() => isLogin = !isLogin),
                        child: Text(isLogin ? 'Não tem conta? Cadastre-se' : 'Já tem conta? Faça Login'),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}