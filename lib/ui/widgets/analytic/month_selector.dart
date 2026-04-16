import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../theme/colors.dart';

/// Month selector: ← April 2026 → with date range subtitle
class MonthSelector extends StatelessWidget {
  final DateTime currentMonth;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const MonthSelector({
    super.key,
    required this.currentMonth,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final monthName = DateFormat('MMMM yyyy').format(currentMonth);
    final firstDay = DateTime(currentMonth.year, currentMonth.month, 1);
    final lastDay = DateTime(currentMonth.year, currentMonth.month + 1, 0);
    final rangeText =
        '(${DateFormat('d MMM').format(firstDay)} - ${DateFormat('d MMM').format(lastDay)})';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Left arrow
          GestureDetector(
            onTap: onPrevious,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primaryPurple.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chevron_left_rounded,
                color: AppColors.primaryPurple,
                size: 22,
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Month + range
          Column(
            children: [
              Text(
                monthName,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                rangeText,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(width: 16),

          // Right arrow
          GestureDetector(
            onTap: onNext,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primaryPurple.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.primaryPurple,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
