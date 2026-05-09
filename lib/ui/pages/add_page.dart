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

// 🔥 IMPORT WIDGET HASIL PECAHAN
import '../widgets/add_page/sliding_pill.dart';
import '../widgets/add_page/category_area.dart';
import '../widgets/add_page/input_row.dart';
import '../widgets/add_page/glass_circle_button.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage>
    with SingleTickerProviderStateMixin {
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
  String? _selectedWallet;
  String? _selectedToWallet;

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();

  late final AnimationController _walletShakeController;
  bool _walletError = false;

  Key _filterTransferKey = UniqueKey();

  static const List<String> _tabLabels = ['Income', 'Expense', 'Transfer'];

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
  }

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

    if (_type == TransactionType.transfer && _selectedToWallet == null) {
      _showSnackBar(
        'Pilih wallet tujuan transfer!',
        AppColors.error,
        Icons.warning_amber_rounded,
      );
      return;
    }

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

    final transaction = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      category: category,
      title: title,
      amount: amount,
      date: DateTime.now(),
      walletName: _selectedWallet!,
      toWalletName:
      _type == TransactionType.transfer ? (_selectedToWallet ?? '') : '',
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

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.of(context).padding.bottom;

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
                //TARUH DI SINI (PALING BAWAH STACK)

                Positioned(
                  right: 16 * sx,
                  top: 90 * sy,
                  child: GlassCircleButton(
                    size: 44,
                    sx: sx,
                    sy: sy,
                    child: Icon(Icons.mic_rounded,
                        color: Colors.white, size: 22 * sx),
                  ),
                ),

                Positioned(
                  right: 16 * sx,
                  top: 142 * sy,
                  child: GlassCircleButton(
                    size: 44,
                    sx: sx,
                    sy: sy,
                    child: Icon(Icons.camera_alt_rounded,
                        color: Colors.white, size: 22 * sx),
                  ),
                ),
                // BACK BUTTON
                Positioned(
                  left: 16 * sx,
                  top: 23 * sy,
                  child: GlassCircleButton(
                    size: 42,
                    sx: sx,
                    sy: sy,
                    onTap: () => Navigator.of(context).pop(),
                    child: SvgPicture.asset(
                      'assets/icon/back.svg',
                      width: 22 * sx,
                      height: 22 * sy,
                      colorFilter:
                      const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    ),
                  ),
                ),

                // SLIDING TAB
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

                // AMOUNT
                Positioned(
                  left: 40 * sx,
                  right: 90 * sx, // kasih batas kanan biar gak nabrak mic
                  top: 110 * sy,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _formattedAmount,
                      style: TextStyle(
                        color: AppColors.backgroundWhite,
                        fontSize: 43 * sy,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),


                Positioned(
                  left: 0,
                  right: 0,
                  top: 220 * sy,
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
                        SizedBox(height: 24 * sy),

                        CategoryArea(
                          typeIndex: _typeIndex,
                          walletOptions: walletOptions,
                          selectedWallet: _selectedWallet,
                          filterTransferKey: _filterTransferKey,
                          onCategorySelected: (val) =>
                              setState(() => _selectedCategory = val),
                          onWalletSelected: (val) =>
                              setState(() => _selectedToWallet = val),
                          sx: sx,
                          sy: sy,
                        ),

                        SizedBox(height: 24 * sy),

                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30 * sx),
                          child: SizedBox(
                            height: 40 * sy,
                            child: InputRow(
                              titleController: _titleController,
                              selectedWallet: _selectedWallet,
                              wallets: walletOptions,
                              titleEnabled: true,
                              walletError: _walletError,
                              walletShakeController: _walletShakeController,
                              onWalletSelected: (val) {
                                setState(() {
                                  _selectedWallet = val;
                                  _walletError = false;
                                });
                              },
                              sx: sx,
                              sy: sy,
                            ),
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
                            child: NumPad(
                              onKeyTap: _onNumPadKeyTap,
                              onBackspace: _onNumPadBackspace,
                              onConfirm: _onConfirm,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}