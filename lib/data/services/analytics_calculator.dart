import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../models/analytic/analytic_models.dart';

/// ══════════════════════════════════════════════════════════════
/// AnalyticsCalculator — semua kalkulasi analytics ada di sini.
///
/// Dipisahkan dari TransactionProvider agar:
///   1. Provider tetap ringan (CRUD + getters saja)
///   2. Logika kalkulasi bisa di-unit-test secara independen
///   3. Mudah di-maintain ketika ada fitur analytics baru
///
/// Penggunaan di provider:
///   final data = AnalyticsCalculator.compute(
///     transactions: _transactions,
///     start: start,
///     end: end,
///     isExpense: true,
///   );
/// ══════════════════════════════════════════════════════════════
class AnalyticsCalculator {
  AnalyticsCalculator._(); // Tidak bisa di-instantiate

  /// Hitung seluruh data analytics untuk rentang [start] - [end].
  ///
  /// [isExpense] menentukan mode (income / expense).
  /// [periodLabel] dipakai untuk pesan comparison ("week", "month", "year").
  static AnalyticSummary compute({
    required List<TransactionModel> transactions,
    required DateTime start,
    required DateTime end,
    bool isExpense = true,
    String periodLabel = 'month',
  }) {
    // ── 1. Filter transaksi dalam rentang ────────────────────
    final periodTx = transactions.where((t) {
      return !t.date.isBefore(start) &&
          t.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();

    final income = periodTx
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (s, t) => s + t.amount);
    final expense = periodTx
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (s, t) => s + t.amount);

    // ── 2. Target sesuai mode ───────────────────────────────
    final targetType =
        isExpense ? TransactionType.expense : TransactionType.income;
    final targetTotal = isExpense ? expense : income;

    // ── 3. Category breakdown ───────────────────────────────
    final targetTx = periodTx.where((t) => t.type == targetType).toList();
    final Map<String, double> catMap = {};
    for (final t in targetTx) {
      catMap[t.category] = (catMap[t.category] ?? 0) + t.amount;
    }

    final categories = catMap.entries.map((e) {
      return CategoryBreakdown(
        name: e.key,
        amount: e.value,
        percentage: targetTotal > 0 ? (e.value / targetTotal * 100) : 0,
        color: _colorForCategory(e.key),
        iconAsset: _iconForCategory(e.key),
        iconData: _materialIconForCategory(e.key),
      );
    }).toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));

    // ── 4. Daily data ───────────────────────────────────────
    final totalDays = end.difference(start).inDays + 1;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final dailyData = List.generate(totalDays, (i) {
      final date = start.add(Duration(days: i));
      if (date.isAfter(today)) return null;
      final dayTx = periodTx.where((t) {
        final td = DateTime(t.date.year, t.date.month, t.date.day);
        return td == date;
      });
      final dayIncome = dayTx
          .where((t) => t.type == TransactionType.income)
          .fold(0.0, (s, t) => s + t.amount);
      final dayExpense = dayTx
          .where((t) => t.type == TransactionType.expense)
          .fold(0.0, (s, t) => s + t.amount);
      return DailyDataPoint(
        date: date,
        income: dayIncome,
        expense: dayExpense,
        saving: dayIncome - dayExpense,
      );
    }).whereType<DailyDataPoint>().toList();

    // ── 5. Averages ─────────────────────────────────────────
    final activeDays = dailyData.length;
    final avgIncome = activeDays > 0 ? income / activeDays : 0.0;
    final avgExpense = activeDays > 0 ? expense / activeDays : 0.0;
    final avgSaving = avgIncome - avgExpense;

    // ── 6. Previous period comparison ───────────────────────
    final duration = end.difference(start);
    final prevEnd = start.subtract(const Duration(days: 1));
    final prevStart = prevEnd.subtract(duration);

    final prevTx = transactions.where((t) {
      return !t.date.isBefore(prevStart) &&
          t.date.isBefore(prevEnd.add(const Duration(days: 1)));
    }).toList();

    final prevTotal = prevTx
        .where((t) => t.type == targetType)
        .fold(0.0, (s, t) => s + t.amount);

    // Persentase perubahan
    final double changePercent;
    if (prevTotal > 0) {
      changePercent = (targetTotal - prevTotal) / prevTotal * 100;
    } else if (targetTotal > 0) {
      changePercent = double.infinity;
    } else {
      changePercent = 0.0;
    }

    // Daily arrays untuk comparison chart
    final prevDays = prevEnd.difference(prevStart).inDays + 1;
    final thisDaily = List.generate(totalDays, (i) {
      final date = start.add(Duration(days: i));
      return periodTx
          .where((t) {
            final td = DateTime(t.date.year, t.date.month, t.date.day);
            return td == date && t.type == targetType;
          })
          .fold(0.0, (s, t) => s + t.amount);
    });
    final lastDaily = List.generate(prevDays, (i) {
      final date = prevStart.add(Duration(days: i));
      return prevTx
          .where((t) {
            final td = DateTime(t.date.year, t.date.month, t.date.day);
            return td == date && t.type == targetType;
          })
          .fold(0.0, (s, t) => s + t.amount);
    });

    // ── 7. Pesan comparison ─────────────────────────────────
    final comparisonLabel = isExpense ? 'Spending' : 'Earning';
    final dailyAvg = isExpense ? avgExpense : avgIncome;

    final comparison = PeriodComparison(
      percentageChange: changePercent,
      message: changePercent.isInfinite
          ? 'First $periodLabel — no previous data.'
          : changePercent > 0
              ? '$comparisonLabel is higher than last $periodLabel.'
              : changePercent < 0
                  ? '$comparisonLabel is lower than last $periodLabel.'
                  : 'No comparison data yet.',
      currentPeriodDaily: thisDaily,
      previousPeriodDaily: lastDaily,
      dailyAverage: dailyAvg,
      projectedTotal: dailyAvg * totalDays,
    );

    // ── 8. Return ────────────────────────────────────────────
    return AnalyticSummary(
      isExpense: isExpense,
      totalIncome: income,
      totalExpense: expense,
      changePercent: changePercent,
      categories: categories,
      dailyData: dailyData,
      periodComparison: comparison,
      avgIncome: avgIncome,
      avgExpense: avgExpense,
      avgSaving: avgSaving,
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  Helpers — Warna & Icon per Kategori
  //
  //  Mapping ini digunakan untuk SEMUA kategori (income & expense).
  //  Jika kategori tidak ditemukan, fallback ke warna/icon default.
  // ═══════════════════════════════════════════════════════════

  static Color _colorForCategory(String name) {
    const map = {
      // ── Expense categories ──
      'Food & Drink': Color(0xFFFF9800),
      'Entertainment': Color(0xFFE91E63),
      'Transportation': Color(0xFF2196F3),
      'Shop': Color(0xFF4CAF50),
      // ── Income categories ──
      'Salary': Color(0xFF7C4DFF),
      'Freelance': Color(0xFF00BCD4),
      'Gift': Color(0xFFFF5722),
      'Investment': Color(0xFF009688),
    };
    return map[name] ?? const Color(0xFF9E9E9E);
  }

  static String _iconForCategory(String name) {
    const map = {
      // ── Expense categories (punya file SVG) ──
      'Food & Drink': 'assets/icon/foods.svg',
      'Entertainment': 'assets/icon/entertainment.svg',
      'Transportation': 'assets/icon/transportation.svg',
      'Shop': 'assets/icon/shop.svg',
    };
    return map[name] ?? 'assets/icon/more.svg';
  }

  /// Material Icon untuk income categories.
  /// Harus SAMA PERSIS dengan icon di [FilterIncome] (filter_income.dart).
  static IconData? _materialIconForCategory(String name) {
    const map = {
      'Salary': Icons.account_balance_wallet_rounded,
      'Freelance': Icons.work_rounded,
      'Gift': Icons.card_giftcard_rounded,
      'Investment': Icons.trending_up_rounded,
      'More': Icons.more_horiz_rounded,
    };
    return map[name];
  }
}
