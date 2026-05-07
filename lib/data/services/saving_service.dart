import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/saving_model.dart';

class SavingService {
  static const String baseUrl = "http://10.10.168.87:8080/api/savings";

  /// 🔥 GET semua saving
  static Future<List<Saving>> getSavings() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        /// ✅ handle 2 kemungkinan format
        final List data =
        decoded is List ? decoded : decoded['data'] ?? [];

        return data.map((e) => Saving.fromJson(e)).toList();
      } else {
        throw Exception(
            "Failed to load savings (${response.statusCode})");
      }
    } catch (e) {
      throw Exception("Error getSavings: $e");
    }
  }

  /// 🔥 POST (create saving)
  static Future<Saving> createSaving(Saving saving) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          /// ❌ jangan kirim id
          "name": saving.name,
          "amount": saving.amount,
          "target": saving.target,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return Saving.fromJson(data);
      } else {
        throw Exception(
            "Failed to create saving (${response.statusCode})");
      }
    } catch (e) {
      throw Exception("Error createSaving: $e");
    }
  }
}