import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// ══════════════════════════════════════════════════════════════
/// Sentiment Helper — logika warna terbalik Income vs Expense.
///
/// Aturan:
///   • Expense naik  → 🔴 BURUK (pengeluaran bertambah)
///   • Expense turun → 🟢 BAGUS (pengeluaran berkurang)
///   • Income naik   → 🟢 BAGUS (pemasukan bertambah)
///   • Income turun  → 🔴 BURUK (pemasukan berkurang)
///
/// Dipakai oleh: ExpenseAlertCard, MonthlyComparisonCard
/// ══════════════════════════════════════════════════════════════

/// Apakah perubahan ini sentimen positif?
bool isPositiveSentiment({required bool isExpense, required bool isUp}) {
  return isExpense ? !isUp : isUp;
}

// ── Warna ─────────────────────────────────────────────────────

/// Warna teks berdasarkan sentimen.
Color sentimentColor(bool positive) => positive ? AppColors.sentimentGreen : AppColors.sentimentRed;

/// Warna background berdasarkan sentimen.
Color sentimentBgColor(bool positive) => positive ? AppColors.incomeGreenBg : AppColors.expenseRedBg;
