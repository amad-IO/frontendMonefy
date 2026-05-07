import 'package:flutter/material.dart';
import '../data/models/wallet_model.dart';

// ══════════════════════════════════════════════════════════════
/// WalletProvider — state manager untuk semua wallet.
///
/// Saat ini menggunakan dummy data in-memory.
/// Ketika backend siap, ganti method [loadWallets], [addWallet],
/// dan [deleteWallet] dengan panggilan HTTP — widget tidak perlu diubah.
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

  // ── Init ─────────────────────────────────────────────────
  WalletProvider() {
    loadWallets();
  }

  // ── Load ─────────────────────────────────────────────────
  /// Load wallet dari backend.
  /// Saat backend belum siap, gunakan dummy data.
  Future<void> loadWallets() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: Ganti baris ini dengan HTTP call ke backend:
      // final response = await http.get(Uri.parse('$baseUrl/wallets'));
      // _wallets = (jsonDecode(response.body) as List)
      //     .map((j) => WalletModel.fromJson(j))
      //     .toList();

      // Simulasi network delay
      await Future.delayed(const Duration(milliseconds: 300));
      _wallets = WalletModel.dummyList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Add ──────────────────────────────────────────────────
  /// Tambah wallet baru.
  Future<void> addWallet(WalletModel wallet) async {
    // TODO: Ganti dengan HTTP POST ke backend
    _wallets = [..._wallets, wallet];
    notifyListeners();
  }

  // ── Delete ───────────────────────────────────────────────
  /// Hapus wallet berdasarkan ID.
  Future<void> deleteWallet(String id) async {
    // TODO: Ganti dengan HTTP DELETE ke backend
    _wallets = _wallets.where((w) => w.id != id).toList();
    notifyListeners();
  }

  // ── Toggle Hide ──────────────────────────────────────────
  void toggleHide() {
    _isHidden = !_isHidden;
    notifyListeners();
  }
}
