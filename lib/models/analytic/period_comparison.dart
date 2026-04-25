/// ══════════════════════════════════════════════════════════════
/// PeriodComparison — data perbandingan dengan periode sebelumnya
///
/// Sebelumnya bernama MonthlyComparison, di-rename karena
/// sekarang mendukung perbandingan weekly, monthly, dan yearly.
/// ══════════════════════════════════════════════════════════════
class PeriodComparison {
  /// Positif = naik, negatif = turun, infinity = belum ada data sebelumnya.
  final double percentageChange;
  final String message;
  final List<double> currentPeriodDaily;
  final List<double> previousPeriodDaily;
  final double dailyAverage;
  final double projectedTotal;

  PeriodComparison({
    required this.percentageChange,
    required this.message,
    required this.currentPeriodDaily,
    required this.previousPeriodDaily,
    required this.dailyAverage,
    required this.projectedTotal,
  });

  factory PeriodComparison.fromJson(Map<String, dynamic> json) {
    return PeriodComparison(
      percentageChange: double.tryParse(json['percentage_change'].toString()) ?? 0.0,
      message: json['message']?.toString() ?? '',
      currentPeriodDaily: (json['current_period_daily'] as List?)
              ?.map((e) => double.tryParse(e.toString()) ?? 0.0)
              .toList() ??
          [],
      previousPeriodDaily: (json['previous_period_daily'] as List?)
              ?.map((e) => double.tryParse(e.toString()) ?? 0.0)
              .toList() ??
          [],
      dailyAverage: double.tryParse(json['daily_average'].toString()) ?? 0.0,
      projectedTotal: double.tryParse(json['projected_total'].toString()) ?? 0.0,
    );
  }
}
