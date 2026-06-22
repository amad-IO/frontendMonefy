import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/saving_provider.dart';
import '../../providers/wallet_provider.dart';
import '../widgets/saving/create_saving_modal.dart';
import '../widgets/saving/saving_list.dart';

class SavingPage extends StatefulWidget {
  const SavingPage({super.key});

  @override
  State<SavingPage> createState() => _SavingPageState();
}

class _SavingPageState extends State<SavingPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final token = context.read<AuthProvider>().token;
      if (token != null) {
        context.read<SavingProvider>().fetchSavings(token);
        context.read<WalletProvider>().loadWalletsFromApi(token);
      }
    });
  }

  void _createSaving(String name, int target, String date) {
    final token = context.read<AuthProvider>().token;
    if (token != null) {
      context.read<SavingProvider>().addSaving(name, target, date, token);
    }
  }

  void _openCreateModal() {
    showCreateSavingModal(context, _createSaving);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SavingProvider>(
      builder: (context, provider, child) {
        final ongoing = provider.savings
            .where((saving) => saving.status != 'terbeli')
            .toList();
        final completed = provider.savings.length - ongoing.length;
        final totalTarget = ongoing.fold<int>(
          0,
          (sum, saving) => sum + saving.target,
        );

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
                  _WishlistHero(
                    totalTarget: totalTarget,
                    ongoingCount: ongoing.length,
                    completedCount: completed,
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
                            blurRadius: 18,
                            offset: Offset(0, -4),
                          ),
                        ],
                      ),
                      child: SavingList(
                        items: provider.savings
                            .map(
                              (saving) => {
                                'id': saving.id,
                                'name': saving.name,
                                'amount': saving.amount,
                                'target': saving.target,
                                'date': saving.date,
                                'isDone': saving.status == 'terbeli',
                              },
                            )
                            .toList(),
                        isLoading: provider.isLoading,
                        onAddTap: _openCreateModal,
                        showSectionHeader: true,
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

class _WishlistHero extends StatelessWidget {
  final int totalTarget;
  final int ongoingCount;
  final int completedCount;

  const _WishlistHero({
    required this.totalTarget,
    required this.ongoingCount,
    required this.completedCount,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##0', 'id_ID');

    return SizedBox(
      height: 286,
      width: double.infinity,
      child: Stack(
        children: [
          const Positioned.fill(child: _CheckerDecoration()),
          Positioned(
            left: 36,
            right: 36,
            top: 12,
            child: Row(
              children: [
                _HeaderButton(
                  icon: Icons.arrow_back_rounded,
                  onTap: () => Navigator.maybePop(context),
                ),
                const Expanded(
                  child: Text(
                    'Wishlist',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.panelWhite,
                    ),
                  ),
                ),
                const SizedBox(width: 50),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(46, 102, 36, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Wishlist Target',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.panelWhite,
                  ),
                ),
                const SizedBox(height: 14),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Rp${formatter.format(totalTarget)}',
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 48,
                      fontWeight: FontWeight.w800,
                      color: AppColors.panelWhite,
                      height: 1,
                    ),
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    _SummaryChip(
                      icon: Icons.auto_awesome_rounded,
                      label: '$ongoingCount ongoing',
                    ),
                    const SizedBox(width: 8),
                    _SummaryChip(
                      icon: Icons.task_alt_rounded,
                      label: '$completedCount completed',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(11),
          child: Icon(icon, color: AppColors.panelWhite, size: 28),
        ),
      ),
    );
  }
}

class _CheckerDecoration extends StatelessWidget {
  const _CheckerDecoration();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: SizedBox(
        width: 235,
        height: 286,
        child: GridView.builder(
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
          ),
          itemCount: 12,
          itemBuilder: (context, index) {
            return ColoredBox(
              color: AppColors.panelWhite.withValues(
                alpha: index.isEven ? 0.035 : 0.012,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SummaryChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.panelWhite.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.panelWhite),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.panelWhite,
            ),
          ),
        ],
      ),
    );
  }
}
