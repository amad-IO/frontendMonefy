import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
      backgroundColor: const Color(0xFF694EDA),
      body: SafeArea(
        child: Column(
          children: [
            /// HEADER
            Container(
              height: 280,
              width: double.infinity,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.10, // 🔥 kecilin biar gak ganggu
                      child: SvgPicture.asset(
                        "assets/images/catur.svg",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 240,
                      height: 200,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment(1, 0.5),
                          end: Alignment(-0.2, 0.3),
                          colors: [
                            Color(0x008F79ED),
                            Color(0xFF694EDA),
                          ],
                        ),
                      ),
                    ),
                  ),

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
                            color: Color(0xFFF6F7FB),
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Spacer(),
                        const SizedBox(width: 40),
                      ],
                    ),
                  ),

                  const Positioned(
                    left: 70,
                    top: 90,
                    child: Text(
                      "Total Outstanding Payment",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  /// 🔥 TOTAL DINAMIS
                  Positioned(
                    left: 90,
                    top: 120,
                    child: Text(
                      "Rp${totalUnpaid.toStringAsFixed(0)}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// LIST
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F5F5),
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
    );
  }
}