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
/// Karena backend tidak memiliki GET /wallets, wallet diperoleh
/// dari dua sumber:
/// 1. Ekstrak dari list transaksi (wallet relasi di setiap transaksi)
/// 2. Setelah user menambah wallet baru via POST /wallets
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

  // ── Load wallet dari list transaksi ──────────────────────
  /// Dipanggil oleh TransactionProvider setelah loadTransactions selesai.
  /// Ekstrak wallet unik berdasarkan wallet_id dari setiap transaksi.
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
          'name_wallet': name,   // ✅ sesuai backend WalletController
          'balance': balance,
        }),
      );

      print('POST /wallets → ${response.statusCode}');
      print('BODY: ${response.body}');

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
}
