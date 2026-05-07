import '../models/login_request.dart';
import '../models/sign_up_request.dart';
import '../models/auth_response.dart';

class AuthService {

  /// DUMMY DATABASE
  static final List<Map<String, String>> _users = [];

  // ✅ LOGIN (PAKAI EMAIL)
  Future<AuthResponse> login(LoginRequest request) async {
    await Future.delayed(const Duration(seconds: 1));

    final user = _users.firstWhere(
          (u) =>
      u['email'] == request.email &&
          u['password'] == request.password,
      orElse: () => {},
    );

    if (user.isNotEmpty) {
      return AuthResponse(
        token: "dummy_token_${request.email}",
        username: user['username']!, // tetap kirim username
      );
    } else {
      throw Exception("Email atau password salah");
    }
  }

  // ✅ SIGN UP (TAMBAH EMAIL)
  Future<void> signUp(SignUpRequest request) async {
    await Future.delayed(const Duration(seconds: 1));

    /// 🔥 CEK EMAIL SUDAH ADA
    final isExist = _users.any(
          (u) => u['email'] == request.email,
    );

    if (isExist) {
      throw Exception("Email sudah digunakan");
    }

    /// 🔥 SIMPAN USER
    _users.add({
      'username': request.username,
      'email': request.email,
      'password': request.password,
    });
  }
}