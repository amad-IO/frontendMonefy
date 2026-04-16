import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../models/analytic_model.dart';
import '../../../theme/colors.dart';

/// Daily overview section with line chart + daily averages
class DailyOverviewCard extends StatelessWidget {
  final List<DailyDataPoint> dailyData;
  final double avgIncome;
  final double avgExpense;
  final double avgSaving;

  const DailyOverviewCard({
    super.key,
    required this.dailyData,
    required this.avgIncome,
    required this.avgExpense,
    required this.avgSaving,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

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
            // Title
            const Text(
              'Daily Overview',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1C1C1E),
              ),
            ),

            const SizedBox(height: 16),

            // Line chart
            SizedBox(
              height: 180,
              child: LineChart(_buildChart()),
            ),

            const SizedBox(height: 12),

            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _legendDot(const Color(0xFF4CAF50), 'Income'),
                const SizedBox(width: 20),
                _legendDot(const Color(0xFFE53935), 'Expense'),
                const SizedBox(width: 20),
                _legendDot(AppColors.primaryPurple, 'Goals'),
              ],
            ),

            const SizedBox(height: 16),

            // Averages
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Avg Inc: ${formatter.format(avgIncome)}',
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                    Text(
                      'Avg Exp: ${formatter.format(avgExpense)}',
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFE53935),
                      ),
                    ),
                    Text(
                      'Avg Sav: ${formatter.format(avgSaving)}',
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryPurple,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 12,
            color: Color(0xFF525252),
          ),
        ),
      ],
    );
  }

  LineChartData _buildChart() {
    if (dailyData.isEmpty) {
      return LineChartData(lineBarsData: []);
    }

    // Normalize data for chart
    final maxVal = dailyData.fold<double>(0, (prev, e) {
      final m = [e.income, e.expense, e.saving]
          .reduce((a, b) => a > b ? a : b);
      return m > prev ? m : prev;
    });
    final double maxY = maxVal > 0 ? maxVal * 1.2 : 100.0;

    return LineChartData(
      gridData: FlGridData(
        show: true,
        horizontalInterval: maxY / 4,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) => FlLine(
          color: const Color(0xFFEEEEEE),
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
            interval: (dailyData.length / 6).ceilToDouble().clamp(1, 7),
            getTitlesWidget: (value, meta) {
              final idx = value.toInt();
              if (idx < 0 || idx >= dailyData.length) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  '${dailyData[idx].date.day}',
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
      maxX: (dailyData.length - 1).toDouble(),
      minY: 0,
      maxY: maxY,
      lineBarsData: [
        // Income line
        _buildLine(
          dailyData.map((e) => e.income).toList(),
          const Color(0xFF4CAF50),
        ),
        // Expense line (dashed)
        _buildLine(
          dailyData.map((e) => e.expense).toList(),
          const Color(0xFFE53935),
          isDashed: true,
        ),
        // Saving line
        _buildLine(
          dailyData.map((e) => e.saving).toList(),
          AppColors.primaryPurple,
        ),
      ],
      lineTouchData: LineTouchData(enabled: false),
    );
  }

  LineChartBarData _buildLine(
    List<double> values,
    Color color, {
    bool isDashed = false,
  }) {
    return LineChartBarData(
      spots: List.generate(
        values.length,
        (i) => FlSpot(i.toDouble(), values[i]),
      ),
      isCurved: true,
      curveSmoothness: 0.3,
      color: color,
      barWidth: 2,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      dashArray: isDashed ? [6, 4] : null,
      belowBarData: BarAreaData(show: false),
    );
  }
}
