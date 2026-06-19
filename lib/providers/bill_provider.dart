import 'package:flutter/material.dart';
import '../data/models/bill_model.dart';
import '../data/services/bill_service.dart';
import '../data/services/notification_service.dart';

class BillProvider with ChangeNotifier {
  final BillService _service = BillService();

  List<Bill> bills = [];
  bool isLoading = false;

  /// 🔥 GET ALL BILLS
  Future<void> fetchBills(String token) async {
    isLoading = true;
    notifyListeners();

    try {
      bills = await _service.getBills(token);

      // ✅ JADWALKAN ALARM TAGIHAN H-2 JATUH TEMPO
      for (var bill in bills) {
        final dueDate = DateTime.tryParse(bill.dueDate);

        if (bill.status.toLowerCase() == "unpaid" && dueDate != null) {
          // Jika belum bayar, jadwalkan notifikasi
          await NotificationService.scheduleBillReminder(
            id: bill.id,
            title: "Tagihan Mendatang ⚠️",
            body: "Tagihan ${bill.provider} sebesar Rp ${bill.amount} akan jatuh tempo dalam 2 hari.",
            dueDate: dueDate,
          );
        } else {
          // Jika sudah dibayar (paid), batalkan notifikasinya
          await NotificationService.cancelReminder(bill.id);
        }
      }
    } catch (e) {
      print("Error fetchBills: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  /// 🔥 ADD BILL
  Future<void> addBill(Map<String, dynamic> data, String token) async {
    try {
      await _service.createBill(data, token);
      await fetchBills(token); // 🔥 auto refresh
    } catch (e) {
      print("Error addBill: $e");
    }
  }

  /// UPDATE BILL
  Future<void> updateBill(
      int id, Map<String, dynamic> data, String token) async {
    try {
      await _service.updateBill(id, data, token);
      await fetchBills(token); // auto refresh
    } catch (e) {
      print("Error updateBill: $e");
    }
  }

  /// PAY BILL (INI YANG DIPAKAI DI UI)
  Future<void> payBill(int id, String token) async {
    try {
      await _service.updateBill(
        id,
        {"status": "paid"}, // 🔥 KUNCI UTAMA
        token,
      );

      await fetchBills(token); // 🔥 refresh UI
    } catch (e) {
      print("Error payBill: $e");
    }
  }

  /// 🔥 DELETE
  Future<void> deleteBill(int id, String token) async {
    try {
      // ✅ Batalkan alarm notifikasi untuk tagihan ini saat dihapus
      await NotificationService.cancelReminder(id);

      await _service.deleteBill(id, token);
      await fetchBills(token);
    } catch (e) {
      print("Error deleteBill: $e");
    }
  }
}