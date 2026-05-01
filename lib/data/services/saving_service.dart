import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/saving_model.dart';

class SavingService {
  /// 🔥 GANTI sesuai backend kamu
  static const String baseUrl = "http://10.10.168.87:8080/api/savings";

  /// 🔥 GET semua saving
  static Future<List<Saving>> getSavings() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      List data = json.decode(response.body);

      return data.map((e) => Saving.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load savings");
    }
  }

  /// 🔥 POST (create saving)
  static Future<void> createSaving(Saving saving) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: json.encode(saving.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Failed to create saving");
    }
  }
}