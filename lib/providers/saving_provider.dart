import 'package:flutter/material.dart';
import '../data/models/saving_model.dart';
import '../data/services/saving_service.dart';

class SavingProvider extends ChangeNotifier {
  List<Saving> savings = [];
  bool isLoading = false;

  Future<void> fetchSavings() async {
    isLoading = true;
    notifyListeners();

    /// simulasi delay (optional, boleh hapus)
    await Future.delayed(const Duration(seconds: 1));

    /// KOSONGIN DATA
    savings = [];

    isLoading = false;
    notifyListeners();
  }
}