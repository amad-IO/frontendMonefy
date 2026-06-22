class Bill {
  final int id;
  final String provider;
  final String accountNumber;
  final double amount;
  final String dueDate;
  final String cycle;
  final String status;

  Bill({
    required this.id,
    required this.provider,
    required this.accountNumber,
    required this.amount,
    required this.dueDate,
    required this.cycle,
    required this.status,
  });

  factory Bill.fromJson(Map<String, dynamic> json) {
    return Bill(
      id: json['id'],
      provider: json['provider'],
      accountNumber: json['account_number'],
      amount: double.parse(json['amount'].toString()),
      dueDate: json['due_date'],
      cycle: json['cycle'],
      status: json['status'],
    );
  }
}