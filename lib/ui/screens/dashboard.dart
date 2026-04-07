import 'package:flutter/material.dart';
import 'package:monefy/ui/widgets/navbar/custom_navbar.dart';
import 'package:monefy/ui/widgets/transaction/transaction_item.dart';
import 'package:monefy/theme/text_style.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),
      extendBody: true,

      body: Stack(
        children: [

          //CONTENT UTAMA
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // 🔹 HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hi, mochi!",
                            style: AppTextStyle.heading.copyWith(
                              color: const Color(0xFF694EDA),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "How are you today?",
                            style: AppTextStyle.caption,
                            ),
                        ],
                      ),
                      SizedBox(
                        width: 85,
                        height: 85,
                        child: Image.asset(
                          'assets/images/logo2.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  //BALANCE CARD
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8F79ED), Color(0xFF694EDA)],
                      ),
                    ),
                    child: Stack(
                      children: [

                        // LINGKARAN
                        Positioned(
                          right: -40,
                          bottom: -40,
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: const BoxDecoration(
                              color: Color(0xFF6B48FF),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),

                        // 🔹 CONTENT
                        Column(
                          children: [
                            const Text(
                              "Total Balance",
                              style: AppTextStyle.caption,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Rp. 3.000.000,00",
                              style:  AppTextStyle.heading,
                              ),

                            const SizedBox(height: 16),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _miniCard("Income", "Rp. 2.000.000,00"),
                                _miniCard("Expense", "Rp. 700.000,00"),
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // BACKGROUND PUTIH MELENGKUNG
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // QUICK ACCESS
                        const Text(
                          "Quick Access",
                          style: AppTextStyle.title,
                          ),

                        const SizedBox(height: 10),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: const [
                            _QuickItem(icon: Icons.receipt, label: "Bills"),
                            _QuickItem(icon: Icons.account_balance_wallet, label: "Add wallet"),
                            _QuickItem(icon: Icons.savings, label: "Saving"),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // 🔹 FILTER
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Chip(label: Text("Day")),
                            Text("Week"),
                            Text("Month"),
                            Text("Year"),
                            Text("All"),
                          ],
                        ),

                        const SizedBox(height: 20),

                        //TRANSACTION LIST
                        const TransactionItem(
                          title: "Food & Drink",
                          date: "16 Maret 2025",
                          amount: "+Rp.500.000",
                          payment: "Gopay",
                          isIncome: true,
                        ),
                        const TransactionItem(
                          title: "Entertainment",
                          date: "16 Maret 2025",
                          amount: "-Rp.200.000",
                          payment: "OVO",
                          isIncome: false,
                        ),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          //NAVBAR
          Align(
            alignment: Alignment.bottomCenter,
            child: CustomBottomNavBar(
              selectedIndex: 0,
              onItemSelected: (index) {
                print("klik $index");
              },
              onAddPressed: () {
                print("add");
              },
            ),
          ),
        ],
      ),
    );
  }

  //MINI CARD
  Widget _miniCard(String title, String amount) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 4),
          Text(amount, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}

//QUICK ITEM
class _QuickItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _QuickItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF694EDA)),
        const SizedBox(height: 6),
        Text(
          label,
          style: AppTextStyle.caption.copyWith(
            color: const Color(0xFF694EDA),
          ),
        ),
      ],
    );
  }
}