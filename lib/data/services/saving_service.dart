import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/saving_model.dart';
import '../../config/app_config.dart';

class SavingService {
  static String get baseUrl => '${AppConfig.baseUrl}/wishlists';

  // ── GET /wishlists ─────────────────────────────
  static Future<List<Saving>> getSavings(String token) async {
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    debugPrint('GET /wishlists → ${response.statusCode}');

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body) as Map<String, dynamic>;
      final List data = decoded['data'] ?? [];

      return data
          .map((e) => Saving.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load savings: ${response.statusCode}');
    }
  }

  // ── POST /wishlists ─────────────────────────────
  static Future<Saving> createSaving(
      String name,
      int target,
      String token,
      ) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'name': name,
        'target_amount': target, // 🔥 FIX SESUAI BACKEND
      }),
    );

    debugPrint('POST /wishlists → ${response.statusCode}');
    debugPrint('BODY → ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = json.decode(response.body) as Map<String, dynamic>;
      return Saving.fromJson(decoded['data']);
    } else {
      throw Exception('Failed to create saving: ${response.body}');
    }
  }

  // ── 🔥 POST /wishlists/{id}/complete-purchase ─────────────────
  static Future<void> completePurchase(
      int id,
      int walletId,
      String token,
      ) async {
    final url = Uri.parse('$baseUrl/$id/complete-purchase');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'wallet_id': walletId,
      }),
    );

    debugPrint('POST /wishlists/$id/complete-purchase → ${response.statusCode}');
    debugPrint('BODY → ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Failed to complete purchase: ${response.body}');
    }
  }

  // ── OPTIONAL: update status manual ─────────────────
  static Future<bool> updateStatus(
      int id,
      String status,
      String token,
      ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'status': status}),
    );

    debugPrint('PUT /wishlists/$id → ${response.statusCode}');
    return response.statusCode == 200;
  }
}