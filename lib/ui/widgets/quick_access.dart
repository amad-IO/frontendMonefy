import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../theme/text_style.dart';
import '../pages/bills_page.dart';

class QuickAccess extends StatelessWidget {
  final VoidCallback? onBillsTap;

  final VoidCallback? onAddWalletTap;

  final VoidCallback? onSavingTap;

  const QuickAccess({
    super.key,
    this.onBillsTap,
    this.onAddWalletTap,
    this.onSavingTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accentColor = colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Access',
            style: AppTextStyle.title.copyWith(
              color: accentColor,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _QuickAccessButton(
                  svgPath: 'assets/icon/Bills.svg',
                  label: 'Bills',
                  color: accentColor,
                  onTap: onBillsTap,

                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickAccessButton(
                  svgPath: 'assets/icon/add.svg',
                  label: 'Add Wallet',
                  color: accentColor,
                  onTap: onAddWalletTap,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickAccessButton(
                  svgPath: 'assets/icon/Saving.svg',
                  label: 'Saving',
                  color: accentColor,
                  onTap: onSavingTap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickAccessButton extends StatelessWidget {
  final String svgPath;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _QuickAccessButton({
    required this.svgPath,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              svgPath,
              width: 34,
              height: 34,
              colorFilter: ColorFilter.mode(
                color,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 6),

            Text(
              label,
              style: AppTextStyle.caption.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}