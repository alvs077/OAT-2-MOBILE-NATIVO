# 💰 Controle Financeiro - App

![Status](https://img.shields.io/badge/Status-Concluído-success)
![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=flat&logo=dart&logoColor=white)
![Arquitetura](https://img.shields.io/badge/Arquitetura-MVVM-blueviolet)

Um protótipo funcional de aplicativo de controle financeiro pessoal focado em organização, design moderno e facilidade de uso. Desenvolvido como projeto acadêmico focado na composição de interfaces declarativas e padronização arquitetural.

---

## 📱 Telas e Funcionalidades

O aplicativo é composto por três módulos principais:

*   **🔐 Autenticação:** Tela de acesso inicial com alternância dinâmica entre Login (E-mail e Senha) e Cadastro completo (Nome, Telefone, E-mail, Senha e Confirmação).
*   **📊 Dashboard (Painel Principal):** Visão geral das finanças do usuário, exibindo um cartão de saldo atual em destaque e o histórico das transações mais recentes.
*   **📈 Análise de Orçamento:** Interface detalhada para acompanhamento de gastos por categoria (Alimentação, Transporte, Lazer) através de barras de progresso visuais e intuitivas.


---

## 🛠️ Tecnologias e Arquitetura

Este projeto foi construído utilizando **Flutter** e **Dart**, e estruturado utilizando o padrão de projeto **MVVM (Model-View-ViewModel)**.

A separação de pastas (`models/`, `views/`, `viewmodels/` e `widgets/`) garante:
1. **Desacoplamento:** A interface gráfica não conhece a lógica de negócios.
2. **Manutenibilidade:** Facilidade para adicionar novos recursos ou alterar o design sem quebrar a estrutura.
3. **Reusabilidade:** Componentes visuais (`widgets`) isolados para uso em múltiplas telas.

---

## 🚀 Como executar o projeto

Este projeto está configurado para rodar em ambiente Web. Siga os passos abaixo:

1. Clone o repositório:
```bash
git clone [https://github.com/SEU_USUARIO/controle_financeiro.git](https://github.com/SEU_USUARIO/controle_financeiro.git)
