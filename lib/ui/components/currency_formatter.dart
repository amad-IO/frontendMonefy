import 'package:flutter/services.dart';
import 'package:intl/intl.dart'; // Pastikan import ini ada di paling atas

// ... (kode rupiahFormatter yang sudah ada)

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Hapus semua karakter non-digit (termasuk titik sebelumnya)
    String cleanText = newValue.text.replaceAll(RegExp(r'\D'), '');

    int? value = int.tryParse(cleanText);
    if (value == null) {
      return oldValue;
    }

    // Format angka menggunakan pemisah ribuan Indonesia (.)
    final formatter = NumberFormat('#,##0', 'id_ID');
    String newText = formatter.format(value).replaceAll(',', '.');

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}