import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/wallet_model.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/add_page_controller.dart'; // ✅ Import Controller Baru

import '../components/wallet_selector_popup.dart';
import '../widgets/add_page/add_button_panel.dart';
import '../widgets/add_page/amount_display.dart';
import '../widgets/add_page/sliding_pill.dart';
import '../widgets/add_page/top_action_buttons.dart';


class AddPage extends StatefulWidget {
  final TransactionModel? editTransaction;
  final Map<String, dynamic>? billData;

  const AddPage({
    super.key,
    this.editTransaction,
    this.billData,
  });

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> with SingleTickerProviderStateMixin {
  late final AddPageController _controller;

  @override
  void initState() {
    super.initState();
    // ✅ Inisialisasi controller di initState
    _controller = AddPageController(
      editTransaction: widget.editTransaction,
      billData: widget.billData,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // ✅ Dispose controller
    super.dispose();
  }

  // Helper konversi WalletModel ke opsi dropdown UI
  static WalletOption _toWalletOption(dynamic w) {
    // ... Logika konversi yang sama seperti sebelumnya
    return WalletOption(
      name: w.name,
      icon: w.category == WalletCategory.cash
          ? Icons.payments_rounded
          : w.category == WalletCategory.bankAccount
          ? Icons.account_balance_rounded
          : Icons.account_balance_wallet_rounded,
      balance: w.balance,
      id: w.id,
      gradient: w.theme.cardGradient,
    );
  }

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.of(context).padding.bottom;
    final walletOptions = context.watch<WalletProvider>().wallets.map(_toWalletOption).toList();

    // ✅ Bungkus halaman dengan ChangeNotifierProvider.value agar UI mendengarkan perubahan di Controller
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<AddPageController>(
        builder: (context, controller, child) {
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
                      // 1. Top Action Buttons (Back & Camera Scan)
                      TopActionButtons(
                        sx: sx,
                        sy: sy,
                        onBack: () => Navigator.of(context).pop(),
                        onCamera: () => controller.openScanPage(context),
                      ),

                      // 2. Sliding Tab
                      Positioned(
                        left: 70 * sx,
                        right: 16 * sx,
                        top: 23 * sy,
                        child: SlidingPill(
                          typeIndex: controller.typeIndex,
                          sx: sx,
                          sy: sy,
                          onTap: (index) => controller.setTypeIndex(index),
                        ),
                      ),

                      // 3. Amount Display
                      Positioned(
                        left: 40 * sx,
                        right: 90 * sx,
                        top: 110 * sy,
                        child: AmountDisplay(
                          rawAmount: controller.amountController.text,
                          sx: sx,
                          sy: sy,
                        ),
                      ),

                      // 4. Bottom Panel Container (Numpad, Input, Category)
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 220 * sy,
                        bottom: 0,
                        child: AddBottomPanel(
                          typeIndex: controller.typeIndex,
                          walletOptions: walletOptions,
                          selectedWallet: controller.selectedWallet,
                          filterTransferKey: controller.filterTransferKey,
                          selectedToWallet: controller.selectedToWallet,
                          excludeWallet: controller.type == TransactionType.transfer ? controller.selectedToWallet : null,
                          walletError: controller.walletError,
                          walletShakeController: controller.walletShakeController,
                          titleController: controller.titleController,
                          titleEnabled: controller.type != TransactionType.transfer && controller.selectedCategory == 'More',
                          sx: sx,
                          sy: sy,
                          safeBottom: safeBottom,
                          onCategorySelected: (val) => controller.setCategory(val),
                          onWalletSelected: (walletOption) => controller.setToWallet(walletOption),
                          onFromWalletSelected: (walletOption) => controller.setFromWallet(walletOption),
                          onNumPadKeyTap: (key) => controller.onNumPadKeyTap(key),
                          onNumPadBackspace: () => controller.onNumPadBackspace(),
                          onConfirm: () => controller.onConfirm(context),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}