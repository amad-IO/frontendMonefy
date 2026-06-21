# Monefy Flutter — Performance Optimization Plan

## 🧠 Konteks untuk Agent Baru (Baca Ini Dulu!)

Dokumen ini adalah **handover document lengkap**. Jika kamu adalah agent baru yang menggantikan agent sebelumnya, baca seluruh dokumen ini sebelum mulai coding. Semua keputusan desain, temuan, dan alasan teknis sudah tercatat di sini.

---

## 📁 Struktur Project

```
e:\semester 6\Aplikasi Berbasis Platfrom\Tubes\
├── Backend-Monefy\          ← Laravel (JANGAN DIUBAH — bukan tanggung jawab kita)
└── mobile\
    └── frontendMonefy\      ← Flutter App (INI yang kita kerjakan)
        └── lib\
            ├── main.dart
            ├── config\
            ├── core\
            ├── data\
            │   ├── api_services.dart
            │   ├── models\
            │   └── services\
            │       ├── analytics_calculator.dart
            │       ├── auth_service.dart
            │       ├── bill_service.dart
            │       ├── dashboard_service.dart
            │       ├── notification_service.dart
            │       ├── saving_service.dart
            │       ├── scan_service.dart
            │       └── transaction_service.dart
            ├── providers\
            │   ├── auth_provider.dart
            │   ├── bill_provider.dart
            │   ├── saving_provider.dart
            │   ├── transaction_provider.dart
            │   └── wallet_provider.dart
            └── ui\
                ├── components\
                ├── pages\
                │   ├── home_page.dart       ← PALING BERMASALAH
                │   ├── history_page.dart    ← PERLU PAGINASI
                │   ├── main_page.dart
                │   ├── add_page.dart
                │   └── ... (halaman lain)
                └── widgets\
```

---

## 🔍 Root Cause Analysis (Sudah Diverifikasi dari Log Nyata)

### Bukti dari Log Flutter Run (SM A217F):

```
[+2608ms] GET /transactions → 200   ← dari _RootPage (main.dart)
[+2612ms] GET /dashboard/summary → 200
[+2287ms] GET /wallets → 200
          ↓ beberapa detik kemudian
[+3519ms] GET /transactions → 200   ← dari HomePage.initState() — DUPLIKAT!
[+2597ms] GET /dashboard/summary → 200
[+2608ms] GET /wallets → 200

Davey! duration=1531ms              ← 1.5 detik freeze render pertama
Skipped 275 frames!                 ← karena notif scheduling di main thread
Skipped 198 frames!
Skipped 86 frames!

Setelah user tambah transaksi:
[+15085ms] POST /transactions → 201
[+2838ms]  GET /transactions → 200   ← refetch semua setelah 1 CRUD
[+3061ms]  GET /dashboard/summary → 200
[+2066ms]  GET /transactions → 200   ← FETCH LAGI dari halaman lain!
[+2573ms]  GET /dashboard/summary → 200
[+2179ms]  GET /wallets → 200
[+3083ms]  GET /transactions → 200   ← FETCH KE-3 KALI!
```

### 4 Root Cause Teridentifikasi:

| # | Masalah | File | Baris | Severity |
|---|---------|------|-------|----------|
| 1 | Duplicate fetch startup | `home_page.dart` | initState() | 🔴 Kritis |
| 2 | loadAll() setelah setiap CRUD | `transaction_provider.dart` | 125, 145, 155 | 🔴 Kritis |
| 3 | Notif scheduling di main thread | `bill_provider.dart` | _evaluateAndScheduleAll() | 🔴 Kritis |
| 4 | Backend /transactions tanpa pagination | `TransactionController.php` | line 201 | 🔴 Kritis (backend) |

---

## 🎯 Keputusan Desain yang Sudah Disepakati

### ❓ Keputusan 1: Cache Duration
**KEPUTUSAN: Event-based invalidation, bukan time-based**
- Cache berlaku sampai ada CRUD operation
- Tidak expire berdasarkan waktu
- Maksimum 200 transaksi tersimpan

