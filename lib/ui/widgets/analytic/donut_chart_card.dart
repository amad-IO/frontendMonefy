import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../models/analytic/analytic_models.dart';
import '../../../utils/currency_formatter.dart';
import 'analytic_card_wrapper.dart';

/// Donut chart with total in center + legend on the right
class DonutChartCard extends StatelessWidget {
  final double totalAmount;
  final List<CategoryBreakdown> categories;

  /// true = mode Expense, false = mode Income.
  final bool isExpense;

  const DonutChartCard({
    super.key,
    required this.totalAmount,
    required this.categories,
    this.isExpense = true,
  });

  @override
  Widget build(BuildContext context) {
    return AnalyticCardWrapper(
      child: Row(
        children: [
          // Donut chart
          SizedBox(
            width: 160,
            height: 160,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 3,
                    centerSpaceRadius: 50,
                    sections: _buildSections(),
                    startDegreeOffset: -90,
                  ),
                ),
                // Center label
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isExpense ? 'Total Expense' : 'Total Income',
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 11,
                        color: Color(0xFF9E9E9E),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      rupiahFormatter.format(totalAmount),
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1C1C1E),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Legend
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: categories.map((cat) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: cat.color,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          cat.name,
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 12,
                            color: Color(0xFF525252),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${cat.percentage.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF525252),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildSections() {
    if (categories.isEmpty) {
      return [
        PieChartSectionData(
          value: 1,
          color: const Color(0xFFE0E0E0),
          radius: 22,
          title: '',
          showTitle: false,
        )
      ];
    }

    return categories.map((cat) {
      return PieChartSectionData(
        value: cat.percentage,
        color: cat.color,
        radius: 22,
        title: '',
        showTitle: false,
      );
    }).toList();
  }
}
