import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
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
      final token = context
          .read<AuthProvider>()
          .token!;
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
      // 1. Ubah background Scaffold menjadi ungu muda solid seperti SavingPage
      backgroundColor: const Color(0xFFB7AEEB),

      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 2. Ubah header agar bersih & transparan dengan teks ungu tua (primaryPurple)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const Text(
                    "Bills",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryPurple,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // 3. Masukkan Total Outstanding ke dalam kartu putih (Total Card)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Total Outstanding Payment"),
                  const SizedBox(height: 5),
                  Text(
                    "Rp ${NumberFormat('#,##0', 'id_ID').format(totalUnpaid)}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryPurple,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 4. Tambahkan Subtitle "Bills List" (opsional agar sama persis)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Bills List",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryPurple,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // 5. Area List Bills
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
    );
  }
}