### ❓ Keputusan 2: Storage Technology
**KEPUTUSAN: Hive (bukan shared_preferences)**
- shared_preferences tidak cocok untuk list of objects
- Hive: binary format, jauh lebih cepat untuk read/write list
- shared_preferences tetap dipakai untuk token auth (sudah ada)

### ❓ Keputusan 3: Optimistic UI untuk Balance
**KEPUTUSAN: Semi-optimistic**
- ✅ Transaksi tampil di list dengan status "pending ⏱" — LANGSUNG
- ⏸️ Balance/Summary angka — TUNGGU konfirmasi server
- ❌ Kalau server gagal → rollback + snackbar error

**Alasan:** App keuangan. Angka harus akurat. Tidak boleh tampil angka yang belum dikonfirmasi server.

### ❓ Keputusan 4: TikTok Pagination
**KEPUTUSAN: Client-side pagination (adaptasi)**
- Backend tidak bisa diubah, /transactions tidak support paginate
- Kita pakai data yang sudah ada di cache, render 20 item per batch
- Scroll ke bawah → render 20 berikutnya dari cache
- Tidak ada request tambahan ke server

### ❓ Keputusan 5: Pull-to-Refresh
**KEPUTUSAN: Wajib ada**
- Satu-satunya cara user sync manual dari server
- Clear cache → fetch fresh → update cache → tampil

### ❓ Keputusan 6: Notification Scheduling
**KEPUTUSAN: Pindah ke compute() isolate**
- Sekarang berjalan di main thread → frame drop
- Pindah ke Flutter compute() untuk isolate terpisah

---

## 📋 Implementation Plan (6 Task Berurutan)

> **PERATURAN PENTING:**
> - Kerjakan BERURUTAN dari Task 1 ke Task 6
> - Jangan lompat ke task berikutnya sebelum task sebelumnya selesai dan diverifikasi
> - User adalah frontend developer, tidak bisa ubah backend
> - Setiap task harus di-hot-reload dan diverifikasi di device sebelum lanjut

---

## ✅ Task 1 — Fix Duplicate Fetch (30 menit)

**Prioritas: KERJAKAN PERTAMA**

### Problem:
`home_page.dart` memanggil `loadAll()` di `initState()` padahal
`main.dart` (`_RootPage._checkLogin()`) sudah melakukan hal yang sama.
Hasilnya: 6 API calls saat startup, padahal cukup 3.

### File yang diubah: `lib/ui/pages/home_page.dart`

### Perubahan:
Hapus seluruh blok `initState()` di `_HomePageState`:

```dart
// HAPUS SELURUH BLOK INI (lines 34-53):
@override
void initState() {
  super.initState();
  Future.microtask(() async {
    final auth = context.read<AuthProvider>();
    if (auth.isLoggedIn) {
      final token = auth.token!;
      final txProvider = context.read<TransactionProvider>();
      final walletProvider = context.read<WalletProvider>();
      await Future.wait([
        txProvider.loadAll(token),
        walletProvider.loadWalletsFromApi(token),
      ]);
      txProvider.enrichToWalletNames(walletProvider.wallets);
    }
  });
}
```

### Verifikasi:
Setelah perubahan, log harus menunjukkan hanya **3 API calls** saat startup (bukan 6):
```
GET /transactions → 200    ← hanya sekali
GET /dashboard/summary → 200  ← hanya sekali
GET /wallets → 200         ← hanya sekali
```

---

## ✅ Task 2 — Install & Setup Hive Cache (2 jam)

### Step 2a: Tambah dependency di pubspec.yaml

```yaml
dependencies:
  hive: ^2.2.3
  hive_flutter: ^1.1.0

dev_dependencies:
  hive_generator: ^2.0.1
  build_runner: ^2.4.6
```

Jalankan:
```bash
flutter pub get
```

### Step 2b: Buat file `lib/data/services/cache_service.dart` (FILE BARU)

