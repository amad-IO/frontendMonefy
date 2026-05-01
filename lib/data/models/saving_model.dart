class Saving {
  final int id;
  final String name;
  final int amount;
  final int target;

  Saving({
    required this.id,
    required this.name,
    required this.amount,
    required this.target,
  });

  /// 🔥 dari JSON (backend → frontend)
  factory Saving.fromJson(Map<String, dynamic> json) {
    return Saving(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      amount: json['amount'] ?? 0,
      target: json['target'] ?? 0,
    );
  }

  /// 🔥 ke JSON (frontend → backend)
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "amount": amount,
      "target": target,
    };
  }
}