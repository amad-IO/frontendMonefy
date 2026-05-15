import 'package:intl/intl.dart';
import '../../data/models/transaction_model.dart';

/// Kumpulan helper function untuk logika bisnis di AddPage.
/// Dipisah dari UI agar mudah di-test dan di-maintain.
class AddPageHelper {
  /// Format angka menjadi "Rp. 100.000"
  static String formatAmount(String rawText) {
    final toParse = rawText.trim();
    final amount = double.tryParse(toParse) ?? 0;
    final formatter = NumberFormat('#,##0', 'id_ID');
    return 'Rp. ${formatter.format(amount)}';
  }

  /// Tentukan category string berdasarkan type transaksi dan pilihan user.
  /// Return 'Transfer' jika transfer, atau category yang dipilih.
  static String resolveCategory({
    required TransactionType type,
    required String? selectedCategory,
  }) {
    if (type == TransactionType.transfer) return 'Transfer';
    if (type == TransactionType.expense) return selectedCategory ?? 'Expense';
    return selectedCategory ?? 'Income';
  }

  /// Tentukan title: hanya diisi jika category == 'More'.
  static String resolveTitle({
    required String category,
    required String rawTitle,
    required TransactionType type,
  }) {
    if (type != TransactionType.transfer && category == 'More') {
      return rawTitle.trim();
    }
    return '';
  }

  /// Validasi input sebelum simpan.
  /// Return pesan error atau null jika valid.
  static String? validate({
    required double amount,
    required String? selectedWallet,
    required TransactionType type,
    required String? selectedToWallet,
  }) {
    if (amount <= 0) return 'Masukkan nominal terlebih dahulu!';
    if (selectedWallet == null) return 'Pilih penyimpanan terlebih dahulu!';
    if (type == TransactionType.transfer && selectedToWallet == null) {
      return 'Pilih wallet tujuan transfer!';
    }
    return null; // valid
  }
}
