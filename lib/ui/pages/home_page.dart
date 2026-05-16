
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:monefy/ui/pages/main_page.dart';
import 'package:monefy/ui/pages/saving_page.dart';
import 'package:monefy/ui/pages/your_wallet_page.dart';
import '../../providers/auth_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/summary_model.dart';
import '../widgets/quick_access.dart';
import '../widgets/history_section.dart';
import '../widgets/summary_card.dart';
import '../widgets/card_history.dart';
import 'bills_page.dart';

// Dummy transaction untuk skeleton placeholder
final _dummyTransaction = TransactionModel(
  id: '0',
  category: 'Shopping',
  title: 'Dummy',
  amount: 150000,
  date: DateTime.now(),
  walletName: 'BCA',
  type: TransactionType.expense,
);

// Dummy summary untuk skeleton placeholder (bukan const karena SummaryModel bukan const)
final _dummySummary = SummaryModel(
  totalBalance: 9999999,
  totalIncome: 5000000,
  totalExpense: 3000000,
);

class HomePage extends StatefulWidget {
  final Function(int)? onNavigate;

  const HomePage({super.key, this.onNavigate});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState() {
    super.initState();
    // ✅ Hanya load jika data belum ada (menghindari double-fetch dengan main.dart).
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final auth           = context.read<AuthProvider>();
      final txProvider     = context.read<TransactionProvider>();
      final walletProvider = context.read<WalletProvider>();

      if (!auth.isLoggedIn) return;

      if (txProvider.transactions.isEmpty && !txProvider.isLoading) {
        final token = auth.token!;
        await Future.wait([
          txProvider.loadAll(token),
          walletProvider.loadWalletsFromApi(token),
        ]);
        if (!mounted) return;
        txProvider.enrichToWalletNames(walletProvider.wallets);
      } else if (walletProvider.wallets.isNotEmpty) {
        txProvider.enrichToWalletNames(walletProvider.wallets);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final txProvider = context.watch<TransactionProvider>();
    final isLoading  = txProvider.isLoading;

    return Scaffold(
      backgroundColor: AppColors.dashboardPurple,
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),

            // ── SummaryCard dengan skeleton ──────────────────────
            Skeletonizer(
              enabled: isLoading,
              child: SummaryCard(
                summary: isLoading ? _dummySummary : txProvider.summary,
              ),
            ),

            const SizedBox(height: 12),

            QuickAccess(
              onBillsTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MainPage(
                      initialIndex: 5,
                      extraPage: const BillsPage(),
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

            // ── HistorySection dengan skeleton ───────────────────
            Expanded(
              child: isLoading
                  ? _buildHistorySkeleton()
                  : HistorySection(
                      transactions: txProvider.transactions,
                      onFilterChanged: (filter) {},
                      onSeeAll: () {},
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// Skeleton palsu 5 card saat data belum dimuat
  Widget _buildHistorySkeleton() {
    return Skeletonizer(
      enabled: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(0, 18, 0, 0),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(28),
            bottomRight: Radius.circular(28),
          ),
        ),
        child: ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 5,
          itemBuilder: (_, __) => CardHistory(transaction: _dummyTransaction),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final auth     = context.watch<AuthProvider>();
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