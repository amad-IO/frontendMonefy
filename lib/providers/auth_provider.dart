import 'dart:io';
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
  String? _avatarUrl;       // URL foto dari Supabase (persisted)
  File?   _localAvatarFile; // File lokal untuk optimistic UI
  bool _isLoading = false;
  bool _isUploadingAvatar = false;

  String? get token       => _token;
  String? get username    => _username;
  String? get email       => _email;
  String? get avatarUrl   => _avatarUrl;
  File?   get localAvatarFile => _localAvatarFile;
  bool get isLoading      => _isLoading;
  bool get isUploadingAvatar => _isUploadingAvatar;
  bool get isLoggedIn     => _token != null && _token!.isNotEmpty;

  // ── Auto-login: baca token tersimpan dari SharedPreferences ──
  /// Dipanggil saat app start di main.dart / root widget.
  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken    = prefs.getString('token');
    final savedUsername = prefs.getString('username');
    final savedEmail    = prefs.getString('email');
    final savedAvatar   = prefs.getString('avatarUrl');

    if (savedToken != null && savedToken.isNotEmpty) {
      _token    = savedToken;
      _username = savedUsername ?? '';
      _email    = savedEmail ?? '';
      _avatarUrl = savedAvatar; // langsung dari cache — instan
      notifyListeners();
      debugPrint('🟢 Auto-login: token restored');

      // Background sync: ambil data profil terbaru dari server
      fetchProfile(savedToken).ignore();
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

      _token    = response.token;
      _username = response.username;
      _email    = email;
      _avatarUrl = response.avatar;

      // Simpan ke SharedPreferences agar persist setelah app restart
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token',     _token!);
      await prefs.setString('username',  _username ?? '');
      await prefs.setString('email',     email);
      if (_avatarUrl != null) {
        await prefs.setString('avatarUrl', _avatarUrl!);
      }

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

      _token    = response.token;
      _username = response.username;
      _email    = email;
      _avatarUrl = response.avatar;

      // Simpan token setelah register
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token',    _token!);
      await prefs.setString('username', _username ?? '');
      await prefs.setString('email',    email);
      if (_avatarUrl != null) {
        await prefs.setString('avatarUrl', _avatarUrl!);
      }

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
    _token    = null;
    _username = null;
    _email    = null;
    _avatarUrl = null;
    _localAvatarFile = null;

    // Hapus token dari SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('username');
    await prefs.remove('email');
    await prefs.remove('avatarUrl');

    // Hapus semua cache Hive agar data tidak bocor ke user lain
    await CacheService.clearAll();

    debugPrint('🔴 Logout: token + cache cleared');
    notifyListeners();
  }

  // ── Fetch Profile dari Server ──────────────────────────────
  /// GET /api/profile → update nama, email, avatarUrl
  Future<void> fetchProfile(String token) async {
    try {
      final data = await _authService.getProfile(token);
      _username = data['name']  as String? ?? _username;
      _email    = data['email'] as String? ?? _email;

      // Hanya update avatar jika server kembalikan URL valid
      // (workaround: backend tulis ke kolom 'url' tapi baca dari 'avatar')
      final serverAvatar = data['avatar'] as String?;
      if (serverAvatar != null && serverAvatar.isNotEmpty) {
        _avatarUrl = serverAvatar;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('avatarUrl', serverAvatar);
      }
      // Jika null → JANGAN timpa cache yang sudah ada

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', _username ?? '');
      await prefs.setString('email',    _email ?? '');

      notifyListeners();
    } catch (e) {
      debugPrint('⚠️ fetchProfile error: $e');
    }
  }

  // ── Upload Avatar (Optimistic) ─────────────────────────────
  /// 1. Tampilkan file lokal instan (optimistic)
  /// 2. Upload ke server di background
  /// 3. Sukses → simpan URL; Gagal → revert ke URL lama
  Future<void> uploadAvatar(File imageFile) async {
    if (_token == null) return;

    final previousUrl  = _avatarUrl;
    final previousFile = _localAvatarFile;

    // ① Optimistic: tampilkan foto lokal langsung
    _localAvatarFile = imageFile;
    notifyListeners();

    _isUploadingAvatar = true;
    notifyListeners();

    try {
      final url = await _authService.uploadAvatar(_token!, imageFile);

      // ② Sukses: simpan URL dari Supabase
      _avatarUrl       = url;
      _localAvatarFile = null; // tidak perlu lagi, sudah ada URL

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('avatarUrl', url);

      debugPrint('✅ Avatar updated: $url');
    } catch (e) {
      // ③ Gagal: kembalikan foto sebelumnya
      _avatarUrl       = previousUrl;
      _localAvatarFile = previousFile;
      debugPrint('❌ Avatar upload failed: $e');
      rethrow; // biarkan UI tampilkan snackbar
    } finally {
      _isUploadingAvatar = false;
      notifyListeners();
    }
  }
}