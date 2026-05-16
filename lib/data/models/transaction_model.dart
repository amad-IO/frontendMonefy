enum TransactionType { income, expense, transfer }

enum TransactionFilter { day, week, month, year, all }

class TransactionModel {
  final String id;
  final String category;
  final String title;
  final String note;          // Field 'note' dari backend (nullable → '' jika kosong)
  final double amount;
  final DateTime date;
  final String walletId;      // Integer ID wallet (untuk kirim ke backend)
  final String walletName;    // Nama wallet (untuk ditampilkan di UI)
  final String toWalletId;    // Integer ID to-wallet (hanya transfer)
  final String toWalletName;  // Nama to-wallet (untuk ditampilkan di UI)
  final TransactionType type;

  TransactionModel({
    required this.id,
    required this.category,
    this.title = '',
    this.note = '',
    required this.amount,
    required this.date,
    this.walletId = '',
    required this.walletName,
    this.toWalletId = '',
    this.toWalletName = '',
    required this.type,
  });

  // ── fromJson — membaca response backend ──────────────────────
  // Backend mengembalikan wallet sebagai relasi nested:
  //   { "wallet": { "id": 2, "name_wallet": "Cash" } }
  // dan date sebagai "transaction_date" (bukan "date")
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    final walletMap = json['wallet'] as Map<String, dynamic>?;
    final destMap   = json['destination_wallet'] as Map<String, dynamic>?;

    // Ambil tanggal dari transaction_date, jam dari created_at
    final txDate    = DateTime.tryParse(json['transaction_date']?.toString() ?? '');
    final createdAt = DateTime.tryParse(json['created_at']?.toString() ?? '')?.toLocal();
    final DateTime combinedDate;
    if (txDate != null && createdAt != null) {
      // Gabungkan: date dari transaction_date, time dari created_at
      combinedDate = DateTime(
        txDate.year, txDate.month, txDate.day,
        createdAt.hour, createdAt.minute,
      );
    } else {
      combinedDate = txDate ?? DateTime.now();
    }

    return TransactionModel(
      id:           json['id'].toString(),
      walletId:     json['wallet_id']?.toString() ?? '',
      toWalletId:   json['to_wallet_id']?.toString() ?? '',
      walletName:   walletMap?['name_wallet']?.toString() ?? '',
      toWalletName: destMap?['name_wallet']?.toString() ?? '',
      category:     json['category']?.toString() ?? '',
      title:        json['title']?.toString() ?? '',
      note:         json['note']?.toString() ?? '',
      amount:       double.tryParse(json['amount'].toString()) ?? 0.0,
      date:         combinedDate,
      type:         _typeFromString(json['type']),
    );
  }

  // ── toJson — payload yang dikirim ke backend ─────────────────
  // Field names harus sesuai dengan validation rules di backend:
  //   wallet_id, to_wallet_id, title, amount, type,
  //   category, transaction_date, note
  Map<String, dynamic> toJson() => {
    'wallet_id':        walletId.isEmpty ? null : walletId,
    'to_wallet_id':     toWalletId.isEmpty ? null : toWalletId,
    'title':            title,
    'amount':           amount,
    'type':             type.name, // 'income' | 'expense' | 'transfer'
    'category':         category,
    'transaction_date': '${date.year.toString().padLeft(4, '0')}-'
                        '${date.month.toString().padLeft(2, '0')}-'
                        '${date.day.toString().padLeft(2, '0')}',
    'note':             note.isEmpty ? null : note,
  };

  // ── copyWith — untuk update partial field saat edit ──────────
  TransactionModel copyWith({
    String? id,
    String? category,
    String? title,
    String? note,
    double? amount,
    DateTime? date,
    String? walletId,
    String? walletName,
    String? toWalletId,
    String? toWalletName,
    TransactionType? type,
  }) {
    return TransactionModel(
      id:           id           ?? this.id,
      category:     category     ?? this.category,
      title:        title        ?? this.title,
      note:         note         ?? this.note,
      amount:       amount       ?? this.amount,
      date:         date         ?? this.date,
      walletId:     walletId     ?? this.walletId,
      walletName:   walletName   ?? this.walletName,
      toWalletId:   toWalletId   ?? this.toWalletId,
      toWalletName: toWalletName ?? this.toWalletName,
      type:         type         ?? this.type,
    );
  }

  // ── Helper private ───────────────────────────────────────────
  static TransactionType _typeFromString(dynamic raw) {
    switch (raw?.toString()) {
      case 'income':   return TransactionType.income;
      case 'transfer': return TransactionType.transfer;
      default:         return TransactionType.expense;
    }
  }
}
