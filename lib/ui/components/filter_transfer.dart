import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'wallet_selector_popup.dart';

/// To-Wallet bubble selector untuk mode Transfer.
///
/// Menampilkan daftar wallet sebagai icon bulat (mirip FilterIncome),
/// namun mengecualikan [excludeWallet] (wallet "From" yang sudah dipilih).
/// Jika [excludeWallet] null maka semua wallet ditampilkan.
class FilterTransfer extends StatefulWidget {
  final List<WalletOption> wallets;

  /// Nama wallet yang dikecualikan (= wallet "From" yang sudah dipilih).
  final String? excludeWallet;

  /// Callback saat user memilih wallet tujuan. Membawa WalletOption penuh.
  final Function(WalletOption wallet)? onWalletSelected;

  final double sx;
  final double sy;

  const FilterTransfer({
    super.key,
    required this.wallets,
    required this.sx,
    required this.sy,
    this.excludeWallet,
    this.onWalletSelected,
  });

  @override
  State<FilterTransfer> createState() => _FilterTransferState();
}

class _FilterTransferState extends State<FilterTransfer> {
  String? _selectedWallet;

  /// Reset pilihan ketika parent mengubah excludeWallet
  /// (misal user ganti From Wallet ke yang lain).
  @override
  void didUpdateWidget(FilterTransfer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Jika wallet yang di-exclude berubah dan wallet terpilih
    // sekarang sama dengan yang diexclude, reset pilihan.
    if (oldWidget.excludeWallet != widget.excludeWallet) {
      if (_selectedWallet == widget.excludeWallet) {
        _selectedWallet = null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sx = widget.sx;
    final sy = widget.sy;

    // Filter out the From Wallet
    final availableWallets = widget.wallets
        .where((w) => w.name != widget.excludeWallet)
        .toList();

    if (availableWallets.isEmpty) {
      return SizedBox(
        height: 88 * sy,
        child: Center(
          child: Text(
            'Tambahkan wallet lain untuk mentransfer.',
            style: AppTextStyle.caption.copyWith(
              fontSize: 11 * sx,
              color: AppColors.disabled,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return SizedBox(
      height: 88 * sy,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        clipBehavior: Clip.none,
        padding: EdgeInsets.symmetric(horizontal: 12 * sx),
        itemCount: availableWallets.length,
        separatorBuilder: (_, _) => SizedBox(width: 8 * sx),
        itemBuilder: (context, index) {
          final wallet = availableWallets[index];
          final isSelected = _selectedWallet == wallet.name;
          final baseGradient =
              wallet.gradient ??
              const [Color(0xFF9B87F5), AppColors.primaryPurple];
          final displayGradient = isSelected
              ? baseGradient
              : baseGradient
                    .map((color) => color.withValues(alpha: 0.76))
                    .toList();

          return GestureDetector(
            onTap: () {
              setState(() => _selectedWallet = wallet.name);
              widget.onWalletSelected?.call(wallet);
            },
            child: SizedBox(
              width: 64 * sx,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Bubble icon ──
                  AnimatedScale(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutBack,
                    scale: isSelected ? 1.08 : 1,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 50 * sx,
                      height: 50 * sy,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: displayGradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.panelWhite,
                          width: isSelected ? 2.5 : 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: baseGradient.last.withValues(
                              alpha: isSelected ? 0.34 : 0.14,
                            ),
                            blurRadius: isSelected ? 15 : 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: wallet.iconAsset != null
                          ? SvgPicture.asset(
                              wallet.iconAsset!,
                              width: 23 * sx,
                              height: 23 * sy,
                              fit: BoxFit.scaleDown,
                              colorFilter: ColorFilter.mode(
                                AppColors.panelWhite.withValues(
                                  alpha: isSelected ? 1 : 0.92,
                                ),
                                BlendMode.srcIn,
                              ),
                            )
                          : Icon(
                              wallet.icon,
                              size: 23 * sx,
                              color: AppColors.panelWhite.withValues(
                                alpha: isSelected ? 1 : 0.92,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 6 * sy),
                  // ── Label ──
                  Text(
                    wallet.name,
                    style: AppTextStyle.caption.copyWith(
                      fontSize: 10 * sx,
                      color: AppColors.textPrimary,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Expose reset method agar parent bisa reset pilihan
  /// (misal ketika mode berubah dari Transfer ke lainnya).
  void reset() {
    if (mounted) setState(() => _selectedWallet = null);
  }
}
