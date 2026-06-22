import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/app_config.dart';
import '../models/scan_result.dart';

// ══════════════════════════════════════════════════════════════════════════════
/// ScanService — kirim foto struk ke backend AI (Gemini), ambil hasil scan.
///
/// Endpoint  : POST {baseUrl}/ai/scan-receipt
/// Body      : multipart/form-data  →  field: image (File, max 5MB)
/// Auth      : Bearer token (opsional — endpoint public, tapi dikirim untuk konsistensi)
///
/// Response sukses:
/// ```json
/// {
///   "success": true,
///   "data": {
///     "nama_toko": "Indomaret",
///     "tanggal": "2024-05-17",
///     "total": 85000,
///     "type": "expense",
///     "kategori": "Makanan",
///     "catatan": "Belanja harian"
///   }
/// }
/// ```
/// Return [ScanResult] jika berhasil, [null] jika gagal / error.
// ══════════════════════════════════════════════════════════════════════════════
class ScanService {
  static const String _endpoint = '${AppConfig.baseUrl}/ai/scan-receipt';

  static Future<ScanResult?> scanReceipt(File imageFile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final request = http.MultipartRequest('POST', Uri.parse(_endpoint));

      // Kirim token jika ada (endpoint public, tapi best practice tetap kirim)
      if (token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.headers['Accept'] = 'application/json';

      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 45), // Gemini butuh waktu lebih lama
      );
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('POST /ai/scan-receipt → ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> body =
            json.decode(response.body) as Map<String, dynamic>;

        // Cek flag success dari backend
        if (body['success'] != true) {
          debugPrint('ScanService: backend returned success=false — ${body['message']}');
          return null;
        }

        final data = body['data'] as Map<String, dynamic>?;
        if (data == null) {
          debugPrint('ScanService: data field is null');
          return null;
        }

        return ScanResult.fromJson(data);
      }

      // 422 = validasi gagal (gambar tidak valid)
      if (response.statusCode == 422) {
        debugPrint('ScanService: file validation failed — ${response.body}');
        return null;
      }

      debugPrint('ScanService: unexpected status ${response.statusCode}');
      return null;
    } catch (e) {
      debugPrint('ScanService error: $e');
      return null;
    }
  }
}
