import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/app_config.dart';
import '../models/transaction_model.dart';

class TransactionService {
  static const String baseUrl = AppConfig.baseUrl;

  static Map<String, String> _headers(String token) => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };

  // ── GET /transactions ─────────────────────────────────────────
  // Backend returns list of transactions dengan relasi wallet & wishlist.
  // Response: [ { id, wallet_id, wallet: {id, name_wallet}, title,
  //              amount, type, category, transaction_date, note, ... } ]
  Future<List<TransactionModel>> getTransactions(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/transactions'),
      headers: _headers(token),
    );

    print('GET /transactions → ${response.statusCode}');
    print('BODY: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => TransactionModel.fromJson(e)).toList();
    } else {
      throw Exception('Gagal load transaksi: ${response.statusCode}');
    }
  }

  // ── POST /transactions ────────────────────────────────────────
  // Required fields: wallet_id, title, amount, type, category, transaction_date
  // Optional: to_wallet_id, note, wishlist_id
  Future<void> addTransaction({
    required String token,
    required String walletId,      // String karena WalletModel.id adalah String
    String? toWalletId,
    required String title,
    required double amount,
    required String type,          // 'income' | 'expense' | 'transfer'
    required String category,
    required String date,          // format: 'YYYY-MM-DD'
    String? note,
  }) async {
    final body = <String, dynamic>{
      'wallet_id': int.tryParse(walletId) ?? walletId,
      'title': title,
      'amount': amount,
      'type': type,
      'category': category,
      'transaction_date': date,
    };

    if (toWalletId != null && toWalletId.isNotEmpty) {
      body['to_wallet_id'] = int.tryParse(toWalletId) ?? toWalletId;
    }
    if (note != null && note.isNotEmpty) {
      body['note'] = note;
    }

    final response = await http.post(
      Uri.parse('$baseUrl/transactions'),
      headers: _headers(token),
      body: json.encode(body),
    );

    print('POST /transactions → ${response.statusCode}');
    print('BODY: ${response.body}');

    if (response.statusCode != 201) {
      final data = json.decode(response.body);
      throw Exception(data['message'] ?? 'Gagal tambah transaksi');
    }
  }

  // ── PUT /transactions/{id} ────────────────────────────────────
  // Backend: title, amount, category, transaction_date, note (semua nullable)
  Future<bool> updateTransaction(
    String id,
    Map<String, dynamic> data,
    String token,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/transactions/$id'),
      headers: _headers(token),
      body: json.encode(data),
    );

    print('PUT /transactions/$id → ${response.statusCode}');
    print('BODY: ${response.body}');

    return response.statusCode == 200;
  }

  // ── DELETE /transactions/{id} ─────────────────────────────────
  // Backend: kembalikan saldo wallet dan hapus transaksi
  Future<bool> deleteTransaction(String id, String token) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/transactions/$id'),
      headers: _headers(token),
    );

    print('DELETE /transactions/$id → ${response.statusCode}');
    return response.statusCode == 200;
  }
}