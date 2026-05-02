enum TransactionType { income, expense }

enum TransactionFilter { day, week, month, year, all }

class TransactionModel {
  final String id;
  final String category;
  final String title; 
  final double amount;
  final DateTime date;
  final String walletName;
  final TransactionType type;

  TransactionModel({
    required this.id,
    required this.category,
    this.title = '',
    required this.amount,
    required this.date,
    required this.walletName,
    required this.type,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'].toString(),
      category: json['category']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      walletName: json['wallet_name']?.toString() ?? '',
      type: json['type'] == 'income'
          ? TransactionType.income
          : TransactionType.expense,
    );
  }
}
