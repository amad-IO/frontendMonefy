
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:monefy/ui/pages/main_page.dart';
import 'package:monefy/ui/pages/saving_page.dart';
import 'package:monefy/ui/pages/your_wallet_page.dart';
import '../../data/models/transaction_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../widgets/quick_access.dart';
import '../widgets/history_section.dart';
import '../widgets/summary_card.dart';
import 'list_bills_page.dart';

class HomePage extends StatefulWidget {
  final Function(int)? onNavigate;

  const HomePage({super.key, this.onNavigate});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TransactionFilter _activeFilter = TransactionFilter.all;

  // initState() sengaja tidak load data dari API.
  // Data sudah di-load oleh _RootPage._checkLogin() di main.dart
  // sebelum halaman ini dibuild. Tidak perlu fetch ulang di sini.

  // ── Pull-to-Refresh: force fetch fresh dari server ────────────
  Future<void> _onRefresh() async {
    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn) return;
    final token = auth.token!;
    final txProvider     = context.read<TransactionProvider>();
    final walletProvider = context.read<WalletProvider>();
    await Future.wait([
      txProvider.loadTransactions(token),
      walletProvider.loadWalletsFromApi(token),
    ]);
    txProvider.enrichToWalletNames(walletProvider.wallets);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();

    return Scaffold(
      backgroundColor: AppColors.dashboardPurple,
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppColors.primaryPurple,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top,
              child: Column(
          children: [
            _buildHeader(),
            SummaryCard(
              summary: provider.summary,
              onIncomeTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MainPage(
                      initialIndex: 3,
                      initialAnalyticIsExpense: false,
                    ),
                  ),
                );
              },
              onExpenseTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MainPage(
                      initialIndex: 3,
                      initialAnalyticIsExpense: true,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),
            QuickAccess(
              onBillsTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MainPage(
                      initialIndex: 5,
                      extraPage: ListBillsPage(),
                    ),
                  ),
                );
              },
              onAddWalletTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MainPage(
                      initialIndex: 5,
                      extraPage: YourWalletPage(),
                    ),
                  ),
                );
              },
              onSavingTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MainPage(
                      initialIndex: 5,
                      extraPage: const SavingPage(),
                    ),
                  ),
                );
              },
            ),
            Expanded(
              child: HistorySection(
                transactions: provider.getFiltered(_activeFilter),
                onFilterChanged: (filter) {
                  setState(() => _activeFilter = filter);
                },
                onSeeAll: () {
                },
              ),
            ),

          ],
        ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final auth = context.watch<AuthProvider>();
    final username = auth.username ?? 'User';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi, $username!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Text('How are you today?', style: AppTextStyle.caption),
            ],
          ),
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 18,
                  spreadRadius: 0.5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SvgPicture.asset(
              'assets/images/moneyfy.svg',
              width: 50,
              height: 50,
            ),
          ),
        ],
      ),
    );
  }
}