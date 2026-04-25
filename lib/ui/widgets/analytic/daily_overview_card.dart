import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../models/analytic/analytic_models.dart';
import '../../../utils/currency_formatter.dart';
import '../../../theme/colors.dart';
import 'analytic_card_wrapper.dart';
import 'analytic_filter_tabs.dart';

/// ══════════════════════════════════════════════════════════════
/// Overview card yang berubah sesuai [AnalyticPeriod]:
///
///   • Weekly  → "Weekly Overview"  — 7 bar (M, T, W, T, F, S, S)
///   • Monthly → "Daily Overview"   — 28-31 bar, scrollable
///   • Yearly  → "Monthly Overview" — 12 bar (Jan - Dec)
///
/// Chart menggunakan grouped bar chart (Income, Expense, Goals).
/// ══════════════════════════════════════════════════════════════
class DailyOverviewCard extends StatelessWidget {
  final AnalyticPeriod period;
  final List<DailyDataPoint> dailyData;
  final double avgIncome;
  final double avgExpense;
  final double avgSaving;

  const DailyOverviewCard({
    super.key,
    required this.period,
    required this.dailyData,
    required this.avgIncome,
    required this.avgExpense,
    required this.avgSaving,
  });

  // ── Warna bar ────────────────────────────────────────────
  static const _incomeColor = Color(0xFF4CAF50);
  static const _expenseColor = Color(0xFFE53935);
  static final _savingColor = AppColors.primaryPurple;

