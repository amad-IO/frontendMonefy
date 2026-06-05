import 'package:flutter/material.dart';
import '../data/models/saving_model.dart';
import '../data/services/saving_service.dart';

class SavingProvider extends ChangeNotifier {
  List<Saving> _savings = [];
  bool _isLoading = false;
  String? _error;

  List<Saving> get savings => List.unmodifiable(_savings);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchSavings(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _savings = await SavingService.getSavings(token);
    } catch (e) {
      _error = e.toString();
      debugPrint('fetchSavings error: $e');
      _savings = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addSaving(
      String name,
      int target,
      String date,
      String token,
      ) async {
    try {
      await SavingService.createSaving(name, target, token);
      await fetchSavings(token);
    } catch (e) {
      debugPrint('addSaving error: $e');
    }
  }

  /// 🔥 BUY DENGAN WALLET
  Future<void> buySaving(
      int id,
      int walletId,
      String token,
      ) async {
    try {
      await SavingService.buySaving(id, walletId, token);
      await fetchSavings(token);
    } catch (e) {
      debugPrint("buySaving error: $e");
    }
  }

  void deleteSaving(int id) {
    _savings = _savings.where((s) => s.id != id).toList();
    notifyListeners();
  }

  void updateSaving(Saving updated) {
    final index = _savings.indexWhere((s) => s.id == updated.id);
    if (index != -1) {
      final list = List<Saving>.of(_savings);
      list[index] = updated;
      _savings = list;
      notifyListeners();
    }
  }
}