import 'package:flutter/material.dart';

import '../data/api_services.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  String? _token;
  String? _username;
  bool _isLoading = false;

  String? get token => _token;
  String? get username => _username;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _token != null;

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.login(email, password);

      _token = response['token'] ?? response['access_token'] ?? response['data']?['token'];
      _username = response['username'] ?? response['data']?['username'] ?? email;

      if (_token == null) {
        throw Exception('Token tidak ditemukan pada respons login');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUp(String username, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _apiService.signUp(username, email, password);
      if (!success) {
        throw Exception('Sign up gagal');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    _token = null;
    _username = null;
    notifyListeners();
  }
}