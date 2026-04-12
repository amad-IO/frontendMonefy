import 'package:flutter/material.dart';
import '../widgets/bills_input.dart';
import '../widgets/navbar/navbar.dart';

class BillsPage extends StatefulWidget {
  const BillsPage({super.key});

  @override
  State<BillsPage> createState() => _BillsPageState();
}

class _BillsPageState extends State<BillsPage> {
  int _selectedIndex = 1; // posisi Bills / History

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // TODO: tambahkan navigasi kalau mau pindah page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  // tombol back di kiri
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),

                  // title di tengah
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
          ],
        ),
      ),
    );
  }
}