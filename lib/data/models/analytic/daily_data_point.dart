/// ══════════════════════════════════════════════════════════════
/// DailyDataPoint — satu titik data harian untuk line chart
/// ══════════════════════════════════════════════════════════════
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
