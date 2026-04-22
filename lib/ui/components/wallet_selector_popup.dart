import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/colors.dart';

/// Data model for a wallet option in the selector.
class WalletOption {
  final String name;
  final IconData icon;
  final double balance;

  const WalletOption({
    required this.name,
    required this.icon,
    this.balance = 0,
  });
}

/// A premium bottom-sheet popup for selecting a wallet.
///
/// Usage:
/// ```dart
/// final selected = await WalletSelectorPopup.show(
///   context: context,
///   wallets: wallets,
///   selectedWallet: currentWallet,
/// );
/// ```
class WalletSelectorPopup extends StatefulWidget {
  final List<WalletOption> wallets;
  final String? selectedWallet;

  const WalletSelectorPopup({
    super.key,
    required this.wallets,
    this.selectedWallet,
  });

  /// Show the wallet selector as a modal bottom sheet.
  /// Returns the selected wallet name, or `null` if dismissed.
  static Future<String?> show({
    required BuildContext context,
    required List<WalletOption> wallets,
    String? selectedWallet,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => WalletSelectorPopup(
        wallets: wallets,
        selectedWallet: selectedWallet,
      ),
    );
  }

  @override
  State<WalletSelectorPopup> createState() => _WalletSelectorPopupState();
}

class _WalletSelectorPopupState extends State<WalletSelectorPopup>
    with SingleTickerProviderStateMixin {
  late String? _currentSelection;
  late final AnimationController _animController;

  static final _balanceFormatter = NumberFormat('#,##0', 'id_ID');

  @override
  void initState() {
    super.initState();
    _currentSelection = widget.selectedWallet;
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        final curve = Curves.easeOutCubic.transform(_animController.value);
        return Transform.translate(
          offset: Offset(0, (1 - curve) * 60),
          child: Opacity(
            opacity: curve.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(
          left: 48,
          right: 48,
          bottom: bottomPadding + 20,
        ),
        padding: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Drag handle ──
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.disabled.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),

            // ── Title ──
            const Text(
              'Select Wallet',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),

            // ── Wallet list (max 3 visible, scrollable) ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ConstrainedBox(
                // Each tile ≈ 72px + 10px gap → 3 items = ~246px
                constraints: const BoxConstraints(maxHeight: 246),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: widget.wallets.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final wallet = widget.wallets[index];
                    final isSelected = _currentSelection == wallet.name;

                    return _WalletTile(
                      wallet: wallet,
                      isSelected: isSelected,
                      balanceFormatter: _balanceFormatter,
                      onTap: () {
                        setState(() => _currentSelection = wallet.name);
                        final nav = Navigator.of(context);
                        Future.delayed(const Duration(milliseconds: 200), () {
                          if (mounted) {
                            nav.pop(wallet.name);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ── Individual wallet tile ──

class _WalletTile extends StatelessWidget {
  final WalletOption wallet;
  final bool isSelected;
  final NumberFormat balanceFormatter;
  final VoidCallback onTap;

  const _WalletTile({
    required this.wallet,
    required this.isSelected,
    required this.balanceFormatter,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.dashboardPurple.withValues(alpha: 0.25)
              : AppColors.panelWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isSelected ? AppColors.primaryPurple : Colors.transparent,
            width: isSelected ? 1.5 : 0,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primaryPurple.withValues(alpha: 0.08)
                  : AppColors.lightShadow,
              blurRadius: isSelected ? 12 : 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── Wallet icon ──
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryPurple.withValues(alpha: 0.12)
                    : AppColors.white2,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  wallet.icon,
                  color: isSelected
                      ? AppColors.primaryPurple
                      : AppColors.textSecondary,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // ── Name + balance ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    wallet.name,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 15,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: isSelected
                          ? AppColors.primaryPurple
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Rp. ${balanceFormatter.format(wallet.balance)}',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? AppColors.primaryPurple.withValues(alpha: 0.6)
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // ── Radio indicator ──
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryPurple
                      : AppColors.disabled,
                  width: isSelected ? 2 : 1.5,
                ),
                color: Colors.transparent,
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryPurple,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
