class Saving {
  final int? id;
  final String name;
  final int amount;
  final int target;
  final String date;

  Saving({
    this.id,
    required this.name,
    required this.amount,
    required this.target,
    required this.date,
  });

  /// 🔹 dari JSON
  factory Saving.fromJson(Map<String, dynamic> json) {
    return Saving(
      id: json['id'],
      name: json['name'] ?? '',
      amount: json['amount'] ?? 0,
      target: json['target'] ?? 0,
      date: json['date'] ?? "-",
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
    };
  }

  /// INI YANG KURANG (WAJIB)
  Saving copyWith({
    int? id,
    String? name,
    int? amount,
    int? target,
    String? date,
  }) {
    return Saving(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      target: target ?? this.target,
      date: date ?? this.date,
    );
  }
}