```dart
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction_model.dart';
import '../models/wallet_model.dart';

/// CacheService — satu-satunya class yang handle baca/tulis cache Hive.
/// 
/// Box yang digunakan:
/// - 'transactions' : List<Map> transaksi (max 200 item terbaru)
/// - 'wallets'      : List<Map> wallet user
/// - 'meta'         : metadata cache (timestamp terakhir fetch, dll)
class CacheService {
  static const String _txBox = 'transactions';
  static const String _walletBox = 'wallets';
  static const String _metaBox = 'meta';
  static const int _maxTransactions = 200;

  // ── Inisialisasi Hive (panggil sekali di main()) ────────────────
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_txBox);
    await Hive.openBox(_walletBox);
    await Hive.openBox(_metaBox);
  }

  // ── Transactions ────────────────────────────────────────────────
  
  /// Simpan list transaksi ke cache (max 200 terbaru)
  static Future<void> saveTransactions(List<TransactionModel> transactions) async {
    final box = Hive.box(_txBox);
    final list = transactions.take(_maxTransactions).map((t) => t.toJson()).toList();
    await box.put('data', list);
    await _saveMeta('transactions_cached_at', DateTime.now().toIso8601String());
  }

  /// Baca transaksi dari cache. Return [] jika cache kosong.
  static List<TransactionModel> getTransactions() {
    final box = Hive.box(_txBox);
    final raw = box.get('data');
    if (raw == null) return [];
    try {
      final list = (raw as List).cast<Map>();
      return list.map((e) => TransactionModel.fromJson(Map<String, dynamic>.from(e))).toList();
    } catch (_) {
      return [];
    }
  }

  /// Tambah 1 transaksi baru ke cache (optimistic add)
  static Future<void> addTransaction(TransactionModel tx) async {
    final current = getTransactions();
    final updated = [tx, ...current].take(_maxTransactions).toList();
    await saveTransactions(updated);
  }

  /// Update 1 transaksi di cache berdasarkan id
  static Future<void> updateTransaction(TransactionModel updated) async {
    final current = getTransactions();
    final newList = current.map((t) => t.id == updated.id ? updated : t).toList();
    await saveTransactions(newList);
  }

  /// Hapus 1 transaksi dari cache berdasarkan id
  static Future<void> deleteTransaction(String id) async {
    final current = getTransactions();
    final newList = current.where((t) => t.id != id).toList();
    await saveTransactions(newList);
  }

  /// Cek apakah cache transaksi ada
  static bool hasTransactions() {
    return Hive.box(_txBox).containsKey('data');
  }

  // ── Wallets ─────────────────────────────────────────────────────

  /// Simpan list wallet ke cache
  static Future<void> saveWallets(List<WalletModel> wallets) async {
    final box = Hive.box(_walletBox);
    final list = wallets.map((w) => w.toJson()).toList();
    await box.put('data', list);
  }

  /// Baca wallet dari cache. Return [] jika cache kosong.
  static List<WalletModel> getWallets() {
    final box = Hive.box(_walletBox);
    final raw = box.get('data');
    if (raw == null) return [];
    try {
      final list = (raw as List).cast<Map>();
      return list
          .asMap()
          .entries
          .map((entry) {
            final map = Map<String, dynamic>.from(entry.value);
            map['theme_index'] = entry.key % WalletTheme.all.length;
            return WalletModel.fromJson(map);
          })
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Cek apakah cache wallet ada
  static bool hasWallets() {
    return Hive.box(_walletBox).containsKey('data');
  }

  // ── Clear Cache ─────────────────────────────────────────────────

  /// Hapus SEMUA cache (panggil saat logout)
  static Future<void> clearAll() async {
    await Hive.box(_txBox).clear();
    await Hive.box(_walletBox).clear();
    await Hive.box(_metaBox).clear();
  }

  // ── Meta ────────────────────────────────────────────────────────
  static Future<void> _saveMeta(String key, String value) async {
    await Hive.box(_metaBox).put(key, value);
  }

  static String? getMeta(String key) {
    return Hive.box(_metaBox).get(key);
  }
}
```

### Step 2c: Inisialisasi Hive di `lib/main.dart`

