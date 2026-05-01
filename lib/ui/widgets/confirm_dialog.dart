import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// ══════════════════════════════════════════════════════════════
/// ConfirmDialog — Reusable confirmation dialog component.
///
/// Berisi: icon bulat, judul, deskripsi, dan dua tombol
/// (Cancel + Confirm) yang semuanya bisa dikustomisasi.
///
/// Cara pakai:
/// ```dart
/// ConfirmDialog.show(
///   context: context,
///   icon: Icons.help_rounded,
///   title: 'Log out of your account?',
///   description: "Are you sure you want to log out of Monefy?",
///   confirmLabel: 'Log Out',
///   confirmColor: AppColors.error,
///   onConfirm: () { /* handle logout */ },
/// );
/// ```
/// ══════════════════════════════════════════════════════════════
class ConfirmDialog extends StatelessWidget {
  // ── Icon ────────────────────────────────────────────────────
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final double iconSize;

  // ── Text ────────────────────────────────────────────────────
  final String title;
  final String description;

  // ── Buttons ─────────────────────────────────────────────────
  final String cancelLabel;
  final String confirmLabel;
  final Color confirmColor;
  final Color cancelBorderColor;

  // ── Callbacks ───────────────────────────────────────────────
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;

  const ConfirmDialog({
    super.key,
    // Icon defaults
    this.icon = Icons.help_rounded,
    this.iconColor = const Color(0xFFFF2452),
    this.iconBgColor = const Color(0xFFFFE4EA),
    this.iconSize = 32,
    // Text (required)
    required this.title,
    required this.description,
    // Button labels
    this.cancelLabel = 'Cancel',
    required this.confirmLabel,
    // Button colors
    this.confirmColor = AppColors.error,
    this.cancelBorderColor = const Color(0xFFD0D0D0),
    // Callbacks
    this.onCancel,
    this.onConfirm,
  });

  // ── Static helper to show dialog ────────────────────────────
  static Future<void> show({
    required BuildContext context,
    IconData icon = Icons.help_rounded,
    Color iconColor = const Color(0xFFFF2452),
    Color iconBgColor = const Color(0xFFFFE4EA),
    double iconSize = 32,
    required String title,
    required String description,
    String cancelLabel = 'Cancel',
    required String confirmLabel,
    Color confirmColor = AppColors.error,
    Color cancelBorderColor = const Color(0xFFD0D0D0),
    VoidCallback? onCancel,
    VoidCallback? onConfirm,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (_) => ConfirmDialog(
        icon: icon,
        iconColor: iconColor,
        iconBgColor: iconBgColor,
        iconSize: iconSize,
        title: title,
        description: description,
        cancelLabel: cancelLabel,
        confirmLabel: confirmLabel,
        confirmColor: confirmColor,
        cancelBorderColor: cancelBorderColor,
        onCancel: onCancel,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: _DialogContent(
        icon: icon,
        iconColor: iconColor,
        iconBgColor: iconBgColor,
        iconSize: iconSize,
        title: title,
        description: description,
        cancelLabel: cancelLabel,
        confirmLabel: confirmLabel,
        confirmColor: confirmColor,
        cancelBorderColor: cancelBorderColor,
        onCancel: onCancel,
        onConfirm: onConfirm,
      ),
    );
  }
}

// ── Internal dialog card ─────────────────────────────────────

class _DialogContent extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final double iconSize;
  final String title;
  final String description;
  final String cancelLabel;
  final String confirmLabel;
  final Color confirmColor;
  final Color cancelBorderColor;
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;

  const _DialogContent({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.iconSize,
    required this.title,
    required this.description,
    required this.cancelLabel,
    required this.confirmLabel,
    required this.confirmColor,
    required this.cancelBorderColor,
    this.onCancel,
    this.onConfirm,
  });

  @override
  State<_DialogContent> createState() => _DialogContentState();
}

class _DialogContentState extends State<_DialogContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _scaleAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleCancel() {
    Navigator.of(context).pop();
    widget.onCancel?.call();
  }

  void _handleConfirm() {
    Navigator.of(context).pop();
    widget.onConfirm?.call();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 32,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Icon bulat ──────────────────────────────────
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: widget.iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    widget.icon,
                    color: widget.iconColor,
                    size: widget.iconSize,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── Judul ───────────────────────────────────────
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  height: 1.3,
                ),
              ),

              const SizedBox(height: 10),

              // ── Deskripsi ───────────────────────────────────
              Text(
                widget.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 28),

              // ── Tombol ──────────────────────────────────────
              Row(
                children: [
                  // Cancel button
                  Expanded(
                    child: _DialogButton(
                      label: widget.cancelLabel,
                      isFilled: false,
                      borderColor: widget.cancelBorderColor,
                      onTap: _handleCancel,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Confirm button
                  Expanded(
                    child: _DialogButton(
                      label: widget.confirmLabel,
                      isFilled: true,
                      fillColor: widget.confirmColor,
                      onTap: _handleConfirm,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Button helper ────────────────────────────────────────────

class _DialogButton extends StatefulWidget {
  final String label;
  final bool isFilled;
  final Color? fillColor;
  final Color? borderColor;
  final VoidCallback? onTap;

  const _DialogButton({
    required this.label,
    required this.isFilled,
    this.fillColor,
    this.borderColor,
    this.onTap,
  });

  @override
  State<_DialogButton> createState() => _DialogButtonState();
}

class _DialogButtonState extends State<_DialogButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final fillColor = widget.fillColor ?? AppColors.error;
    final borderColor = widget.borderColor ?? const Color(0xFFD0D0D0);

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => Future.delayed(
        const Duration(milliseconds: 120),
        () { if (mounted) setState(() => _pressed = false); },
      ),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: widget.isFilled
                ? (_pressed
                    ? fillColor.withValues(alpha: 0.85)
                    : fillColor)
                : (_pressed
                    ? Colors.grey.shade100
                    : Colors.white),
            borderRadius: BorderRadius.circular(12),
            border: widget.isFilled
                ? null
                : Border.all(color: borderColor, width: 1.5),
            boxShadow: widget.isFilled
                ? [
                    BoxShadow(
                      color: fillColor.withValues(alpha: 0.30),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: widget.isFilled ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
