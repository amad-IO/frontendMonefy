import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../components/wallet_selector_popup.dart'; // ✅ cukup ini

class InputRow extends StatelessWidget {
  final TextEditingController titleController;
  final String? selectedWallet;
  final List<WalletOption> wallets;
  final bool titleEnabled;
  final bool walletError;
  final AnimationController walletShakeController;
  final Function(WalletOption) onWalletSelected;
  final String? excludeWallet; // ← untuk exclude To Wallet dari From selector
  final double sx;
  final double sy;

  const InputRow({
    super.key,
    required this.titleController,
    required this.selectedWallet,
    required this.wallets,
    required this.titleEnabled,
    required this.walletError,
    required this.walletShakeController,
    required this.onWalletSelected,
    this.excludeWallet,
    required this.sx,
    required this.sy,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // ── TITLE INPUT ──
        Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: double.infinity,
            padding: EdgeInsets.only(
              top: 9 * sy,
              left: 12 * sx,
              bottom: 9 * sy,
            ),
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
                    controller: titleController,
                    enabled: titleEnabled,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 13.5 * sy,
                      color: titleEnabled
                          ? AppColors.textPrimary
                          : AppColors.disabled,
                    ),
                    decoration: InputDecoration(
                      hintText: titleEnabled ? 'Add Title' : 'Disabled',
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

        // ── SELECT WALLET (SHAKE) ──
        AnimatedBuilder(
          animation: walletShakeController,
          builder: (context, child) {
            final double shake = walletShakeController.value == 0
                ? 0
                : math.sin(walletShakeController.value * math.pi * 6) *
                4 *
                (1 - walletShakeController.value);

            return Transform.translate(
              offset: Offset(shake.toDouble(), 0), // ✅ FIX num → double
              child: child,
            );
          },
          child: GestureDetector(
            onTap: () async {
              final selectedName = await WalletSelectorPopup.show(
                context: context,
                wallets: wallets,
                selectedWallet: selectedWallet,
                excludeWallet: excludeWallet, // ← sembunyikan To Wallet
              );

              if (selectedName != null) {
                // Cari WalletOption berdasarkan nama yang dipilih
                final found = wallets.firstWhere(
                  (w) => w.name == selectedName,
                  orElse: () => WalletOption(
                    id: '',
                    name: selectedName,
                    icon: Icons.account_balance_wallet,
                  ),
                );
                onWalletSelected(found);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 100 * sx,
              height: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 4 * sx),
              decoration: BoxDecoration(
                color: walletError
                    ? AppColors.error.withValues(alpha: 0.08)
                    : AppColors.white2,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: walletError
                      ? AppColors.error
                      : selectedWallet != null
                      ? AppColors.primaryPurple.withValues(alpha: 0.3)
                      : Colors.transparent,
                  width: walletError ? 1.5 : (selectedWallet != null ? 1 : 0),
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
                    selectedWallet ?? 'Select Wallet',
                    maxLines: 1,
                    style: TextStyle(
                      color: walletError
                          ? AppColors.error
                          : selectedWallet != null
                          ? AppColors.primaryPurple
                          : AppColors.disabled,
                      fontSize: 13.5 * sy,
                      fontFamily: 'Nunito',
                      fontWeight: walletError || selectedWallet != null
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