import 'category_breakdown.dart';
import 'daily_data_point.dart';
import 'period_comparison.dart';

/// ══════════════════════════════════════════════════════════════
/// AnalyticSummary — data utama halaman analytic
///
/// Field [isExpense] menentukan mode data saat ini.
/// Field [changePercent] bersifat generik:
///   • Mode expense → perubahan pengeluaran dari periode lalu
///   • Mode income  → perubahan pemasukan dari periode lalu
/// ══════════════════════════════════════════════════════════════
class AnalyticSummary {
  /// true = sedang menampilkan data Expense,
  /// false = sedang menampilkan data Income.
  final bool isExpense;

  final double totalIncome;
  final double totalExpense;

  /// Persentase perubahan (income atau expense) dari periode lalu.
  /// Positif = naik, negatif = turun, infinity = belum ada data sebelumnya.
  final double changePercent;

  /// Breakdown per kategori — isinya bergantung pada [isExpense].
  final List<CategoryBreakdown> categories;

  final List<DailyDataPoint> dailyData;
  final PeriodComparison periodComparison;
  final double avgIncome;
  final double avgExpense;
  final double avgSaving;

  AnalyticSummary({
    required this.isExpense,
    required this.totalIncome,
    required this.totalExpense,
    required this.changePercent,
    required this.categories,
    required this.dailyData,
    required this.periodComparison,
    required this.avgIncome,
    required this.avgExpense,
    required this.avgSaving,
  });

  /// Shortcut: total sesuai mode aktif.
  double get activeTotal => isExpense ? totalExpense : totalIncome;

  factory AnalyticSummary.fromJson(Map<String, dynamic> json) {
    return AnalyticSummary(
      isExpense: json['is_expense'] as bool? ?? true,
      totalIncome: double.tryParse(json['total_income'].toString()) ?? 0.0,
      totalExpense: double.tryParse(json['total_expense'].toString()) ?? 0.0,
      changePercent: double.tryParse(json['change_percent'].toString()) ?? 0.0,
      categories: (json['categories'] as List?)
              ?.map((e) => CategoryBreakdown.fromJson(e))
              .toList() ??
          [],
      dailyData: (json['daily_data'] as List?)
              ?.map((e) => DailyDataPoint.fromJson(e))
              .toList() ??
          [],
      periodComparison: PeriodComparison.fromJson(json['period_comparison'] ?? {}),
      avgIncome: double.tryParse(json['avg_income'].toString()) ?? 0.0,
      avgExpense: double.tryParse(json['avg_expense'].toString()) ?? 0.0,
      avgSaving: double.tryParse(json['avg_saving'].toString()) ?? 0.0,
    );
  }
}
