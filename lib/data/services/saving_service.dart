import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/saving_model.dart';

class SavingService {
  static const String baseUrl = "http://10.0.2.2:8000/api/savings";

  static Future<List<Saving>> getSavings(String token) async {
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List data =
      decoded is List ? decoded : decoded['data'] ?? [];

      return data.map((e) => Saving.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load savings");
    }
  }

  static Future<Saving> createSaving(
      Saving saving, String token) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: json.encode({
        "name": saving.name,
        "amount": saving.amount,
        "target": saving.target,
      }),
    );

    if (response.statusCode == 200 ||
        response.statusCode == 201) {
      final data = json.decode(response.body);
      return Saving.fromJson(data);
    } else {
      throw Exception("Failed to create saving");
    }
  }
}