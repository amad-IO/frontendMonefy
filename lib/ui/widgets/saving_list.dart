import 'package:flutter/material.dart';

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
        color: Colors.white,
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
              color: Color(0xFF694EDA),
            ),
            child: const Icon(
              Icons.attach_money,
              color: Colors.white,
              size: 28,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF694EDA),
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
            style: TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFD2D4D6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 30, color: Color(0xFF694EDA)),
            SizedBox(height: 8),
            Text("Create saving"),
          ],
        ),
      ),
    );
  }
}