```dart
// Tambahkan import:
import 'data/services/cache_service.dart';

// Di dalam main():
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID');
  Intl.defaultLocale = 'id_ID';
  await NotificationService.init();
  await CacheService.init();  // ← TAMBAHKAN INI
  runApp(const MonefyApp());
}
```

> **CATATAN:** Jika `TransactionModel` dan `WalletModel` belum punya method `toJson()`,
> perlu ditambahkan. Cek file `lib/data/models/` dan tambahkan jika belum ada.

---

## ✅ Task 3 — Implementasi Cache di Provider (2 jam)

### File: `lib/providers/transaction_provider.dart`

Modifikasi `loadTransactions()` agar load dari cache dulu:

```dart
// ── Load Transactions: Cache First, then Background Fetch ──────
Future<void> loadTransactions(String token) async {
  // 1. Load dari cache dulu → UI tampil instan
  if (CacheService.hasTransactions()) {
    _transactions = CacheService.getTransactions();
    _isLoading = false;
    notifyListeners();
  } else {
    // Tidak ada cache → tampil loading
    _isLoading = true;
    notifyListeners();
  }

  // 2. Fetch dari server di background
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
```

Modifikasi `addTransactionWithApi()` — **HAPUS loadAll(), pakai optimistic update:**

```dart
Future<void> addTransactionWithApi(
  TransactionModel transaction,
  String token, {
  required String walletId,
  String? toWalletId,
}) async {
  // 1. Buat temporary ID untuk optimistic update
  final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
  final optimisticTx = transaction.copyWith(
    id: tempId,
    isPending: true, // flag pending (tambahkan ke model)
  );

  // 2. Optimistic: tambah ke list lokal LANGSUNG
  _transactions = [optimisticTx, ..._transactions];
  await CacheService.addTransaction(optimisticTx);
  notifyListeners();

  try {
    // 3. POST ke server (background)
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

    // 4. Sukses → refresh dari server untuk dapat ID asli + balance update
    // Ini satu-satunya saat kita fetch ulang — setelah konfirmasi sukses
    final fresh = await _txService.getTransactions(token);
    _transactions = fresh;
    await CacheService.saveTransactions(fresh);
    notifyListeners();

  } catch (e) {
    // 5. Gagal → rollback optimistic update
    _transactions = _transactions.where((t) => t.id != tempId).toList();
    await CacheService.deleteTransaction(tempId);
    notifyListeners();
    rethrow; // lempar ke UI untuk tampil snackbar error
  }
}
```

Modifikasi `deleteTransactionWithApi()`:

```dart
Future<void> deleteTransactionWithApi(String id, String token) async {
  // 1. Optimistic: hapus dari list lokal LANGSUNG
  final backup = List<TransactionModel>.from(_transactions);
  _transactions = _transactions.where((t) => t.id != id).toList();
  await CacheService.deleteTransaction(id);
  notifyListeners();

  try {
    // 2. DELETE ke server
    final ok = await _txService.deleteTransaction(id, token);
    if (!ok) throw Exception('Gagal hapus transaksi');
  } catch (e) {
    // 3. Gagal → rollback
    _transactions = backup;
    await CacheService.saveTransactions(backup);
    notifyListeners();
    rethrow;
  }
}
```

### File: `lib/providers/wallet_provider.dart`

Modifikasi `loadWalletsFromApi()`:

```dart
Future<void> loadWalletsFromApi(String token) async {
  // 1. Load dari cache dulu
  if (CacheService.hasWallets()) {
    _wallets = CacheService.getWallets();
    _isLoading = false;
    notifyListeners();
  } else {
    _isLoading = true;
    notifyListeners();
  }

  // 2. Fetch dari server di background
  try {
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/wallets'),
      headers: { /* ... sama seperti sebelumnya */ },
    );

    if (response.statusCode == 200) {
      final body = json.decode(response.body) as Map<String, dynamic>;
      final List<dynamic> data = body['data'] ?? [];
      _wallets = data.asMap().entries.map((entry) {
        final e = entry.value as Map<String, dynamic>;
        e['theme_index'] = entry.key % WalletTheme.all.length;
        return WalletModel.fromJson(e);
      }).toList();
      await CacheService.saveWallets(_wallets); // update cache
    }
  } catch (e) {
    _error = e.toString();
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}
```

