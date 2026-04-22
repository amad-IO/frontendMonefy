import '../models/transaction_model.dart';
import '../models/summary_model.dart';
import '../models/analytic_model.dart';
import 'package:flutter/material.dart';

/// Centralized state manager for all transactions.
///
/// Architecture note: Currently in-memory only.
/// When backend is ready, replace the body of [addTransaction],
/// [deleteTransaction], and add a [loadTransactions] that calls
/// your REST API. The rest of the app won't need any changes.
class TransactionProvider extends ChangeNotifier {
  final List<TransactionModel> _transactions = [];

  // ═══════════════════════════════════════════════════════════
  //  Getters
  // ═══════════════════════════════════════════════════════════

  List<TransactionModel> get transactions =>
      List.unmodifiable(_transactions);

  double get totalIncome => _transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalExpense => _transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get balance => totalIncome - totalExpense;

  /// Summary for the SummaryCard widget on the dashboard.
  SummaryModel get summary => SummaryModel(
        totalBalance: balance,
        totalIncome: totalIncome,
        totalExpense: totalExpense,
      );

  // ═══════════════════════════════════════════════════════════
  //  Filtered list (for History & Dashboard)
  // ═══════════════════════════════════════════════════════════

  List<TransactionModel> getFiltered(
    TransactionFilter filter, {
    String query = '',
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    List<TransactionModel> result;

    switch (filter) {
      case TransactionFilter.day:
        result = _transactions.where((t) {
          final d = DateTime(t.date.year, t.date.month, t.date.day);
          return d == today;
        }).toList();
        break;

      case TransactionFilter.week:
        final weekStart = today.subtract(Duration(days: today.weekday - 1));
        result = _transactions.where((t) {
          final d = DateTime(t.date.year, t.date.month, t.date.day);
          return !d.isBefore(weekStart) && !d.isAfter(today);
        }).toList();
        break;

      case TransactionFilter.month:
        result = _transactions.where((t) {
          return t.date.year == now.year && t.date.month == now.month;
        }).toList();
        break;

      case TransactionFilter.year:
        result = _transactions.where((t) {
          return t.date.year == now.year;
        }).toList();
        break;

      case TransactionFilter.all:
        result = List.of(_transactions);
        break;
    }

    // Apply search query
    if (query.isNotEmpty) {
      final q = query.toLowerCase();
      result = result.where((t) {
        return t.category.toLowerCase().contains(q) ||
            t.walletName.toLowerCase().contains(q);
      }).toList();
    }

    return result;
  }

  // ═══════════════════════════════════════════════════════════
  //  Analytics computed data
  // ═══════════════════════════════════════════════════════════

  AnalyticSummary getAnalytics(DateTime month) {
    // Filter transactions for the given month
    final monthTx = _transactions.where((t) {
      return t.date.year == month.year && t.date.month == month.month;
    }).toList();

    final income = monthTx
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (s, t) => s + t.amount);

    final expense = monthTx
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (s, t) => s + t.amount);

    // ── Category breakdown (expenses) ──
    final expenseTx =
        monthTx.where((t) => t.type == TransactionType.expense).toList();
    final Map<String, double> catMap = {};
    for (final t in expenseTx) {
      catMap[t.category] = (catMap[t.category] ?? 0) + t.amount;
    }

