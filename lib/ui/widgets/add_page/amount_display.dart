import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/add_page_helper.dart';

/// Widget yang menampilkan jumlah uang di bagian atas AddPage.
/// Contoh: "Rp. 100.000"
class AmountDisplay extends StatelessWidget {
  final String rawAmount;
  final double sx;
  final double sy;

  const AmountDisplay({
    super.key,
    required this.rawAmount,
    required this.sx,
    required this.sy,
  });

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Text(
        AddPageHelper.formatAmount(rawAmount),
        style: TextStyle(
          color: AppColors.backgroundWhite,
          fontSize: 43 * sy,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
