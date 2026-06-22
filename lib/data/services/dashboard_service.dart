import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../config/app_config.dart';
import '../models/summary_model.dart';

class DashboardService {
  static const String baseUrl = AppConfig.baseUrl;

  static Map<String, String> _headers(String token) => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };

  // ── GET /dashboard/summary ────────────────────────────────────
  // Backend response:
  // {
  //   "user": { "id", "name", "email", ... },
  //   "total_balance": 0,
  //   "total_income": 0,
  //   "total_expense": 0,
  //   "total_transactions": 0
  // }
  Future<SummaryModel> getSummary(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/dashboard/summary'),
      headers: _headers(token),
    );

    debugPrint('GET /dashboard/summary → ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return SummaryModel.fromJson(data);
    } else {
      throw Exception('Gagal load summary: ${response.statusCode}');
    }
  }
}
