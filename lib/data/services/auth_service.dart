import '../models/login_request.dart';
import '../models/sign_up_request.dart';
import '../models/auth_response.dart';

class AuthService {

  /// SIMPAN DATA USER SEMENTARA (DUMMY DATABASE)
  static final List<Map<String, String>> _users = [];

  // LOGIN
  Future<AuthResponse> login(LoginRequest request) async {
    await Future.delayed(const Duration(seconds: 1));

    final user = _users.firstWhere(
          (u) =>
      u['username'] == request.username &&
          u['password'] == request.password,
      orElse: () => {},
    );

    if (user.isNotEmpty) {
      return AuthResponse(
        token: "dummy_token_${request.username}",
        username: request.username,
      );
    } else {
      throw Exception("Username atau password salah");
    }
  }

  // SIGN UP
  Future<void> signUp(SignUpRequest request) async {
    await Future.delayed(const Duration(seconds: 1));

    /// 🔥 CEK USER SUDAH ADA
    final isExist = _users.any(
          (u) => u['username'] == request.username,
    );

    if (isExist) {
      throw Exception("Username sudah digunakan");
    }

    /// 🔥 SIMPAN USER
    _users.add({
      'username': request.username,
      'password': request.password,
    });
  }
}