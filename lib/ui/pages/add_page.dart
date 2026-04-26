import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../data/models/transaction_model.dart';
import '../../providers/transaction_provider.dart';
import '../../core/theme/app_colors.dart';
import '../components/numpad.dart';
import '../components/filter_expense.dart';
import '../components/filter_income.dart';
import '../components/wallet_selector_popup.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage>
    with SingleTickerProviderStateMixin {
  TransactionType _type = TransactionType.income;
  String? _selectedCategory;
  String? _selectedWallet;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();

  // ── Wallet shake animation ──
  late final AnimationController _walletShakeController;
  bool _walletError = false;

  static final List<WalletOption> _wallets = [
    WalletOption(name: 'Gopay', icon: Icons.account_balance_wallet_rounded, balance: 500000),
    WalletOption(name: 'ShopeePay', icon: Icons.shopping_bag_rounded, balance: 250000),
    WalletOption(name: 'BCA', icon: Icons.account_balance_rounded, balance: 1500000),
    WalletOption(name: 'Cash', icon: Icons.payments_rounded, balance: 300000),
  ];

  @override
  void initState() {
    super.initState();
    _walletShakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _walletShakeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _walletShakeController.reset();
      }
    });
  }

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

    // ── Validate wallet selection ──
    if (_selectedWallet == null) {
      setState(() => _walletError = true);
      _walletShakeController.forward(from: 0);

      // Auto-clear error highlight after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _walletError = false);
      });

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: Colors.white, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Pilih penyimpanan terlebih dahulu!',
                  style: TextStyle(
                      fontFamily: 'Nunito', fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    // ── Determine category ──
    String category;
    if (_type == TransactionType.expense) {
      category = _selectedCategory ?? 'Expense';
      // If "More" was selected, use the title
      if (category == 'More' && _titleController.text.trim().isNotEmpty) {
        category = _titleController.text.trim();
      }
    } else {
      category = _selectedCategory ?? 'Income';
      if (category == 'More' && _titleController.text.trim().isNotEmpty) {
        category = _titleController.text.trim();
      }
    }

    // ── Create transaction and save to provider ──
    final transaction = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      category: category,
      amount: amount,
      date: DateTime.now(),
      walletName: _selectedWallet!,
      type: _type,
    );

    context.read<TransactionProvider>().addTransaction(transaction);

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
    _walletShakeController.dispose();
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
                      color: AppColors.decorativeCircle,
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
                      color: AppColors.decorativeCircle,
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
                  left: 105 * sx,
                  top: 24 * sy,
                  child: _buildToggleButton(
                      'Income', TransactionType.income, sx, sy),
                ),

                // ── Expense toggle (glass) ──
                Positioned(
                  left: 235 * sx,
                  top: 24 * sy,
                  child: _buildToggleButton(
                      'Expense', TransactionType.expense, sx, sy),
                ),

                // ── Mic button (glass, bottom-right) ──
                Positioned(
                  left: 330 * sx,
                  top: 60 * sy,
                  child: _GlassCircleButton(
                    size: 52,
                    sx: sx,
                    sy: sy,
                    child: Icon(Icons.mic_rounded,
                        color: Colors.white, size: 26 * sx),
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
                        color: AppColors.backgroundWhite,
                        fontSize: 43 * sy,
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                // ── Camera button (glass, bottom-right) ──
                Positioned(
                  left: 330 * sx,
                  top: 125 * sy,
                  child: _GlassCircleButton(
                    size: 52,
                    sx: sx,
                    sy: sy,
                    child: Icon(Icons.camera_alt_rounded,
                        color: Colors.white, size: 26 * sx),
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
                      color: AppColors.backgroundWhite,
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

                // ── Category icons ──
                Positioned(
                  left: 20 * sx,
                  right: 20 * sx,
                  top: (194 + 24) * sy,
                  child: _type == TransactionType.expense
                      ? FilterExpanse(
                          sx: sx,
                          sy: sy,
                          onCategorySelected: (cat) {
                            setState(() => _selectedCategory = cat);
                          },
                        )
                      : FilterIncome(
                          sx: sx,
                          sy: sy,
                          onCategorySelected: (cat) {
                            setState(() => _selectedCategory = cat);
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

    final isIncome = type == TransactionType.income;
    final arrowIcon = isIncome
        ? Icons.arrow_downward_rounded
        : Icons.arrow_upward_rounded;

    final child = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 100 * sx,
      height: 40 * sy,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.dashboardPurple
            : Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          width: isActive ? 1.0 : 0.5,
          color: isActive
              ? AppColors.dashboardPurple
              : Colors.white.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            arrowIcon,
            color: isActive ? AppColors.primaryPurple : AppColors.white2,
            size: 16 * sy,
          ),
          SizedBox(width: 4 * sx),
          Text(
            label,
            style: TextStyle(
              color: isActive
                  ? AppColors.primaryPurple
                  : AppColors.white2,
              fontSize: 14 * sy,
              fontFamily: 'Nunito',
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );

    return GestureDetector(
      onTap: () {
        setState(() {
          _type = type;
          _selectedCategory = null;
          _titleController.clear();
        });
      },
      child: isActive
          ? child
          : ClipRRect(
              borderRadius: BorderRadius.circular(18),
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
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: double.infinity,
            padding: EdgeInsets.only(
                top: 9 * sy, left: 12 * sx, bottom: 9 * sy),
            decoration: BoxDecoration(
              color: _selectedCategory == 'More'
                  ? AppColors.dashboardPurple.withValues(alpha: 0.3)
                  : AppColors.white2,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _selectedCategory == 'More'
                    ? AppColors.primaryPurple
                    : Colors.transparent,
                width: 1.2,
              ),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.lightShadow,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.description_outlined,
                    size: 16 * sx,
                    color: _selectedCategory == 'More'
                        ? AppColors.primaryPurple
                        : AppColors.disabled),
                SizedBox(width: 8 * sx),
                Expanded(
                  child: TextField(
                    controller: _titleController,
                    enabled: _selectedCategory == 'More',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 13.5 * sy,
                      color: _selectedCategory == 'More'
                          ? AppColors.textPrimary
                          : AppColors.disabled,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Add Title',
                      hintStyle: TextStyle(
                        color: _selectedCategory == 'More'
                            ? AppColors.primaryPurple.withValues(alpha: 0.5)
                            : AppColors.disabled,
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

        // Select Wallet — wrapped with shake animation
        AnimatedBuilder(
          animation: _walletShakeController,
          builder: (context, child) {
            // Sine-based shake: oscillates 3× across 500 ms
            final double shake = _walletShakeController.value == 0
                ? 0
                : math.sin(_walletShakeController.value * math.pi * 6) *
                    4 *
                    (1 - _walletShakeController.value);
            return Transform.translate(
              offset: Offset(shake, 0),
              child: child,
            );
          },
          child: GestureDetector(
            onTap: () async {
              final selected = await WalletSelectorPopup.show(
                context: context,
                wallets: _wallets,
                selectedWallet: _selectedWallet,
              );
              if (selected != null && mounted) {
                setState(() {
                  _selectedWallet = selected;
                  _walletError = false;
                });
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 100 * sx,
              height: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 4 * sx),
              decoration: BoxDecoration(
                color: _walletError
                    ? AppColors.error.withValues(alpha: 0.08)
                    : AppColors.white2,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _walletError
                      ? AppColors.error
                      : _selectedWallet != null
                          ? AppColors.primaryPurple.withValues(alpha: 0.3)
                          : Colors.transparent,
                  width: _walletError ? 1.5 : (_selectedWallet != null ? 1 : 0),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.lightShadow,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    _selectedWallet ?? 'Select Wallet',
                    maxLines: 1,
                    style: TextStyle(
                      color: _walletError
                          ? AppColors.error
                          : _selectedWallet != null
                              ? AppColors.primaryPurple
                              : AppColors.disabled,
                      fontSize: 13.5 * sy,
                      fontFamily: 'Nunito',
                      fontWeight: _walletError || _selectedWallet != null
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
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
