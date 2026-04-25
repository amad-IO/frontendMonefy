import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../theme/colors.dart';
import 'analytic_filter_tabs.dart';

/// Period selector yang berubah label-nya sesuai [AnalyticPeriod]:
///   • Weekly  → "Week 1, Apr 2026  (21 Apr - 27 Apr)"
///   • Monthly → "April 2026  (1 Apr - 30 Apr)"
///   • Yearly  → "2026  (1 Jan - 31 Dec)"
class PeriodSelector extends StatelessWidget {
  final AnalyticPeriod period;
  final DateTime anchorDate;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const PeriodSelector({
    super.key,
    required this.period,
    required this.anchorDate,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final (title, subtitle) = _buildLabels();

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

          // Title + subtitle
          Column(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
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

  /// Menghasilkan (title, subtitle) sesuai period.
  (String, String) _buildLabels() {
    switch (period) {
      case AnalyticPeriod.weekly:
        final weekStart = anchorDate.subtract(
          Duration(days: anchorDate.weekday - 1),
        );
        final weekEnd = weekStart.add(const Duration(days: 6));
        // Hitung minggu ke berapa dalam bulan
        final weekNum = ((weekStart.day - 1) / 7).floor() + 1;
        final title = 'Week $weekNum, ${DateFormat('MMM yyyy').format(weekStart)}';
        final sub =
            '(${DateFormat('d MMM').format(weekStart)} - ${DateFormat('d MMM').format(weekEnd)})';
        return (title, sub);

      case AnalyticPeriod.monthly:
        final firstDay = DateTime(anchorDate.year, anchorDate.month, 1);
        final lastDay = DateTime(anchorDate.year, anchorDate.month + 1, 0);
        final title = DateFormat('MMMM yyyy').format(anchorDate);
        final sub =
            '(${DateFormat('d MMM').format(firstDay)} - ${DateFormat('d MMM').format(lastDay)})';
        return (title, sub);

      case AnalyticPeriod.yearly:
        final title = '${anchorDate.year}';
        final sub = '(1 Jan - 31 Dec)';
        return (title, sub);
    }
  }
}
