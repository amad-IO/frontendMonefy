import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/wallet_model.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../core/theme/app_colors.dart';
import '../components/numpad.dart';
import '../components/filter_expense.dart';
import '../components/filter_income.dart';
import '../components/filter_transfer.dart';
import '../components/wallet_selector_popup.dart';

class AddPage extends StatefulWidget {
  /// Jika diisi, AddPage berjalan dalam mode Edit.
  /// Semua field akan di-preload dari transaksi ini.
  /// Jika null, AddPage berjalan dalam mode Add (tambah baru).
  final TransactionModel? editTransaction;

  const AddPage({super.key, this.editTransaction});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage>
    with SingleTickerProviderStateMixin {
  // ── Mode flag ──
  bool get _isEditMode => widget.editTransaction != null;

  // ── Transaction type (0=Income, 1=Expense, 2=Transfer) ──
  int _typeIndex = 0;

  TransactionType get _type {
    switch (_typeIndex) {
      case 1:
        return TransactionType.expense;
      case 2:
        return TransactionType.transfer;
      default:
        return TransactionType.income;
    }
  }

  String? _selectedCategory;
  String? _selectedWallet;     // From wallet (semua mode)
  String? _selectedToWallet;   // To wallet (hanya Transfer)

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();

  // ── Wallet shake animation (validasi) ──
  late final AnimationController _walletShakeController;
  bool _walletError = false;

  // ── Key to reset FilterTransfer selection when From wallet changes ──
  Key _filterTransferKey = UniqueKey();

  // ── Tab labels ──
  static const List<String> _tabLabels = ['Income', 'Expense', 'Transfer'];

  /// Konversi WalletModel → WalletOption.
  /// Icon ditentukan berdasarkan WalletCategory.
  static WalletOption _toWalletOption(WalletModel w) {
    final IconData icon;
    switch (w.category) {
      case WalletCategory.cash:
        icon = Icons.payments_rounded;
        break;
      case WalletCategory.bankAccount:
        icon = Icons.account_balance_rounded;
        break;
      case WalletCategory.eWallet:
        icon = Icons.account_balance_wallet_rounded;
        break;
    }
    return WalletOption(name: w.name, icon: icon, balance: w.balance);
  }

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

    // ── Preload data jika mode Edit ──
    if (_isEditMode) {
      final t = widget.editTransaction!;

      // Set tab index sesuai type transaksi
      _typeIndex = t.type == TransactionType.income
          ? 0
          : t.type == TransactionType.expense
              ? 1
              : 2;

      // Set category & wallet
      _selectedCategory = t.category;
      _selectedWallet   = t.walletName.isEmpty ? null : t.walletName;
      _selectedToWallet = t.toWalletName.isEmpty ? null : t.toWalletName;

      // Set amount — tanpa desimal jika bulat
      _amountController.text = t.amount == t.amount.truncateToDouble()
          ? t.amount.toInt().toString()
          : t.amount.toString();

      // Set title
      _titleController.text = t.title;
    }
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

    // ── Validate From Wallet ──
    if (_selectedWallet == null) {
      setState(() => _walletError = true);
      _walletShakeController.forward(from: 0);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _walletError = false);
      });
      _showSnackBar(
        'Pilih penyimpanan terlebih dahulu!',
        AppColors.error,
        Icons.warning_amber_rounded,
      );
      return;
    }

    // ── Validate To Wallet (Transfer only) ──
    if (_type == TransactionType.transfer && _selectedToWallet == null) {
      _showSnackBar(
        'Pilih wallet tujuan transfer!',
        AppColors.error,
        Icons.warning_amber_rounded,
      );
      return;
    }

    // ── Determine category & title ──
    String category;
    String title = '';

    if (_type == TransactionType.transfer) {
      category = 'Transfer';
    } else if (_type == TransactionType.expense) {
      category = _selectedCategory ?? 'Expense';
      if (category == 'More') title = _titleController.text.trim();
    } else {
      category = _selectedCategory ?? 'Income';
      if (category == 'More') title = _titleController.text.trim();
    }

    if (_isEditMode) {
      // ── Mode Edit: update transaksi yang sudah ada ──
      final updated = widget.editTransaction!.copyWith(
        category:     category,
        title:        title,
        amount:       amount,
        walletName:   _selectedWallet!,
        toWalletName: _type == TransactionType.transfer
            ? (_selectedToWallet ?? '')
            : '',
        type: _type,
        // date dibiarkan tetap (tanggal asli transaksi)
        // Jika ingin update tanggal ke sekarang: date: DateTime.now()
      );

      context.read<TransactionProvider>().updateTransaction(updated);

      Navigator.of(context).pop();
      _showSnackBar(
        'Transaksi berhasil diperbarui!',
        AppColors.success,
        Icons.check_circle_rounded,
      );
    } else {
      // ── Mode Add: tambah transaksi baru ──
      final transaction = TransactionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        category: category,
        title: title,
        amount: amount,
        date: DateTime.now(),
        walletName: _selectedWallet!,
        toWalletName: _type == TransactionType.transfer
            ? (_selectedToWallet ?? '')
            : '',
        type: _type,
      );

      context.read<TransactionProvider>().addTransaction(transaction);

      Navigator.of(context).pop();
      _showSnackBar(
        _type == TransactionType.transfer
            ? 'Transfer berhasil dicatat!'
            : 'Transaction added successfully!',
        AppColors.success,
        Icons.check_circle_rounded,
      );
    }
  }

  void _showSnackBar(String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                    fontFamily: 'Nunito', fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        duration: const Duration(seconds: 2),
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

  // ══════════════════════════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.of(context).padding.bottom;

    // ── Baca wallet dari WalletProvider, konvert ke WalletOption ──
    final walletOptions = context
        .watch<WalletProvider>()
        .wallets
        .map(_toWalletOption)
        .toList();

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
                  left: 16 * sx,
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

                // ── Sliding Glass Pill (3 tabs, text-only) ──
                Positioned(
                  left: 70 * sx,
                  right: 16 * sx,
                  top: 23 * sy,
                  child: _buildSlidingPill(sx, sy),
                ),

                // ── Mic button (glass, right side) ──
                Positioned(
                  right: 16 * sx,
                  top: 90 * sy,
                  child: _GlassCircleButton(
                    size: 44,
                    sx: sx,
                    sy: sy,
                    child: Icon(Icons.mic_rounded,
                        color: Colors.white, size: 22 * sx),
                  ),
                ),

                // ── Amount text ──
                Positioned(
                  left: 24 * sx,
                  top: 80 * sy,
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

                // ── Camera button (glass, right side) ──
                Positioned(
                  right: 16 * sx,
                  top: 142 * sy,
                  child: _GlassCircleButton(
                    size: 44,
                    sx: sx,
                    sy: sy,
                    child: Icon(Icons.camera_alt_rounded,
                        color: Colors.white, size: 22 * sx),
                  ),
                ),

                // ── Content area (white card) ──
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
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: 134 * sy),

                        // ── Input row (Add Title + Select Wallet) ──
                        Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 30 * sx),
                          child: SizedBox(
                            height: 40 * sy,
                            child: _buildInputRow(sx, sy, walletOptions),
                          ),
                        ),
                        SizedBox(height: 24 * sy),

                        // ── NumPad ──
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

                // ── Category / To-Wallet area ──
                Positioned(
                  left: 20 * sx,
                  right: 20 * sx,
                  top: (194 + 24) * sy,
                  child: _buildCategoryArea(sx, sy, walletOptions),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  //  Sliding Glass Pill — 3 tabs
  // ══════════════════════════════════════════════════════════

  Widget _buildSlidingPill(double sx, double sy) {
    return Container(
      height: 40 * sy,
      decoration: BoxDecoration(
        // Sangat transparan — ungu di belakang tetap terlihat
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.45),
          width: 1.2,
        ),
      ),
      child: Stack(
        children: [
          // ── Animated white pill indicator ──
          LayoutBuilder(
            builder: (context, c) {
              final pillW = c.maxWidth / _tabLabels.length;
              final alignment = Alignment(
                -1.0 + (2.0 * _typeIndex / (_tabLabels.length - 1)),
                0,
              );
              return AnimatedAlign(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeInOutCubic,
                alignment: alignment,
                child: Container(
                  width: pillW,
                  margin: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.10),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // ── Tab labels ──
          Row(
            children: List.generate(_tabLabels.length, (index) {
              final isActive = _typeIndex == index;

              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    setState(() {
                      _typeIndex = index;
                      _selectedCategory = null;
                      _selectedToWallet = null;
                      _titleController.clear();
                      _filterTransferKey = UniqueKey();
                    });
                  },
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 220),
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 13 * sx,
                        fontWeight:
                            isActive ? FontWeight.w800 : FontWeight.w500,
                        color: isActive
                            ? AppColors.primaryPurple
                            : Colors.white.withValues(alpha: 0.85),
                      ),
                      child: Text(_tabLabels[index]),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }


  // ══════════════════════════════════════════════════════════
  //  Category / To-Wallet area (switches by mode)
  // ══════════════════════════════════════════════════════════

  Widget _buildCategoryArea(double sx, double sy, List<WalletOption> walletOptions) {
    if (_type == TransactionType.transfer) {
      // Transfer mode — tampilkan bubble wallet (To Wallet)
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          FilterTransfer(
            key: _filterTransferKey,
            wallets: walletOptions,
            excludeWallet: _selectedWallet,
            sx: sx,
            sy: sy,
            onWalletSelected: (name) {
              setState(() => _selectedToWallet = name);
            },
          ),
        ],
      );
    } else if (_type == TransactionType.expense) {
      return FilterExpanse(
        sx: sx,
        sy: sy,
        onCategorySelected: (cat) {
          setState(() => _selectedCategory = cat);
        },
      );
    } else {
      return FilterIncome(
        sx: sx,
        sy: sy,
        onCategorySelected: (cat) {
          setState(() => _selectedCategory = cat);
        },
      );
    }
  }

  // ══════════════════════════════════════════════════════════
  //  Input row — Add Title + Select Wallet (From)
  // ══════════════════════════════════════════════════════════

  Widget _buildInputRow(double sx, double sy, List<WalletOption> walletOptions) {
    // Title field: disabled saat Transfer atau saat category != 'More'
    final bool titleEnabled =
        _type != TransactionType.transfer && _selectedCategory == 'More';

    return Row(
      children: [
        // ── Add Title / Note ──
        Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: double.infinity,
            padding:
                EdgeInsets.only(top: 9 * sy, left: 12 * sx, bottom: 9 * sy),
            decoration: BoxDecoration(
              color: titleEnabled
                  ? AppColors.dashboardPurple.withValues(alpha: 0.3)
                  : AppColors.white2,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: titleEnabled
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
                Icon(
                  Icons.description_outlined,
                  size: 16 * sx,
                  color: titleEnabled
                      ? AppColors.primaryPurple
                      : AppColors.disabled,
                ),
                SizedBox(width: 8 * sx),
                Expanded(
                  child: TextField(
                    controller: _titleController,
                    enabled: titleEnabled,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 13.5 * sy,
                      color: titleEnabled
                          ? AppColors.textPrimary
                          : AppColors.disabled,
                    ),
                    decoration: InputDecoration(
                      hintText: _type == TransactionType.transfer
                          ? 'Disabled'
                          : 'Add Title',
                      hintStyle: TextStyle(
                        color: titleEnabled
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

        // ── Select Wallet (From) — shake animation on error ──
        AnimatedBuilder(
          animation: _walletShakeController,
          builder: (context, child) {
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
                wallets: walletOptions,
                selectedWallet: _selectedWallet,
              );
              if (selected != null && mounted) {
                setState(() {
                  _selectedWallet = selected;
                  _walletError = false;
                  // Reset To Wallet jika sama dengan From yang baru dipilih
                  if (_selectedToWallet == selected) {
                    _selectedToWallet = null;
                    _filterTransferKey = UniqueKey();
                  }
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

// ══════════════════════════════════════════════════════════
//  Glass Circle Button
// ══════════════════════════════════════════════════════════

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
