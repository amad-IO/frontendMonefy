import 'package:flutter/material.dart';
import '../data/models/transaction_model.dart';
import '../data/models/summary_model.dart';
import '../data/models/analytic/analytic_models.dart';
import '../data/services/analytics_calculator.dart';
import '../data/services/transaction_service.dart';
import '../data/services/dashboard_service.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionService _txService = TransactionService();
  final DashboardService _dashService = DashboardService();

  List<TransactionModel> _transactions = [];
  SummaryModel? _backendSummary;
  bool _isLoading = false;
  String? _error;

  // ── Getters ────────────────────────────────────────────────────
  List<TransactionModel> get transactions => List.unmodifiable(_transactions);
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get totalIncome => _transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalExpense => _transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get balance => totalIncome - totalExpense;

  /// Summary: gunakan data backend jika sudah loaded, fallback ke computed lokal
  SummaryModel get summary => _backendSummary ??
      SummaryModel(
        totalBalance: balance,
        totalIncome: totalIncome,
        totalExpense: totalExpense,
      );

  // ── Load Transactions dari Backend ─────────────────────────────
  /// Panggil GET /transactions, update state.
  Future<void> loadTransactions(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _transactions = await _txService.getTransactions(token);
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ loadTransactions error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Load Summary dari Backend ──────────────────────────────────
  /// Panggil GET /dashboard/summary, update _backendSummary.
  Future<void> loadSummary(String token) async {
    try {
      _backendSummary = await _dashService.getSummary(token);
      notifyListeners();
    } catch (e) {
      debugPrint('❌ loadSummary error: $e');
    }
  }

  // ── Load All (summary + transactions) ─────────────────────────
  Future<void> loadAll(String token) async {
    await Future.wait([
      loadTransactions(token),
      loadSummary(token),
    ]);
  }

  // ── Enrich toWalletName dari daftar wallet ──────────────────────
  /// Backend tidak eager-load destinationWallet di GET /transactions,
  /// sehingga toWalletName selalu kosong.
  /// Method ini mengisi toWalletName dengan lookup ke daftar wallet.
  /// Panggil setelah loadAll() + loadWalletsFromApi() selesai.
  void enrichToWalletNames(List<dynamic> wallets) {
    if (wallets.isEmpty) return;
    bool changed = false;
    _transactions = _transactions.map((t) {
      if (t.toWalletId.isNotEmpty && t.toWalletName.isEmpty) {
        // Cari wallet dengan id yang cocok
        final dest = wallets.cast<dynamic>().firstWhere(
          (w) => w.id == t.toWalletId,
          orElse: () => null,
        );
        if (dest != null) {
          changed = true;
          return t.copyWith(toWalletName: dest.name as String);
        }
      }
      return t;
    }).toList();
    if (changed) notifyListeners();
  }

  // ── Add Transaction via API ─────────────────────────────────────
  Future<void> addTransactionWithApi(
    TransactionModel transaction,
    String token, {
    required String walletId,
    String? toWalletId,
  }) async {
    await _txService.addTransaction(
      token: token,
      walletId: walletId,
      toWalletId: toWalletId,
      title: transaction.title.isEmpty ? transaction.category : transaction.title,
      amount: transaction.amount,
      type: transaction.type.name,
      category: transaction.category,
      date: '${transaction.date.year.toString().padLeft(4, '0')}-'
            '${transaction.date.month.toString().padLeft(2, '0')}-'
            '${transaction.date.day.toString().padLeft(2, '0')}',
      note: transaction.note.isEmpty ? null : transaction.note,
    );

    // Refresh data dari backend setelah berhasil add
    await loadAll(token);
  }

  // ── Update Transaction via API ─────────────────────────────────
  Future<void> updateTransactionWithApi(
    TransactionModel updated,
    String token,
  ) async {
    final payload = <String, dynamic>{
      'title': updated.title,
      'amount': updated.amount,
      'category': updated.category,
      'transaction_date': '${updated.date.year.toString().padLeft(4, '0')}-'
                          '${updated.date.month.toString().padLeft(2, '0')}-'
                          '${updated.date.day.toString().padLeft(2, '0')}',
    };
    if (updated.note.isNotEmpty) payload['note'] = updated.note;

    final ok = await _txService.updateTransaction(updated.id, payload, token);
    if (ok) {
      await loadAll(token);
    } else {
      throw Exception('Gagal update transaksi');
    }
  }

  // ── Delete Transaction via API ─────────────────────────────────
  Future<void> deleteTransactionWithApi(String id, String token) async {
    final ok = await _txService.deleteTransaction(id, token);
    if (ok) {
      await loadAll(token);
    } else {
      throw Exception('Gagal hapus transaksi');
    }
  }

  // ── Local-only methods (tetap ada untuk backward compat) ────────
  void addTransaction(TransactionModel transaction) {
    _transactions = [transaction, ..._transactions];
    notifyListeners();
  }

  void deleteTransaction(String id) {
    _transactions = _transactions.where((t) => t.id != id).toList();
    notifyListeners();
  }

  void updateTransaction(TransactionModel updated) {
    final index = _transactions.indexWhere((t) => t.id == updated.id);
    if (index != -1) {
      _transactions = List.of(_transactions)..[index] = updated;
      notifyListeners();
    }
  }

  // ── Filter & Analytics ─────────────────────────────────────────
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
}
