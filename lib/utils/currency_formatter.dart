import 'package:intl/intl.dart';

/// ══════════════════════════════════════════════════════════════
/// Formatter Rupiah — satu instance untuk seluruh app.
///
/// Contoh penggunaan:
///   rupiahFormatter.format(150000)  → "Rp150.000"
/// ══════════════════════════════════════════════════════════════
final rupiahFormatter = NumberFormat.currency(
  locale: 'id_ID',
  symbol: 'Rp',
  decimalDigits: 0,
);
