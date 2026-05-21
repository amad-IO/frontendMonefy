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

  // ── FETCH ─────────────────────────────
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

  // ── CREATE (FIXED) ─────────────────────────────
  Future<void> addSaving(
      String name,
      int target,
      String date,
      String token,
      ) async {
    try {
      /// FIX: kirim target_amount ke backend
      await SavingService.createSaving(name, target, token);

      /// refresh data dari backend
      await fetchSavings(token);

    } catch (e) {
      debugPrint('addSaving error: $e');
    }
  }

  // ── BUY / COMPLETE PURCHASE ─────────────────
  Future<void> buySaving(
      int id,
      int walletId,
      String token,
      ) async {
    try {
      await SavingService.completePurchase(id, walletId, token);

      ///  refresh setelah beli
      await fetchSavings(token);

    } catch (e) {
      debugPrint("buySaving error: $e");
    }
  }

  // ── DELETE (LOCAL SAJA) ─────────────────────────
  void deleteSaving(int id) {
    _savings = _savings.where((s) => s.id != id).toList();
    notifyListeners();
  }

  // ── UPDATE (LOCAL SAJA) ─────────────────────────
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