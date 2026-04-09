import 'package:flutter/material.dart';

class TransactionItem extends StatelessWidget {
  final String title;
  final String date;
  final String amount;
  final String payment;
  final bool isIncome;

  const TransactionItem({
    super.key,
    required this.title,
    required this.date,
    required this.amount,
    required this.payment,
    required this.isIncome,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: Row(
        children: [
          // 🔽 ICON
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isIncome
                  ? Colors.green.withOpacity(0.15)
                  : Colors.red.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isIncome ? Icons.arrow_downward : Icons.arrow_upward,
              color: isIncome ? Colors.green : Colors.red,
              size: 18,
            ),
          ),

          const SizedBox(width: 12),

          // 📄 TITLE + DATE
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4A4A4A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF9E9E9E),
                  ),
                ),
              ],
            ),
          ),

          // 💰 AMOUNT + PAYMENT
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isIncome ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                payment,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF9E9E9E),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}