import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction_model.dart';
import '../models/wallet_model.dart';

/// CacheService — satu-satunya class yang handle baca/tulis cache Hive.
///
/// Box yang digunakan:
/// - 'transactions' : List transaksi (max 200 item terbaru)
/// - 'wallets'      : List wallet user
///
/// Cara pakai:
/// 1. Panggil CacheService.init() sekali di main() sebelum runApp()
/// 2. Gunakan CacheService.getTransactions() untuk baca cache
/// 3. Gunakan CacheService.saveTransactions(list) untuk tulis cache
/// 4. Panggil CacheService.clearAll() saat logout
class CacheService {
  static const String _txBox     = 'transactions';
  static const String _walletBox = 'wallets';
  static const int    _maxTx     = 200; // maksimum transaksi di cache

  // ── Inisialisasi (panggil sekali di main()) ─────────────────────
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<dynamic>(_txBox);
    await Hive.openBox<dynamic>(_walletBox);
  }

  // ═══════════════════════════════════════════════════════════════
  // TRANSACTIONS
  // ═══════════════════════════════════════════════════════════════

  /// Simpan list transaksi ke cache. Hanya simpan max [_maxTx] terbaru.
  static Future<void> saveTransactions(List<TransactionModel> transactions) async {
    final box  = Hive.box<dynamic>(_txBox);
    // Ambil max 200, map ke plain Map agar Hive bisa simpan
    final list = transactions
        .take(_maxTx)
        .map((t) => _txToMap(t))
        .toList();
    await box.put('data', list);
  }

  /// Baca transaksi dari cache. Return [] jika cache kosong atau error.
  static List<TransactionModel> getTransactions() {
    final box = Hive.box<dynamic>(_txBox);
    final raw = box.get('data');
    if (raw == null) return [];
    try {
      return (raw as List)
          .map((e) => TransactionModel.fromJson(
                Map<String, dynamic>.from(e as Map),
              ))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Cek apakah cache transaksi ada (tidak kosong).
  static bool hasTransactions() {
    return Hive.box<dynamic>(_txBox).containsKey('data');
  }

  /// Tambah 1 transaksi ke depan cache (optimistic add).
  static Future<void> addTransaction(TransactionModel tx) async {
    final current = getTransactions();
    final updated = [tx, ...current].take(_maxTx).toList();
    await saveTransactions(updated);
  }

  /// Update 1 transaksi di cache berdasarkan id.
  static Future<void> updateTransaction(TransactionModel updated) async {
    final current = getTransactions();
    final newList = current
        .map((t) => t.id == updated.id ? updated : t)
        .toList();
    await saveTransactions(newList);
  }

  /// Hapus 1 transaksi dari cache berdasarkan id.
  static Future<void> deleteTransaction(String id) async {
    final current = getTransactions();
    final newList = current.where((t) => t.id != id).toList();
    await saveTransactions(newList);
  }

  // ═══════════════════════════════════════════════════════════════
  // WALLETS
  // ═══════════════════════════════════════════════════════════════

  /// Simpan list wallet ke cache.
  static Future<void> saveWallets(List<WalletModel> wallets) async {
    final box  = Hive.box<dynamic>(_walletBox);
    final list = wallets.map((w) => w.toJson()).toList();
    await box.put('data', list);
  }

  /// Baca wallet dari cache. Return [] jika cache kosong atau error.
  static List<WalletModel> getWallets() {
    final box = Hive.box<dynamic>(_walletBox);
    final raw = box.get('data');
    if (raw == null) return [];
    try {
      return (raw as List).asMap().entries.map((entry) {
        final map = Map<String, dynamic>.from(entry.value as Map);
        // Inject theme_index berdasarkan posisi agar setiap wallet punya tema berbeda.
        // WalletModel.fromJson() sudah handle clamp ke range yang valid.
        map['theme_index'] = entry.key;
        return WalletModel.fromJson(map);
      }).toList();
    } catch (_) {
      return [];
    }
  }

  /// Cek apakah cache wallet ada (tidak kosong).
  static bool hasWallets() {
    return Hive.box<dynamic>(_walletBox).containsKey('data');
  }

  // ═══════════════════════════════════════════════════════════════
  // CLEAR
  // ═══════════════════════════════════════════════════════════════

  /// Hapus SEMUA cache. Panggil ini saat user logout.
  static Future<void> clearAll() async {
    await Hive.box<dynamic>(_txBox).clear();
    await Hive.box<dynamic>(_walletBox).clear();
  }

  // ═══════════════════════════════════════════════════════════════
  // PRIVATE HELPERS
  // ═══════════════════════════════════════════════════════════════

  /// Konversi TransactionModel ke plain Map yang aman disimpan di Hive.
  /// Tidak bisa pakai toJson() langsung karena ada field 'wallet' nested
  /// yang tidak ada di toJson() backend — kita simpan flat format.
  static Map<String, dynamic> _txToMap(TransactionModel t) => {
    'id':               t.id,
    'wallet_id':        t.walletId,
    'to_wallet_id':     t.toWalletId,
    // Simpan wallet sebagai nested map agar fromJson() bisa parsing
    'wallet':           {'id': t.walletId, 'name_wallet': t.walletName},
    'destination_wallet': t.toWalletId.isEmpty
        ? null
        : {'id': t.toWalletId, 'name_wallet': t.toWalletName},
    'title':            t.title,
    'amount':           t.amount,
    'type':             t.type.name,
    'category':         t.category,
    'transaction_date': '${t.date.year.toString().padLeft(4, '0')}-'
                        '${t.date.month.toString().padLeft(2, '0')}-'
                        '${t.date.day.toString().padLeft(2, '0')}',
    'created_at':       t.date.toIso8601String(),
    'note':             t.note,
  };
}
