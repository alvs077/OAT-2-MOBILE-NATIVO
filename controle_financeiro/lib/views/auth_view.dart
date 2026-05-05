import 'package:flutter/material.dart';

class AuthView extends StatefulWidget {
  const AuthView({super.key});

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  bool isLogin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF03045E), Color(0xFF00B4D8)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.account_balance_wallet_rounded, size: 64, color: Color(0xFF03045E)),
                    const SizedBox(height: 16),
                    Text(
                      isLogin ? 'Bem-vindo de volta!' : 'Crie sua conta',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 32),

                    // ==========================================
                    // CAMPOS EXCLUSIVOS DA TELA DE CADASTRO
                    // ==========================================
                    if (!isLogin) ...[
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Nome Completo',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        keyboardType: TextInputType.phone, // Abre o teclado numérico no celular
                        decoration: InputDecoration(
                          labelText: 'Telefone / WhatsApp',
                          prefixIcon: const Icon(Icons.phone_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // ==========================================
                    // CAMPOS COMUNS (APARECEM NO LOGIN E CADASTRO)
                    // ==========================================
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'E-mail',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ==========================================
                    // CAMPO EXCLUSIVO DE CONFIRMAR SENHA
                    // ==========================================
                    if (!isLogin) ...[
                      TextFormField(
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Confirmar Senha',
                          prefixIcon: const Icon(Icons.lock_reset),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    const SizedBox(height: 8),

                    // BOTÃO PRINCIPAL
                    FilledButton(
                      onPressed: () => Navigator.pushReplacementNamed(context, '/dashboard'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        backgroundColor: const Color(0xFF0077B6),
                      ),
                      child: Text(
                        isLogin ? 'ENTRAR' : 'CADASTRAR', 
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // BOTÃO DE ALTERNAR (LOGIN <-> CADASTRO)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          isLogin = !isLogin;
                        });
                      },
                      child: Text(
                        isLogin ? 'Não tem conta? Cadastre-se' : 'Já tem conta? Faça Login',
                        style: const TextStyle(color: Color(0xFF03045E), fontWeight: FontWeight.w600),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}