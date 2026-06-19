import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/bill_model.dart';
import '../data/services/bill_service.dart';
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

  // ── GET ALL BILLS ─────────────────────────────────────────────
  Future<void> fetchBills(String token) async {
    isLoading = true;
    notifyListeners();

    try {
      bills = await _service.getBills(token);
    } catch (e) {
      debugPrint('❌ fetchBills error: $e');
    }

    isLoading = false;
    notifyListeners();

    // Jadwalkan notifikasi di background — TIDAK blocking UI
    // Dipanggil tanpa await agar main thread bebas render
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

  // ── ADD BILL ──────────────────────────────────────────────────
  Future<void> addBill(Map<String, dynamic> data, String token) async {
    try {
      await _service.createBill(data, token);
      await fetchBills(token);
    } catch (e) {
      debugPrint('❌ addBill error: $e');
    }
  }

  // ── UPDATE BILL ───────────────────────────────────────────────
  Future<void> updateBill(int id, Map<String, dynamic> data, String token) async {
    try {
      // Cancel semua notif lama sebelum reschedule
      await NotificationService.cancelAllReminders(id);
      await _clearLastPaid(id);

      await _service.updateBill(id, data, token);
      await fetchBills(token); // fetchBills akan reschedule otomatis
    } catch (e) {
      debugPrint('❌ updateBill error: $e');
    }
  }

  // ── PAY BILL ──────────────────────────────────────────────────
  Future<void> payBill(int id, String token) async {
    try {
      await _service.updateBill(id, {'status': 'paid'}, token);

      // Simpan periode terakhir bayar ke HP (Opsi B)
      final bill = bills.firstWhere((b) => b.id == id, orElse: () => bills.first);
      await _saveLastPaid(id, bill.cycle);

      // Cancel overdue, biarkan H-2/H-1/H-0 untuk bulan depan
      await NotificationService.cancelOverdue(id);

      await fetchBills(token);
    } catch (e) {
      debugPrint('❌ payBill error: $e');
    }
  }

  // ── DELETE BILL ───────────────────────────────────────────────
  Future<void> deleteBill(int id, String token) async {
    try {
      // Cancel SEMUA notifikasi + hapus data SharedPreferences
      await NotificationService.cancelAllReminders(id);
      await _clearLastPaid(id);

      await _service.deleteBill(id, token);
      await fetchBills(token);
    } catch (e) {
      debugPrint('❌ deleteBill error: $e');
    }
  }
}