
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:monefy/ui/pages/main_page.dart';
import 'package:monefy/ui/pages/saving_page.dart';
import '../../models/summary_model.dart';
import '../../models/transaction_model.dart';
import '../../models/user_model.dart';
import '../../theme/colors.dart';
import '../../theme/text_style.dart';
import '../widgets/quick_access.dart';
import '../widgets/history_section.dart';
import '../widgets/summary_card.dart';
import 'add_wallet_page.dart';
import 'bills_page.dart';

class HomePage extends StatefulWidget {
  final Function(int)? onNavigate;

  const HomePage({super.key, this.onNavigate});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final List<TransactionModel> _transactions;
  late final UserModel _user;

  @override
  void initState() {
    super.initState();
    _transactions = TransactionModel.dummyList();
    _user = UserModel.dummy();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dashboardPurple,
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            SummaryCard(
              summary: SummaryModel.dummy(),
            ),

            const SizedBox(height: 12),
            QuickAccess(
              onBillsTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MainPage(
                      initialIndex: 5, // index Bills
                      extraPage: const BillsPage(),
                    ),
                  ),
                );
              },
              onAddWalletTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MainPage(initialIndex: 2),
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
                transactions: _transactions,
                onFilterChanged: (filter) {
                },
                onSeeAll: () {
                },
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi, ${_user.username}!',
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