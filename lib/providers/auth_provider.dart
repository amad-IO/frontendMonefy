import 'package:flutter/material.dart';

import '../data/services/auth_service.dart';
import '../data/models/login_request.dart';
import '../data/models/sign_up_request.dart';

/// AuthProvider — MODE LOCAL (tanpa backend).
///
/// Menggunakan [AuthService] yang menyimpan user di memori (dummy database).
/// Ketika backend sudah siap, ganti [AuthService] dengan ApiService
/// dan sesuaikan method login/signUp di bawah.
class AuthProvider with ChangeNotifier {
  // ✅ Ganti ApiService → AuthService (local/dummy, tanpa backend)
  final AuthService _authService = AuthService();

  String? _token;
  String? _username;
  bool _isLoading = false;

  String? get token => _token;
  String? get username => _username;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _token != null;

  /// Login dengan email & password.
  /// Data disimpan di-memory oleh [AuthService] — tidak perlu backend.
  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _authService.login(
        LoginRequest(email: email, password: password),
      );

      _token = response.token;
      _username = response.username;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Daftar akun baru.
  /// User langsung tersimpan di-memory (sesi ini saja).
  Future<void> signUp(String username, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signUp(
        SignUpRequest(username: username, email: email, password: password),
      );
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