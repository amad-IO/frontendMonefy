import '../models/login_request.dart';
import '../models/sign_up_request.dart';
import '../models/auth_response.dart';

class AuthService {
  /// ─── AKUN TEST — langsung bisa login tanpa daftar ───────────────────────
  ///
  ///   Email    : test@monefy.com
  ///   Password : 123456
  ///
  ///   Tambah akun lain di list _users di bawah jika perlu.
  /// ────────────────────────────────────────────────────────────────────────
  static final List<Map<String, String>> _users = [
    {
      'username': 'Test User',
      'email': 'test@monefy.com',
      'password': 'Test@123',   //  memenuhi: huruf besar, kecil, angka, simbol
    },
   
  ];

  // ─── LOGIN ────────────────────────────────────────────────────────────────
  Future<AuthResponse> login(LoginRequest request) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final user = _users.firstWhere(
      (u) =>
          u['email'] == request.email.trim() &&
          u['password'] == request.password.trim(),
      orElse: () => {},
    );

    if (user.isNotEmpty) {
      return AuthResponse(
        token: 'local_token_${user['email']}',
        username: user['username']!,
      );
    } else {
      throw Exception('Email atau password salah');
    }
  }

  // ─── SIGN UP (opsional, tetap ada untuk keperluan lain) ──────────────────
  Future<void> signUp(SignUpRequest request) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final isExist = _users.any((u) => u['email'] == request.email.trim());

    if (isExist) {
      throw Exception('Email sudah digunakan');
    }

    _users.add({
      'username': request.username,
      'email': request.email.trim(),
      'password': request.password,
    });
  }
}