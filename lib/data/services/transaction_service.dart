import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/app_config.dart';

class TransactionService {
  static const String baseUrl = AppConfig.baseUrl;

  Future<void> addTransaction({
    required String token,
    required int walletId,
    int? toWalletId,
    required String title,
    required double amount,
    required String type,
    required String category,
    required String date,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/transactions"),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
      body: json.encode({
        "wallet_id": walletId,
        "to_wallet_id": toWalletId,
        "title": title,
        "amount": amount,
        "type": type,
        "category": category,
        "transaction_date": date,
      }),
    );

    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

    final data = json.decode(response.body);

    if (response.statusCode != 201) {
      throw Exception(data["message"] ?? "Gagal tambah transaksi");
    }
  }
}