import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../providers/transaction_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../widgets/analytic/analytic_filter_tabs.dart';
import '../widgets/analytic/month_selector.dart';
import '../widgets/analytic/expense_alert_card.dart';
import '../widgets/analytic/income_expense_toggle.dart';
import '../widgets/analytic/donut_chart_card.dart';
import '../widgets/analytic/category_breakdown_list.dart';
import '../widgets/analytic/daily_overview_card.dart';
import '../widgets/analytic/monthly_comparison_card.dart';

class AnalyticPage extends StatefulWidget {
  final VoidCallback? onBack;

  const AnalyticPage({super.key, this.onBack});

  @override
  State<AnalyticPage> createState() => _AnalyticPageState();
}

class _AnalyticPageState extends State<AnalyticPage> {
  // ── State ──────────────────────────────────────────────────
  int _filterIndex = 1; // default: Monthly (0=Weekly, 1=Monthly, 2=Yearly)
  DateTime _anchorDate = DateTime.now();
  bool _isExpenseSelected = true;

  /// Konversi index ke enum.
  AnalyticPeriod get _period => AnalyticPeriod.values[_filterIndex];

  // ── Navigasi periode ──────────────────────────────────────
  void _goToPrevious() {
    setState(() {
      switch (_period) {
        case AnalyticPeriod.weekly:
          _anchorDate = _anchorDate.subtract(const Duration(days: 7));
          break;
        case AnalyticPeriod.monthly:
          _anchorDate = DateTime(_anchorDate.year, _anchorDate.month - 1, 1);
          break;
        case AnalyticPeriod.yearly:
          _anchorDate = DateTime(_anchorDate.year - 1, 1, 1);
          break;
      }
    });
  }

  void _goToNext() {
    setState(() {
      switch (_period) {
        case AnalyticPeriod.weekly:
          _anchorDate = _anchorDate.add(const Duration(days: 7));
          break;
        case AnalyticPeriod.monthly:
          _anchorDate = DateTime(_anchorDate.year, _anchorDate.month + 1, 1);
          break;
        case AnalyticPeriod.yearly:
          _anchorDate = DateTime(_anchorDate.year + 1, 1, 1);
          break;
      }
    });
  }

  /// Hitung rentang tanggal [start, end] berdasarkan periode aktif.
  (DateTime, DateTime) _getDateRange() {
    switch (_period) {
      case AnalyticPeriod.weekly:
        // Senin - Minggu dari minggu yang mengandung _anchorDate
        final weekStart = _anchorDate.subtract(
          Duration(days: _anchorDate.weekday - 1),
        );
        final weekEnd = weekStart.add(const Duration(days: 6));
        return (weekStart, weekEnd);

      case AnalyticPeriod.monthly:
        final firstDay = DateTime(_anchorDate.year, _anchorDate.month, 1);
        final lastDay = DateTime(_anchorDate.year, _anchorDate.month + 1, 0);
        return (firstDay, lastDay);

      case AnalyticPeriod.yearly:
        final firstDay = DateTime(_anchorDate.year, 1, 1);
        final lastDay = DateTime(_anchorDate.year, 12, 31);
        return (firstDay, lastDay);
    }
  }

  /// Label periode untuk pesan comparison ("week", "month", "year").
  String get _periodLabel {
    switch (_period) {
      case AnalyticPeriod.weekly:
        return 'week';
      case AnalyticPeriod.monthly:
        return 'month';
      case AnalyticPeriod.yearly:
        return 'year';
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final (start, end) = _getDateRange();
    final data = provider.getAnalytics(
      start: start,
      end: end,
      isExpense: _isExpenseSelected,
      periodLabel: _periodLabel,
    );

    return Scaffold(
      backgroundColor: AppColors.dashboardPurple,
      extendBody: true,
      body: Column(
        children: [
          // ── Header ────────────────────────────────────────
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: widget.onBack,
                    child: SvgPicture.asset(
                      'assets/icon/back.svg',
                      width: 35,
                      height: 35,
                      colorFilter: const ColorFilter.mode(
                        AppColors.primaryPurple,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Analytic',
                      textAlign: TextAlign.center,
                      style: AppTextStyle.heading.copyWith(
                        color: AppColors.primaryPurple,
                        fontSize: 25,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                ],
              ),
            ),
          ),

          // ── Body (white card) ─────────────────────────────
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.backgroundWhite,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 18,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(top: 18, bottom: 120),
                child: Column(
                  children: [
                    // 1. Filter tabs (Weekly / Monthly / Yearly)
                    AnalyticFilterTabs(
                      selectedIndex: _filterIndex,
                      onChanged: (i) => setState(() {
                        _filterIndex = i;
                        // Reset ke hari ini agar langsung menampilkan
                        // periode yang relevan saat ganti filter.
                        _anchorDate = DateTime.now();
                      }),
                    ),

                    const SizedBox(height: 16),

                    // 2. Period selector — label berubah sesuai filter
                    PeriodSelector(
                      period: _period,
                      anchorDate: _anchorDate,
                      onPrevious: _goToPrevious,
                      onNext: _goToNext,
                    ),

                    const SizedBox(height: 16),

                    // 3. Alert card — warna & pesan berubah sesuai mode
                    ExpenseAlertCard(
                      changePercent: data.changePercent,
                      isExpense: data.isExpense,
                    ),

                    const SizedBox(height: 16),

                    // 4. Income / Expense toggle
                    IncomeExpenseToggle(
                      isExpenseSelected: _isExpenseSelected,
                      onChanged: (val) =>
                          setState(() => _isExpenseSelected = val),
                    ),

                    const SizedBox(height: 20),

                    // 5. Donut chart — total & categories sesuai mode
                    DonutChartCard(
                      totalAmount: data.activeTotal,
                      categories: data.categories,
                      isExpense: data.isExpense,
                    ),

                    const SizedBox(height: 16),

                    // 6. Category breakdown — list sesuai mode
                    CategoryBreakdownList(
                      categories: data.categories,
                    ),

                    const SizedBox(height: 24),

                    // 7. Overview card — adapts to active period
                    DailyOverviewCard(
                      period: _period,
                      dailyData: data.dailyData,
                      avgIncome: data.avgIncome,
                      avgExpense: data.avgExpense,
                      avgSaving: data.avgSaving,
                    ),

                    const SizedBox(height: 16),

                    // 8. Period comparison — data sesuai mode
                    MonthlyComparisonCard(
                      data: data.periodComparison,
                      isExpense: data.isExpense,
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
