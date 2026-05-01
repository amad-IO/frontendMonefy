import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class SavingList extends StatelessWidget {
  final List<Map<String, dynamic>> items;

  const SavingList({
    super.key,
    this.items = const [], // 🔥 default kosong
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        itemCount: items.isEmpty ? 1 : items.length + 1,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.1,
        ),
        itemBuilder: (context, index) {
          /// 🔥 KALAU BELUM ADA DATA
          if (items.isEmpty) {
            return _buildCreateCard();
          }

          /// 🔥 CARD TAMBAH
          if (index == items.length) {
            return _buildCreateCard();
          }

          final item = items[index];

          return _buildItem(
            title: item['name'],
            amount: item['amount'],
            target: item['target'],
          );
        },
      ),
    );
  }

  Widget _buildItem({
    required String title,
    required int amount,
    required int target,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.panelWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.attach_money, size: 30),
          const SizedBox(height: 10),
          Text(title),
          Text("Rp. $amount"),
          Text("of Rp. $target"),
        ],
      ),
    );
  }

  Widget _buildCreateCard() {
    return Container(
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
            Text("Create saving"),
          ],
        ),
      ),
    );
  }
}