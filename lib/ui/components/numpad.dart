import 'package:flutter/material.dart';
import '../../theme/colors.dart';

class NumPad extends StatelessWidget {
  final ValueChanged<String>? onKeyTap;
  final VoidCallback? onBackspace;
  final VoidCallback? onConfirm;

  const NumPad({
    super.key,
    this.onKeyTap,
    this.onBackspace,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double height = constraints.maxHeight;

        const double baseWidth = 329;
        const double baseHeight = 218;
        final double sx = width / baseWidth;

        // Keep original design spacing ratio, but make key sizes derived
        // from the available space so the grid always fits exactly.
        final double gapX = 12 * (width / baseWidth);
        final double gapY = 12 * (height / baseHeight);
        final double buttonWidth = (width - (gapX * 3)) / 4;
        final double buttonHeight = (height - (gapY * 3)) / 4;
        final double specialWidth = buttonWidth;
        final double specialHeight = buttonHeight * 2 + gapY;
        final double radius = 18 * sx;

        Widget numberButton(String label, double left, double top) {
          return Positioned(
            left: left,
            top: top,
            child: _KeyButton(
              width: buttonWidth,
              height: buttonHeight,
              backgroundColor: AppColors.numpadButton,
              shadowColor: AppColors.panelShadow,
              borderRadius: radius,
              onTap: onKeyTap == null ? null : () => onKeyTap!(label),
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: label == '000' ? 16 * sx : 17 * sx,
                  fontWeight: FontWeight.w700,
                  color: AppColors.numpadText,
                ),
              ),
            ),
          );
        }

        Widget iconButton({
          required double left,
          required double top,
          required double width,
          required double height,
          required Color backgroundColor,
          required Color iconColor,
          required IconData icon,
          required VoidCallback? onTap,
        }) {
          return Positioned(
            left: left,
            top: top,
            child: _KeyButton(
              width: width,
              height: height,
              backgroundColor: backgroundColor,
              shadowColor: AppColors.panelShadow,
              borderRadius: radius,
              onTap: onTap,
              child: Icon(
                icon,
                color: iconColor,
                size: 26 * sx,
              ),
            ),
          );
        }

        return SizedBox(
          width: width,
          height: height,
          child: Stack(
            children: [
              numberButton('1', 0, 0),
              numberButton('2', buttonWidth + gapX, 0),
              numberButton('3', (buttonWidth + gapX) * 2, 0),

              iconButton(
                left: (buttonWidth + gapX) * 3,
                top: 0,
                width: specialWidth,
                height: buttonHeight,
                backgroundColor: AppColors.numpadDeleteBg,
                iconColor: AppColors.numpadDeleteIcon,
                icon: Icons.backspace_outlined,
                onTap: onBackspace,
              ),

              numberButton('4', 0, buttonHeight + gapY),
              numberButton('5', buttonWidth + gapX, buttonHeight + gapY),
              numberButton('6', (buttonWidth + gapX) * 2, buttonHeight + gapY),

              Positioned(
                left: (buttonWidth + gapX) * 3,
                top: buttonHeight + gapY,
                child: Container(
                  width: specialWidth,
                  height: buttonHeight,
                  decoration: BoxDecoration(
                    color: AppColors.numpadButton,
                    borderRadius: BorderRadius.circular(radius),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.panelShadow,
                        blurRadius: 18,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                ),
              ),

              numberButton('7', 0, (buttonHeight + gapY) * 2),
              numberButton('8', buttonWidth + gapX, (buttonHeight + gapY) * 2),
              numberButton('9', (buttonWidth + gapX) * 2, (buttonHeight + gapY) * 2),

              iconButton(
                left: (buttonWidth + gapX) * 3,
                top: (buttonHeight + gapY) * 2,
                width: specialWidth,
                height: specialHeight,
                backgroundColor: AppColors.numpadConfirmBg,
                iconColor: AppColors.numpadConfirmIcon,
                icon: Icons.check_rounded,
                onTap: onConfirm,
              ),

              numberButton('.', 0, (buttonHeight + gapY) * 3),
              numberButton('0', buttonWidth + gapX, (buttonHeight + gapY) * 3),
              numberButton('000', (buttonWidth + gapX) * 2, (buttonHeight + gapY) * 3),
            ],
          ),
        );
      },
    );
  }
}

class _KeyButton extends StatefulWidget {
  final double width;
  final double height;
  final Color backgroundColor;
  final Color shadowColor;
  final double borderRadius;
  final VoidCallback? onTap;
  final Widget child;

  const _KeyButton({
    required this.width,
    required this.height,
    required this.backgroundColor,
    required this.shadowColor,
    required this.borderRadius,
    required this.onTap,
    required this.child,
  });

  @override
  State<_KeyButton> createState() => _KeyButtonState();
}

class _KeyButtonState extends State<_KeyButton> {
  bool _pressed = false;

  static const _pressedColor = AppColors.dashboardPurple;
  static const _pressedBorder = AppColors.primaryPurple;

  void _handleTapDown(TapDownDetails _) {
    setState(() => _pressed = true);
  }

  void _handleTapUp(TapUpDetails _) {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) setState(() => _pressed = false);
    });
  }

  void _handleTapCancel() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _pressed = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedScale(
        scale: _pressed ? 0.88 : 1.0,
        duration: Duration(milliseconds: _pressed ? 40 : 150),
        curve: Curves.easeOut,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: _pressed ? _pressedColor : widget.backgroundColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: _pressed
                ? Border.all(color: _pressedBorder.withValues(alpha: 0.35), width: 1.5)
                : null,
            boxShadow: [
              BoxShadow(
                color: _pressed
                    ? AppColors.primaryPurple.withValues(alpha: 0.2)
                    : widget.shadowColor,
                blurRadius: _pressed ? 6 : 18,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Center(child: widget.child),
        ),
      ),
    );
  }
}