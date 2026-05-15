import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/transaction_model.dart';
import '../../data/models/wallet_model.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/add_page_helper.dart';

import '../components/wallet_selector_popup.dart';
import '../components/numpad.dart';
import '../widgets/add_page/sliding_pill.dart';
import '../widgets/add_page/category_area.dart';
import '../widgets/add_page/input_row.dart';
import '../widgets/add_page/amount_display.dart';
import '../widgets/add_page/top_action_buttons.dart';
import 'scan_page.dart';

class AddPage extends StatefulWidget {
  /// Jika diisi, AddPage berjalan dalam mode Edit.
  /// Semua field akan di-preload dari transaksi ini.
  /// Jika null, AddPage berjalan dalam mode Add (tambah baru).
  final TransactionModel? editTransaction;

  const AddPage({super.key, this.editTransaction});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> with SingleTickerProviderStateMixin {
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
  String? _selectedWallet;     // nama wallet (untuk ditampilkan)
  String? _selectedWalletId;  // ID wallet (untuk dikirim ke backend)
  String? _selectedToWallet;  // nama to-wallet
  String? _selectedToWalletId; // ID to-wallet

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _titleController  = TextEditingController();

  late final AnimationController _walletShakeController;
  bool _walletError = false;

  Key _filterTransferKey = UniqueKey();

  // ── Konversi WalletModel → WalletOption ──
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
    return WalletOption(name: w.name, icon: icon, balance: w.balance, id: w.id);
  }

