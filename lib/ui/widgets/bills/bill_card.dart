import 'package:flutter/material.dart';

class BillCard extends StatelessWidget {
  final String title;
  final String amount;
  final bool isPaid;
  final VoidCallback? onTap;
  final VoidCallback? onPay;

  const BillCard({
    super.key,
    required this.title,
    required this.amount,
    required this.isPaid,
    this.onTap,
    this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              blurRadius: 6,
              color: Colors.black12,
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: const Color(0xFFD5CEF5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.attach_money,
                color: Color(0xFF694EDA),
                size: 18,
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF694EDA),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amount,
                  style: const TextStyle(
                    color: Color(0xFF694EDA),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),

                GestureDetector(
                  onTap: isPaid ? null : onPay,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isPaid
                          ? Colors.grey
                          : const Color(0xFF694EDA),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isPaid ? "Done" : "Pay Now",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}