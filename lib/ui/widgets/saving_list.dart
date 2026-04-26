import 'package:flutter/material.dart';
import '../../theme/colors.dart';

class SavingList extends StatelessWidget {
  const SavingList({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      "Phone",
      "Car",
      "Laptop",
      "Watch",
      "Watch",
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        itemCount: items.length + 1,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.1,
        ),
        itemBuilder: (context, index) {
          if (index == items.length) {
            return _buildCreateCard();
          }
          return _buildItem(items[index]);
        },
      ),
    );
  }

  Widget _buildItem(String title) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.panelWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ICON BULAT
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryPurple,
            ),
            child: const Icon(
              Icons.attach_money,
              color: AppColors.panelWhite,
              size: 28,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            title,
            style: const TextStyle(
              color: AppColors.primaryPurple,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            "1.000.000,00",
            style: TextStyle(fontSize: 12),
          ),

          const SizedBox(height: 2),

          const Text(
            "of 1.000.000 saving",
            style: TextStyle(fontSize: 10, color: AppColors.disabled),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardMuted,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 30, color: AppColors.primaryPurple),
            SizedBox(height: 8),
            Text("Create saving"),
          ],
        ),
      ),
    );
  }
}