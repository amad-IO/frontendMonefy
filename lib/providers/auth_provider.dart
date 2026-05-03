import 'package:flutter/material.dart';
import '../data/models/login_request.dart';
import '../data/models/sign_up_request.dart';
import '../data/services/auth_service.dart';
class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  String? _token;
  String? _username;
  bool _isLoading = false;

  String? get token => _token;
  String? get username => _username;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _token != null;

  // LOGIN
  Future<void> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _authService.login(
        LoginRequest(username: username, password: password),
      );

      _token = response.token;
      _username = response.username;

    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // SIGN UP
  Future<void> signUp(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signUp(
        SignUpRequest(username: username, password: password),
      );
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // LOGOUT
  void logout() {
    _token = null;
    _username = null;
    notifyListeners();
  }
}