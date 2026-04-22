import 'package:flutter/material.dart';

// ══════════════════════════════════════════════════════════════
// CategoryBreakdown — satu item kategori pengeluaran/pemasukan
// ══════════════════════════════════════════════════════════════
class CategoryBreakdown {
  final String name;
  final double amount;
  final double percentage;
  final Color color;
  final String iconAsset; // path ke SVG icon

  CategoryBreakdown({
    required this.name,
    required this.amount,
    required this.percentage,
    required this.color,
    required this.iconAsset,
  });

  factory CategoryBreakdown.fromJson(Map<String, dynamic> json) {
    return CategoryBreakdown(
      name: json['name']?.toString() ?? '',
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      percentage: double.tryParse(json['percentage'].toString()) ?? 0.0,
      color: Color(int.tryParse(json['color']?.toString() ?? '0xFF888888') ?? 0xFF888888),
      iconAsset: json['icon_asset']?.toString() ?? 'assets/icon/more.svg',
    );
  }
}

// ══════════════════════════════════════════════════════════════
// DailyDataPoint — satu titik data harian untuk line chart
// ══════════════════════════════════════════════════════════════
class DailyDataPoint {
  final DateTime date;
  final double income;
  final double expense;
  final double saving;

  DailyDataPoint({
    required this.date,
    required this.income,
    required this.expense,
    required this.saving,
  });

  factory DailyDataPoint.fromJson(Map<String, dynamic> json) {
    return DailyDataPoint(
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      income: double.tryParse(json['income'].toString()) ?? 0.0,
      expense: double.tryParse(json['expense'].toString()) ?? 0.0,
      saving: double.tryParse(json['saving'].toString()) ?? 0.0,
    );
  }
}

// ══════════════════════════════════════════════════════════════
// MonthlyComparison — data perbandingan dg bulan sebelumnya
// ══════════════════════════════════════════════════════════════
class MonthlyComparison {
  final double percentageChange; // positif = naik, negatif = turun
  final String message;
  final List<double> thisMonthDaily; // spending per hari
  final List<double> lastMonthDaily;
  final double dailyAverage;
  final double projectedTotal;

  MonthlyComparison({
    required this.percentageChange,
    required this.message,
    required this.thisMonthDaily,
    required this.lastMonthDaily,
    required this.dailyAverage,
    required this.projectedTotal,
  });

  factory MonthlyComparison.fromJson(Map<String, dynamic> json) {
    return MonthlyComparison(
      percentageChange: double.tryParse(json['percentage_change'].toString()) ?? 0.0,
      message: json['message']?.toString() ?? '',
      thisMonthDaily: (json['this_month_daily'] as List?)
              ?.map((e) => double.tryParse(e.toString()) ?? 0.0)
              .toList() ??
          [],
      lastMonthDaily: (json['last_month_daily'] as List?)
              ?.map((e) => double.tryParse(e.toString()) ?? 0.0)
              .toList() ??
          [],
      dailyAverage: double.tryParse(json['daily_average'].toString()) ?? 0.0,
      projectedTotal: double.tryParse(json['projected_total'].toString()) ?? 0.0,
    );
  }
}

// ══════════════════════════════════════════════════════════════
// AnalyticSummary — data utama halaman analytic
// ══════════════════════════════════════════════════════════════
class AnalyticSummary {
  final double totalIncome;
  final double totalExpense;
  final double expenseChangePercent; // % perubahan dari bulan lalu
  final List<CategoryBreakdown> categories;
  final List<DailyDataPoint> dailyData;
  final MonthlyComparison monthlyComparison;
  final double avgIncome;
  final double avgExpense;
  final double avgSaving;

  AnalyticSummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.expenseChangePercent,
    required this.categories,
    required this.dailyData,
    required this.monthlyComparison,
    required this.avgIncome,
    required this.avgExpense,
    required this.avgSaving,
  });

  factory AnalyticSummary.fromJson(Map<String, dynamic> json) {
    return AnalyticSummary(
      totalIncome: double.tryParse(json['total_income'].toString()) ?? 0.0,
      totalExpense: double.tryParse(json['total_expense'].toString()) ?? 0.0,
      expenseChangePercent: double.tryParse(json['expense_change_percent'].toString()) ?? 0.0,
      categories: (json['categories'] as List?)
              ?.map((e) => CategoryBreakdown.fromJson(e))
              .toList() ??
          [],
      dailyData: (json['daily_data'] as List?)
              ?.map((e) => DailyDataPoint.fromJson(e))
              .toList() ??
          [],
      monthlyComparison: MonthlyComparison.fromJson(json['monthly_comparison'] ?? {}),
      avgIncome: double.tryParse(json['avg_income'].toString()) ?? 0.0,
      avgExpense: double.tryParse(json['avg_expense'].toString()) ?? 0.0,
      avgSaving: double.tryParse(json['avg_saving'].toString()) ?? 0.0,
    );
  }
}

