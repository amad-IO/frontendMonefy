import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import '../../models/transaction_model.dart';
import '../../theme/colors.dart';
import '../../theme/text_style.dart';
import '../widgets/numpad.dart';
import '../components/filter_expanse.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  TransactionType _type = TransactionType.income;
  String? _selectedWallet;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();

  static const List<String> _wallets = ['Gopay', 'ShopeePay', 'BCA', 'Cash'];

  // ── Amount formatting ──

  String get _formattedAmount {
    final toParse = _amountController.text.trim();
    final amount = double.tryParse(toParse) ?? 0;
    final formatter = NumberFormat('#,##0', 'id_ID');
    return 'Rp. ${formatter.format(amount)}';
  }

  void _onNumPadKeyTap(String key) {
    final current = _amountController.text;

    if (key == '.') {
      if (current.contains('.')) return;
      final next = current.isEmpty ? '0.' : '$current.';
      setState(() => _amountController.text = next);
      return;
    }

    if (key == '000') {
      if (current.isEmpty) {
        setState(() => _amountController.text = '0');
      } else {
        setState(() => _amountController.text = '$current$key');
      }
      return;
    }

    if (current == '0') {
      setState(() => _amountController.text = key);
      return;
    }

    setState(() => _amountController.text = '$current$key');
  }

  void _onNumPadBackspace() {
    final current = _amountController.text;
    if (current.isEmpty) return;

    setState(() {
      _amountController.text = current.substring(0, current.length - 1);
    });
  }

  void _onConfirm() {
    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    if (amount <= 0) return;

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Transaction added successfully!',
          style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  // ── Build ──
  //
  // Figma reference frame  : 390 × 673
  //   gradient zone         : 0 → 194   (29 %)
  //   content area          : 194 → 673  (71 %, height 479)
  //     category padding‑top: 134
  //     input row           : 28
  //     gap                 : 36
  //     numpad              : 218
  //     bottom padding      : 63
  //
  // All positions below are derived from those values
  // and scaled via sx / sy so the layout adapts to any screen.

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.of(context).padding.bottom;

    return FractionallySizedBox(
      heightFactor: 0.86,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double w = constraints.maxWidth;
          final double h = constraints.maxHeight;

          // Scale factors from Figma (390 × 673)
          final double sx = w / 390;
          final double sy = h / 673;

          return Container(
            clipBehavior: Clip.antiAlias,
            decoration: const ShapeDecoration(
              gradient: AppColors.primaryGradient,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                  bottomLeft: Radius.circular(0),
                  bottomRight: Radius.circular(0),
                ),
              ),
            ),
            child: Stack(
              children: [
                // ── Decorative circles ──
                Positioned(
                  left: 268 * sx,
                  top: -46 * sy,
                  child: Container(
                    width: 168 * sx,
                    height: 168 * sy,
                    decoration: const ShapeDecoration(
                      color: Color(0x0CF6F7FB),
                      shape: OvalBorder(),
                    ),
                  ),
                ),
                Positioned(
                  left: -56 * sx,
                  top: 89 * sy,
                  child: Container(
                    width: 168 * sx,
                    height: 168 * sy,
                    decoration: const ShapeDecoration(
                      color: Color(0x0CF6F7FB),
                      shape: OvalBorder(),
                    ),
                  ),
                ),

                // ── Back button (glass) ──
                Positioned(
                  left: 28 * sx,
                  top: 23 * sy,
                  child: _GlassCircleButton(
                    size: 42,
                    sx: sx,
                    sy: sy,
                    onTap: () => Navigator.of(context).pop(),
                    child: SvgPicture.asset(
                      'assets/icon/back.svg',
                      width: 22 * sx,
                      height: 22 * sy,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),

                // ── Income toggle (glass) ──
                Positioned(
                  left: 117 * sx,
                  top: 28 * sy,
                  child: _buildToggleButton(
                      'Income', TransactionType.income, sx, sy),
                ),

                // ── Expense toggle (glass) ──
                Positioned(
                  left: 218 * sx,
                  top: 28 * sy,
                  child: _buildToggleButton(
                      'Expense', TransactionType.expense, sx, sy),
                ),

                // ── Mic button (glass) ──
                Positioned(
                  left: 335 * sx,
                  top: 25 * sy,
                  child: _GlassCircleButton(
                    size: 40,
                    sx: sx,
                    sy: sy,
                    child: Icon(Icons.mic_rounded,
                        color: Colors.white, size: 22 * sx),
                  ),
                ),

                // ── Amount text ──
                Positioned(
                  left: 61 * sx,
                  top: 78 * sy,
                  right: 72 * sx,
                  child: FittedBox(
                    alignment: Alignment.centerLeft,
                    fit: BoxFit.scaleDown,
                    child: Text(
                      _formattedAmount,
                      maxLines: 1,
                      style: TextStyle(
                        color: const Color(0xFFF1F1F1),
                        fontSize: 43 * sy,
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                // ── Camera button (glass) ──
                Positioned(
                  left: 332 * sx,
                  top: 87 * sy,
                  child: _GlassCircleButton(
                    size: 40,
                    sx: sx,
                    sy: sy,
                    child: Icon(Icons.camera_alt_rounded,
                        color: Colors.white, size: 22 * sx),
                  ),
                ),

                // ── Content area (F1F1F1) ──
                Positioned(
                  left: 0,
                  right: 0,
                  top: 194 * sy,
                  bottom: 0,
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: const ShapeDecoration(
                      color: Color(0xFFF1F1F1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                          bottomLeft: Radius.circular(0),
                          bottomRight: Radius.circular(0),
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: 134 * sy),

                        // ── Input row (Add Title + Choose Wallet) ──
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30 * sx),
                          child: SizedBox(
                            height: 40 * sy,
                            child: _buildInputRow(sx, sy),
                          ),
                        ),
                        SizedBox(height: 24 * sy),

                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: 30 * sx,
                              right: 30 * sx,
                              bottom: safeBottom + (12 * sy),
                            ),
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: SizedBox(
                                width: double.infinity,
                                height: 218 * sy,
                                child: NumPad(
                                  onKeyTap: _onNumPadKeyTap,
                                  onBackspace: _onNumPadBackspace,
                                  onConfirm: _onConfirm,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Category icons (floating in the content top‑padding zone) ──
                Positioned(
                  left: 20 * sx,
                  right: 20 * sx,
                  top: (194 + 24) * sy,
                  child: FilterExpanse(
                    sx: sx,
                    sy: sy,
                    onCategorySelected: (cat) {
                      // print("Category Selected: $cat");
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Toggle button (Income / Expense) ──

  // ── Glass circle helper ──

  // ── Toggle button (Income / Expense) — glass ──

  Widget _buildToggleButton(
      String label, TransactionType type, double sx, double sy) {
    final isActive = _type == type;

    final child = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 86 * sx,
      height: 32 * sy,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.dashboardPurple
            : Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          width: isActive ? 1.0 : 0.5,
          color: isActive
              ? AppColors.dashboardPurple
              : Colors.white.withValues(alpha: 0.2),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive
              ? AppColors.primaryPurple
              : const Color(0xFFF6F7FB),
          fontSize: 16.87 * sy,
          fontFamily: 'Nunito',
          fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );

    return GestureDetector(
      onTap: () => setState(() => _type = type),
      child: isActive
          ? child
          : ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: child,
              ),
            ),
    );
  }

  // ── Category row ──



  // ── Input row ──

  Widget _buildInputRow(double sx, double sy) {
    return Row(
      children: [
        // Add Title
        Expanded(
          child: Container(
            height: double.infinity,
            padding: EdgeInsets.only(
                top: 9 * sy, left: 12 * sx, bottom: 9 * sy),
            decoration: ShapeDecoration(
              color: const Color(0xFFF6F7FB),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              shadows: const [
                BoxShadow(
                  color: Color(0x0C000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.description_outlined,
                    size: 16 * sx, color: AppColors.disabled),
                SizedBox(width: 8 * sx),
                Expanded(
                  child: TextField(
                    controller: _titleController,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 13.5 * sy,
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Add Title',
                      hintStyle: TextStyle(
                        color: const Color(0xFFB2B2B2),
                        fontSize: 13.5 * sy,
                        fontFamily: 'Nunito',
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(width: 21 * sx),

        // Choose Wallet
        PopupMenuButton<String>(
          onSelected: (value) => setState(() => _selectedWallet = value),
          offset: Offset(0, 42 * sy),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          itemBuilder: (context) => _wallets.map((w) {
            return PopupMenuItem<String>(
              value: w,
              child: Text(
                w,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
              ),
            );
          }).toList(),
          child: Container(
            width: 100 * sx,
            height: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 4 * sx),
            decoration: ShapeDecoration(
              color: const Color(0xFFF6F7FB),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              shadows: const [
                BoxShadow(
                  color: Color(0x0C000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  _selectedWallet ?? 'Choose Wallet',
                  maxLines: 1,
                  style: TextStyle(
                    color: _selectedWallet != null
                        ? AppColors.textPrimary
                        : const Color(0xFFB2B2B2),
                    fontSize: 13.5 * sy,
                    fontFamily: 'Nunito',
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}



class _GlassCircleButton extends StatefulWidget {
  final double size;
  final double sx;
  final double sy;
  final VoidCallback? onTap;
  final Widget child;

  const _GlassCircleButton({
    required this.size,
    required this.sx,
    required this.sy,
    this.onTap,
    required this.child,
  });

  @override
  State<_GlassCircleButton> createState() => _GlassCircleButtonState();
}

class _GlassCircleButtonState extends State<_GlassCircleButton> {
  bool _pressed = false;

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
