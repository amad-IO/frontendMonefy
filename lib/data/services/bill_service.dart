import '../api_services.dart';
import '../models/bill_model.dart';

class BillService {
  final ApiService _api = ApiService();

  /// GET BILLS
  Future<List<Bill>> getBills(String token) async {
    final list = await _api.getBills(token);

    return list.map((e) => Bill.fromJson(e)).toList();
  }

  /// CREATE
  Future<void> createBill(Map<String, dynamic> data, String token) async {
    await _api.createBill(data, token);
  }

  /// UPDATE
  Future<void> updateBill(int id, Map<String, dynamic> data, String token) async {
    await _api.updateBill(id.toString(), data, token);
  }

  /// DELETE
  Future<void> deleteBill(int id, String token) async {
    await _api.deleteBill(id.toString(), token);
  }
}