import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../core/theme/app_colors.dart';
import '../data/models/wallet_model.dart';
import '../data/models/transaction_model.dart';

// ══════════════════════════════════════════════════════════════
/// WalletProvider — state manager untuk semua wallet.
///
/// Wallet diperoleh dari dua sumber:
/// 1. GET /wallets (utama) → balance akurat
/// 2. Ekstrak dari list transaksi (fallback jika API gagal)
/// 3. Setelah user menambah wallet baru via POST /wallets
// ══════════════════════════════════════════════════════════════
class WalletProvider extends ChangeNotifier {
  List<WalletModel> _wallets = [];
  bool _isLoading = false;
  bool _isHidden = false;
  String? _error;

  // ── Getters ──────────────────────────────────────────────
  List<WalletModel> get wallets => List.unmodifiable(_wallets);
  bool get isLoading => _isLoading;
  bool get isHidden => _isHidden;
  String? get error => _error;

  double get totalBalance =>
      _wallets.fold(0.0, (sum, w) => sum + w.balance);

  List<WalletModel> byCategory(WalletCategory cat) =>
      _wallets.where((w) => w.category == cat).toList();

  // ── Load wallet langsung dari API ───────────────────────────
  /// Panggil GET /wallets — balance akurat dari backend.
  /// Response: { "status": "success", "data": [ { id, name_wallet, balance, ... } ] }
  Future<void> loadWalletsFromApi(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/wallets'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('GET /wallets → ${response.statusCode}');

      if (response.statusCode == 200) {
        final body = json.decode(response.body) as Map<String, dynamic>;
        final List<dynamic> data = body['data'] ?? [];
        _wallets = data.asMap().entries.map((entry) {
          final idx = entry.key;
          final e = entry.value as Map<String, dynamic>;
          // Inject theme_index agar WalletModel.fromJson() bisa assign tema
          e['theme_index'] = idx % WalletTheme.all.length;
          return WalletModel.fromJson(e); // ✅ category dibaca dari field 'category' backend
        }).toList();
      } else {
        _error = 'Gagal load wallet: ${response.statusCode}';
        debugPrint('❌ loadWalletsFromApi: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ loadWalletsFromApi error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Load wallet dari list transaksi (fallback) ───────────────
  /// Dipanggil sebagai fallback jika loadWalletsFromApi gagal.
  /// Balance selalu 0 karena relasi transaksi tidak membawa field balance.
  void loadWalletsFromTransactions(List<TransactionModel> transactions) {
    final Map<String, WalletModel> seen = {};

    for (final tx in transactions) {
      if (tx.walletId.isNotEmpty && !seen.containsKey(tx.walletId)) {
        seen[tx.walletId] = WalletModel(
          id: tx.walletId,
          name: tx.walletName,
          balance: 0, // balance tidak ada di relasi transaksi
          category: WalletCategory.cash, // default, backend tidak kirim category
          theme: WalletTheme.all[int.parse(tx.walletId).clamp(0, WalletTheme.all.length - 1) % WalletTheme.all.length],
        );
      }
    }

    _wallets = seen.values.toList();
    notifyListeners();
  }

  // ── Add Wallet ke Backend ─────────────────────────────────
  /// POST /wallets dengan field name_wallet & balance.
  /// Backend validation: name_wallet required, balance required numeric min 0.
  Future<bool> addWalletToBackend({
    required String name,
    required double balance,
    required String token,
    WalletCategory category = WalletCategory.cash,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/wallets'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'name_wallet': name,
          'balance': balance,
          'category': _categoryToString(category), // kirim ke backend
        }),
      );

      debugPrint('POST /wallets → ${response.statusCode}');

      if (response.statusCode == 201) {
        final data = json.decode(response.body)['data'] as Map<String, dynamic>;
        final newWallet = WalletModel(
          id: data['id'].toString(),
          name: data['name_wallet']?.toString() ?? name,
          balance: double.tryParse(data['balance'].toString()) ?? balance,
          category: category,
          theme: WalletTheme.all[_wallets.length % WalletTheme.all.length],
        );
        _wallets = [..._wallets, newWallet];
        return true;
      } else {
        final msg = json.decode(response.body)['message'] ?? 'Gagal tambah wallet';
        _error = msg.toString();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ addWalletToBackend error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Add wallet lokal (fallback / backward compat) ─────────
  Future<void> addWallet(WalletModel wallet) async {
    _wallets = [..._wallets, wallet];
    notifyListeners();
  }

  // ── Delete wallet lokal ────────────────────────────────────
  Future<void> deleteWallet(String id) async {
    _wallets = _wallets.where((w) => w.id != id).toList();
    notifyListeners();
  }

  // ── Toggle Hide ───────────────────────────────────────────
  void toggleHide() {
    _isHidden = !_isHidden;
    notifyListeners();
  }

  // ── Helper: WalletCategory → string backend ───────────────
  static String _categoryToString(WalletCategory cat) {
    switch (cat) {
      case WalletCategory.bankAccount:
        return 'Bank Account';
      case WalletCategory.eWallet:
        return 'E-Wallet';
      case WalletCategory.cash:
        return 'Cash';
    }
  }
}
