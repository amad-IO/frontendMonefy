import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/bill_provider.dart';

void showBillDetailModal(
    BuildContext context,
    Map<String, dynamic> item,
    ) {
  final token = context.read<AuthProvider>().token!;

  final nameController = TextEditingController(text: item["name"]);
  final accountController =
  TextEditingController(text: item["account"]);
  final amountController =
  TextEditingController(text: item["amount"].toString());
  final dueDateController =
  TextEditingController(text: item["due_date"]);

  String? selectedCycle = item["cycle"];

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(25),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// DRAG HANDLE
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 15),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const Text(
                    "Edit Bill",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF694EDA),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// BILL NAME
                  _field("Bill Name", nameController),

                  /// ACCOUNT
                  _field("Account Number", accountController, isNumber: true),

                  /// AMOUNT
                  _field("Amount", amountController, isNumber: true),

                  /// DATE
                  _field(
                    "Due Date",
                    dueDateController,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.tryParse(dueDateController.text) ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );

                      if (picked != null) {
                        dueDateController.text =
                        picked.toIso8601String().split("T")[0];
                      }
                    },
                  ),

                  const SizedBox(height: 15),

                  /// CYCLE
                  const Text("Billing Cycle"),
                  const SizedBox(height: 6),

                  DropdownButton<String>(
                    value: selectedCycle,
                    isExpanded: true,
                    hint: const Text("Select cycle"),
                    items: const [
                      DropdownMenuItem(value: "Bulanan", child: Text("Bulanan")),
                      DropdownMenuItem(value: "Tahunan", child: Text("Tahunan")),
                      DropdownMenuItem(value: "Sekali Bayar", child: Text("Sekali Bayar")),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedCycle = value;
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  /// UPDATE
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF694EDA),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () async {
                        await context.read<BillProvider>().updateBill(
                          item["id"],
                          {
                            "name": nameController.text,
                            "account": accountController.text,
                            "amount": int.tryParse(amountController.text) ?? 0,
                            "due_date": dueDateController.text,
                            "cycle": selectedCycle,
                          },
                          token,
                        );

                        Navigator.pop(context);
                      },
                      child: const Text("Update Bill"),
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// DELETE
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () async {
                        await context.read<BillProvider>().deleteBill(
                          item["id"],
                          token,
                        );

                        Navigator.pop(context);
                      },
                      child: const Text("Delete"),
                    ),
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

/// FIELD HELPER
Widget _field(
    String label,
    TextEditingController controller, {
      bool isNumber = false,
      VoidCallback? onTap,
    }) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 15),
      Text(label),
      const SizedBox(height: 6),
      TextField(
        controller: controller,
        readOnly: onTap != null,
        onTap: onTap,
        keyboardType:
        isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFF1F1F1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    ],
  );
}