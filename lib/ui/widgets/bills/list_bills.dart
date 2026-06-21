import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../providers/auth_provider.dart';
import '../../../providers/bill_provider.dart';
import '../../pages/add_page.dart';
import 'bill_card.dart';
import 'bill_detail_modal.dart';
import '../loading_spinner.dart';
import '../../../core/utils/currency_formatter.dart';

class ListBills extends StatefulWidget {
  final VoidCallback? onAddTap;

  const ListBills({super.key, this.onAddTap});

  @override
  State<ListBills> createState() => _ListBillsState();
}

class _ListBillsState extends State<ListBills> {
  bool isUnpaid = true;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BillProvider>();
    context.read<AuthProvider>().token; // baca token agar auth listener aktif

    /// 🔥 FILTER DATA
    final bills = provider.bills.where((b) {
      if (isUnpaid) {
        return b.status.toLowerCase() == "unpaid";
      } else {
        return b.status.toLowerCase() == "paid";
      }
    }).toList();

    return Container(
      height: double.infinity,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1F1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Stack(
        children: [
          /// BACKGROUND
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: SvgPicture.asset(
                "assets/images/kontur.svg",
                fit: BoxFit.cover,
              ),
            ),
          ),

          /// CONTENT
          ListView(
            padding: const EdgeInsets.only(top: 20),
            children: [
              /// ADD BILL
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: widget.onAddTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD5CEF5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add,
                              size: 16, color: Colors.white),
                          SizedBox(width: 5),
                          Text(
                            "Add Bills",
                            style: TextStyle(
                              color: Color(0xFF694EDA),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// TOGGLE
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0x33694EDA),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    /// UNPAID
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() => isUnpaid = true);
                        },
                        child: Container(
                          padding:
                          const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isUnpaid
                                ? Colors.white
                                : Colors.transparent,
                            borderRadius:
                            BorderRadius.circular(20),
                          ),
                          child: const Center(
                            child: Text(
                              "Unpaid",
                              style: TextStyle(
                                color: Color(0xFF694EDA),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    /// PAID
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() => isUnpaid = false);
                        },
                        child: Container(
                          padding:
                          const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: !isUnpaid
                                ? Colors.white
                                : Colors.transparent,
                            borderRadius:
                            BorderRadius.circular(20),
                          ),
                          child: const Center(
                            child: Text(
                              "Paid",
                              style: TextStyle(
                                color: Color(0xFF694EDA),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// LOADING
              if (provider.isLoading)
                const LoadingSpinner(), // ✅ Menggunakan spinner kustom Anda

              /// EMPTY STATE
              if (!provider.isLoading && bills.isEmpty)
                const Center(
                  child: Text("No Bills"),
                ),

              /// LIST DATA
              if (!provider.isLoading) // ✅ Hanya tampilkan data jika TIDAK sedang loading
                ...bills.map((bill) {
                  return BillCard(
                    title: bill.provider,
                    amount: rupiahFormatter.format(bill.amount),
                    isPaid: bill.status.toLowerCase() == "paid",
                    onTap: () {
                      showBillDetailModal(
                        context,
                        {
                          "id": bill.id,
                          "name": bill.provider,
                          "account": bill.accountNumber,
                          "amount": bill.amount,
                          "due_date": bill.dueDate,
                          "cycle": bill.cycle,
                          "status": bill.status,
                        },
                      );
                    },
                    onPay: () {
                      // Buka AddPage sebagai bottom sheet (sesuai pola app)
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => AddPage(
                          billData: {
                            'id': bill.id,
                            'provider': bill.provider,
                            'amount': bill.amount,
                            'cycle': bill.cycle,
                          },
                        ),
                      );
                    },
                  );
                }).toList(),

              const SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }
}