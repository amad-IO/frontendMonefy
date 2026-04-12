import 'package:flutter/material.dart';

class SavingCard extends StatelessWidget {
  const SavingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, //FULL WIDTH
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7FB),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            offset: const Offset(0, 6),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center, //tengah
        children: const [
          Text(
            'Total Saving',
            style: TextStyle(
              color: Color(0xFF694EDA),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Rp. 5.000.000,00',
            style: TextStyle(
              color: Color(0xFF694EDA),
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}