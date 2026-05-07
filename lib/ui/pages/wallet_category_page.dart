import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/wallet_model.dart';
import '../../providers/wallet_provider.dart';
import '../widgets/wallet_card.dart';

// ══════════════════════════════════════════════════════════════
/// WalletCategoryPage — halaman detail per kategori wallet.
///
/// Ditampilkan saat user memilih Cash / Bank Accounts / E-Wallets.
/// Menampilkan:
/// - Header ungu dengan judul kategori
/// - Horizontal carousel WalletCard
/// - Body putih + kontur background
/// - Tombol Delete untuk wallet yang sedang aktif
// ══════════════════════════════════════════════════════════════
class WalletCategoryPage extends StatefulWidget {
  final WalletCategory category;

  const WalletCategoryPage({super.key, required this.category});

  @override
  State<WalletCategoryPage> createState() => _WalletCategoryPageState();
}

class _WalletCategoryPageState extends State<WalletCategoryPage> {
  int _selectedIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.82);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String get _pageTitle {
    switch (widget.category) {
      case WalletCategory.cash:
        return 'Your Cash';
      case WalletCategory.bankAccount:
        return 'Your Bank Accounts';
      case WalletCategory.eWallet:
        return 'Your E-Wallets';
    }
  }

  // ── Show delete confirmation dialog ─────────────────────
  Future<void> _confirmDelete(BuildContext context, WalletModel wallet) async {
    // Cache context-dependent objects BEFORE any await
    final provider = context.read<WalletProvider>();
    final navigator = Navigator.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Text(
          'Hapus Wallet',
          style: AppTextStyle.title.copyWith(
            color: AppColors.primaryPurple,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Text(
          'Apakah kamu yakin ingin menghapus wallet "${wallet.name}"?\nTindakan ini tidak bisa dibatalkan.',
          style: AppTextStyle.body.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Batal',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Hapus', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await provider.deleteWallet(wallet.id);

      if (!mounted) return;

      // Kalau tidak ada wallet lagi, pop
      final remaining = provider.byCategory(widget.category);
      if (remaining.isEmpty) {
        navigator.maybePop();
      } else {
        // Sesuaikan index
        setState(() {
          _selectedIndex = _selectedIndex.clamp(0, remaining.length - 1);
        });
      }
    }
  }

  // ══════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Consumer<WalletProvider>(
      builder: (context, provider, _) {
        final wallets = provider.byCategory(widget.category);

        return Scaffold(
          backgroundColor: AppColors.primaryPurple,
          body: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ─────────────────────────────────
                _buildHeader(context, wallets, provider),

                // ── Body putih ─────────────────────────────
                Expanded(child: _buildBody(context, wallets, provider)),
              ],
            ),
          ),
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════
  // HEADER — judul + carousel kartu
  // ══════════════════════════════════════════════════════════
  Widget _buildHeader(
    BuildContext context,
    List<WalletModel> wallets,
    WalletProvider provider,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Back + Judul ──────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.maybePop(context),
                  child: SvgPicture.asset(
                    'assets/icon/back.svg',
                    width: 30,
                    height: 30,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    _pageTitle,
                    textAlign: TextAlign.center,
                    style: AppTextStyle.heading.copyWith(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 30),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Carousel kartu wallet ─────────────────────
          if (wallets.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Text(
                'Belum ada wallet di kategori ini.',
                style: AppTextStyle.body.copyWith(
                  color: Colors.white.withValues(alpha: 0.75),
                ),
              ),
            )
          else
            SizedBox(
              height: _cardHeight(context),
              child: PageView.builder(
                controller: _pageController,
                itemCount: wallets.length,
                onPageChanged: (i) => setState(() => _selectedIndex = i),
                itemBuilder: (ctx, i) {
                  final wallet = wallets[i];
                  final isActive = i == _selectedIndex;
                  return AnimatedScale(
                    scale: isActive ? 1.0 : 0.93,
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOut,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: WalletCard(
                        walletName: wallet.name,
                        balance: wallet.balance,
                        theme: wallet.theme,
                        isHidden: provider.isHidden,
                        onToggleHide: provider.toggleHide,
                      ),
                    ),
                  );
                },
              ),
            ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // BODY — kontur + tombol delete + info wallet
  // ══════════════════════════════════════════════════════════
  Widget _buildBody(
    BuildContext context,
    List<WalletModel> wallets,
    WalletProvider provider,
  ) {
    final mediaBottom = MediaQuery.of(context).padding.bottom;
    final selectedWallet = wallets.isNotEmpty ? wallets[_selectedIndex.clamp(0, wallets.length - 1)] : null;

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
            // ── Kontur SVG background ──────────────────
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

            // ── Konten ────────────────────────────────
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                top: 20,
                bottom: 32 + mediaBottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tombol Delete (pojok kanan)
                  if (selectedWallet != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 20, bottom: 20),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: _DeleteButton(
                          onTap: () => _confirmDelete(context, selectedWallet),
                        ),
                      ),
                    ),

                  // Info wallet yang dipilih
                  if (selectedWallet != null)
                    _buildWalletInfo(selectedWallet, provider.isHidden),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Info detail wallet yang dipilih ─────────────────────
  Widget _buildWalletInfo(WalletModel wallet, bool isHidden) {
    final formatter = NumberFormat('#,##0', 'id_ID');
    final balanceText = isHidden
        ? '••••••••'
        : 'Rp. ${formatter.format(wallet.balance)},00';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoTile(
            icon: Icons.account_balance_wallet_rounded,
            label: 'Nama Wallet',
            value: wallet.name,
          ),
          const SizedBox(height: 14),
          _InfoTile(
            icon: Icons.monetization_on_rounded,
            label: 'Saldo',
            value: balanceText,
          ),
          const SizedBox(height: 14),
          _InfoTile(
            icon: Icons.category_rounded,
            label: 'Kategori',
            value: wallet.category.label,
          ),
        ],
      ),
    );
  }

  // ── Card height ────────────────────────────────────────
  double _cardHeight(BuildContext context) {
    final w = MediaQuery.of(context).size.width * 0.82;
    return w / 1.65;
  }
}

// ══════════════════════════════════════════════════════════════
// Tombol Delete — merah rounded dengan ikon trash
// ══════════════════════════════════════════════════════════════
class _DeleteButton extends StatefulWidget {
  final VoidCallback onTap;
  const _DeleteButton({required this.onTap});

  @override
  State<_DeleteButton> createState() => _DeleteButtonState();
}

class _DeleteButtonState extends State<_DeleteButton> {
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.error,
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: AppColors.error.withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.delete_rounded, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text(
                'Delete',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Info tile satu baris
// ══════════════════════════════════════════════════════════════
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withValues(alpha: 0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.dashboardPurple,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primaryPurple, size: 20),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 11,
                  color: Color(0xFF9B9B9B),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
