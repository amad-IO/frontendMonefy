class Saving {
  final int? id; // ✅ UBAH JADI OPTIONAL
  final String name;
  final int amount;
  final int target;

  Saving({
    this.id, // ❌ hilangkan required
    required this.name,
    required this.amount,
    required this.target,
  });

  /// dari JSON (backend → frontend)
  factory Saving.fromJson(Map<String, dynamic> json) {
    return Saving(
      id: json['id'], // ✅ gak perlu ?? 0 lagi
      name: json['name'] ?? '',
      amount: json['amount'] ?? 0,
      target: json['target'] ?? 0,
    );
  }

  /// ke JSON (frontend → backend)
  Map<String, dynamic> toJson() {
    return {
      "id": id, // boleh null
      "name": name,
      "amount": amount,
      "target": target,
    };
  }
}