import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/saving_provider.dart';

class SavingDetailDialog extends StatelessWidget {
  final Map saving;

  const SavingDetailDialog({super.key, required this.saving});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<SavingProvider>();

    return Stack(
      children: [
        /// BLUR BACKGROUND
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(color: Colors.transparent),
        ),

        /// POPUP
        Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F7FC),
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 15,
                )
              ],
            ),

            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// TITLE
                Text(
                  saving["name"],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),

                const SizedBox(height: 16),

                /// AMOUNT
                Row(
                  children: [
                    const Icon(Icons.attach_money, color: Colors.deepPurple),
                    const SizedBox(width: 8),
                    Text("Rp ${saving["amount"]}"),
                  ],
                ),

                const SizedBox(height: 10),

                /// TARGET
                Row(
                  children: [
                    const Icon(Icons.flag, color: Colors.deepPurple),
                    const SizedBox(width: 8),
                    Text("Target: Rp ${saving["target"] ?? "-"}"),
                  ],
                ),

                const SizedBox(height: 10),

                /// DATE
                Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.deepPurple),
                    const SizedBox(width: 8),
                    Text(saving["date"] ?? "-"),
                  ],
                ),

                const SizedBox(height: 20),

                /// BUTTONS
                Row(
                  children: [

                    /// ✏EDIT
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          _showEditDialog(context);
                        },
                        child: const Text("Edit"),
                      ),
                    ),

                    const SizedBox(width: 10),

                    /// 🗑DELETE
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () {
                          provider.deleteSaving(saving["id"]);
                          Navigator.pop(context);
                        },
                        child: const Text("Hapus"),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// EDIT DIALOG
  void _showEditDialog(BuildContext context) {
    final provider = context.read<SavingProvider>();

    final nameController =
    TextEditingController(text: saving["name"]);
    final targetController =
    TextEditingController(text: saving["target"].toString());

    String selectedDate = saving["date"];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Wishlist"),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  TextField(
                    controller: nameController,
                    decoration:
                    const InputDecoration(labelText: "Nama"),
                  ),

                  TextField(
                    controller: targetController,
                    keyboardType: TextInputType.number,
                    decoration:
                    const InputDecoration(labelText: "Target"),
                  ),

                  const SizedBox(height: 10),

                  /// DATE
                  Row(
                    children: [
                      const Icon(Icons.calendar_today),
                      const SizedBox(width: 10),
                      Text(selectedDate),
                      const Spacer(),
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
                        child: const Text("Ubah"),
                      )
                    ],
                  )
                ],
              );
            },
          ),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),

            ElevatedButton(
              onPressed: () {
                provider.updateSaving(
                  provider.savings.firstWhere(
                        (e) => e.id == saving["id"],
                  ).copyWith(
                    name: nameController.text,
                    target:
                    int.tryParse(targetController.text) ?? 0,
                    date: selectedDate,
                  ),
                );

                Navigator.pop(context);
              },
              child: const Text("Simpan"),
            )
          ],
        );
      },
    );
  }
}