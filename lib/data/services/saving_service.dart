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
    debugPrint('BODY → ${response.body}');

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body) as Map<String, dynamic>;
      final List data = decoded['data'] ?? [];

      return data
          .map((e) => Saving.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load savings: ${response.body}');
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
        'target_amount': target,
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

  // ── 🔥 BUY (PAKAI WALLET DARI UI) ─────────────────
  static Future<void> buySaving(
      int id,
      int walletId,
      String token,
      ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'status': 'terbeli',
        'wallet_id': walletId,
      }),
    );

    debugPrint('PUT /wishlists/$id → ${response.statusCode}');
    debugPrint('BODY → ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Failed to update wishlist: ${response.body}');
    }
  }

  static Future<void> updateSaving(
      int id,
      String name,
      int target,
      String? date,
      String token,
      ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'name': name,
        'target_amount': target,
        'date': date,
      }),
    );

    debugPrint('PUT UPDATE /wishlists/$id → ${response.statusCode}');
    debugPrint('BODY → ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Failed to update saving: ${response.body}');
    }
  }

  // ── DELETE ─────────────────────────────
  static Future<void> deleteSaving(
      int id,
      String token,
      ) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    debugPrint('DELETE /wishlists/$id → ${response.statusCode}');

    if (response.statusCode != 200) {
      throw Exception('Failed to delete wishlist');
    }
  }
}