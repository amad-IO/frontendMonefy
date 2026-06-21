import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../providers/analytic_provider.dart';
import '../../providers/auth_provider.dart';
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
  final bool initialIsExpense;

  const AnalyticPage({super.key, this.onBack, this.initialIsExpense = true});

  @override
  State<AnalyticPage> createState() => _AnalyticPageState();
}

class _AnalyticPageState extends State<AnalyticPage> {
  // ── State ──────────────────────────────────────────────────
  int _filterIndex = 1; // default: Monthly (0=Weekly, 1=Monthly, 2=Yearly)
  DateTime _anchorDate = DateTime.now();
  late bool _isExpenseSelected;

  @override
  void initState() {
    super.initState();
    _isExpenseSelected = widget.initialIsExpense;
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  /// Konversi index ke enum.
  AnalyticPeriod get _period => AnalyticPeriod.values[_filterIndex];

  String _getTrend() {
    switch (_period) {
      case AnalyticPeriod.weekly:
        return 'weekly';
      case AnalyticPeriod.monthly:
        return 'monthly';
      case AnalyticPeriod.yearly:
        return 'yearly';
    }
  }

  int _getWeekOfMonth() {
    final firstDay = DateTime(_anchorDate.year, _anchorDate.month, 1);
    return ((_anchorDate.day + firstDay.weekday - 2) / 7).floor() + 1;
  }

  void _loadData() {
    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn) return;

    context.read<AnalyticProvider>().loadAnalytic(
      token: auth.token!,
      trend: _getTrend(),
      month: _anchorDate.month,
      year: _anchorDate.year,
      week: _getWeekOfMonth(),
    );
  }

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
    _loadData();
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
    _loadData();
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

  Future<void> _onRefresh() async {
    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn) return;

    await context.read<AnalyticProvider>().refresh(
      token: auth.token!,
      trend: _getTrend(),
      month: _anchorDate.month,
      year: _anchorDate.year,
      week: _getWeekOfMonth(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final analyticProvider = context.watch<AnalyticProvider>();
    final transactionProvider = context.watch<TransactionProvider>();
    final (start, end) = _getDateRange();
    final localComparison = transactionProvider.getAnalytics(
      start: start,
      end: end,
      isExpense: _isExpenseSelected,
      periodLabel: _periodLabel,
    );
    final data = analyticProvider.getSummary(
      isExpense: _isExpenseSelected,
      localComparison: localComparison,
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
              child: analyticProvider.isLoading && data == null
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryPurple,
                      ),
                    )
                  : data == null
                  ? _AnalyticErrorState(
                      message: analyticProvider.error,
                      onRetry: _loadData,
                    )
                  : RefreshIndicator(
                      onRefresh: _onRefresh,
                      color: AppColors.primaryPurple,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: const EdgeInsets.only(top: 18, bottom: 120),
                        child: Column(
                          children: [
                            AnalyticFilterTabs(
                              selectedIndex: _filterIndex,
                              onChanged: (i) {
                                setState(() {
                                  _filterIndex = i;
                                  _anchorDate = DateTime.now();
                                });
                                _loadData();
                              },
                            ),
                            const SizedBox(height: 16),
                            PeriodSelector(
                              period: _period,
                              anchorDate: _anchorDate,
                              onPrevious: _goToPrevious,
                              onNext: _goToNext,
                            ),
                            const SizedBox(height: 16),
                            ExpenseAlertCard(
                              changePercent: data.changePercent,
                              isExpense: data.isExpense,
                            ),
                            const SizedBox(height: 16),
                            IncomeExpenseToggle(
                              isExpenseSelected: _isExpenseSelected,
                              onChanged: (value) =>
                                  setState(() => _isExpenseSelected = value),
                            ),
                            const SizedBox(height: 20),
                            DonutChartCard(
                              totalAmount: data.activeTotal,
                              categories: data.categories,
                              isExpense: data.isExpense,
                            ),
                            const SizedBox(height: 16),
                            CategoryBreakdownList(categories: data.categories),
                            const SizedBox(height: 24),
                            DailyOverviewCard(
                              period: _period,
                              dailyData: data.dailyData,
                              avgIncome: data.avgIncome,
                              avgExpense: data.avgExpense,
                              avgSaving: data.avgSaving,
                            ),
                            const SizedBox(height: 16),
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
          ),
        ],
      ),
    );
  }
}

class _AnalyticErrorState extends StatelessWidget {
  final String? message;
  final VoidCallback onRetry;

  const _AnalyticErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 48,
              color: AppColors.disabled,
            ),
            const SizedBox(height: 12),
            Text(
              message ?? 'Gagal memuat data analytic.',
              textAlign: TextAlign.center,
              style: AppTextStyle.caption,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryPurple,
              ),
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
