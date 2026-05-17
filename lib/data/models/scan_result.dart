/// Model hasil scan struk dari backend AI (GeminiService).
///
/// Backend mengembalikan:
/// ```json
/// {
///   "success": true,
///   "data": {
///     "nama_toko": "Indomaret",
///     "tanggal": "2024-05-17",
///     "total": 85000,
///     "type": "expense",
///     "kategori": "Makanan",
///     "catatan": "Belanja harian"
///   }
/// }
/// ```
class ScanResult {
  /// Nama merchant / toko / pengirim gaji
  final String merchantName;

  /// Tanggal transaksi dari struk (format YYYY-MM-DD)
  final String? date;

  /// Nominal total
  final double total;

  /// Tipe: 'expense' atau 'income'
  final String type;

  /// Kategori: 'Makanan', 'Belanja', 'Gaji', 'Bonus', 'Lainnya', dll
  final String category;

  /// Deskripsi singkat dari AI
  final String? note;

  const ScanResult({
    required this.merchantName,
    required this.total,
    required this.type,
    required this.category,
    this.date,
    this.note,
  });

  factory ScanResult.fromJson(Map<String, dynamic> json) {
    // Ambil nilai dengan fallback aman
    final rawTotal = json['total'];
    final double parsedTotal = rawTotal != null
        ? (rawTotal as num).toDouble()
        : 0.0;

    return ScanResult(
      merchantName: (json['nama_toko'] as String?) ?? 'Unknown',
      total: parsedTotal,
      type: (json['type'] as String?) ?? 'expense',
      category: (json['kategori'] as String?) ?? 'Lainnya',
      date: json['tanggal'] as String?,
      note: json['catatan'] as String?,
    );
  }

  /// Apakah tipe ini income?
  bool get isIncome => type == 'income';

  @override
  String toString() =>
      'ScanResult(merchant: $merchantName, total: $total, type: $type, category: $category)';
}
