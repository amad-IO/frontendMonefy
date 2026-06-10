import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/saving_provider.dart';

void showSavingDetailModal(
    BuildContext context,
    Map<String, dynamic> item,
    ) {
  final token = context.read<AuthProvider>().token!;

  final nameController = TextEditingController(text: item["name"]);
  final targetController =
  TextEditingController(text: item["target"].toString());

  /// 🔥 TAMBAHAN DATE
  DateTime? selectedDate =
  item["date"] != null ? DateTime.tryParse(item["date"]) : null;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return StatefulBuilder( // 🔥 biar date bisa update UI
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

                  /// TITLE
                  const Text(
                    "Edit Saving",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF694EDA),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// GOAL NAME
                  const Text("Goal Name"),
                  const SizedBox(height: 6),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: "e.g. Beli Laptop",
                      filled: true,
                      fillColor: const Color(0xFFF1F1F1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  /// TARGET AMOUNT
                  const Text("Target Amount"),
                  const SizedBox(height: 6),
                  TextField(
                    controller: targetController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "e.g. 5000000",
                      filled: true,
                      fillColor: const Color(0xFFF1F1F1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  /// 🔥 TARGET DATE (TAMBAHAN)
                  const Text("Target Date"),
                  const SizedBox(height: 6),

                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );

                      if (picked != null) {
                        setState(() {
                          selectedDate = picked;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F1F1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedDate != null
                                ? "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"
                                : "Pilih tanggal",
                          ),
                          const Text(
                            "Pilih",
                            style: TextStyle(color: Color(0xFF694EDA)),
                          )
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// UPDATE BUTTON
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
                        final name = nameController.text.trim();
                        final target =
                            int.tryParse(targetController.text) ?? 0;

                        if (name.isEmpty || target <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Isi data dengan benar")),
                          );
                          return;
                        }

                        await context.read<SavingProvider>().updateSavingApi(
                          item["id"],
                          name,
                          target,
                          selectedDate?.toIso8601String(), // 🔥 kirim date
                          token,
                        );

                        Navigator.pop(context);
                      },
                      child: const Text("Update Saving"),
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// DELETE BUTTON
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
                        await context.read<SavingProvider>()
                            .deleteSavingApi(item["id"], token);

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