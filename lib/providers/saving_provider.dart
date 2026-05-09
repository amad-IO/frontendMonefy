import 'package:flutter/material.dart';
import '../data/models/saving_model.dart';
import '../data/services/saving_service.dart';

class SavingProvider extends ChangeNotifier {
  final SavingService _service = SavingService();

  List<Saving> savings = [];
  bool isLoading = false;

  /// 🔥 FETCH DATA
  Future<void> fetchSavings() async {
    isLoading = true;
    notifyListeners();

    try {
      // 🔥 kalau pakai API nanti
      // savings = await _service.getSavings();

      await Future.delayed(const Duration(seconds: 1));

      /// sementara kosong / dummy
      savings = [];

    } catch (e) {
      debugPrint("Error fetch savings: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// 🔥 TAMBAH SAVING
  void addSaving(String name, int target, String date) {
    final newSaving = Saving(
      id: DateTime.now().millisecondsSinceEpoch,
      name: name,

      /// 💰 awalnya belum ada uang terkumpul
      amount: 0,

      target: target,
      date: date,
    );

    savings.add(newSaving);
    notifyListeners();
  }

  /// 🔥 DELETE (lebih aman pakai id)
  void deleteSaving(int id) {
    savings.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  /// 🔥 UPDATE (buat edit nanti)
  void updateSaving(Saving updated) {
    final index = savings.indexWhere((e) => e.id == updated.id);

    if (index != -1) {
      savings[index] = updated;
      notifyListeners();
    }
  }
}