### File: `lib/providers/auth_provider.dart`

Tambahkan clear cache saat logout:

```dart
// Di method logout():
Future<void> logout() async {
  await CacheService.clearAll(); // ← TAMBAHKAN INI
  // ... kode logout yang sudah ada
}
```

---

## ✅ Task 4 — Client-Side Pagination di HistoryPage (1 jam)

**Konsep:** Data sudah ada di cache/memory. Kita hanya render 20 item per batch.
Tidak ada request tambahan ke server.

### File: `lib/ui/pages/history_page.dart`

Tambahkan state pagination:

```dart
class _HistoryPageState extends State<HistoryPage> {
  // ... state yang sudah ada ...

  // ── Pagination ────────────────────────────────────────
  static const int _pageSize = 20;
  int _visibleCount = _pageSize;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
        _visibleCount = _pageSize; // reset pagination saat search
      });
    });

    // Listener untuk load more saat scroll mendekati bawah
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // User mendekati 200px dari bawah → load lebih banyak
      setState(() => _visibleCount += _pageSize);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }
```

Modifikasi ListView:

```dart
// Ganti ListView.builder dengan:
final visibleTransactions = filtered.take(_visibleCount).toList();

ListView.builder(
  controller: _scrollController,  // ← tambahkan ini
  physics: const BouncingScrollPhysics(),
  padding: EdgeInsets.only(top: 4, bottom: 120 + mediaBottom),
  itemCount: visibleTransactions.length + (filtered.length > _visibleCount ? 1 : 0),
  itemBuilder: (context, index) {
    if (index == visibleTransactions.length) {
      // Loading indicator di bawah list
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return CardHistory(transaction: visibleTransactions[index]);
  },
),
```

---

## ✅ Task 5 — Pull-to-Refresh (30 menit)

### File: `lib/ui/pages/home_page.dart`

Tambahkan method `_onRefresh()` dan wrap body dengan `RefreshIndicator`:

```dart
Future<void> _onRefresh() async {
  final auth = context.read<AuthProvider>();
  if (!auth.isLoggedIn) return;
  final token = auth.token!;
  
  // Force fetch fresh dari server (bypass cache)
  await Future.wait([
    context.read<TransactionProvider>().loadTransactions(token),
    context.read<WalletProvider>().loadWalletsFromApi(token),
  ]);
  context.read<TransactionProvider>().enrichToWalletNames(
    context.read<WalletProvider>().wallets,
  );
}

// Di build(), wrap body column dengan:
RefreshIndicator(
  onRefresh: _onRefresh,
  child: /* ... column yang sudah ada ... */
)
```

### File: `lib/ui/pages/history_page.dart`

Tambahkan RefreshIndicator yang sama di HistoryPage:

```dart
Future<void> _onRefresh() async {
  final auth = context.read<AuthProvider>();
  if (!auth.isLoggedIn) return;
  final token = auth.token!;
  setState(() => _visibleCount = _pageSize); // reset pagination
  await context.read<TransactionProvider>().loadTransactions(token);
}
```

---

## ✅ Task 6 — Pindah Notification Scheduling ke Background (1 jam)

### File: `lib/providers/bill_provider.dart`

Saat ini `_evaluateAndScheduleAll()` dipanggil langsung di main thread.
Ini menyebabkan **Skipped 275 frames** saat startup.

```dart
// SEBELUM (blocking main thread):
Future<void> fetchBills(String token) async {
  isLoading = true;
  notifyListeners();
  try {
    bills = await _service.getBills(token);
    await _evaluateAndScheduleAll(); // ← BLOCKING! menyebabkan frame drop
  } catch (e) { ... }
  isLoading = false;
  notifyListeners();
}

// SESUDAH (non-blocking):
Future<void> fetchBills(String token) async {
  isLoading = true;
  notifyListeners();
  try {
    bills = await _service.getBills(token);
    isLoading = false;
    notifyListeners();
    
    // Scheduling di background — UI tidak ter-block
    // Tidak perlu await — biarkan berjalan sendiri
    _evaluateAndScheduleAllBackground();
  } catch (e) {
    debugPrint('❌ fetchBills error: $e');
    isLoading = false;
    notifyListeners();
  }
}

// Method baru yang tidak di-await dari main thread:
Future<void> _evaluateAndScheduleAllBackground() async {
  try {
    await _evaluateAndScheduleAll(); // tetap sama, tapi tidak blocking UI
  } catch (e) {
    debugPrint('❌ Notif scheduling error: $e');
  }
}
```

