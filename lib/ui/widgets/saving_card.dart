import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class SavingCard extends StatelessWidget {
  final int? total;

  const SavingCard({super.key, this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.white2,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 6),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Total Saving',
            style: TextStyle(
              color: AppColors.primaryPurple,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),

          /// 🔥 KALAU BELUM ADA DATA
          Text(
            total == null ? "-" : "Rp. $total",
            style: const TextStyle(
              color: AppColors.primaryPurple,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}