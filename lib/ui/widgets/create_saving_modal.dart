import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

void showCreateSavingModal(
    BuildContext context,
    Function(String name, int amount, String date) onCreate,
    ) {
  final nameController = TextEditingController();
  final amountController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  String selectedDate = "";

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
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

                    /// NAME
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

                    /// TARGET
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
                        hintText: "e.g., 5000000",
                        filled: true,
                        fillColor: const Color(0xFFF6F7FB),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// DATE PICKER
                    const Text(
                      "Target Date",
                      style: TextStyle(color: AppColors.primaryPurple),
                    ),
                    const SizedBox(height: 6),

                    Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            color: AppColors.primaryPurple),
                        const SizedBox(width: 10),

                        Expanded(
                          child: Text(
                            selectedDate.isEmpty
                                ? "Pilih tanggal"
                                : selectedDate,
                          ),
                        ),

                        TextButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );

                            if (picked != null) {
                              setState(() {
                                selectedDate =
                                picked.toString().split(" ")[0];
                              });
                            }
                          },
                          child: const Text("Pilih"),
                        ),
                      ],
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

                          final raw = amountController.text
                              .replaceAll('.', '')
                              .replaceAll('Rp', '')
                              .replaceAll(' ', '');

                          final amount = int.tryParse(raw) ?? 0;

                          if (amount <= 0 || selectedDate.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Lengkapi semua data"),
                              ),
                            );
                            return;
                          }

                          /// KIRIM DATA
                          onCreate(name, amount, selectedDate);

                          Navigator.pop(context);
                        },
                        child: const Text("Create Wishlist"),
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
    },
  );
}