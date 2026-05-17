import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../../data/models/transaction_model.dart';

/// Kumpulan helper functions untuk UI transaksi.
///
/// Digunakan oleh [TransactionLoadingWidget], [TransactionSuccessWidget],
/// dan [NotifikasiTransaction] untuk mendapatkan warna & gradient
/// yang sesuai dengan tipe transaksi.
///
/// Semua fungsi bersifat pure (stateless) dan aman dipanggil dari mana saja.

/// Kembalikan [LinearGradient] sesuai tipe transaksi.
/// - Income  → [AppColors.incomeGradient]  (hijau)
/// - Expense → [AppColors.expenseGradient] (merah-oranye)
/// - Transfer → [AppColors.transferGradient] (kuning-oranye)
LinearGradient getTransactionGradient(TransactionType type) {
  switch (type) {
    case TransactionType.expense:
      return AppColors.expenseGradient;
    case TransactionType.transfer:
      return AppColors.transferGradient;
    case TransactionType.income:
      return AppColors.incomeGradient;
  }
}

/// Kembalikan warna ring/pulse sesuai tipe transaksi.
/// Dipakai untuk lingkaran background dan dots animasi loading.
Color getTransactionRingColor(TransactionType type) {
  switch (type) {
    case TransactionType.expense:
      return AppColors.expenseRingColor;
    case TransactionType.transfer:
      return AppColors.transferRingColor;
    case TransactionType.income:
      return AppColors.incomeRingColor;
  }
}

/// Kembalikan warna teks nominal (amount) sesuai tipe transaksi.
/// Dipakai di popup sukses untuk menampilkan nominal dengan warna khas.
Color getTransactionAmountColor(TransactionType type) {
  switch (type) {
    case TransactionType.expense:
      return AppColors.successExpenseText;
    case TransactionType.transfer:
      return AppColors.successTransferText;
    case TransactionType.income:
      return AppColors.successIncomeText;
  }
}

/// Kembalikan warna gelap (dark shade) sesuai tipe transaksi.
/// Dipakai untuk elemen dalam ilustrasi (lingkaran centang di bills, dll).
Color getTransactionDarkColor(TransactionType type) {
  switch (type) {
    case TransactionType.expense:
      return const Color(0xFFB71C1C);
    case TransactionType.transfer:
      return const Color(0xFFE65100);
    case TransactionType.income:
      return AppColors.transactionCardGreen;
  }
}
