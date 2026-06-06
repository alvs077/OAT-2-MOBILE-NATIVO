/// Modelo de transação financeira com suporte a categorias.
class TransactionModel {
  final int? id;
  final int userId;
  final String title;
  final double amount;
  final DateTime date;
  final String type; // 'entrada' ou 'saida'
  final String category; // 'alimentacao', 'transporte', 'lazer', 'salario', 'outros'

  TransactionModel({
    this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
    this.category = 'outros',
  });

  TransactionModel copyWith({
    int? id,
    int? userId,
    String? title,
    double? amount,
    DateTime? date,
    String? type,
    String? category,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      type: type ?? this.type,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'type': type,
      'category': category,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      userId: map['userId'],
      title: map['title'],
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date']),
      type: map['type'],
      category: map['category'] ?? 'outros',
    );
  }

  /// Retorna ícone e cor associados à categoria.
  static Map<String, dynamic> categoryMeta(String category) {
    switch (category) {
      case 'alimentacao':
        return {'label': 'Alimentação', 'icon': 0xe532}; // Icons.restaurant
      case 'transporte':
        return {'label': 'Transporte', 'icon': 0xe1d7}; // Icons.directions_car
      case 'lazer':
        return {'label': 'Lazer', 'icon': 0xe5f5}; // Icons.sports_esports
      case 'salario':
        return {'label': 'Salário', 'icon': 0xf578}; // Icons.payments
      default:
        return {'label': 'Outros', 'icon': 0xe22b}; // Icons.category
    }
  }
}
