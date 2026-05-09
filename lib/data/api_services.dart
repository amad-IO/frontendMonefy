import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class ApiService {
  // baseUrl dibaca dari app_config.dart (lokal, tidak di-push ke GitHub)
  static const String baseUrl = AppConfig.baseUrl;

  // ── Auth Headers ─────────────────────────────────────────────
  // Semua request yang membutuhkan autentikasi menggunakan header ini.
  // Token didapat dari AuthProvider setelah login.
  static Map<String, String> _authHeaders(String token) => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };

  // ── GET /transactions ────────────────────────────────────────
  Future<List<dynamic>> getTransactions(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/transactions'),
        headers: _authHeaders(token),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Gagal mengambil data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // ── POST /transactions ───────────────────────────────────────
  // Kirim data transaksi baru ke backend.
  // [data] harus mengikuti format toJson() dari TransactionModel:
  //   wallet_id, to_wallet_id, title, amount, type,
  //   category, transaction_date, note
  Future<bool> addTransaction(Map<String, dynamic> data, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/transactions'),
        headers: _authHeaders(token),
        body: json.encode(data),
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  // ── DELETE /transactions/{id} ────────────────────────────────
  // Hapus transaksi berdasarkan ID.
  // Backend wajib memastikan transaksi milik user yang sedang login.
  // Expected response:
  //   200: { "message": "Transaksi berhasil dihapus" }
  //   403: { "message": "Unauthorized" }
  //   404: { "message": "Transaksi tidak ditemukan" }
  Future<bool> deleteTransaction(String id, String token) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/transactions/$id'),
        headers: _authHeaders(token),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ── PUT /transactions/{id} ───────────────────────────────────
  // Update transaksi yang sudah ada.
  // [data] harus mengikuti format toJson() dari TransactionModel.
  // Backend perlu meng-adjust saldo wallet jika amount berubah.
  // Expected response:
  //   200: { "message": "Berhasil!", "data": { ...TransactionModel... } }
  //   403: { "message": "Unauthorized" }
  //   404: { "message": "Transaksi tidak ditemukan" }
  //   422: { "message": "Validation error", "errors": { ... } }
  Future<bool> updateTransaction(
    String id,
    Map<String, dynamic> data,
    String token,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/transactions/$id'),
        headers: _authHeaders(token),
        body: json.encode(data),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ── Login ────────────────────────────────────────────────────
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Login failed: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // ── Sign up ──────────────────────────────────────────────────
  Future<bool> signUp(String username, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: json.encode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }
}