---

## 🧪 Verification Plan

Setelah setiap task selesai, verifikasi dengan menjalankan `flutter run` dan baca log:

### ✅ Verifikasi Task 1 (Duplicate Fetch):
```
Startup log harus tampilkan:
GET /transactions → 200   (hanya 1x)
GET /dashboard/summary → 200  (hanya 1x)
GET /wallets → 200  (hanya 1x)
TIDAK boleh ada duplikat!
```

### ✅ Verifikasi Task 2 & 3 (Cache):
```
Pertama kali buka: loading dari server seperti biasa
Tutup app → buka lagi:
  - Data langsung tampil (< 100ms)
  - Di background ada GET /transactions (update cache)
```

### ✅ Verifikasi Task 4 (Pagination):
```
Buka History → hanya 20 item tampil
Scroll ke bawah → 20 item baru muncul
Tidak ada additional API call saat scroll
```

### ✅ Verifikasi Task 5 (Pull-to-Refresh):
```
Swipe down di HomePage/HistoryPage:
  - Muncul loading indicator
  - GET /transactions dipanggil
  - Data refresh
```

### ✅ Verifikasi Task 6 (Frame Drop):
```
Log startup TIDAK boleh ada:
  Skipped 200+ frames!
Boleh ada Skipped < 30 frames (normal)
```

---

## ⚠️ Hal Penting yang JANGAN Dilakukan

1. **JANGAN ubah apapun di folder `Backend-Monefy/`** — itu bukan tanggung jawab frontend
2. **JANGAN pakai fully optimistic update untuk angka balance** — app keuangan, angka harus akurat
3. **JANGAN hapus `shared_preferences`** — masih dipakai untuk auth token
4. **JANGAN implement server-side pagination** — backend tidak support, tidak bisa diubah
5. **JANGAN kerjakan task secara paralel** — kerjakan berurutan, verifikasi dulu setiap task

---

## 📦 Package yang Perlu Ditambahkan

```yaml
# di pubspec.yaml — tambahkan di bawah dependencies:
hive: ^2.2.3
hive_flutter: ^1.1.0

# di dev_dependencies:
hive_generator: ^2.0.1
build_runner: ^2.4.6
```

---

## 📊 Estimasi Dampak Performa (Target)

| Kondisi | Sebelum | Target Sesudah |
|---------|---------|----------------|
| Buka app (ada cache) | 6-8 detik | < 0.1 detik |
| Buka app (fresh install) | 6-8 detik | 2-3 detik |
| Tambah transaksi (UX) | 8+ detik freeze | < 0.5 detik |
| Scroll history | Semua item render | 20 per batch, smooth |
| Frame drop startup | Skip 275 frames | < 30 frames |
| API calls saat startup | 6 calls | 3 calls |
| API calls setelah CRUD | 6-9 calls | 1 call (POST/PUT/DELETE saja) |

---

## 🔄 Status Progress

- [ ] Task 1: Fix Duplicate Fetch
- [ ] Task 2: Install & Setup Hive
- [ ] Task 3: Cache di Providers + Optimistic Update
- [ ] Task 4: Client-Side Pagination di HistoryPage
- [ ] Task 5: Pull-to-Refresh
- [ ] Task 6: Background Notification Scheduling

---

*Dokumen ini dibuat pada: 2026-06-19*
*Device test: Samsung SM-A217F (Android)*
*Flutter project path: `e:\semester 6\Aplikasi Berbasis Platfrom\Tubes\mobile\frontendMonefy`*