  // ────────────────────────────────────────────
  // LIFECYCLE
  // ────────────────────────────────────────────

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
      _typeIndex = t.type == TransactionType.income
          ? 0
          : t.type == TransactionType.expense
              ? 1
              : 2;
      _selectedCategory  = t.category;
      _selectedWallet    = t.walletName.isEmpty ? null : t.walletName;
      _selectedWalletId  = t.walletId.isEmpty ? null : t.walletId;
      _selectedToWallet  = t.toWalletName.isEmpty ? null : t.toWalletName;
      _selectedToWalletId = t.toWalletId.isEmpty ? null : t.toWalletId;
      _amountController.text = t.amount == t.amount.truncateToDouble()
          ? t.amount.toInt().toString()
          : t.amount.toString();
      _titleController.text = t.title;
    }
  }

  @override
  void dispose() {
    _walletShakeController.dispose();
    _amountController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  // ────────────────────────────────────────────
  // NUMPAD HANDLERS
  // ────────────────────────────────────────────

  void _onNumPadKeyTap(String key) {
    final current = _amountController.text;
    if (key == '.') {
      if (current.contains('.')) return;
      setState(() => _amountController.text = current.isEmpty ? '0.' : '$current.');
      return;
    }
    if (key == '000') {
      setState(() => _amountController.text = current.isEmpty ? '0' : '$current$key');
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

  // ────────────────────────────────────────────
  // CONFIRM — Validasi + Simpan
  // ────────────────────────────────────────────

  Future<void> _onConfirm() async {
    final amount = double.tryParse(_amountController.text.trim()) ?? 0;

    // 1. Validasi input
    final validationError = AddPageHelper.validate(
      amount: amount,
      selectedWallet: _selectedWallet,
      type: _type,
      selectedToWallet: _selectedToWallet,
    );

    if (validationError != null) {
      // Shake animation khusus untuk wallet
      if (_selectedWallet == null && amount > 0) {
        setState(() => _walletError = true);
        _walletShakeController.forward(from: 0);
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) setState(() => _walletError = false);
        });
      }
      _showSnackBar(validationError, AppColors.error, Icons.warning_amber_rounded);
      return;
    }

    // 2. Siapkan data
    final category = AddPageHelper.resolveCategory(
      type: _type,
      selectedCategory: _selectedCategory,
    );
    final title = AddPageHelper.resolveTitle(
      category: category,
      rawTitle: _titleController.text,
      type: _type,
    );

    // 3A. Mode Edit
    if (_isEditMode) {
      final updated = widget.editTransaction!.copyWith(
        category:     category,
        title:        title,
        amount:       amount,
        walletName:   _selectedWallet!,
        toWalletName: _type == TransactionType.transfer ? (_selectedToWallet ?? '') : '',
        type:         _type,
      );
      context.read<TransactionProvider>().updateTransaction(updated);
      Navigator.of(context).pop();
      _showSnackBar('Transaksi berhasil diperbarui!', AppColors.success, Icons.check_circle_rounded);
      return;
    }

    // 3B. Mode Add — tambah via API
    // Simpan referensi context-dependent sebelum await (avoid async gap warning)
    final provider   = context.read<TransactionProvider>();
    final navigator  = Navigator.of(context);
    final messenger  = ScaffoldMessenger.of(context);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      if (!mounted) return;
      _showSnackBarOnMessenger(messenger, 'Token tidak ditemukan. Silakan login ulang.', AppColors.error, Icons.warning_amber_rounded);
      return;
    }
    final walletId = _selectedWalletId ?? '';
    if (walletId.isEmpty) {
      if (!mounted) return;
      _showSnackBarOnMessenger(messenger, 'Wallet tidak valid. Silakan pilih wallet.', AppColors.error, Icons.warning_amber_rounded);
      return;
    }

    final transaction = TransactionModel(
      id:           DateTime.now().millisecondsSinceEpoch.toString(),
      category:     category,
      title:        title,
      amount:       amount,
      date:         DateTime.now(),
      walletName:   _selectedWallet!,
      toWalletName: _type == TransactionType.transfer ? (_selectedToWallet ?? '') : '',
      type:         _type,
    );

    await provider.addTransactionWithApi(
      transaction,
      token,
      walletId: walletId,
      toWalletId: _selectedToWalletId,
    );

    if (!mounted) return;
    navigator.pop();
    _showSnackBarOnMessenger(
      messenger,
      _type == TransactionType.transfer ? 'Transfer berhasil dicatat!' : 'Transaction added successfully!',
      AppColors.success,
      Icons.check_circle_rounded,
    );
  }

  // ────────────────────────────────────────────
  // HELPERS
  // ────────────────────────────────────────────

  void _showSnackBar(String message, Color color, IconData icon) {
    _showSnackBarOnMessenger(ScaffoldMessenger.of(context), message, color, icon);
  }

  void _showSnackBarOnMessenger(
    ScaffoldMessengerState messenger,
    String message,
    Color color,
    IconData icon,
  ) {
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w600),
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

  Future<void> _openScanPage() async {
    final result = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ScanPage(),
    );
    if (result != null && mounted) {
      setState(() => _amountController.text = result.toInt().toString());
    }
  }

  // ────────────────────────────────────────────
  // BUILD
  // ────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.of(context).padding.bottom;
    final walletOptions = context.watch<WalletProvider>().wallets.map(_toWalletOption).toList();

    return FractionallySizedBox(
      heightFactor: 0.86,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double sx = constraints.maxWidth / 390;
          final double sy = constraints.maxHeight / 673;

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
                // ── Tombol Back, Mic, Camera ──
                TopActionButtons(
                  sx: sx,
                  sy: sy,
                  onBack: () => Navigator.of(context).pop(),
                  onCamera: _openScanPage,
                ),

                // ── Tab Slider (Income / Expense / Transfer) ──
                Positioned(
                  left: 70 * sx,
                  right: 16 * sx,
                  top: 23 * sy,
                  child: SlidingPill(
                    typeIndex: _typeIndex,
                    sx: sx,
                    sy: sy,
                    onTap: (index) {
                      setState(() {
                        _typeIndex = index;
                        _selectedCategory = null;
                        _selectedToWallet = null;
                        _titleController.clear();
                        _filterTransferKey = UniqueKey();
                      });
                    },
                  ),
                ),

                // ── Tampilan jumlah uang ──
                Positioned(
                  left: 40 * sx,
                  right: 90 * sx,
                  top: 110 * sy,
                  child: AmountDisplay(
                    rawAmount: _amountController.text,
                    sx: sx,
                    sy: sy,
                  ),
                ),

                // ── Panel putih bawah (kategori, wallet, numpad) ──
                Positioned(
                  left: 0,
                  right: 0,
                  top: 220 * sy,
                  bottom: 0,
                  child: _buildBottomPanel(
                    sx: sx,
                    sy: sy,
                    safeBottom: safeBottom,
                    walletOptions: walletOptions,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomPanel({
    required double sx,
    required double sy,
    required double safeBottom,
    required List<WalletOption> walletOptions,
  }) {
    return Container(
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
          SizedBox(height: 24 * sy),

          // Area pilih kategori / transfer
          CategoryArea(
            typeIndex: _typeIndex,
            walletOptions: walletOptions,
            selectedWallet: _selectedWallet,
            filterTransferKey: _filterTransferKey,
            onCategorySelected: (val) => setState(() => _selectedCategory = val),
            onWalletSelected: (walletOption) => setState(() {
              _selectedToWallet   = walletOption.name;
              _selectedToWalletId = walletOption.id;
            }),
            sx: sx,
            sy: sy,
          ),

          SizedBox(height: 24 * sy),

          // Input title & pilih wallet
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30 * sx),
            child: SizedBox(
              height: 40 * sy,
              child: InputRow(
                titleController:       _titleController,
                selectedWallet:        _selectedWallet,
                wallets:               walletOptions,
                titleEnabled:          true,
                walletError:           _walletError,
                walletShakeController: _walletShakeController,
                onWalletSelected: (walletOption) {
                  setState(() {
                    _selectedWallet   = walletOption.name;
                    _selectedWalletId = walletOption.id;
                    _walletError      = false;
                  });
                },
                sx: sx,
                sy: sy,
              ),
            ),
          ),

          SizedBox(height: 24 * sy),

          // NumPad
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: 30 * sx,
                right: 30 * sx,
                bottom: safeBottom + (12 * sy),
              ),
              child: NumPad(
                onKeyTap:  _onNumPadKeyTap,
                onBackspace: _onNumPadBackspace,
                onConfirm: _onConfirm,
              ),
            ),
          ),
        ],
      ),
    );
  }
}