import 'package:flutter/material.dart';

/// Alert card showing expense change percentage from last month.
/// Green if expenses went down, red if up.
class ExpenseAlertCard extends StatelessWidget {
  final double changePercent;

  const ExpenseAlertCard({
    super.key,
    required this.changePercent,
  });

  @override
  Widget build(BuildContext context) {
    final isUp = changePercent >= 0;
    final bgColor = isUp ? const Color(0xFFFDE8EC) : const Color(0xFFE8F5E9);
    final textColor = isUp ? const Color(0xFFE53935) : const Color(0xFF2E7D32);
    final icon = isUp ? Icons.trending_up_rounded : Icons.trending_down_rounded;
    final label = isUp
        ? 'Expenses up ${changePercent.toStringAsFixed(1)}% from last Month'
        : 'Expenses down ${changePercent.abs().toStringAsFixed(1)}% from last Month';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: textColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: textColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
