import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'saving_detail_dialog.dart';

class SavingList extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final VoidCallback? onCreateTap;

  const SavingList({
    super.key,
    this.items = const [],
    this.onCreateTap,
  });

  @override
  State<SavingList> createState() => _SavingListState();
}

class _SavingListState extends State<SavingList> {
  bool isDone = false;

  @override
  Widget build(BuildContext context) {
    final filteredItems = widget.items.where((item) {
      return item["isDone"] == isDone;
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 10),

          /// TOP BAR (Add Wishlist + Toggle)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildToggle(),
              _buildAddButton(),
            ],
          ),

          const SizedBox(height: 16),

          /// LIST
          Expanded(
            child: ListView.builder(
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final item = filteredItems[index];
                return _buildItem(context, item);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// =========================
  /// TOGGLE (Figma style)
  /// =========================
  Widget _buildToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0x33694EDA),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _buildTab("Ongoing", !isDone, () {
            setState(() => isDone = false);
          }),
          _buildTab("Done", isDone, () {
            setState(() => isDone = true);
          }),
        ],
      ),
    );
  }

  Widget _buildTab(String text, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: AppColors.primaryPurple,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// =========================
  /// ADD WISHLIST BUTTON
  /// =========================
  Widget _buildAddButton() {
    return GestureDetector(
      onTap: widget.onCreateTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFD5CEF5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: const [
            Icon(Icons.add, size: 14, color: AppColors.primaryPurple),
            SizedBox(width: 6),
            Text(
              "Add Wishlist",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryPurple,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// =========================
  /// ITEM CARD (Figma style)
  /// =========================
  Widget _buildItem(BuildContext context, Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          barrierColor: Colors.black.withOpacity(0.3),
          builder: (_) => SavingDetailDialog(saving: item),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            /// ICON BOX
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFD5CEF5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.attach_money,
                color: AppColors.primaryPurple,
              ),
            ),

            const SizedBox(width: 12),

            /// TITLE
            Expanded(
              child: Text(
                item["name"],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.primaryPurple,
                ),
              ),
            ),

            /// PRICE
            Text(
              "Rp${item["target"]}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryPurple,
              ),
            ),

            const SizedBox(width: 10),

            /// BUY BUTTON
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryPurple,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                "Buy",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}