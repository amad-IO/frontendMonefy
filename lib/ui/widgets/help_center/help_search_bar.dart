import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class HelpSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const HelpSearchBar({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: AppColors.lightShadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        onChanged: onChanged,
        decoration: const InputDecoration(
          hintText: "Cari pertanyaan Anda...",
          hintStyle: TextStyle(color: Colors.grey, fontFamily: 'Nunito'),
          prefixIcon: Icon(Icons.search, color: AppColors.primaryPurple),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}