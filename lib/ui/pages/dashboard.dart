import 'package:flutter/material.dart';
import '../../theme/colors.dart' as theme;
import '../../theme/text_style.dart';
import '../../widgets/navbar/custom_navbar.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme.AppColors.backgroundWhite,

      body: SafeArea(
        child: Column(
          children: [
            // 🔥 HEADER
            _buildHeader(),

            // 🔥 BALANCE CARD
            _buildBalanceCard(),

            // 🔥 QUICK ACCESS
            _buildQuickAccess(),

            // 🔥 LIST
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildTransaction("Food & Drink", "+Rp.500.000", true),
                  _buildTransaction("Entertainment", "-Rp.200.000", false),
                  _buildTransaction("Transport", "-Rp.100.000", false),
                ],
              ),
            ),
          ],
        ),
      ),

      // 🔥 NAVBAR KAMU
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

  // ===========================
  // COMPONENT
  // ===========================

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Hi, mochi!", style: AppTextStyle.heading.copyWith(color: theme.AppColors.primaryPurple)),
              Text("How are you today?", style: AppTextStyle.caption),
            ],
          ),
          const CircleAvatar(radius: 24),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: theme.AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text("Total Balance", style: AppTextStyle.caption.copyWith(color: Colors.white)),
          const SizedBox(height: 8),
          Text("Rp. 3.000.000", style: AppTextStyle.heading.copyWith(color: Colors.white)),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _miniCard("Income", "Rp. 2.000.000"),
              _miniCard("Expense", "Rp. 700.000"),
            ],
          )
        ],
      ),
    );
  }

  Widget _miniCard(String title, String value) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(title, style: AppTextStyle.caption.copyWith(color: Colors.white)),
          Text(value, style: AppTextStyle.body.copyWith(color: Colors.white)),
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
            color: theme.AppColors.primaryPurple.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 6),
        Text(title, style: AppTextStyle.caption.copyWith(color: theme.AppColors.primaryPurple)),
      ],
    );
  }

  Widget _buildTransaction(String title, String amount, bool isIncome) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyle.body),
          Text(
            amount,
            style: AppTextStyle.body.copyWith(
              color: isIncome ? theme.AppColors.success : theme.AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}