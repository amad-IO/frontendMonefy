import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../data/models/analytic/category_breakdown.dart';

/// ══════════════════════════════════════════════════════════════
/// Reusable icon widget untuk kategori transaksi.
///
/// Otomatis memilih render path:
///   • Material Icon  → untuk income categories (Salary, Freelance, dll.)
///   • SVG asset      → untuk expense categories (Food, Transport, dll.)
///
/// Bisa dipakai di CategoryBreakdownList, DonutChart legend, dll.
/// ══════════════════════════════════════════════════════════════
class CategoryIcon extends StatelessWidget {
  final CategoryBreakdown category;
  final double size;
  final double iconSize;

  const CategoryIcon({
    super.key,
    required this.category,
    this.size = 40,
    this.iconSize = 22,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: category.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: category.useMaterialIcon
            ? Icon(
                category.iconData,
                size: iconSize,
                color: category.color,
              )
            : SvgPicture.asset(
                category.iconAsset,
                width: iconSize,
                height: iconSize,
                colorFilter: ColorFilter.mode(
                  category.color,
                  BlendMode.srcIn,
                ),
              ),
      ),
    );
  }
}
