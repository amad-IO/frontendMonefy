import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';

// ══════════════════════════════════════════════════════════════
/// WalletCard — kartu wallet reusable dengan desain ATM card.
///
/// Elemen visual:
/// - Background gradient (dari [WalletTheme])
/// - Watermark teks miring + opacity rendah
/// - Chip ATM SVG (assets/icon/chip atm.svg)
/// - Label nama wallet (top-left)
/// - "Total Balance" + ikon mata (hide/show dikontrol dari luar)
/// - Nominal saldo
/// - Logo Mastercard SVG (bottom-right)
///
/// Cara pakai:
/// ```dart
/// WalletCard(
///   walletName: 'SHOPEEPAY',
///   balance: 1000000,
///   theme: WalletTheme.volcano,
///   isHidden: _isHidden,
///   onToggleHide: () => setState(() => _isHidden = !_isHidden),
/// )
/// ```
// ══════════════════════════════════════════════════════════════
class WalletCard extends StatelessWidget {
  final String walletName;
  final double balance;
  final WalletTheme theme;
  final bool isHidden;
  final VoidCallback? onToggleHide;

  const WalletCard({
    super.key,
    required this.walletName,
    required this.balance,
    required this.theme,
    this.isHidden = false,
    this.onToggleHide,
  });

  // ── Helpers ───────────────────────────────────────────────
  String get _formattedBalance {
    if (isHidden) return '••••••••';
    final formatter = NumberFormat('#,##0', 'id_ID');
    return 'Rp. ${formatter.format(balance)},00';
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.65,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: theme.cardLinearGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: theme.cardGradient.first.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // ── Watermark teks miring ──────────────────────
            _buildWatermark(),

            // ── Glassmorphism subtle overlay ──────────────
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.06),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // ── Konten utama ──────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Baris atas: nama wallet + logo mastercard ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Nama wallet
                      Text(
                        walletName.toUpperCase(),
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ── Chip ATM ──────────────────────────────
                  SvgPicture.asset(
                    'assets/icon/chip atm.svg',
                    width: 38,
                    height: 28,
                  ),

                  const Spacer(),

                  // ── Total Balance + ikon mata ──────────────
                  Row(
                    children: [
                      const Text(
                        'Total Balance',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: onToggleHide,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          child: Icon(
                            isHidden
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                            key: ValueKey(isHidden),
                            color: Colors.white70,
                            size: 15,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // ── Baris bawah: nominal + mastercard ─────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Nominal
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 280),
                        child: Text(
                          _formattedBalance,
                          key: ValueKey(isHidden),
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      // Logo Mastercard
                      SvgPicture.asset(
                        'assets/icon/mastercard.svg',
                        width: 42,
                        height: 28,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Watermark teks miring ─────────────────────────────────
  Widget _buildWatermark() {
    return Positioned(
      left: -20,
      top: 0,
      bottom: 0,
      right: -20,
      child: Center(
        child: Transform.rotate(
          angle: -0.22, // ~12.5 derajat miring ke atas
          child: Text(
            walletName.toUpperCase(),
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 68,
              fontWeight: FontWeight.w900,
              color: Colors.white.withValues(alpha: 0.10),
              letterSpacing: 4,
            ),
            maxLines: 1,
          ),
        ),
      ),
    );
  }
}
