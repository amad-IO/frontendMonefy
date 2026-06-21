import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import 'analytic_summary.dart';
import 'category_breakdown.dart';
import 'daily_data_point.dart';
import 'period_comparison.dart';

/// Raw response gabungan dari endpoint summary dan top categories.
class AnalyticChartData {
  final double totalIncome;
  final double totalExpense;
  final double totalBalance;
  final List<String> chartLabels;
  final List<double> chartIncome;
  final List<double> chartExpense;
  final List<BackendCategory> expenseCategories;
  final List<BackendCategory> incomeCategories;
  final String trend;
  final int month;
  final int year;
  final int week;
  final DateTime fetchedAt;

  AnalyticChartData({
    required this.totalIncome,
    required this.totalExpense,
    required this.totalBalance,
    required this.chartLabels,
    required this.chartIncome,
    required this.chartExpense,
    required this.expenseCategories,
    required this.incomeCategories,
    required this.trend,
    required this.month,
    required this.year,
    required this.week,
    required this.fetchedAt,
  });

  String get cacheKey => 'analytic_${trend}_${year}_${month}_$week';

  bool get isStale => DateTime.now().difference(fetchedAt).inMinutes >= 30;

  factory AnalyticChartData.fromJson(
    Map<String, dynamic> summaryJson,
    Map<String, dynamic> categoriesJson,
    String trend,
    int month,
    int year,
    int week,
  ) {
    List<double> toDoubleList(dynamic raw) =>
        (raw as List?)
            ?.map((e) => double.tryParse(e.toString()) ?? 0.0)
            .toList() ??
        [];

    List<String> toStringList(dynamic raw) =>
        (raw as List?)?.map((e) => e.toString()).toList() ?? [];

    List<BackendCategory> parseCategories(dynamic raw) =>
        (raw as List?)
            ?.map(
              (e) =>
                  BackendCategory.fromJson(Map<String, dynamic>.from(e as Map)),
            )
            .toList() ??
        [];

    return AnalyticChartData(
      totalIncome:
          double.tryParse(summaryJson['total_income'].toString()) ?? 0.0,
      totalExpense:
          double.tryParse(summaryJson['total_expense'].toString()) ?? 0.0,
      totalBalance:
          double.tryParse(summaryJson['total_balance'].toString()) ?? 0.0,
      chartLabels: toStringList(summaryJson['chart_labels']),
      chartIncome: toDoubleList(summaryJson['chart_income']),
      chartExpense: toDoubleList(summaryJson['chart_expense']),
      expenseCategories: parseCategories(categoriesJson['expenses']),
      incomeCategories: parseCategories(categoriesJson['incomes']),
      trend: trend,
      month: month,
      year: year,
      week: week,
      fetchedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'total_income': totalIncome,
    'total_expense': totalExpense,
    'total_balance': totalBalance,
    'chart_labels': chartLabels,
    'chart_income': chartIncome,
    'chart_expense': chartExpense,
    'expense_categories': expenseCategories.map((c) => c.toJson()).toList(),
    'income_categories': incomeCategories.map((c) => c.toJson()).toList(),
    'trend': trend,
    'month': month,
    'year': year,
    'week': week,
    'fetched_at': fetchedAt.toIso8601String(),
  };

  factory AnalyticChartData.fromCacheJson(Map<String, dynamic> json) {
    List<BackendCategory> parseCategories(dynamic raw) =>
        (raw as List?)
            ?.map(
              (e) =>
                  BackendCategory.fromJson(Map<String, dynamic>.from(e as Map)),
            )
            .toList() ??
        [];

    return AnalyticChartData(
      totalIncome: double.tryParse(json['total_income'].toString()) ?? 0.0,
      totalExpense: double.tryParse(json['total_expense'].toString()) ?? 0.0,
      totalBalance: double.tryParse(json['total_balance'].toString()) ?? 0.0,
      chartLabels:
          (json['chart_labels'] as List?)?.map((e) => e.toString()).toList() ??
          [],
      chartIncome:
          (json['chart_income'] as List?)
              ?.map((e) => double.tryParse(e.toString()) ?? 0.0)
              .toList() ??
          [],
      chartExpense:
          (json['chart_expense'] as List?)
              ?.map((e) => double.tryParse(e.toString()) ?? 0.0)
              .toList() ??
          [],
      expenseCategories: parseCategories(json['expense_categories']),
      incomeCategories: parseCategories(json['income_categories']),
      trend: json['trend']?.toString() ?? 'monthly',
      month: int.tryParse(json['month'].toString()) ?? DateTime.now().month,
      year: int.tryParse(json['year'].toString()) ?? DateTime.now().year,
      week: int.tryParse(json['week'].toString()) ?? 1,
      fetchedAt:
          DateTime.tryParse(json['fetched_at']?.toString() ?? '') ??
          DateTime(2000),
    );
  }

  /// Backend menjadi sumber total, chart, average, dan kategori.
  /// Hasil kalkulasi lokal hanya dipakai untuk comparison antarperiode.
  AnalyticSummary toAnalyticSummary({
    required bool isExpense,
    AnalyticSummary? localComparison,
  }) {
    final rawCategories = isExpense ? expenseCategories : incomeCategories;

    final categories = rawCategories
        .map(
          (category) => CategoryBreakdown(
            name: category.categoryName,
            amount: category.totalAmount,
            percentage: category.percentage,
            color: AppColors.categoryColor(category.categoryName),
            iconAsset: _iconAssetForCategory(category.categoryName),
            iconData: isExpense
                ? null
                : _iconDataForCategory(category.categoryName),
          ),
        )
        .toList();

    final pointCount = [
      chartLabels.length,
      chartIncome.length,
      chartExpense.length,
    ].reduce((a, b) => a > b ? a : b);

    final dailyData = List.generate(pointCount, (index) {
      final income = index < chartIncome.length ? chartIncome[index] : 0.0;
      final expense = index < chartExpense.length ? chartExpense[index] : 0.0;
      return DailyDataPoint(
        date: _dateForIndex(index),
        income: income,
        expense: expense,
        saving: income - expense,
      );
    });

    final divisor = dailyData.isEmpty ? 1 : dailyData.length;
    final avgIncome = totalIncome / divisor;
    final avgExpense = totalExpense / divisor;
    final avgSaving = avgIncome - avgExpense;

    final fallbackComparison = PeriodComparison(
      percentageChange: 0,
      message: 'No comparison data yet.',
      currentPeriodDaily: isExpense ? chartExpense : chartIncome,
      previousPeriodDaily: const [],
      dailyAverage: isExpense ? avgExpense : avgIncome,
      projectedTotal: isExpense ? totalExpense : totalIncome,
    );

    return AnalyticSummary(
      isExpense: isExpense,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      changePercent: localComparison?.changePercent ?? 0,
      categories: categories,
      dailyData: dailyData,
      periodComparison: localComparison?.periodComparison ?? fallbackComparison,
      avgIncome: avgIncome,
      avgExpense: avgExpense,
      avgSaving: avgSaving,
    );
  }

  DateTime _dateForIndex(int index) {
    switch (trend) {
      case 'weekly':
        final start = DateTime(
          year,
          month,
          1,
        ).add(Duration(days: (week - 1) * 7));
        return start.add(Duration(days: index));
      case 'yearly':
        return DateTime(year, index + 1, 1);
      case 'monthly':
      default:
        return DateTime(year, month, index + 1);
    }
  }

  static String _iconAssetForCategory(String name) {
    const icons = {
      'Food & Drink': 'assets/icon/foods.svg',
      'Entertainment': 'assets/icon/entertainment.svg',
      'Transportation': 'assets/icon/transportation.svg',
      'Shop': 'assets/icon/shop.svg',
    };
    return icons[name] ?? 'assets/icon/more.svg';
  }

  static IconData? _iconDataForCategory(String name) {
    const icons = {
      'Salary': Icons.account_balance_wallet_rounded,
      'Freelance': Icons.work_rounded,
      'Gift': Icons.card_giftcard_rounded,
      'Investment': Icons.trending_up_rounded,
      'More': Icons.more_horiz_rounded,
    };
    return icons[name];
  }
}

class BackendCategory {
  final String categoryName;
  final double totalAmount;
  final double percentage;

  BackendCategory({
    required this.categoryName,
    required this.totalAmount,
    required this.percentage,
  });

  factory BackendCategory.fromJson(Map<String, dynamic> json) {
    return BackendCategory(
      categoryName: json['category_name']?.toString() ?? '',
      totalAmount: double.tryParse(json['total_amount'].toString()) ?? 0.0,
      percentage: double.tryParse(json['percentage'].toString()) ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'category_name': categoryName,
    'total_amount': totalAmount,
    'percentage': percentage,
  };
}
