class SummaryModel {
  final double totalBalance;
  final double totalIncome;
  final double totalExpense;
  final String filterLabel;

  SummaryModel({
    required this.totalBalance,
    required this.totalIncome,
    required this.totalExpense,
    this.filterLabel = 'month',
  });

  factory SummaryModel.fromJson(Map<String, dynamic> json, {String filterLabel = 'month'}) {
    return SummaryModel(
      totalBalance: double.tryParse(json['total_balance'].toString()) ?? 0.0,
      totalIncome: double.tryParse(json['total_income'].toString()) ?? 0.0,
      totalExpense: double.tryParse(json['total_expense'].toString()) ?? 0.0,
      filterLabel: filterLabel,
    );
  }
  static SummaryModel dummy() {
    return SummaryModel(
      totalBalance: 3000000,
      totalIncome: 2000000,
      totalExpense: 700000,
      filterLabel: 'month',
    );
  }
}