import 'package:flutter/material.dart';
import '../data/models/saving_model.dart';
import '../data/services/saving_service.dart';

// ══════════════════════════════════════════════════════════════
/// SavingProvider — state manager untuk Saving (Wishlist).
///
/// ⚠️ Schema mismatch: Backend hanya simpan name + status.
/// Field amount/target/date bersifat lokal (tidak persist ke backend).
// ══════════════════════════════════════════════════════════════
class SavingProvider extends ChangeNotifier {
  List<Saving> _savings = [];
  bool _isLoading = false;
  String? _error;

  List<Saving> get savings => List.unmodifiable(_savings);
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ── Fetch dari API ──────────────────────────────────────────
  Future<void> fetchSavings(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _savings = await SavingService.getSavings(token);
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ fetchSavings error: $e');
      // Fallback: tetap tampilkan list kosong, jangan crash
      _savings = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Tambah saving via API ───────────────────────────────────
  /// Backend hanya menerima name. target/date disimpan lokal sementara.
  Future<void> addSaving(
    String name,
    int target,
    String date,
    String token,
  ) async {
    try {
      final created = await SavingService.createSaving(name, token);
      // Isi field lokal yang tidak ada di backend
      final withLocal = Saving(
        id: created.id,
        name: created.name,
        amount: 0,
        target: target,
        date: date,
      );
      _savings = [..._savings, withLocal];
      notifyListeners();
    } catch (e) {
      debugPrint('❌ addSaving error: $e');
      // Fallback: tambah lokal saja jika API gagal
      final localSaving = Saving(
        id: DateTime.now().millisecondsSinceEpoch,
        name: name,
        amount: 0,
        target: target,
        date: date,
      );
      _savings = [..._savings, localSaving];
      notifyListeners();
    }
  }

  // ── Delete lokal ────────────────────────────────────────────
  void deleteSaving(int id) {
    _savings = _savings.where((s) => s.id != id).toList();
    notifyListeners();
  }

  // ── Update lokal ────────────────────────────────────────────
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