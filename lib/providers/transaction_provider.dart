import '../data/models/transaction_model.dart';
import '../data/models/summary_model.dart';
import '../data/models/analytic/analytic_models.dart';
import '../data/services/analytics_calculator.dart';
import '../data/services/transaction_service.dart';
import 'package:flutter/material.dart';

class TransactionProvider extends ChangeNotifier {
  final List<TransactionModel> _transactions = [];

  List<TransactionModel> get transactions =>
      List.unmodifiable(_transactions);

  double get totalIncome => _transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalExpense => _transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get balance => totalIncome - totalExpense;

  SummaryModel get summary => SummaryModel(
    totalBalance: balance,
    totalIncome: totalIncome,
    totalExpense: totalExpense,
  );

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

    if (query.isNotEmpty) {
      final q = query.toLowerCase();
      result = result.where((t) {
        return t.category.toLowerCase().contains(q) ||
            t.walletName.toLowerCase().contains(q);
      }).toList();
    }

    return result;
  }

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

  // =========================
  // EXISTING (JANGAN DIUBAH)
  // =========================
  void addTransaction(TransactionModel transaction) {
    _transactions.insert(0, transaction);
    notifyListeners();
  }

  void deleteTransaction(String id) {
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  /// Update an existing transaction by ID.
  /// When backend is ready, replace with:
  /// ```dart
  /// Future<void> updateTransaction(TransactionModel updated) async {
  ///   await http.put(Uri.parse('$baseUrl/transactions/${updated.id}'),
  ///       headers: {'Authorization': 'Bearer $token',
  ///                 'Content-Type': 'application/json'},
  ///       body: json.encode(updated.toJson()));
  ///   await loadTransactions();
  /// }
  /// ```
  void updateTransaction(TransactionModel updated) {
    final index = _transactions.indexWhere((t) => t.id == updated.id);
    if (index != -1) {
      _transactions[index] = updated;
      notifyListeners();
    }
  }

  // =========================
  // 🔥 NEW (API VERSION)
  // =========================
  Future<void> addTransactionWithApi(
      TransactionModel transaction,
      String token,
      int walletId,
      int? toWalletId,
      ) async {
    final service = TransactionService();

    await service.addTransaction(
      token: token,
      walletId: walletId,
      toWalletId: toWalletId,
      title: transaction.title,
      amount: transaction.amount,
      type: transaction.type.name,
      category: transaction.category,
      date: transaction.date.toIso8601String(),
    );

    // tetap pakai logic lama biar UI update
    addTransaction(transaction);
  }
}
