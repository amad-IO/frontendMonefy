class Saving {
  final int? id;
  final String name;
  final int amount;
  final int target;
  final String date;
  final String status;

  Saving({
    this.id,
    required this.name,
    required this.amount,
    required this.target,
    required this.date,
    required this.status,
  });

  /// 🔹 FROM JSON (SUDAH AMAN 100%)
  factory Saving.fromJson(Map<String, dynamic> json) {
    return Saving(
      id: json['id'],

      /// 🔥 AMANIN STRING
      name: json['name']?.toString() ?? '',

      /// 🔥 BACKEND NGGAK ADA → DEFAULT
      amount: 0,

      /// 🔥 FIX UTAMA (HANDLE "0.00")
      target: int.tryParse(
        (json['target_amount'] ?? '0').toString().split('.').first,
      ) ?? 0,

      /// 🔥 AMANIN NULL
      date: json['date']?.toString() ?? "-",

      /// 🔥 INI PENTING UNTUK ONGOING / DONE
      status: json['status']?.toString() ?? 'belum_terbeli',
    );
  }

  /// 🔹 TO JSON
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

  /// 🔹 COPY WITH
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