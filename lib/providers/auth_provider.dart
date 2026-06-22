import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/services/auth_service.dart';
import '../data/services/cache_service.dart';
import '../data/models/login_request.dart';
import '../data/models/sign_up_request.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  String? _token;
  String? _username;
  String? _email;
  bool _isLoading = false;

  String? get token => _token;
  String? get username => _username;
  String? get email => _email;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _token != null && _token!.isNotEmpty;

  // ── Auto-login: baca token tersimpan dari SharedPreferences ──
  /// Dipanggil saat app start di main.dart / root widget.
  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString('token');
    final savedUsername = prefs.getString('username');
    final savedEmail = prefs.getString('email');

    if (savedToken != null && savedToken.isNotEmpty) {
      _token = savedToken;
      _username = savedUsername ?? '';
      _email = savedEmail ?? '';
      notifyListeners();
      debugPrint('🟢 Auto-login: token restored');
    }
  }

  // ── Login ─────────────────────────────────────────────────────
  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _authService.login(
        LoginRequest(email: email, password: password),
      );

      _token = response.token;
      _username = response.username;
      _email = email;

      // Simpan ke SharedPreferences agar persist setelah app restart
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
      await prefs.setString('username', _username ?? '');
      await prefs.setString('email', email);

      debugPrint('🟢 Login success: $_username');
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Sign Up ───────────────────────────────────────────────────
  Future<void> signUp(String username, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _authService.signUp(
        SignUpRequest(username: username, email: email, password: password),
      );

      _token = response.token;
      _username = response.username;
      _email = email;

      // Simpan token setelah register
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
      await prefs.setString('username', _username ?? '');
      await prefs.setString('email', email);

      debugPrint('🟢 SignUp success: $_username');
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Logout ────────────────────────────────────────────────────
  Future<void> logout() async {
    _token = null;
    _username = null;
    _email = null;

    // Hapus token dari SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('username');
    await prefs.remove('email');

    // Hapus semua cache Hive agar data tidak bocor ke user lain
    await CacheService.clearAll();

    debugPrint('🔴 Logout: token + cache cleared');
    notifyListeners();
  }
}