import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/wallet_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/wallet_provider.dart';
import 'create_wallet_page.dart';
import 'wallet_category_page.dart';

class YourWalletPage extends StatefulWidget {
  const YourWalletPage({super.key});

  @override
  State<YourWalletPage> createState() => _YourWalletPageState();
}

class _YourWalletPageState extends State<YourWalletPage> {
  static final NumberFormat _currencyFormatter = NumberFormat('#,##0', 'id_ID');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final token = context.read<AuthProvider>().token;
      if (token != null) {
        context.read<WalletProvider>().loadWalletsFromApi(token);
      }
    });
  }

  void _openCreateWallet() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateWalletPage()),
    );
  }

  void _openCategory(WalletCategory category) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => WalletCategoryPage(category: category)),
    );
  }

  double _categoryBalance(WalletProvider provider, WalletCategory category) {
    return provider
        .byCategory(category)
        .fold(0, (sum, wallet) => sum + wallet.balance);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WalletProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: AppColors.primaryPurple,
          body: Container(
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  _WalletHero(
                    totalBalance: provider.totalBalance,
                    walletCount: provider.wallets.length,
                    isHidden: provider.isHidden,
                    isLoading: provider.isLoading,
                    onBack: () => Navigator.maybePop(context),
                    onToggleVisibility: provider.toggleHide,
                  ),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: AppColors.backgroundWhite,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(38),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.panelShadow,
                            blurRadius: 20,
                            offset: Offset(0, -5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(38),
                        ),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Opacity(
                                opacity: 0.13,
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
                            ListView(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(
                                20,
                                24,
                                20,
                                135,
                              ),
                              children: [
                                _WalletSectionHeader(
                                  onAddWallet: _openCreateWallet,
                                ),
                                const SizedBox(height: 18),
                                Skeletonizer(
                                  enabled: provider.isLoading,
                                  child: Column(
                                    children: [
                                      _WalletCategoryCard(
                                        iconAsset: 'assets/icon/cash.svg',
                                        title: 'Cash',
                                        subtitle: 'Money ready in your hands',
                                        count: provider
                                            .byCategory(WalletCategory.cash)
                                            .length,
                                        balance: _categoryBalance(
                                          provider,
                                          WalletCategory.cash,
                                        ),
                                        isHidden: provider.isHidden,
                                        gradient: const [
                                          Color(0xFFFF8A65),
                                          Color(0xFFFF5722),
                                        ],
                                        onTap: () =>
                                            _openCategory(WalletCategory.cash),
                                      ),
                                      const SizedBox(height: 12),
                                      _WalletCategoryCard(
                                        icon: Icons.account_balance_outlined,
                                        title: 'Bank accounts',
                                        subtitle:
                                            'Your connected bank balances',
                                        count: provider
                                            .byCategory(
                                              WalletCategory.bankAccount,
                                            )
                                            .length,
                                        balance: _categoryBalance(
                                          provider,
                                          WalletCategory.bankAccount,
                                        ),
                                        isHidden: provider.isHidden,
                                        gradient: const [
                                          Color(0xFF38BDF8),
                                          Color(0xFF2563EB),
                                        ],
                                        onTap: () => _openCategory(
                                          WalletCategory.bankAccount,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      _WalletCategoryCard(
                                        icon: Icons
                                            .account_balance_wallet_outlined,
                                        title: 'E-wallets',
                                        subtitle:
                                            'Your everyday digital wallets',
                                        count: provider
                                            .byCategory(WalletCategory.eWallet)
                                            .length,
                                        balance: _categoryBalance(
                                          provider,
                                          WalletCategory.eWallet,
                                        ),
                                        isHidden: provider.isHidden,
                                        gradient: const [
                                          Color(0xFF9B87F5),
                                          AppColors.primaryPurple,
                                        ],
                                        onTap: () => _openCategory(
                                          WalletCategory.eWallet,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _WalletHero extends StatelessWidget {
  final double totalBalance;
  final int walletCount;
  final bool isHidden;
  final bool isLoading;
  final VoidCallback onBack;
  final VoidCallback onToggleVisibility;

  const _WalletHero({
    required this.totalBalance,
    required this.walletCount,
    required this.isHidden,
    required this.isLoading,
    required this.onBack,
    required this.onToggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    final balance = isHidden
        ? '••••••••'
        : 'Rp${_YourWalletPageState._currencyFormatter.format(totalBalance)}';

    return SizedBox(
      height: 286,
      width: double.infinity,
      child: Stack(
        children: [
          const Positioned.fill(child: _WalletCheckerDecoration()),
          Positioned(
            left: 14,
            right: 14,
            top: 8,
            child: Row(
              children: [
                Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: onBack,
                    customBorder: const CircleBorder(),
                    child: const Padding(
                      padding: EdgeInsets.all(11),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.panelWhite,
                        size: 25,
                      ),
                    ),
                  ),
                ),
                const Expanded(
                  child: Text(
                    'Your Wallet',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                      color: AppColors.panelWhite,
                    ),
                  ),
                ),
                const SizedBox(width: 47),
              ],
            ),
          ),
          Positioned(
            left: 30,
            right: 30,
            top: 92,
            child: Skeletonizer(
              enabled: isLoading,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Total balance',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.panelWhite,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Material(
                        color: Colors.transparent,
                        shape: const CircleBorder(),
                        child: InkWell(
                          onTap: onToggleVisibility,
                          customBorder: const CircleBorder(),
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: Icon(
                                isHidden
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                key: ValueKey(isHidden),
                                color: AppColors.panelWhite,
                                size: 19,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      isLoading ? 'Rp99.999.999' : balance,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 46,
                        height: 1,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.1,
                        color: AppColors.panelWhite,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.panelWhite.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: AppColors.panelWhite.withValues(alpha: 0.20),
                      ),
                    ),
                    child: Text(
                      '$walletCount ${walletCount == 1 ? 'wallet' : 'wallets'} connected',
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.panelWhite,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WalletSectionHeader extends StatelessWidget {
  final VoidCallback onAddWallet;

  const _WalletSectionHeader({required this.onAddWallet});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Wallet overview',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryPurple,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Choose a category to see its wallets',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Material(
          color: AppColors.primaryPurple,
          borderRadius: BorderRadius.circular(17),
          child: InkWell(
            onTap: onAddWallet,
            borderRadius: BorderRadius.circular(17),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 13, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add_card_rounded,
                    color: AppColors.panelWhite,
                    size: 18,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Add wallet',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.panelWhite,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _WalletCategoryCard extends StatelessWidget {
  final IconData? icon;
  final String? iconAsset;
  final String title;
  final String subtitle;
  final int count;
  final double balance;
  final bool isHidden;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _WalletCategoryCard({
    this.icon,
    this.iconAsset,
    required this.title,
    required this.subtitle,
    required this.count,
    required this.balance,
    required this.isHidden,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final balanceText = isHidden
        ? '••••••'
        : 'Rp${_YourWalletPageState._currencyFormatter.format(balance)}';

    return Material(
      color: AppColors.panelWhite,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: gradient.last.withValues(alpha: 0.10)),
            boxShadow: const [
              BoxShadow(
                color: AppColors.lightShadow,
                blurRadius: 14,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(17),
                  boxShadow: [
                    BoxShadow(
                      color: gradient.last.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: iconAsset != null
                    ? SvgPicture.asset(
                        iconAsset!,
                        width: 24,
                        height: 24,
                        colorFilter: const ColorFilter.mode(
                          AppColors.panelWhite,
                          BlendMode.srcIn,
                        ),
                      )
                    : Icon(icon, color: AppColors.panelWhite, size: 25),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Text(
                          balanceText,
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: gradient.last,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 10.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$count ${count == 1 ? 'wallet' : 'wallets'}',
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.disabled,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.disabled,
                size: 23,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WalletCheckerDecoration extends StatelessWidget {
  const _WalletCheckerDecoration();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: SizedBox(
        width: 160,
        height: 240,
        child: GridView.builder(
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
          ),
          itemCount: 15,
          itemBuilder: (_, index) => ColoredBox(
            color: index.isEven
                ? AppColors.panelWhite.withValues(alpha: 0.035)
                : AppColors.primaryPurple.withValues(alpha: 0.04),
          ),
        ),
      ),
    );
  }
}
