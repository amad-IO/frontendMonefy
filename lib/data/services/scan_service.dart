import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/app_config.dart';

// ══════════════════════════════════════════════════════════════════════════════
/// ScanService — kirim foto struk ke backend AI, ambil total.
///
/// Endpoint  : POST {baseUrl}/scan-receipt
/// Body      : multipart/form-data  →  field: image (File)
/// Auth      : Bearer token
/// Response  : { "total": 85000 }
///
/// TODO: Ganti _endpoint jika path backend berubah.
// ══════════════════════════════════════════════════════════════════════════════
class ScanService {
  static const String _endpoint = '${AppConfig.baseUrl}/ai/scan-receipt';

  /// Kirim [imageFile] ke backend.
  /// Return [double] total jika berhasil, [null] jika gagal / error.
  static Future<double?> scanReceipt(File imageFile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final request = http.MultipartRequest(
        'POST',
        Uri.parse(_endpoint),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
      );
      final response = await http.Response.fromStream(streamedResponse);

      print('POST /scan-receipt → ${response.statusCode}');
      print('BODY: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        // Backend response: { "success": true, "data": { "total": 85000 } }
        final innerData = data['data'] as Map<String, dynamic>?;
        final rawTotal = innerData?['total'];
        if (rawTotal != null) {
          return (rawTotal as num).toDouble();
        }
      }

      return null;
    } catch (e) {
      print('ScanService error: $e');
      return null;
    }
  }
}
