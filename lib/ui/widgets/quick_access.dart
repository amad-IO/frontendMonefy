import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_colors.dart';

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
      padding: const EdgeInsets.fromLTRB(16, 12, 16,1),
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
              color:accentColor,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _QuickAccessButton(
                  svgPath: 'assets/icon/Bills.svg',
                  label: 'Bills',
                  color: accentColor,
                  labelColor: colorScheme.onSurface.withValues(alpha: 0.8),
                  onTap: onBillsTap,
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: _QuickAccessButton(
                  svgPath: 'assets/icon/add.svg',
                  label: 'Add Wallet',
                  color: accentColor,
                  labelColor: colorScheme.onSurface.withValues(alpha: 0.8),
                  onTap: onAddWalletTap,
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: _QuickAccessButton(
                  svgPath: 'assets/icon/Saving.svg',
                  label: 'Saving',
                  color: accentColor,
                  labelColor: colorScheme.onSurface.withValues(alpha: 0.8),
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

class _QuickAccessButton extends StatefulWidget {
  final String svgPath;
  final String label;
  final Color color;
  final Color? labelColor;
  final VoidCallback? onTap;

  const _QuickAccessButton({
    required this.svgPath,
    required this.label,
    required this.color,
    this.labelColor,
    this.onTap,
  });

  @override
  State<_QuickAccessButton> createState() => _QuickAccessButtonState();
}

class _QuickAccessButtonState extends State<_QuickAccessButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onTap,
                  customBorder: const CircleBorder(),
                  splashFactory: InkRipple.splashFactory,
                  splashColor: widget.color.withValues(alpha: 0.30),
                  highlightColor: widget.color.withValues(alpha: 0.15),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: SvgPicture.asset(
                      widget.svgPath,
                      width: 34,
                      height: 34,
                      colorFilter: ColorFilter.mode(
                        widget.color,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.label,
                style: AppTextStyle.caption.copyWith(
                  color: widget.labelColor ?? widget.color,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}