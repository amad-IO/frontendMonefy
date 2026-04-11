import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../models/summary_model.dart';
import '../../models/transaction_model.dart';
import '../../models/user_model.dart';
import '../../theme/colors.dart';
import '../../theme/text_style.dart';
import '../widgets/navbar/navbar.dart';
import '../widgets/quick_access.dart';
import '../widgets/history_section.dart';
import '../widgets/summary_card.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int selectedIndex = 0;
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
              onBillsTap: () {},
              onAddWalletTap: () {},
              onSavingTap: () {},
            ),

            Expanded(
              child: HistorySection(
                transactions: _transactions,
                onFilterChanged: (filter) {},
                onSeeAll: () {},
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: CustomNavbar(
        selectedIndex: selectedIndex,
        onItemTapped: (i) {
          setState(() => selectedIndex = i);
        },
      ),
      floatingActionButton: CustomAddFab(
        onPressed: () {
          setState(() => selectedIndex = 2);
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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