  // ── Title sesuai period ──────────────────────────────────
  String get _title {
    switch (period) {
      case AnalyticPeriod.weekly:
        return 'Weekly Overview';
      case AnalyticPeriod.monthly:
        return 'Daily Overview';
      case AnalyticPeriod.yearly:
        return 'Monthly Overview';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnalyticCardWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: Title + Averages ──────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _title,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1C1C1E),
                ),
              ),
              const Spacer(),
              // Averages (di kanan atas)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _avgText('Avg Inc:', avgIncome, _incomeColor),
                  _avgText('Avg Exp:', avgExpense, _expenseColor),
                  _avgText('Avg Sav:', avgSaving, _savingColor),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Chart ────────────────────────────────────────
          _buildChartArea(),

          const SizedBox(height: 12),

          // ── Legend ───────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendDot(_incomeColor, 'Income'),
              const SizedBox(width: 20),
              _legendDot(_expenseColor, 'Expense'),
              const SizedBox(width: 20),
              _legendDot(_savingColor, 'Goals'),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  Chart area — scrollable untuk monthly
  // ═══════════════════════════════════════════════════════════

  Widget _buildChartArea() {
    final barData = _prepareBarData();
    final maxY = _getMaxY(barData);

    // Lebar chart: monthly butuh scroll, yang lain tidak
    final double chartWidth;
    switch (period) {
      case AnalyticPeriod.weekly:
        chartWidth = double.infinity; // fit container
        break;
      case AnalyticPeriod.monthly:
        // Setiap group 28px lebar, minimal 30 hari
        chartWidth = (barData.length * 28.0).clamp(300, 900);
        break;
      case AnalyticPeriod.yearly:
        chartWidth = double.infinity; // fit container
        break;
    }

    final chart = SizedBox(
      height: 180,
      width: chartWidth == double.infinity ? null : chartWidth,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          barTouchData: BarTouchData(enabled: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY > 0 ? maxY / 4 : 25,
            getDrawingHorizontalLine: (value) => FlLine(
              color: const Color(0xFFF0F0F0),
              strokeWidth: 1,
              dashArray: [5, 5],
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: _getBottomLabel,
                reservedSize: 28,
              ),
            ),
          ),
          barGroups: barData,
        ),
      ),
    );

    // Monthly → scrollable horizontal
    if (period == AnalyticPeriod.monthly) {
      return SizedBox(
        height: 180,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: chart,
        ),
      );
    }

    return chart;
  }

  // ═══════════════════════════════════════════════════════════
  //  Prepare bar data sesuai period
  // ═══════════════════════════════════════════════════════════

  List<BarChartGroupData> _prepareBarData() {
    switch (period) {
      case AnalyticPeriod.weekly:
        return _weeklyBars();
      case AnalyticPeriod.monthly:
        return _monthlyBars();
      case AnalyticPeriod.yearly:
        return _yearlyBars();
    }
  }

  /// Weekly: 7 bar (Senin - Minggu)
  List<BarChartGroupData> _weeklyBars() {
    // dailyData sudah berisi 7 hari (atau kurang jika belum lengkap)
    return List.generate(7, (i) {
      double inc = 0, exp = 0, sav = 0;
      if (i < dailyData.length) {
        inc = dailyData[i].income;
        exp = dailyData[i].expense;
        sav = dailyData[i].saving.clamp(0.0, double.infinity).toDouble();
      }
      return _makeGroup(i, inc, exp, sav);
    });
  }

  /// Monthly: 1 bar per tanggal
  List<BarChartGroupData> _monthlyBars() {
    return List.generate(dailyData.length, (i) {
      return _makeGroup(
        i,
        dailyData[i].income,
        dailyData[i].expense,
        dailyData[i].saving.clamp(0.0, double.infinity).toDouble(),
      );
    });
  }

  /// Yearly: 12 bar (Jan - Dec), aggregate dailyData per bulan
  List<BarChartGroupData> _yearlyBars() {
    // Aggregate by month (1-12)
    final Map<int, double> monthIncome = {};
    final Map<int, double> monthExpense = {};
    for (final d in dailyData) {
      final m = d.date.month;
      monthIncome[m] = (monthIncome[m] ?? 0) + d.income;
      monthExpense[m] = (monthExpense[m] ?? 0) + d.expense;
    }

    return List.generate(12, (i) {
      final month = i + 1;
      final inc = monthIncome[month] ?? 0;
      final exp = monthExpense[month] ?? 0;
      final sav = (inc - exp).clamp(0.0, double.infinity).toDouble();
      return _makeGroup(i, inc, exp, sav);
    });
  }

  /// Helper: buat satu group bar (income + expense + saving)
  BarChartGroupData _makeGroup(int x, double inc, double exp, double sav) {
    const barWidth = 5.0;
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: inc,
          color: _incomeColor,
          width: barWidth,
          borderRadius: BorderRadius.circular(2),
        ),
        BarChartRodData(
          toY: exp,
          color: _expenseColor,
          width: barWidth,
          borderRadius: BorderRadius.circular(2),
        ),
        BarChartRodData(
          toY: sav,
          color: _savingColor,
          width: barWidth,
          borderRadius: BorderRadius.circular(2),
        ),
      ],
    );
  }

  double _getMaxY(List<BarChartGroupData> groups) {
    double max = 0;
    for (final g in groups) {
      for (final rod in g.barRods) {
        if (rod.toY > max) max = rod.toY;
      }
    }
    return max > 0 ? max * 1.2 : 100;
  }

  // ═══════════════════════════════════════════════════════════
  //  X-axis labels
  // ═══════════════════════════════════════════════════════════

  Widget _getBottomLabel(double value, TitleMeta meta) {
    final idx = value.toInt();
    String text;

    switch (period) {
      case AnalyticPeriod.weekly:
        const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
        text = idx >= 0 && idx < days.length ? days[idx] : '';
        break;

      case AnalyticPeriod.monthly:
        // Tampilkan tanggal
        if (idx >= 0 && idx < dailyData.length) {
          text = '${dailyData[idx].date.day}';
        } else {
          text = '';
        }
        break;

      case AnalyticPeriod.yearly:
        const months = [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
        ];
        text = idx >= 0 && idx < months.length ? months[idx] : '';
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Nunito',
          fontSize: 10,
          color: Color(0xFF9E9E9E),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  Small UI helpers
  // ═══════════════════════════════════════════════════════════

  Widget _avgText(String label, double value, Color color) {
    return Text(
      '$label ${rupiahFormatter.format(value)}',
      style: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: color,
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
}
