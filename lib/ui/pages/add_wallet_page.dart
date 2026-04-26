import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../widgets/input_add_wallet.dart';

class AddWalletPage extends StatelessWidget {
  AddWalletPage({super.key});

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔥 HEADER
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    const Expanded(
                      child: Text(
                        "Add New Wallet",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryPurple,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // balance biar center
                  ],
                ),

                const SizedBox(height: 20),

                const Text(
                  "Wallet Details",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryPurple,
                  ),
                ),

                const SizedBox(height: 16),

                // Wallet Name
                InputAddWallet(
                  label: "Wallet Name",
                  hint: "e.g., BCA, GoPay, Cash",
                  isTextOnly: true,
                ),

                // Initial Balance
                InputAddWallet(
                  label: "Initial Balance",
                  hint: "0",
                  isNumber: true,
                ),

                const SizedBox(height: 24),

                // 🔥 BUTTON SIMPAN
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.pop(context); // balik setelah simpan
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryPurple,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Simpan",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}