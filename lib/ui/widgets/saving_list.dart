import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'saving_detail_dialog.dart';

class SavingList extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final VoidCallback? onCreateTap;

  const SavingList({
    super.key,
    this.items = const [],
    this.onCreateTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        padding: const EdgeInsets.only(bottom: 80),

        /// SELALU TAMBAH 1 (untuk create card)
        itemCount: items.length + 1,

        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.05,
        ),

        itemBuilder: (context, index) {
          /// CARD CREATE
          if (index == items.length) {
            return _buildCreateCard();
          }

          final item = items[index];

          return _buildItem(
            context: context,
            item: item, // 🔥 kirim full item
          );
        },
      ),
    );
  }

  /// 🔥 ITEM CARD (FIXED)
  Widget _buildItem({
    required BuildContext context,
    required Map<String, dynamic> item,
  }) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          barrierColor: Colors.black.withValues(alpha: 0.3), // 🔥 fix warning
          builder: (context) {
            return SavingDetailDialog(
              saving: item, // 🔥 kirim langsung semua data
            );
          },
        );
      },

      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.panelWhite,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
            )
          ],
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.attach_money,
              size: 28,
              color: AppColors.primaryPurple,
            ),

            const SizedBox(height: 10),

            Text(
              item["name"],
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 5),

            Text(
              "Rp. ${item["amount"]}",
              style: const TextStyle(
                color: AppColors.primaryPurple,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(
              "of Rp. ${item["target"]}",
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  /// ➕ CREATE CARD
  Widget _buildCreateCard() {
    return GestureDetector(
      onTap: onCreateTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardMuted,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, size: 30, color: AppColors.primaryPurple),
              SizedBox(height: 8),
              Text(
                "Create saving",
                style: TextStyle(color: AppColors.primaryPurple),
              ),
            ],
          ),
        ),
      ),
    );
  }
}