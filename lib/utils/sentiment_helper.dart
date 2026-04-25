import 'package:flutter/material.dart';

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

const _green = Color(0xFF2E7D32);
const _red = Color(0xFFE53935);
const _greenBg = Color(0xFFE8F5E9);
const _redBg = Color(0xFFFDE8EC);

/// Warna teks berdasarkan sentimen.
Color sentimentColor(bool positive) => positive ? _green : _red;

/// Warna background berdasarkan sentimen.
Color sentimentBgColor(bool positive) => positive ? _greenBg : _redBg;
