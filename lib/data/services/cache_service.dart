import 'package:hive_flutter/hive_flutter.dart';
import '../models/analytic/analytic_chart_data.dart';
import '../models/bill_model.dart';
import '../models/transaction_model.dart';
import '../models/wallet_model.dart';

/// CacheService — satu-satunya class yang handle baca/tulis cache Hive.
///
/// Box yang digunakan:
/// - 'transactions' : List transaksi (max 200 item terbaru)
/// - 'wallets'      : List wallet user
/// - 'bills'        : List bills user (max 25 item, TTL 5 menit)
/// - 'analytics'    : Data analytic per periode
///
/// Cara pakai:
/// 1. Panggil CacheService.init() sekali di main() sebelum runApp()
/// 2. Gunakan CacheService.getTransactions() untuk baca cache
/// 3. Gunakan CacheService.saveTransactions(list) untuk tulis cache
/// 4. Panggil CacheService.clearAll() saat logout
class CacheService {
  static const String _txBox = 'transactions';
  static const String _walletBox = 'wallets';
  static const String _analyticBox = 'analytics';
  static const String _billBox = 'bills';
  static const int _maxTx = 200; // maksimum transaksi di cache
  static const int _billTtlMinutes = 5; // cache bills kadaluarsa 5 menit

  // ── Inisialisasi (panggil sekali di main()) ─────────────────────
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<dynamic>(_txBox);
    await Hive.openBox<dynamic>(_walletBox);
    await Hive.openBox<dynamic>(_analyticBox);
    await Hive.openBox<dynamic>(_billBox);
  }

  // ═══════════════════════════════════════════════════════════════
  // TRANSACTIONS
  // ═══════════════════════════════════════════════════════════════

  /// Simpan list transaksi ke cache. Hanya simpan max [_maxTx] terbaru.
  static Future<void> saveTransactions(
    List<TransactionModel> transactions,
  ) async {
    final box = Hive.box<dynamic>(_txBox);
    // Ambil max 200, map ke plain Map agar Hive bisa simpan
    final list = transactions.take(_maxTx).map((t) => _txToMap(t)).toList();
    await box.put('data', list);
  }

  /// Baca transaksi dari cache. Return [] jika cache kosong atau error.
  static List<TransactionModel> getTransactions() {
    final box = Hive.box<dynamic>(_txBox);
    final raw = box.get('data');
    if (raw == null) return [];
    try {
      return (raw as List)
          .map(
            (e) =>
                TransactionModel.fromJson(Map<String, dynamic>.from(e as Map)),
          )
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
    final box = Hive.box<dynamic>(_walletBox);
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
    await Hive.box<dynamic>(_analyticBox).clear();
    await Hive.box<dynamic>(_billBox).clear();
  }

  // ═══════════════════════════════════════════════════════════════
  // BILLS
  // ═══════════════════════════════════════════════════════════════

  /// Simpan list bills ke cache beserta timestamp fetch.
  static Future<void> saveBills(List<Bill> bills) async {
    final box = Hive.box<dynamic>(_billBox);
    final list = bills.map((b) => _billToMap(b)).toList();
    await box.put('data', list);
    await box.put('fetched_at', DateTime.now().toIso8601String());
  }

  /// Baca bills dari cache. Return [] jika cache kosong atau error.
  static List<Bill> getBills() {
    final box = Hive.box<dynamic>(_billBox);
    final raw = box.get('data');
    if (raw == null) return [];
    try {
      return (raw as List)
          .map((e) => Bill.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Cek apakah cache bills ada dan belum kadaluarsa (TTL 5 menit).
  static bool hasFreshBills() {
    final box = Hive.box<dynamic>(_billBox);
    if (!box.containsKey('data')) return false;
    final fetchedAt = DateTime.tryParse(box.get('fetched_at') ?? '');
    if (fetchedAt == null) return false;
    return DateTime.now().difference(fetchedAt).inMinutes < _billTtlMinutes;
  }

  /// Cek apakah cache bills ada (meski sudah stale).
  /// Dipakai untuk cache-first — tampil stale dulu sambil background fetch.
  static bool hasBills() {
    return Hive.box<dynamic>(_billBox).containsKey('data');
  }

  /// Update 1 bill di cache berdasarkan id (untuk optimistic update).
  static Future<void> updateBill(Bill updated) async {
    final current = getBills();
    final newList = current.map((b) => b.id == updated.id ? updated : b).toList();
    await saveBills(newList);
  }

  /// Hapus 1 bill dari cache berdasarkan id (untuk optimistic delete).
  static Future<void> deleteBill(int id) async {
    final current = getBills();
    final newList = current.where((b) => b.id != id).toList();
    await saveBills(newList);
  }

  /// Hapus cache bills saja.
  static Future<void> clearBills() async {
    await Hive.box<dynamic>(_billBox).clear();
  }

  // ═══════════════════════════════════════════════════════════════
  // ANALYTICS
  // ═══════════════════════════════════════════════════════════════

  static Future<void> saveAnalytic(AnalyticChartData data) async {
    await Hive.box<dynamic>(_analyticBox).put(data.cacheKey, data.toJson());
  }

  static AnalyticChartData? getAnalytic({
    required String trend,
    required int month,
    required int year,
    required int week,
  }) {
    final key = 'analytic_${trend}_${year}_${month}_$week';
    final raw = Hive.box<dynamic>(_analyticBox).get(key);
    if (raw == null) return null;

    try {
      return AnalyticChartData.fromCacheJson(
        Map<String, dynamic>.from(raw as Map),
      );
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearAnalyticKey({
    required String trend,
    required int month,
    required int year,
    required int week,
  }) async {
    final key = 'analytic_${trend}_${year}_${month}_$week';
    await Hive.box<dynamic>(_analyticBox).delete(key);
  }

  static Future<void> clearAllAnalytics() async {
    await Hive.box<dynamic>(_analyticBox).clear();
  }

  // ═══════════════════════════════════════════════════════════════
  // PRIVATE HELPERS
  // ═══════════════════════════════════════════════════════════════

  /// Konversi TransactionModel ke plain Map yang aman disimpan di Hive.
  /// Tidak bisa pakai toJson() langsung karena ada field 'wallet' nested
  /// yang tidak ada di toJson() backend — kita simpan flat format.
  static Map<String, dynamic> _txToMap(TransactionModel t) => {
    'id': t.id,
    'wallet_id': t.walletId,
    'to_wallet_id': t.toWalletId,
    // Simpan wallet sebagai nested map agar fromJson() bisa parsing
    'wallet': {'id': t.walletId, 'name_wallet': t.walletName},
    'destination_wallet': t.toWalletId.isEmpty
        ? null
        : {'id': t.toWalletId, 'name_wallet': t.toWalletName},
    'title': t.title,
    'amount': t.amount,
    'type': t.type.name,
    'category': t.category,
    'transaction_date':
        '${t.date.year.toString().padLeft(4, '0')}-'
        '${t.date.month.toString().padLeft(2, '0')}-'
        '${t.date.day.toString().padLeft(2, '0')}',
    'created_at': t.date.toIso8601String(),
    'note': t.note,
  };

  /// Konversi Bill ke plain Map yang aman disimpan di Hive.
  /// Field name cocok dengan Bill.fromJson() agar bisa di-parse kembali.
  static Map<String, dynamic> _billToMap(Bill b) => {
    'id': b.id,
    'provider': b.provider,
    'account_number': b.accountNumber,
    'amount': b.amount,
    'due_date': b.dueDate,
    'cycle': b.cycle,
    'status': b.status,
  };
}
