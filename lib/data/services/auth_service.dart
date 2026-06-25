import 'dart:convert';
import 'dart:io';
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
      debugPrint('Auth: avatar from login = ${auth.avatar}'); // 👈 cek avatar

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

  // =========================
  // GET PROFILE
  // =========================
  /// GET /api/profile → kembalikan { name, email, avatar }
  Future<Map<String, dynamic>> getProfile(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/profile'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      debugPrint('Profile fetched: ${data['name']}');
      return data;
    } else {
      throw Exception('Gagal memuat profil (${response.statusCode})');
    }
  }

  // =========================
  // UPLOAD AVATAR
  // =========================
  /// POST /api/profile/avatar (multipart/form-data)
  /// → Response: { status, message, avatar: 'https://...' }
  Future<String> uploadAvatar(String token, File imageFile) async {
    final uri = Uri.parse('$baseUrl/profile/avatar');
    final request = http.MultipartRequest('POST', uri)
      ..headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      })
      ..files.add(await http.MultipartFile.fromPath(
        'avatar', // nama field sesuai validasi backend
        imageFile.path,
      ));

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    final data = json.decode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200 && data['status'] == 'success') {
      debugPrint('Avatar uploaded: ${data['avatar']}');
      return data['avatar'] as String; // URL Supabase
    } else {
      throw Exception(data['message'] ?? 'Gagal upload foto');
    }
  }
}