import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/colors.dart';

class InputAddWallet extends StatelessWidget {
  final String label;
  final String hint;
  final bool isNumber; // untuk initial balance
  final bool isTextOnly; // untuk saving list

  const InputAddWallet({
    super.key,
    required this.label,
    required this.hint,
    this.isNumber = false,
    this.isTextOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 6),
          TextFormField(
            keyboardType:
            isNumber ? TextInputType.number : TextInputType.text,

            inputFormatters: [
              if (isNumber)
                FilteringTextInputFormatter.digitsOnly,
              if (isTextOnly)
                FilteringTextInputFormatter.allow(
                    RegExp(r'[a-zA-Z\s,]')),
            ],

            validator: (value) {
              if (value == null || value.isEmpty) {
                return '$label tidak boleh kosong';
              }

              if (isTextOnly && RegExp(r'[0-9]').hasMatch(value)) {
                return 'Tidak boleh mengandung angka';
              }

              if (isNumber &&
                  !RegExp(r'^[0-9]+$').hasMatch(value)) {
                return 'Harus berupa angka';
              }

              return null;
            },

            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: AppColors.white2,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}