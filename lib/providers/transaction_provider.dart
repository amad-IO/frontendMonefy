import 'package:flutter/material.dart';
import '../data/models/transaction_model.dart';
import '../data/models/summary_model.dart';
import '../data/models/analytic/analytic_models.dart';
import '../data/services/analytics_calculator.dart';
import '../data/services/transaction_service.dart';
import '../data/services/dashboard_service.dart';
import '../data/services/cache_service.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionService _txService = TransactionService();
  final DashboardService _dashService = DashboardService();

  List<TransactionModel> _transactions = [];
  SummaryModel? _backendSummary;
  bool _isLoading = false;
  String? _error;

  // Helper untuk update summary lokal secara instan (optimistic)
  void _updateSummaryOptimistic({
    TransactionModel? oldTx,
    TransactionModel? newTx,
  }) {
    if (_backendSummary == null) return;

    double incomeDelta = 0;
    double expenseDelta = 0;

    if (oldTx != null) {
      if (oldTx.type == TransactionType.income) incomeDelta -= oldTx.amount;
      if (oldTx.type == TransactionType.expense) expenseDelta -= oldTx.amount;
    }

    if (newTx != null) {
      if (newTx.type == TransactionType.income) incomeDelta += newTx.amount;
      if (newTx.type == TransactionType.expense) expenseDelta += newTx.amount;
    }

    _backendSummary = SummaryModel(
      totalBalance: _backendSummary!.totalBalance + incomeDelta - expenseDelta,
      totalIncome: _backendSummary!.totalIncome + incomeDelta,
      totalExpense: _backendSummary!.totalExpense + expenseDelta,
      filterLabel: _backendSummary!.filterLabel,
    );
  }

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
  SummaryModel get summary =>
      _backendSummary ??
      SummaryModel(
        totalBalance: balance,
        totalIncome: totalIncome,
        totalExpense: totalExpense,
      );

  // ── Load Transactions: Cache-first, lalu background fetch ──────
  /// Langkah 1: load dari cache lokal → UI tampil instan.
  /// Langkah 2: fetch dari server di background → update cache.
  Future<void> loadTransactions(String token) async {
    // 1. Load dari cache dulu jika ada → tampil instan
    if (CacheService.hasTransactions()) {
      _transactions = CacheService.getTransactions();
      _isLoading = false;
      _error = null;
      notifyListeners();
    } else {
      // Tidak ada cache → tampil loading spinner
      _isLoading = true;
      _error = null;
      notifyListeners();
    }

    // 2. Fetch fresh dari server (background)
    try {
      final fresh = await _txService.getTransactions(token);
      _transactions = fresh;
      await CacheService.saveTransactions(fresh); // update cache
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
    await Future.wait([loadTransactions(token), loadSummary(token)]);
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

  // ── Add Transaction via API (Optimistic Update) ────────────────
  /// Strategi:
  /// 1. Tambah ke list lokal + cache LANGSUNG (optimistic)
  /// 2. POST ke server di background
  /// 3. Jika sukses → fetch ulang untuk dapat ID asli + balance update
  /// 4. Jika gagal → rollback list + cache + lempar error ke UI
  Future<void> addTransactionWithApi(
    TransactionModel transaction,
    String token, {
    required String walletId,
    String? toWalletId,
  }) async {
    // 1. Buat temporary transaction dengan ID sementara
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final optimisticTx = transaction.copyWith(id: tempId);

    // 2. Tambah ke list lokal dan cache LANGSUNG
    _transactions = [optimisticTx, ..._transactions];
    _updateSummaryOptimistic(newTx: optimisticTx); // Update summary instan
    await CacheService.addTransaction(optimisticTx);
    notifyListeners();

    try {
      // 3. POST ke server
      await _txService.addTransaction(
        token: token,
        walletId: walletId,
        toWalletId: toWalletId,
        title: transaction.title.isEmpty
            ? transaction.category
            : transaction.title,
        amount: transaction.amount,
        type: transaction.type.name,
        category: transaction.category,
        date:
            '${transaction.date.year.toString().padLeft(4, '0')}-'
            '${transaction.date.month.toString().padLeft(2, '0')}-'
            '${transaction.date.day.toString().padLeft(2, '0')}',
        note: transaction.note.isEmpty ? null : transaction.note,
      );

      // 4. Sukses → fetch ulang untuk dapat ID asli dari server + balance terbaru
      final fresh = await _txService.getTransactions(token);
      _transactions = fresh;
      await CacheService.saveTransactions(fresh);
      await CacheService.clearAllAnalytics();
      loadSummary(token); // Sync summary dari backend
      notifyListeners();
    } catch (e) {
      // 5. Gagal → rollback: hapus transaksi optimistic
      _transactions = _transactions.where((t) => t.id != tempId).toList();
      _updateSummaryOptimistic(oldTx: optimisticTx); // Rollback summary
      await CacheService.deleteTransaction(tempId);
      notifyListeners();
      rethrow; // lempar ke UI untuk tampil snackbar error
    }
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
      'transaction_date':
          '${updated.date.year.toString().padLeft(4, '0')}-'
          '${updated.date.month.toString().padLeft(2, '0')}-'
          '${updated.date.day.toString().padLeft(2, '0')}',
    };
    if (updated.note.isNotEmpty) payload['note'] = updated.note;

    final ok = await _txService.updateTransaction(updated.id, payload, token);
    if (ok) {
      // Cari transaksi lama untuk delta summary
      final oldTx = _transactions.firstWhere(
        (t) => t.id == updated.id,
        orElse: () => updated,
      );

      // Update lokal dan cache — tidak perlu loadAll lagi
      updateTransaction(updated);
      _updateSummaryOptimistic(
        oldTx: oldTx,
        newTx: updated,
      ); // Update summary instan
      await CacheService.updateTransaction(updated);
      await CacheService.clearAllAnalytics();
      loadSummary(token); // Sync summary dari backend
      notifyListeners();
    } else {
      throw Exception('Gagal update transaksi');
    }
  }

  // ── Delete Transaction via API (Optimistic Update) ─────────────
  Future<void> deleteTransactionWithApi(String id, String token) async {
    // 1. Simpan backup untuk rollback
    final backup = List<TransactionModel>.from(_transactions);
    final backupSummary = _backendSummary;
    final txToDelete = _transactions.firstWhere((t) => t.id == id);

    // 2. Hapus dari list lokal dan cache LANGSUNG (optimistic)
    _transactions = _transactions.where((t) => t.id != id).toList();
    _updateSummaryOptimistic(oldTx: txToDelete); // Update summary instan
    await CacheService.deleteTransaction(id);
    notifyListeners();

    try {
      // 3. DELETE ke server
      final ok = await _txService.deleteTransaction(id, token);
      if (!ok) throw Exception('Gagal hapus transaksi');

      await CacheService.clearAllAnalytics();
      loadSummary(token); // Sync summary dari backend
    } catch (e) {
      // 4. Gagal → rollback
      _transactions = backup;
      _backendSummary = backupSummary;
      await CacheService.saveTransactions(backup);
      notifyListeners();
      rethrow;
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
