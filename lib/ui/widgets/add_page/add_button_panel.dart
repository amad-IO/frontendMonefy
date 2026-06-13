import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../components/numpad.dart';
import '../../components/wallet_selector_popup.dart';
import 'category_area.dart';
import 'input_row.dart';

class AddBottomPanel extends StatelessWidget {
  final int typeIndex;
  final List<WalletOption> walletOptions;
  final String? selectedWallet;
  final Key filterTransferKey;
  final String? selectedToWallet;
  final String? excludeWallet;
  final bool walletError;
  final AnimationController walletShakeController;
  final TextEditingController titleController;
  final bool titleEnabled;
  final double sx;
  final double sy;
  final double safeBottom;

  // Callbacks
  final Function(String) onCategorySelected;
  final Function(WalletOption) onWalletSelected; // untuk To-Wallet
  final Function(WalletOption) onFromWalletSelected; // untuk From-Wallet
  final Function(String) onNumPadKeyTap;
  final VoidCallback onNumPadBackspace;
  final VoidCallback onConfirm;

  const AddBottomPanel({
    super.key,
    required this.typeIndex,
    required this.walletOptions,
    required this.selectedWallet,
    required this.filterTransferKey,
    required this.selectedToWallet,
    required this.excludeWallet,
    required this.walletError,
    required this.walletShakeController,
    required this.titleController,
    required this.titleEnabled,
    required this.sx,
    required this.sy,
    required this.safeBottom,
    required this.onCategorySelected,
    required this.onWalletSelected,
    required this.onFromWalletSelected,
    required this.onNumPadKeyTap,
    required this.onNumPadBackspace,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
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

          CategoryArea(
            typeIndex: typeIndex,
            walletOptions: walletOptions,
            selectedWallet: selectedWallet,
            filterTransferKey: filterTransferKey,
            onCategorySelected: onCategorySelected,
            onWalletSelected: onWalletSelected,
            sx: sx,
            sy: sy,
          ),

          SizedBox(height: 24 * sy),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30 * sx),
            child: SizedBox(
              height: 40 * sy,
              child: InputRow(
                titleController: titleController,
                selectedWallet: selectedWallet,
                wallets: walletOptions,
                titleEnabled: titleEnabled,
                walletError: walletError,
                walletShakeController: walletShakeController,
                excludeWallet: excludeWallet,
                onWalletSelected: onFromWalletSelected,
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
                onKeyTap: onNumPadKeyTap,
                onBackspace: onNumPadBackspace,
                onConfirm: onConfirm,
              ),
            ),
          ),
        ],
      ),
    );
  }
}