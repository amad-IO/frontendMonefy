import 'package:flutter/material.dart';
import '../widgets/bills_input.dart';
import '../widgets/navbar/navbar.dart';
import 'main_page.dart';

class BillsPage extends StatefulWidget {
  const BillsPage({super.key});

  @override
  State<BillsPage> createState() => _BillsPageState();
}

class _BillsPageState extends State<BillsPage> {
  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MainPage(initialIndex: index),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFFF1F1F1),

      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.all(16),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const Text(
                    "Bills",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF694EDA),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // TITLE
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Wallet Details",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF694EDA),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // FORM
            const BillsInput(
              label: "Bill Name",
              hint: "e.g., BCA, GoPay, Cash",
            ),
            const BillsInput(
              label: "Account Number",
              hint: "0",
            ),
            const BillsInput(
              label: "Amount",
              hint: "e.g., 100000",
            ),

            // INI PENTING BANGET
            const SizedBox(height: 100), // biar gak ketutup navbar
          ],
        ),
      ),
    );
  }
}


