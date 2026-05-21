import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/bill_provider.dart';
import '../widgets/bills/list_bills.dart';
import 'bills_page.dart';

class ListBillsPage extends StatefulWidget {
  const ListBillsPage({super.key});

  @override
  State<ListBillsPage> createState() => _ListBillsPageState();
}

class _ListBillsPageState extends State<ListBillsPage> {

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final token = context.read<AuthProvider>().token!;
      context.read<BillProvider>().fetchBills(token);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BillProvider>();

    double totalUnpaid = provider.bills
        .where((b) => b.status == "unpaid")
        .fold(0, (sum, item) => sum + item.amount);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF694EDA),
              Color(0xFF8F79ED),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: SafeArea(
          child: Column(
            children: [

              /// HEADER (BERSIH TANPA SVG)
              SizedBox(
                height: 220,
                width: double.infinity,
                child: Stack(
                  children: [

                    /// BACK BUTTON + TITLE
                    Positioned(
                      top: 20,
                      left: 0,
                      right: 0,
                      child: Row(
                        children: [
                          const SizedBox(width: 20),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(Icons.arrow_back,
                                color: Colors.white),
                          ),
                          const Spacer(),
                          const Text(
                            "Bills",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const Spacer(),
                          const SizedBox(width: 40),
                        ],
                      ),
                    ),

                    /// TITLE TOTAL
                    const Positioned(
                      left: 40,
                      top: 90,
                      child: Text(
                        "Total Outstanding Payment",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    /// TOTAL AMOUNT
                    Positioned(
                      left: 40,
                      top: 120,
                      child: Text(
                        "Rp${totalUnpaid.toStringAsFixed(0)}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              /// LIST AREA
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1F1F1),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  child: ListBills(
                    onAddTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BillsPage(),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}