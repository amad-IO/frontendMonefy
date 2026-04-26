import 'package:flutter/material.dart';

/// ══════════════════════════════════════════════════════════════
/// CategoryBreakdown — satu item kategori pengeluaran/pemasukan
///
/// Mendukung DUA jenis icon:
///   • SVG asset  → untuk expense categories (Food, Transport, dll.)
///   • Material Icon → untuk income categories (Salary, Freelance, dll.)
///
/// Gunakan [useMaterialIcon] untuk menentukan jenis icon yang dipakai.
/// ══════════════════════════════════════════════════════════════
class CategoryBreakdown {
  final String name;
  final double amount;
  final double percentage;
  final Color color;

  /// Path ke SVG icon (untuk expense categories).
  final String iconAsset;

  /// Material icon (untuk income categories).
  /// Jika tidak null, widget harus render Icon() bukan SvgPicture.
  final IconData? iconData;

  /// true jika kategori ini menggunakan Material Icon.
  bool get useMaterialIcon => iconData != null;

  CategoryBreakdown({
    required this.name,
    required this.amount,
    required this.percentage,
    required this.color,
    required this.iconAsset,
    this.iconData,
  });

  factory CategoryBreakdown.fromJson(Map<String, dynamic> json) {
    return CategoryBreakdown(
      name: json['name']?.toString() ?? '',
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      percentage: double.tryParse(json['percentage'].toString()) ?? 0.0,
      color: Color(int.tryParse(json['color']?.toString() ?? '0xFF888888') ?? 0xFF888888),
      iconAsset: json['icon_asset']?.toString() ?? 'assets/icon/more.svg',
    );
  }
}
