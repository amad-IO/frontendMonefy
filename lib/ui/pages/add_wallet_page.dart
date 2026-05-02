import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/wallet_model.dart';
import '../widgets/wallet_card.dart';
import 'create_wallet_page.dart';

// ══════════════════════════════════════════════════════════════
/// AddWalletPage — halaman daftar wallet per kategori.
///
/// Menampilkan:
/// - Header ungu: total balance semua wallet + hide/show
/// - Body putih + kontur background
/// - Tombol tambah wallet baru (navigasi ke [CreateWalletPage])
/// - Section per kategori: Cash, Bank Accounts, E-wallets
/// - Horizontal card list (WalletCard) per section
// ══════════════════════════════════════════════════════════════
class AddWalletPage extends StatefulWidget {
  const AddWalletPage({super.key});

  @override
  State<AddWalletPage> createState() => _AddWalletPageState();
}

class _AddWalletPageState extends State<AddWalletPage> {
  bool _isHidden = false;

  // ── Dummy data — ganti dengan Provider/API saat backend ready ──
  final List<WalletModel> _wallets = WalletModel.dummyList();

  // ── Helpers ───────────────────────────────────────────────
  double get _totalBalance =>
      _wallets.fold(0.0, (sum, w) => sum + w.balance);

  String get _formattedTotal {
    if (_isHidden) return '••••••••';
    final formatter = NumberFormat('#,##0', 'id_ID');
    return 'Rp.${formatter.format(_totalBalance)},00';
  }

  List<WalletModel> _walletsByCategory(WalletCategory cat) =>
      _wallets.where((w) => w.category == cat).toList();

  void _toggleHide() => setState(() => _isHidden = !_isHidden);

  // ── Navigation ────────────────────────────────────────────
  void _goToCreateWallet() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CreateWalletPage()),
    );
  }

  // ══════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // primaryPurple jadi background penuh, body putih overlap di atas
      backgroundColor: AppColors.primaryPurple,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header gelap ─────────────────────────────────
            _buildHeader(),

            // ── Body putih (rounded top + kontur) ───────────
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // HEADER
  // ══════════════════════════════════════════════════════════
  Widget _buildHeader() {
    return Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Baris: Back arrow + judul ────────────────────
              Row(
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
                      'Add New Wallet',
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

              const SizedBox(height: 28),

              // ── Label "Your total balance is" + ikon mata ────
              Row(
                children: [
                  Text(
                    'Your total balance is',
                    style: AppTextStyle.body.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _toggleHide,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: Icon(
                        _isHidden
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        key: ValueKey(_isHidden),
                        color: Colors.white.withValues(alpha: 0.85),
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // ── Total nominal ─────────────────────────────────
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                child: Text(
                  _formattedTotal,
                  key: ValueKey(_isHidden),
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
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
  Widget _buildBody() {
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
            // ── Kontur SVG — hanya di body putih, bukan header ─
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

            // ── Konten scrollable ──────────────────────────
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                top: 20,
                bottom: 100 + mediaBottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tombol tambah wallet (pojok kanan)
                  Padding(
                    padding: const EdgeInsets.only(right: 20, bottom: 8),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: _AddWalletButton(onTap: _goToCreateWallet),
                    ),
                  ),

                  // ── Section per kategori ───────────────────
                  _buildSection(WalletCategory.cash),
                  _buildSection(WalletCategory.bankAccount),
                  _buildSection(WalletCategory.eWallet),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Section satu kategori ─────────────────────────────────
  Widget _buildSection(WalletCategory category) {
    final wallets = _walletsByCategory(category);
    if (wallets.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label kategori
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
            child: Text(
              category.label,
              style: AppTextStyle.title.copyWith(
                color: AppColors.primaryPurple,
                fontWeight: FontWeight.w800,
                fontSize: 17,
              ),
            ),
          ),

          // Horizontal scroll kartu
          SizedBox(
            height: _cardHeight,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: wallets.length,
              itemBuilder: (context, index) {
                final wallet = wallets[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: SizedBox(
                    width: _cardWidth,
                    child: WalletCard(
                      walletName: wallet.name,
                      balance: wallet.balance,
                      theme: wallet.theme,
                      isHidden: _isHidden,
                      onToggleHide: _toggleHide,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Ukuran card ───────────────────────────────────────────
  double get _cardWidth {
    final screenWidth = MediaQuery.of(context).size.width;
    // Card utama ~75% lebar screen, card berikut mengintip ~18%
    return screenWidth * 0.72;
  }

  double get _cardHeight => _cardWidth / 1.65;
}

// ══════════════════════════════════════════════════════════════
// Tombol tambah wallet — lingkaran ungu dengan ikon card+
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
        scale: _pressed ? 0.90 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.dashboardPurple,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryPurple.withValues(alpha: 0.18),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.add_card_rounded,
            color: AppColors.primaryPurple,
            size: 26,
          ),
        ),
      ),
    );
  }
}