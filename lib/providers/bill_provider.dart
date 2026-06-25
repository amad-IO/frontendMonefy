import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/bill_model.dart';
import '../data/services/bill_service.dart';
import '../data/services/cache_service.dart';
import '../data/services/notification_service.dart';

class BillProvider with ChangeNotifier {
  final BillService _service = BillService();

  List<Bill> bills = [];
  bool isLoading = false;

  // ── SharedPreferences key helper ─────────────────────────────
  static String _lastPaidKey(int id) => 'bill_${id}_last_paid';

  /// Simpan bulan/tahun terakhir bayar ke HP
  static Future<void> _saveLastPaid(int id, String cycle) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();

    if (cycle.toLowerCase().contains('bulanan')) {
      // Simpan "YYYY-MM"
      await prefs.setString(_lastPaidKey(id), '${now.year}-${now.month.toString().padLeft(2, '0')}');
    } else if (cycle.toLowerCase().contains('tahunan')) {
      // Simpan "YYYY"
      await prefs.setString(_lastPaidKey(id), '${now.year}');
    } else {
      // Sekali bayar — simpan flag sudah bayar
      await prefs.setString(_lastPaidKey(id), 'paid');
    }
  }

  /// Hapus catatan last paid (saat delete/edit)
  static Future<void> _clearLastPaid(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastPaidKey(id));
  }

  /// Cek apakah bill ini sudah dibayar untuk periode saat ini (Opsi B)
  static Future<bool> _isPaidThisPeriod(int id, String cycle, String backendStatus) async {
    final lc = cycle.toLowerCase();

    // Sekali bayar: ikut status backend sepenuhnya
    if (!lc.contains('bulanan') && !lc.contains('tahunan')) {
      return backendStatus.toLowerCase() == 'paid';
    }

    final prefs = await SharedPreferences.getInstance();
    final lastPaid = prefs.getString(_lastPaidKey(id));
    if (lastPaid == null) return false;

    final now = DateTime.now();

    if (lc.contains('bulanan')) {
      final currentPeriod = '${now.year}-${now.month.toString().padLeft(2, '0')}';
      return lastPaid == currentPeriod;
    }

    if (lc.contains('tahunan')) {
      return lastPaid == '${now.year}';
    }

    return false;
  }

  // ── GET ALL BILLS (cache-first) ─────────────────────────────
  Future<void> fetchBills(String token) async {
    // 1. Tampil cache dulu agar UI instan
    final cached = CacheService.getBills();
    if (cached.isNotEmpty) {
      bills = cached;
      isLoading = false;
      notifyListeners();

      // Jika cache masih fresh (< 5 menit), cukup background refresh
      if (CacheService.hasFreshBills()) {
        _fetchFromServer(token);
        return;
      }
    } else {
      // Cache kosong: tampil loading
      isLoading = true;
      notifyListeners();
    }

    // 2. Fetch dari server (blocking hanya jika cache kosong)
    await _fetchFromServer(token);
  }

  /// Internal: fetch bills dari server, update cache & UI
  Future<void> _fetchFromServer(String token) async {
    try {
      final fresh = await _service.getBills(token);
      bills = fresh;
      await CacheService.saveBills(fresh);
    } catch (e) {
      debugPrint('❌ _fetchFromServer bills error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }

    // Jadwalkan notifikasi di background — TIDAK blocking UI
    _scheduleNotifsInBackground();
  }

  /// Jalankan scheduling di background tanpa block UI.
  void _scheduleNotifsInBackground() {
    Future(() => _evaluateAndScheduleAll()).catchError((e) {
      debugPrint('❌ Notif scheduling error: $e');
    });
  }

  /// Evaluasi setiap bill dan schedule notif yang tepat
  Future<void> _evaluateAndScheduleAll() async {
    for (final bill in bills) {
      final dueDate = DateTime.tryParse(bill.dueDate);
      if (dueDate == null) continue;

      final paidThisPeriod = await _isPaidThisPeriod(bill.id, bill.cycle, bill.status);
      final now = DateTime.now();
      final dueDateAt9 = DateTime(dueDate.year, dueDate.month, dueDate.day, 9, 0);
      final isOverdue = now.isAfter(dueDateAt9) && !paidThisPeriod;

      if (paidThisPeriod) {
        // Sudah bayar periode ini → batalkan hanya overdue
        // H-2, H-1, H-0 dibiarkan untuk cycle berikutnya (bulanan/tahunan)
        await NotificationService.cancelOverdue(bill.id);
      } else if (isOverdue) {
        // Belum bayar + sudah lewat jatuh tempo → aktifkan daily overdue
        await NotificationService.scheduleAllReminders(
          billId: bill.id,
          billName: bill.provider,
          dueDate: dueDate,
          cycle: bill.cycle,
        );
        await NotificationService.scheduleOverdue(
          billId: bill.id,
          billName: bill.provider,
        );
      } else {
        // Belum bayar + belum jatuh tempo → schedule H-2, H-1, H-0
        await NotificationService.scheduleAllReminders(
          billId: bill.id,
          billName: bill.provider,
          dueDate: dueDate,
          cycle: bill.cycle,
        );
      }
    }
  }

  // ── ADD BILL (optimistic) ────────────────────────────────
  Future<void> addBill(Map<String, dynamic> data, String token) async {
    try {
      // POST ke server dulu, lalu refresh cache
      await _service.createBill(data, token);
      // Background refresh untuk dapat ID asli dari server
      _fetchFromServer(token);
    } catch (e) {
      debugPrint('❌ addBill error: $e');
    }
  }

  // ── UPDATE BILL (optimistic) ─────────────────────────────
  Future<void> updateBill(int id, Map<String, dynamic> data, String token) async {
    // Optimistic: update lokal dulu agar UI responsif
    final oldBills = List<Bill>.from(bills);
    bills = bills.map((b) {
      if (b.id != id) return b;
      return Bill(
        id: b.id,
        provider: (data['provider'] as String?) ?? b.provider,
        accountNumber: (data['account_number'] as String?) ?? b.accountNumber,
        amount: data['amount'] != null
            ? double.tryParse(data['amount'].toString()) ?? b.amount
            : b.amount,
        dueDate: (data['due_date'] as String?) ?? b.dueDate,
        cycle: (data['cycle'] as String?) ?? b.cycle,
        status: (data['status'] as String?) ?? b.status,
      );
    }).toList();
    notifyListeners();

    try {
      await NotificationService.cancelAllReminders(id);
      await _clearLastPaid(id);
      await _service.updateBill(id, data, token);
      await CacheService.saveBills(bills);
      // Background refresh untuk sinkronisasi data server
      _fetchFromServer(token);
    } catch (e) {
      // Rollback jika gagal
      bills = oldBills;
      notifyListeners();
      debugPrint('❌ updateBill error: $e');
    }
  }

  // ── PAY BILL (optimistic) ───────────────────────────────
  Future<void> payBill(int id, String token) async {
    // Optimistic: update status 'paid' lokal dulu
    final bill = bills.firstWhere((b) => b.id == id, orElse: () => bills.first);
    final optimisticBill = Bill(
      id: bill.id,
      provider: bill.provider,
      accountNumber: bill.accountNumber,
      amount: bill.amount,
      dueDate: bill.dueDate,
      cycle: bill.cycle,
      status: 'paid',
    );
    bills = bills.map((b) => b.id == id ? optimisticBill : b).toList();
    notifyListeners();
    await CacheService.updateBill(optimisticBill);

    try {
      await _service.updateBill(id, {'status': 'paid'}, token);
      await _saveLastPaid(id, bill.cycle);
      await NotificationService.cancelOverdue(id);
      // Background refresh untuk sinkronisasi
      _fetchFromServer(token);
    } catch (e) {
      // Rollback jika gagal
      bills = bills.map((b) => b.id == id ? bill : b).toList();
      await CacheService.updateBill(bill);
      notifyListeners();
      debugPrint('❌ payBill error: $e');
    }
  }

  // ── DELETE BILL (optimistic) ─────────────────────────────
  Future<void> deleteBill(int id, String token) async {
    // Optimistic: hapus dari list lokal dulu
    final oldBills = List<Bill>.from(bills);
    bills = bills.where((b) => b.id != id).toList();
    notifyListeners();
    await CacheService.deleteBill(id);

    try {
      await NotificationService.cancelAllReminders(id);
      await _clearLastPaid(id);
      await _service.deleteBill(id, token);
      // Background refresh untuk konfirmasi server
      _fetchFromServer(token);
    } catch (e) {
      // Rollback jika gagal
      bills = oldBills;
      await CacheService.saveBills(oldBills);
      notifyListeners();
      debugPrint('❌ deleteBill error: $e');
    }
  }
}