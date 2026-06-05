class TransactionModel {
  final int? id;
  final int userId;
  final String title;
  final double amount;
  final DateTime date;
  final String type; // 'entrada' ou 'saida'

  TransactionModel({
    this.id, required this.userId, required this.title, 
    required this.amount, required this.date, required this.type
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id, 'userId': userId, 'title': title, 'amount': amount,
      'date': date.toIso8601String(), 'type': type,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'], userId: map['userId'], title: map['title'],
      amount: map['amount'], date: DateTime.parse(map['date']), type: map['type'],
    );
  }
}
