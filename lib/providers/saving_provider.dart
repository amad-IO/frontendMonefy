import 'package:flutter/material.dart';
import '../data/models/saving_model.dart';
import '../data/services/saving_service.dart';

class SavingProvider extends ChangeNotifier {
  final SavingService _service = SavingService(); // siap backend nanti

  List<Saving> savings = [];
  bool isLoading = false;

  /// 🔥 FETCH DATA
  Future<void> fetchSavings() async {
    isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));

      /// ✅ tambahin id biar aman
      //savings = [];

      /// 🔥 nanti kalau pakai API:
      /// savings = await _service.getSavings();

    } catch (e) {
      debugPrint("Error fetch savings: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// 🔥 TAMBAH SAVING (LOCAL MODE)
  void addSaving(String name, int target) {
    print("PROVIDER MASUK: $name");
    final newSaving = Saving(
      id: DateTime.now().millisecondsSinceEpoch,
      name: name,
      amount: target, // 🔥 ubah ini
      target: target,
    );

    savings.add(newSaving);
    print("TOTAL DATA: ${savings.length}");
    notifyListeners();
  }

  /// 🔥 DELETE
  void deleteSaving(int index) {
    savings.removeAt(index);
    notifyListeners();
  }
}