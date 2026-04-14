enum TransactionType { income, expense }

enum TransactionFilter { day, week, month, year, all }

class TransactionModel {
  final String id;
  final String category;
  final double amount;
  final DateTime date;
  final String walletName;
  final TransactionType type;

  TransactionModel({
    required this.id,
    required this.category,
    required this.amount,
    required this.date,
    required this.walletName,
    required this.type,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'].toString(),
      category: json['category']?.toString() ?? '',
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      walletName: json['wallet_name']?.toString() ?? '',
      type: json['type'] == 'income'
          ? TransactionType.income
          : TransactionType.expense,
    );
  }

  static List<TransactionModel> dummyList() {
    return [
      TransactionModel(
        id: '1',
        category: 'Food & Drink',
        amount: 500000,
        date: DateTime(2025, 3, 16),
        walletName: 'Gopay',
        type: TransactionType.income,
      ),
      TransactionModel(
        id: '2',
        category: 'Food & Drink',
        amount: 500000,
        date: DateTime(2025, 3, 16),
        walletName: 'Shopeepay',
        type: TransactionType.income,
      ),
      TransactionModel(
        id: '3',
        category: 'Entertainment',
        amount: 200000,
        date: DateTime(2025, 3, 16),
        walletName: 'Gopay',
        type: TransactionType.expense,
      ),
      TransactionModel(
        id: '4',
        category: 'Food & Drink',
        amount: 500000,
        date: DateTime(2025, 3, 16),
        walletName: 'Gopay',
        type: TransactionType.income,
      ),
      TransactionModel(
        id: '5',
        category: 'Transportasi',
        amount: 100000,
        date: DateTime(2025, 3, 16),
        walletName: 'Shopeepay',
        type: TransactionType.expense,
      ),
      TransactionModel(
        id: '6',
        category: 'Belanja',
        amount: 350000,
        date: DateTime(2025, 3, 10),
        walletName: 'Gopay',
        type: TransactionType.expense,
      ),
      TransactionModel(
        id: '7',
        category: 'Tabungan',
        amount: 1000000,
        date: DateTime(2025, 3, 1),
        walletName: 'BCA',
        type: TransactionType.income,
      ),
      TransactionModel(
        id: '8',
        category: 'Tabungan',
        amount: 1000000,
        date: DateTime(2025, 3, 1),
        walletName: 'BCA',
        type: TransactionType.income,
      ),
    ];
  }
}