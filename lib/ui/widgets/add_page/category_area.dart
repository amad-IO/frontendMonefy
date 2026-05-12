import 'package:flutter/material.dart';
import '../../components/filter_expense.dart';
import '../../components/filter_income.dart';
import '../../components/filter_transfer.dart';
import '../../components/wallet_selector_popup.dart';

class CategoryArea extends StatelessWidget {
  final int typeIndex;
  final List<WalletOption> walletOptions;
  final String? selectedWallet;
  final Key filterTransferKey;
  final Function(String) onCategorySelected;
  /// Callback untuk pilih to-wallet saat Transfer mode.
  /// Membawa WalletOption penuh agar parent bisa ambil id & name.
  final Function(WalletOption) onWalletSelected;
  final double sx;
  final double sy;

  const CategoryArea({
    super.key,
    required this.typeIndex,
    required this.walletOptions,
    required this.selectedWallet,
    required this.filterTransferKey,
    required this.onCategorySelected,
    required this.onWalletSelected,
    required this.sx,
    required this.sy,
  });

  @override
  Widget build(BuildContext context) {
    if (typeIndex == 2) {
      return FilterTransfer(
        key: filterTransferKey,
        wallets: walletOptions,
        excludeWallet: selectedWallet,
        sx: sx,
        sy: sy,
        onWalletSelected: onWalletSelected,
      );
    } else if (typeIndex == 1) {
      return FilterExpanse(
        sx: sx,
        sy: sy,
        onCategorySelected: onCategorySelected,
      );
    } else {
      return FilterIncome(
        sx: sx,
        sy: sy,
        onCategorySelected: onCategorySelected,
      );
    }
  }
}