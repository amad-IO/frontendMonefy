import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../models/analytic/analytic_models.dart';
import '../../../utils/currency_formatter.dart';
import '../../../utils/sentiment_helper.dart';
import '../../../theme/colors.dart';
import 'analytic_card_wrapper.dart';

/// Period comparison card with area chart + daily avg & projected total.
///
/// Sebelumnya bernama MonthlyComparisonCard, sekarang mendukung
/// perbandingan weekly, monthly, dan yearly.
class MonthlyComparisonCard extends StatelessWidget {
  final PeriodComparison data;

  /// true = mode Expense, false = mode Income.
  final bool isExpense;

  const MonthlyComparisonCard({
    super.key,
    required this.data,
    this.isExpense = true,
  });

  @override
  Widget build(BuildContext context) {
    final isUp = data.percentageChange >= 0;

    // ── Gunakan sentiment helper (shared utility) ──────────
    final positive = isPositiveSentiment(isExpense: isExpense, isUp: isUp);
    final badgeColor = sentimentBgColor(positive);
    final badgeTextColor = sentimentColor(positive);
    final badgeIcon = isUp
        ? Icons.trending_up_rounded
        : Icons.trending_down_rounded;

    return AnalyticCardWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Period Comparison',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),

              // Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(badgeIcon, size: 14, color: badgeTextColor),
                    const SizedBox(width: 3),
                    Text(
                      data.percentageChange.isInfinite
                          ? 'New'
                          : '${data.percentageChange.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: badgeTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          Text(
            data.message,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 12,
              color: AppColors.disabled,
            ),
          ),

          const SizedBox(height: 16),

          // Area chart
          SizedBox(
            height: 140,
            child: LineChart(_buildAreaChart()),
          ),

          const SizedBox(height: 16),

          // Daily Average | Projected Total
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Daily Average',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12,
                        color: AppColors.disabled,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      rupiahFormatter.format(data.dailyAverage),
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              // Divider
              Container(
                width: 1,
                height: 40,
                color: AppColors.divider,
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Projected Total',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 12,
                          color: AppColors.disabled,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        rupiahFormatter.format(data.projectedTotal),
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Info text
          Row(
            children: [
              Icon(Icons.info_outline_rounded,
                  size: 16, color: Colors.grey.shade400),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  isExpense
                      ? 'Based on your spending habits so far.'
                      : 'Based on your earning patterns so far.',
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 11,
                    color: AppColors.disabled,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  LineChartData _buildAreaChart() {
    final spots = <FlSpot>[];
    for (int i = 0; i < data.currentPeriodDaily.length; i++) {
      spots.add(FlSpot(i.toDouble(), data.currentPeriodDaily[i]));
    }

    final maxVal = data.currentPeriodDaily.isEmpty
        ? 100.0
        : data.currentPeriodDaily.reduce((a, b) => a > b ? a : b);
    final maxY = maxVal > 0 ? maxVal * 1.3 : 100.0;

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: maxY / 4,
        getDrawingHorizontalLine: (value) => FlLine(
          color: AppColors.neutralBg,
          strokeWidth: 1,
        ),
      ),
      titlesData: FlTitlesData(
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: (spots.length / 4).ceilToDouble().clamp(1, 10),
            getTitlesWidget: (value, meta) {
              final idx = value.toInt();
              if (idx < 0 || idx >= spots.length) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  '${idx + 1}',
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 10,
                    color: AppColors.disabled,
                  ),
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: spots.isEmpty ? 1 : (spots.length - 1).toDouble(),
      minY: 0,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: false,
          // Merah untuk expense, hijau untuk income
          color: isExpense
              ? AppColors.expenseRed
              : AppColors.incomeGreen,
          barWidth: 2.5,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: isExpense
                ? AppColors.expenseRed.withValues(alpha: 0.12)
                : AppColors.incomeGreen.withValues(alpha: 0.12),
          ),
        ),
      ],
      lineTouchData: LineTouchData(enabled: false),
    );
  }
}
