import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/login_request.dart';
import '../models/sign_up_request.dart';
import '../models/auth_response.dart';
import '../../config/app_config.dart';

class AuthService {
  static const String baseUrl = AppConfig.baseUrl;

  // =========================
  // LOGIN
  // =========================
  Future<AuthResponse> login(LoginRequest request) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: json.encode({
        "email": request.email,
        "password": request.password,
      }),
    );

    final data = json.decode(response.body);

    if (response.statusCode == 200) {
      return AuthResponse.fromJson(data);
    } else {
      if (data["errors"] != null) {
        throw Exception(data["errors"].toString());
      } else {
        throw Exception(data["message"] ?? "Login gagal");
      }
    }
  }

  // =========================
  // SIGN UP
  // =========================
  Future<void> signUp(SignUpRequest request) async {
    final response = await http.post(
      Uri.parse("$baseUrl/register"),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: json.encode({
        "name": request.username,
        "email": request.email,
        "password": request.password,
        "password_confirmation": request.password,
      }),
    );

    final data = json.decode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return;
    } else {
      if (data["errors"] != null) {
        throw Exception(data["errors"].toString());
      } else {
        throw Exception(data["message"] ?? "Sign up gagal");
      }
    }
  }
}