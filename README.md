<h1 align="center">
  💰 Controle Financeiro App
</h1>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" />
  <img src="https://img.shields.io/badge/Riverpod-000000?style=for-the-badge&logo=dart&logoColor=white" />
  <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" />
  <img src="https://img.shields.io/badge/SQLite-003B57?style=for-the-badge&logo=sqlite&logoColor=white" />
</p>

<p align="center">
  Um aplicativo de gestão financeira completo com arquitetura robusta (Offline-first), foco em UX Premium e as melhores práticas do ecossistema Flutter. 🚀
</p>

---

## 📱 O que é este projeto?

O **Controle Financeiro** é um aplicativo mobile nativo desenvolvido em Flutter que permite aos usuários gerenciar suas receitas e despesas de forma inteligente. Ele foi projetado para simular uma experiência de *fintech* real, entregando uma interface moderna, transições suaves e tratamento robusto de dados.

Este projeto foi construído para demonstrar habilidades avançadas no ecossistema Mobile:
- Arquitetura limpa e escalável
- Gerenciamento de estado avançado
- Estratégias Offline-First (Sincronização em Background)
- UX/UI Premium

---

## ✨ Principais Funcionalidades

- 🔒 **Sistema de Autenticação:** Login e Cadastro com verificação em tempo real (Firebase Auth + Fallback local).
- 📊 **Dashboard Dinâmico:** Visão geral de saldo com efeito *Glassmorphism* e contador animado (`AnimatedCounter`).
- 📰 **Feed de Notícias:** Integração com API externa (`NewsAPI`) que traz as últimas notícias do mercado financeiro, com imagens carregadas via cache e *Skeleton Screens* durante o carregamento.
- 💸 **Gestão de Transações:** Adição e listagem de receitas e despesas com categorização (emojis intuitivos) e funcionalidade *Swipe-to-Delete*.
- 📈 **Análise de Orçamento:** Telas de estatísticas que geram dicas dinâmicas (ex: alertas de saldo negativo ou sugestões de corte de gastos na categoria mais custosa).

---

## 🛠️ Tecnologias e Arquitetura

O projeto foi construído utilizando o que há de mais moderno na stack do Flutter:

* **[Flutter & Dart](https://flutter.dev/):** Desenvolvimento cross-platform performático (Android/iOS).
* **[Riverpod (StateNotifier)](https://riverpod.dev/):** Gerenciamento de Estado de forma imutável e previsível, superando as limitações do Provider tradicional.
* **[Injeção de Dependência (DI) Centralizada](https://en.wikipedia.org/wiki/Dependency_injection):** Desacoplamento completo da UI da lógica de negócios e persistência.
* **[SQLite (sqflite)](https://pub.dev/packages/sqflite):** Banco de dados relacional local, permitindo que o app funcione `100% offline`.
* **[Firebase (Firestore & Auth) - Opcional](https://firebase.google.com/):** Sistema de sincronização em nuvem silenciosa (*background sync*). Se não houver internet, o app opera com SQLite e tenta sincronizar depois.
* **[Design Premium]:** `Google Fonts (Inter)`, animações de transição de rota (`Fade` e `Slide`), Skeleton Loaders (shimmer effect) e tratamento de erros visuais (SnackBars customizados).

---

## 🎯 Arquitetura de Estado (Riverpod)

O projeto abandonou a arquitetura legada (onde tudo era centralizado em um único arquivo gigante) e adotou uma abordagem modular:

```dart
// 1. Provedores de Dependência (DI)
final sqliteHelperProvider = Provider((ref) => SQLiteHelper());
final apiServiceProvider = Provider((ref) => ApiService());

// 2. Provedores de Estado Reativo
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) => ...);
final transactionProvider = StateNotifierProvider<TransactionNotifier, TransactionState>((ref) => ...);

// 3. Provedores Derivados
final totalBalanceProvider = Provider<double>((ref) {
  final state = ref.watch(transactionProvider);
  // Cálculo de saldo reativo
});
```

---

## ⬇️ Como testar o aplicativo? (Download APK)

Para os recrutadores e desenvolvedores que desejam ver o app rodando sem precisar compilar o código, disponibilizei o **APK de instalação direta** para Android:

1. Baixe o arquivo **[app-debug.apk](./controle_financeiro/build/app/outputs/flutter-apk/app-debug.apk)** ou compile via terminal:
```bash
flutter build apk --debug
```
2. Instale no seu smartphone Android.
3. Crie uma conta no app (os dados ficam salvos localmente e o app suporta funcionamento offline).

---

## 💡 Próximos Passos (Roadmap)
- [ ] Implementação de gráficos de pizza/barras com a biblioteca `fl_chart`.
- [ ] Filtros avançados por mês e ano.
- [ ] Exportação de relatórios em PDF/CSV.

---

<p align="center">
  <i>Desenvolvido com 💙 em Flutter. Se você gostou do projeto, não esqueça de deixar uma ⭐!</i><br>
  <strong>Pronto para fazer a diferença em equipes Mobile de alto nível.</strong>
</p>
