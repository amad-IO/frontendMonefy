import 'package:flutter/material.dart';
import '../../models/transaction_model.dart';
import '../../theme/text_style.dart';
import '../widgets/navbar/custom_navbar.dart';
import '../widgets/history_section.dart';

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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBody: true,

      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),

            _buildBalanceCard(colorScheme),

            _buildQuickAccess(),

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

  Widget _buildBalanceCard(ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withValues(alpha: 0.75),
            colorScheme.primary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            "Total Balance",
            style: AppTextStyle.caption.copyWith(
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Rp. 3.000.000",
            style: AppTextStyle.heading.copyWith(
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _miniCard(context, "Income", "Rp. 2.000.000"),
              _miniCard(context, "Expense", "Rp. 700.000"),
            ],
          )
        ],
      ),
    );
  }

  Widget _miniCard(BuildContext context, String title, String value) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .onPrimary
            .withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: AppTextStyle.caption.copyWith(
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          Text(
            value,
            style: AppTextStyle.body.copyWith(
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccess() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _quickItem("Bills"),
          _quickItem("Add wallet"),
          _quickItem("Saving"),
        ],
      ),
    );
  }

  Widget _quickItem(String title) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: AppTextStyle.caption.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }
}