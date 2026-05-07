import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Ganti dengan IP laptopmu jika pakai HP fisik (misal: 192.168.x.x)
  // Atau gunakan 10.0.2.2 jika pakai Emulator Android
  static const String baseUrl = "http://192.168.1.66:8000/api";

  // Contoh fungsi untuk mengambil data (GET)
  Future<List<dynamic>> getTransactions() async {
    try {
      print('Mengambil data dari: $baseUrl/transactions');
      final response = await http.get(Uri.parse('$baseUrl/transactions'));
      print('Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        // Decode body dari Laravel (JSON)
        return json.decode(response.body);
      } else {
        throw Exception('Gagal mengambil data');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Contoh fungsi untuk mengirim data (POST)
  Future<bool> addTransaction(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/transactions'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  // Login: mengirim email & password, mengembalikan parsed JSON saat sukses
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
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

  // Sign up: mendaftar user baru
  Future<bool> signUp(String username, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
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