import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/saving_model.dart';
import '../../config/app_config.dart';

// ══════════════════════════════════════════════════════════════
/// SavingService — service untuk CRUD Saving via backend API.
///
/// ⚠️ CATATAN SCHEMA MISMATCH:
/// Backend Wishlist hanya punya: id, name, status (belum_terbeli/terbeli)
/// Frontend Saving punya: id, name, amount, target, date
/// Field amount/target/date TIDAK ada di backend → hanya disimpan lokal.
///
/// Endpoint: /wishlists (bukan /saving-goals)
// ══════════════════════════════════════════════════════════════
class SavingService {
  static String get baseUrl => '${AppConfig.baseUrl}/wishlists';

  // ── GET /wishlists ──────────────────────────────────────────
  /// Response: { "status": "success", "data": [ { id, name, status } ] }
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
      return data.map((e) => Saving.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load savings: ${response.statusCode}');
    }
  }

  // ── POST /wishlists ─────────────────────────────────────────
  /// Backend hanya terima: name, status (opsional)
  /// Field target/date tidak ada di backend → hanya dikirim name.
  static Future<Saving> createSaving(String name, String token) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'name': name,
        'status': 'belum_terbeli',
      }),
    );

    debugPrint('POST /wishlists → ${response.statusCode}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = json.decode(response.body) as Map<String, dynamic>;
      return Saving.fromJson(decoded['data'] as Map<String, dynamic>);
    } else {
      throw Exception('Failed to create saving: ${response.statusCode}');
    }
  }

  // ── PUT /wishlists/{id} — update status ─────────────────────
  static Future<bool> updateStatus(int id, String status, String token) async {
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