    final categories = catMap.entries.map((e) {
      return CategoryBreakdown(
        name: e.key,
        amount: e.value,
        percentage: expense > 0 ? (e.value / expense * 100) : 0,
        color: _colorForCategory(e.key),
        iconAsset: _iconForCategory(e.key),
      );
    }).toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));

    // ── Daily data ──
    final daysInMonth =
        DateTime(month.year, month.month + 1, 0).day;
    final int today = DateTime.now().day;
    final int maxDay = (month.year == DateTime.now().year &&
            month.month == DateTime.now().month)
        ? today
        : daysInMonth;

    final dailyData = List.generate(maxDay, (i) {
      final day = i + 1;
      final dayTx = monthTx.where((t) => t.date.day == day);
      final dayIncome = dayTx
          .where((t) => t.type == TransactionType.income)
          .fold(0.0, (s, t) => s + t.amount);
      final dayExpense = dayTx
          .where((t) => t.type == TransactionType.expense)
          .fold(0.0, (s, t) => s + t.amount);
      return DailyDataPoint(
        date: DateTime(month.year, month.month, day),
        income: dayIncome,
        expense: dayExpense,
        saving: dayIncome - dayExpense,
      );
    });

    // ── Averages ──
    final avgIncome = maxDay > 0 ? income / maxDay : 0.0;
    final avgExpense = maxDay > 0 ? expense / maxDay : 0.0;
    final avgSaving = avgIncome - avgExpense;

    // ── Previous month comparison ──
    final prevMonth = DateTime(month.year, month.month - 1);
    final prevTx = _transactions.where((t) {
      return t.date.year == prevMonth.year &&
          t.date.month == prevMonth.month;
    }).toList();
    final prevExpense = prevTx
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (s, t) => s + t.amount);

    final changePercent = prevExpense > 0
        ? ((expense - prevExpense) / prevExpense * 100)
        : 0.0;

    // Daily spending arrays for comparison chart
    final prevDaysInMonth =
        DateTime(prevMonth.year, prevMonth.month + 1, 0).day;
    final thisMonthDaily = List.generate(daysInMonth, (i) {
      final day = i + 1;
      return monthTx
          .where((t) =>
              t.type == TransactionType.expense && t.date.day == day)
          .fold(0.0, (s, t) => s + t.amount);
    });
    final lastMonthDaily = List.generate(prevDaysInMonth, (i) {
      final day = i + 1;
      return prevTx
          .where((t) =>
              t.type == TransactionType.expense && t.date.day == day)
          .fold(0.0, (s, t) => s + t.amount);
    });

    final comparison = MonthlyComparison(
      percentageChange: changePercent,
      message: changePercent > 0
          ? 'Spending is higher than last month.'
          : changePercent < 0
              ? 'Spending is lower than last month.'
              : 'No comparison data yet.',
      thisMonthDaily: thisMonthDaily,
      lastMonthDaily: lastMonthDaily,
      dailyAverage: avgExpense,
      projectedTotal: avgExpense * daysInMonth,
    );

    return AnalyticSummary(
      totalIncome: income,
      totalExpense: expense,
      expenseChangePercent: changePercent,
      categories: categories,
      dailyData: dailyData,
      monthlyComparison: comparison,
      avgIncome: avgIncome,
      avgExpense: avgExpense,
      avgSaving: avgSaving,
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  Mutations
  // ═══════════════════════════════════════════════════════════

  /// Add a new transaction. When backend is ready, replace with:
  /// ```dart
  /// Future<void> addTransaction(TransactionModel t) async {
  ///   await http.post(Uri.parse('$baseUrl/transactions'), body: t.toJson());
  ///   await loadTransactions();
  /// }
  /// ```
  void addTransaction(TransactionModel transaction) {
    _transactions.insert(0, transaction); // newest first
    notifyListeners();
  }

  /// Delete a transaction by ID.
  void deleteTransaction(String id) {
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════
  //  Helpers
  // ═══════════════════════════════════════════════════════════

  static Color _colorForCategory(String name) {
    const map = {
      'Food & Drink': Color(0xFFFF9800),
      'Entertainment': Color(0xFFE91E63),
      'Transportation': Color(0xFF2196F3),
      'Shop': Color(0xFF4CAF50),
      'Salary': Color(0xFF7C4DFF),
      'Freelance': Color(0xFF00BCD4),
      'Gift': Color(0xFFFF5722),
      'Investment': Color(0xFF009688),
    };
    return map[name] ?? const Color(0xFF9E9E9E);
  }

  static String _iconForCategory(String name) {
    const map = {
      'Food & Drink': 'assets/icon/foods.svg',
      'Entertainment': 'assets/icon/entertainment.svg',
      'Transportation': 'assets/icon/transportation.svg',
      'Shop': 'assets/icon/shop.svg',
    };
    return map[name] ?? 'assets/icon/more.svg';
  }
}
