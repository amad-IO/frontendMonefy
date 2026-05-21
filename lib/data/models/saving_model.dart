class Saving {
  final int? id;
  final String name;
  final int amount;
  final int target;
  final String date;
  final String status; // 🔥 TAMBAHAN PENTING

  Saving({
    this.id,
    required this.name,
    required this.amount,
    required this.target,
    required this.date,
    required this.status,
  });

  /// 🔹 dari JSON (FIXED)
  factory Saving.fromJson(Map<String, dynamic> json) {
    return Saving(
      id: json['id'],
      name: json['name'] ?? '',

      /// 🔥 backend nggak punya amount → default 0
      amount: 0,

      /// 🔥 FIX: pakai target_amount dari backend
      target: (json['target_amount'] ?? 0).toInt(),

      /// 🔥 backend nggak punya date → default
      date: json['date'] ?? "-",

      /// 🔥 INI KUNCI
      status: json['status'] ?? 'belum_terbeli',
    );
  }

  /// 🔹 ke JSON
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "amount": amount,
      "target": target,
      "date": date,
      "status": status,
    };
  }

  /// 🔹 copyWith
  Saving copyWith({
    int? id,
    String? name,
    int? amount,
    int? target,
    String? date,
    String? status,
  }) {
    return Saving(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      target: target ?? this.target,
      date: date ?? this.date,
      status: status ?? this.status,
    );
  }
}