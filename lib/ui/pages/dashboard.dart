import 'package:flutter/material.dart';
import '../../models/summary_model.dart';
import '../../models/transaction_model.dart';
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

  @override
  void initState() {
    super.initState();
    _transactions = TransactionModel.dummyList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDE8F8),
      extendBody: true,

      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),

            SummaryCard(
              summary: SummaryModel.dummy(), // sementara, ganti dengan data API nanti
            ),

            const SizedBox(height: 12),

            QuickAccess(
              onBillsTap: () {
                // TODO: Navigator.push ke Bills page
              },
              onAddWalletTap: () {
                // TODO: Navigator.push ke Add Wallet page
              },
              onSavingTap: () {
                // TODO: Navigator.push ke Saving page
              },
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
                "Hi, mochi!",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Text("How are you today?", style: AppTextStyle.caption),
            ],
          ),
          const CircleAvatar(radius: 24),
        ],
      ),
    );
  }
}