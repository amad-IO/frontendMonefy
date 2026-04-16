import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../models/analytic_model.dart';

/// Monthly comparison card with area chart + daily avg & projected total
class MonthlyComparisonCard extends StatelessWidget {
  final MonthlyComparison data;

  const MonthlyComparisonCard({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    final isUp = data.percentageChange >= 0;
    final badgeColor = isUp ? const Color(0xFFFDE8EC) : const Color(0xFFE8F5E9);
    final badgeTextColor = isUp ? const Color(0xFFE53935) : const Color(0xFF2E7D32);
    final badgeIcon = isUp ? Icons.trending_up_rounded : Icons.trending_down_rounded;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Monthly Comparison',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1C1C1E),
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
                        '${data.percentageChange.toStringAsFixed(1)}%',
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
                color: Color(0xFF9E9E9E),
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
                          color: Color(0xFF9E9E9E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatter.format(data.dailyAverage),
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1C1C1E),
                        ),
                      ),
                    ],
                  ),
                ),

                // Divider
                Container(
                  width: 1,
                  height: 40,
                  color: const Color(0xFFEEEEEE),
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
                            color: Color(0xFF9E9E9E),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formatter.format(data.projectedTotal),
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1C1C1E),
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
                const Expanded(
                  child: Text(
                    'Based on your spending habits so far this month.',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 11,
                      color: Color(0xFF9E9E9E),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  LineChartData _buildAreaChart() {
    final spots = <FlSpot>[];
    for (int i = 0; i < data.thisMonthDaily.length; i++) {
      spots.add(FlSpot(i.toDouble(), data.thisMonthDaily[i]));
    }

    final maxY = data.thisMonthDaily.isEmpty
        ? 100.0
        : data.thisMonthDaily.reduce((a, b) => a > b ? a : b) * 1.3;

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: maxY / 4,
        getDrawingHorizontalLine: (value) => FlLine(
          color: const Color(0xFFF5F5F5),
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
                    color: Color(0xFF9E9E9E),
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
          color: const Color(0xFFE53935),
          barWidth: 2.5,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: const Color(0xFFE53935).withValues(alpha: 0.12),
          ),
        ),
      ],
      lineTouchData: LineTouchData(enabled: false),
    );
  }
}
