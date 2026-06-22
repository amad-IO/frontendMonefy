import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../config/app_config.dart';
import '../models/login_request.dart';
import '../models/sign_up_request.dart';
import '../models/auth_response.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      final auth = AuthResponse.fromJson(data);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', auth.token);

      debugPrint('Auth: token saved for ${request.email}');

      return auth;
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
  Future<AuthResponse> signUp(SignUpRequest request) async {
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
      final auth = AuthResponse.fromJson(data);

      //SIMPAN TOKEN
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', auth.token);

      debugPrint('Auth: token saved after signup for ${request.email}');

      return auth;
    } else {
      if (data["errors"] != null) {
        throw Exception(data["errors"].toString());
      } else {
        throw Exception(data["message"] ?? "Sign up gagal");
      }
    }
  }
}