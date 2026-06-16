import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class ApiService {
  static const String baseUrl = AppConfig.baseUrl;

  /// AUTH HEADER
  static Map<String, String> _authHeaders(String token) => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };

  // = TRANSACTIONS =

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

  // =BILLS=

  /// GET ALL BILLS
  Future<List<dynamic>> getBills(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/bills'),
        headers: _authHeaders(token),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data']; // Laravel format
      } else {
        throw Exception('Gagal mengambil bills: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// CREATE BILL
  Future<bool> createBill(Map<String, dynamic> data, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/bills'),
        headers: _authHeaders(token),
        body: json.encode(data),
      );

      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  /// UPDATE BILL (PAY / EDIT)
  Future<void> updateBill(
      String id, Map<String, dynamic> data, String token) async {

    final response = await http.put(
      Uri.parse('$baseUrl/bills/$id'),
      headers: _authHeaders(token),
      body: json.encode(data),
    );

    print("===== UPDATE BILL DEBUG =====");
    print("URL: $baseUrl/bills/$id");
    print("BODY: $data");
    print("STATUS CODE: ${response.statusCode}");
    print("RESPONSE: ${response.body}");
    print("=============================");

    if (response.statusCode != 200) {
      throw Exception("Update bill gagal");
    }
  }

  /// DELETE BILL
  Future<bool> deleteBill(String id, String token) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/bills/$id'),
        headers: _authHeaders(token),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // =AUTH=

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
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

  Future<bool> signUp(
      String username, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
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