import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../providers/transaction_provider.dart';
import '../../theme/colors.dart';
import '../../theme/text_style.dart';
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
  int _filterIndex = 1; // default: Monthly
  DateTime _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
  bool _isExpenseSelected = true;

  void _goToPreviousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _goToNextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final data = provider.getAnalytics(_currentMonth);

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
                    // 1. Filter tabs
                    AnalyticFilterTabs(
                      selectedIndex: _filterIndex,
                      onChanged: (i) => setState(() => _filterIndex = i),
                    ),

                    const SizedBox(height: 16),

                    // 2. Month selector
                    MonthSelector(
                      currentMonth: _currentMonth,
                      onPrevious: _goToPreviousMonth,
                      onNext: _goToNextMonth,
                    ),

                    const SizedBox(height: 16),

                    // 3. Expense alert card
                    ExpenseAlertCard(
                      changePercent: data.expenseChangePercent,
                    ),

                    const SizedBox(height: 16),

                    // 4. Income / Expense toggle
                    IncomeExpenseToggle(
                      isExpenseSelected: _isExpenseSelected,
                      onChanged: (val) =>
                          setState(() => _isExpenseSelected = val),
                    ),

                    const SizedBox(height: 20),

                    // 5. Donut chart
                    DonutChartCard(
                      totalAmount: _isExpenseSelected
                          ? data.totalExpense
                          : data.totalIncome,
                      categories: data.categories,
                    ),

                    const SizedBox(height: 16),

                    // 6. Category breakdown
                    CategoryBreakdownList(
                      categories: data.categories,
                    ),

                    const SizedBox(height: 24),

                    // 7. Daily overview
                    DailyOverviewCard(
                      dailyData: data.dailyData,
                      avgIncome: data.avgIncome,
                      avgExpense: data.avgExpense,
                      avgSaving: data.avgSaving,
                    ),

                    const SizedBox(height: 16),

                    // 8. Monthly comparison
                    MonthlyComparisonCard(
                      data: data.monthlyComparison,
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
