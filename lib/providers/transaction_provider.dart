import '../models/transaction_model.dart';
import '../models/summary_model.dart';
import '../models/analytic/analytic_models.dart';
import 'analytics_calculator.dart';
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
  //  Analytics — delegasi ke AnalyticsCalculator
  //
  //  Provider hanya menjadi "bridge" antara data dan kalkulator.
  //  Semua logika kalkulasi ada di analytics_calculator.dart.
  // ═══════════════════════════════════════════════════════════

  AnalyticSummary getAnalytics({
    required DateTime start,
    required DateTime end,
    bool isExpense = true,
    String periodLabel = 'month',
  }) {
    return AnalyticsCalculator.compute(
      transactions: _transactions,
      start: start,
      end: end,
      isExpense: isExpense,
      periodLabel: periodLabel,
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
}
