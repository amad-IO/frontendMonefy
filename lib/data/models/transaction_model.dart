enum TransactionType { income, expense, transfer }

enum TransactionFilter { day, week, month, year, all }

class TransactionModel {
  final String id;
  final String category;
  final String title;
  final double amount;
  final DateTime date;
  final String walletName;     // From wallet (semua tipe) / sumber transfer
  final String toWalletName;   // Hanya diisi saat tipe transfer, '' untuk income/expense
  final TransactionType type;

  TransactionModel({
    required this.id,
    required this.category,
    this.title = '',
    required this.amount,
    required this.date,
    required this.walletName,
    this.toWalletName = '',
    required this.type,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    TransactionType type;
    switch (json['type']?.toString()) {
      case 'income':
        type = TransactionType.income;
        break;
      case 'transfer':
        type = TransactionType.transfer;
        break;
      default:
        type = TransactionType.expense;
    }

    return TransactionModel(
      id: json['id'].toString(),
      category: json['category']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      walletName: json['wallet_name']?.toString() ?? '',
      toWalletName: json['to_wallet_name']?.toString() ?? '',
      type: type,
    );
  }
}
