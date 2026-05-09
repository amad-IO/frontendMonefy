import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class GlassCircleButton extends StatefulWidget {
  final double size;
  final double sx;
  final double sy;
  final VoidCallback? onTap;
  final Widget child;

  const GlassCircleButton({
    super.key,
    required this.size,
    required this.sx,
    required this.sy,
    this.onTap,
    required this.child,
  });

  @override
  State<GlassCircleButton> createState() => _GlassCircleButtonState();
}

class _GlassCircleButtonState extends State<GlassCircleButton> {
  bool _pressed = false;

  void _handleTapDown(TapDownDetails _) => setState(() => _pressed = true);

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
    final w = widget.size * widget.sx;
    final h = widget.size * widget.sy;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedScale(
        scale: _pressed ? 0.88 : 1.0,
        duration: Duration(milliseconds: _pressed ? 40 : 150),
        curve: Curves.easeOut,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(w),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              width: w,
              height: h,
              decoration: BoxDecoration(
                color: _pressed
                    ? AppColors.dashboardPurple.withValues(alpha: 0.7)
                    : Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: _pressed
                      ? AppColors.primaryPurple.withValues(alpha: 0.5)
                      : Colors.white.withValues(alpha: 0.3),
                  width: _pressed ? 1.5 : 0.8,
                ),
              ),
              child: Center(child: widget.child),
            ),
          ),
        ),
      ),
    );
  }
}