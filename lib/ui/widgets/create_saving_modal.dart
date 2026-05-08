import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

void showCreateSavingModal(
    BuildContext context,
    Function(String name, int amount) onCreate,
    ) {
  final nameController = TextEditingController();
  final amountController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(30),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// HANDLE
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// TITLE
                const Text(
                  "Create Saving",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryPurple,
                  ),
                ),

                const SizedBox(height: 20),

                /// GOAL NAME
                const Text(
                  "Goal Name",
                  style: TextStyle(color: AppColors.primaryPurple),
                ),
                const SizedBox(height: 6),

                TextFormField(
                  controller: nameController,
                  validator: (v) =>
                  v == null || v.isEmpty ? "Tidak boleh kosong" : null,
                  decoration: InputDecoration(
                    hintText: "e.g., Beli Laptop",
                    filled: true,
                    fillColor: const Color(0xFFF6F7FB),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                /// TARGET AMOUNT
                const Text(
                  "Target Amount",
                  style: TextStyle(color: AppColors.primaryPurple),
                ),
                const SizedBox(height: 6),

                TextFormField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  validator: (v) =>
                  v == null || v.isEmpty ? "Tidak boleh kosong" : null,
                  decoration: InputDecoration(
                    hintText: "e.g., 5000000 / 5.000.000",
                    filled: true,
                    fillColor: const Color(0xFFF6F7FB),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                /// BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {
                      if (!formKey.currentState!.validate()) return;

                      final name = nameController.text.trim();

                      /// BERSIHIN INPUT ANGKA
                      final raw = amountController.text
                          .replaceAll('.', '')
                          .replaceAll('Rp', '')
                          .replaceAll(' ', '');

                      final amount = int.tryParse(raw) ?? 0;

                      /// VALIDASI ANGKA
                      if (amount <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Masukkan angka yang valid"),
                          ),
                        );
                        return;
                      }

                      /// DEBUG (opsional)
                      print("CREATE SAVING: $name - $amount");

                      /// 🔥 KIRIM DATA
                      onCreate(name, amount);

                      /// TUTUP MODAL
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Create Saving",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      );
    },
  );
}