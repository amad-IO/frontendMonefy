import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/wallet_model.dart';
import '../../providers/wallet_provider.dart';
import 'create_wallet_page.dart';
import 'wallet_category_page.dart';

// ══════════════════════════════════════════════════════════════
/// YourWalletPage — halaman daftar wallet per kategori.
///
/// Menampilkan total balance, kategori Cash/Bank/E-Wallet
/// dan navigasi ke WalletCategoryPage.
// ══════════════════════════════════════════════════════════════
class YourWalletPage extends StatelessWidget {
  const YourWalletPage({super.key});

  void _goToCreateWallet(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CreateWalletPage()),
    );
  }

  void _goToCategory(BuildContext context, WalletCategory category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WalletCategoryPage(category: category),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Consumer<WalletProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF8B5CF6), // violet muda
                  Color(0xFF6D28D9), // violet tengah
                  Color(0xFF4C1D95), // indigo gelap
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, provider),
                  Expanded(child: _buildBody(context, provider)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════
  // HEADER
  // ══════════════════════════════════════════════════════════
  Widget _buildHeader(BuildContext context, WalletProvider provider) {
    // Format: Rp3000.000 style (divide by 1000, append .000)
    final totalInK = (provider.totalBalance / 1000).toStringAsFixed(0);
    final balanceText = provider.isHidden
        ? '••••••••'
        : 'Rp$totalInK.000';

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Back arrow + judul ───────────────────
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.maybePop(context),
                child: SvgPicture.asset(
                  'assets/icon/back.svg',
                  width: 32,
                  height: 32,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Your Wallet',
                  textAlign: TextAlign.center,
                  style: AppTextStyle.heading.copyWith(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.2,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        offset: Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 32),
            ],
          ),

          const SizedBox(height: 36),

          // ── Label "Your total balance is" + mata ─
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'Your total balance is',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  color: Colors.white.withValues(alpha: 0.95),
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: provider.toggleHide,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: Icon(
                    provider.isHidden
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_off_rounded,
                    key: ValueKey(provider.isHidden),
                    color: Colors.white.withValues(alpha: 0.85),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Total nominal ─────────────────────────
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            child: Text(
              balanceText,
              key: ValueKey(provider.isHidden),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 44,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // BODY
  // ══════════════════════════════════════════════════════════
  Widget _buildBody(BuildContext context, WalletProvider provider) {
    final mediaBottom = MediaQuery.of(context).padding.bottom;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: Stack(
          children: [
            // ── Kontur SVG ─────────────────────────────
            Positioned.fill(
              child: Opacity(
                opacity: 0.55,
                child: SvgPicture.asset(
                  'assets/images/kontur.svg',
                  fit: BoxFit.cover,
                  colorFilter: const ColorFilter.mode(
                    AppColors.decorativePurple,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),

            // ── Konten ─────────────────────────────────
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                top: 20,
                bottom: 32 + mediaBottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Tombol Add wallet (pojok kanan) ───
                  Padding(
                    padding: const EdgeInsets.only(right: 20, bottom: 12),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: _AddWalletButton(
                        onTap: () => _goToCreateWallet(context),
                      ),
                    ),
                  ),

                  // ── Label "Wallet List" ───────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                    child: Text(
                      'Wallet List',
                      style: AppTextStyle.title.copyWith(
                        color: AppColors.primaryPurple,
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                      ),
                    ),
                  ),

                  // ── Kategori items ────────────────────
                  _CategoryTile(
                    icon: Icons.attach_money_rounded,
                    label: 'Cash',
                    count: provider.byCategory(WalletCategory.cash).length,
                    onTap: () => _goToCategory(context, WalletCategory.cash),
                  ),
                  _CategoryTile(
                    icon: Icons.account_balance_rounded,
                    label: 'Bank Accounts',
                    count: provider.byCategory(WalletCategory.bankAccount).length,
                    onTap: () => _goToCategory(context, WalletCategory.bankAccount),
                  ),
                  _CategoryTile(
                    icon: Icons.wallet_rounded,
                    label: 'E-Wallets',
                    count: provider.byCategory(WalletCategory.eWallet).length,
                    onTap: () => _goToCategory(context, WalletCategory.eWallet),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Tile satu kategori — ikon ungu + label + chevron
// ══════════════════════════════════════════════════════════════
class _CategoryTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final int count;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.icon,
    required this.label,
    required this.count,
    required this.onTap,
  });

  @override
  State<_CategoryTile> createState() => _CategoryTileState();
}

class _CategoryTileState extends State<_CategoryTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryPurple.withValues(alpha: 0.07),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Ikon dalam kotak ungu muda
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.dashboardPurple,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    widget.icon,
                    color: AppColors.primaryPurple,
                    size: 22,
                  ),
                ),

                const SizedBox(width: 16),

                // Label
                Expanded(
                  child: Text(
                    widget.label,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),

                // Chevron
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.primaryPurple,
                  size: 26,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Tombol Add wallet — pill ungu muda dengan ikon card + teks
// ══════════════════════════════════════════════════════════════
class _AddWalletButton extends StatefulWidget {
  final VoidCallback onTap;
  const _AddWalletButton({required this.onTap});

  @override
  State<_AddWalletButton> createState() => _AddWalletButtonState();
}

class _AddWalletButtonState extends State<_AddWalletButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.dashboardPurple,
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryPurple.withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.add_card_rounded, color: AppColors.primaryPurple, size: 18),
              SizedBox(width: 8),
              Text(
                'Add wallet',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  color: AppColors.primaryPurple,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}