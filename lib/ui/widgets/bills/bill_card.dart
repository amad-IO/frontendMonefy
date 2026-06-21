import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';

class BillCard extends StatelessWidget {
  final String title;
  final String accountNumber;
  final String amount;
  final String dueDate;
  final String cycle;
  final bool isPaid;
  final VoidCallback? onTap;
  final VoidCallback? onPay;

  const BillCard({
    super.key,
    required this.title,
    required this.accountNumber,
    required this.amount,
    required this.dueDate,
    required this.cycle,
    required this.isPaid,
    this.onTap,
    this.onPay,
  });

  DateTime? get _parsedDueDate => DateTime.tryParse(dueDate);

  bool get _isOverdue {
    final date = _parsedDueDate;
    if (date == null || isPaid) return false;
    final today = DateTime.now();
    return DateTime(
      date.year,
      date.month,
      date.day,
    ).isBefore(DateTime(today.year, today.month, today.day));
  }

  bool get _isDueSoon {
    final date = _parsedDueDate;
    if (date == null || isPaid || _isOverdue) return false;
    final today = DateTime.now();
    final days = DateTime(
      date.year,
      date.month,
      date.day,
    ).difference(DateTime(today.year, today.month, today.day)).inDays;
    return days <= 3;
  }

  String get _dueLabel {
    if (isPaid) return 'Paid';
    if (_isOverdue) return 'Overdue';
    if (_isDueSoon) return 'Due soon';
    return 'Upcoming';
  }

  Color get _statusColor {
    if (isPaid) return AppColors.incomeGreen;
    if (_isOverdue) return AppColors.expenseRed;
    if (_isDueSoon) return AppColors.transferOrange;
    return AppColors.billsColor;
  }

  Color get _statusBackground {
    if (isPaid) return AppColors.incomeGreenBg;
    if (_isOverdue) return AppColors.expenseRedBg;
    if (_isDueSoon) return AppColors.transferBg;
    return AppColors.billsBg;
  }

  String get _formattedDueDate {
    final date = _parsedDueDate;
    if (date == null) return 'No due date';
    return 'Due ${DateFormat('d MMM yyyy', 'id_ID').format(date)}';
  }

  String get _maskedAccount {
    if (accountNumber.isEmpty) return cycle;
    if (accountNumber.length <= 4) return accountNumber;
    return '•••• ${accountNumber.substring(accountNumber.length - 4)}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.panelWhite,
        borderRadius: BorderRadius.circular(22),
        elevation: 0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: _statusColor.withValues(alpha: 0.12)),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.lightShadow,
                  blurRadius: 14,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: isPaid
                        ? AppColors.incomeGradient
                        : AppColors.billsGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    isPaid ? Icons.check_rounded : Icons.receipt_long_rounded,
                    color: AppColors.panelWhite,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _StatusBadge(
                            label: _dueLabel,
                            color: _statusColor,
                            background: _statusBackground,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$_maskedAccount  •  $cycle',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 13),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  amount,
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: isPaid
                                        ? AppColors.incomeGreen
                                        : AppColors.primaryPurple,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _formattedDueDate,
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: _isOverdue
                                        ? AppColors.expenseRed
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!isPaid)
                            Material(
                              color: AppColors.primaryPurple,
                              borderRadius: BorderRadius.circular(14),
                              child: InkWell(
                                onTap: onPay,
                                borderRadius: BorderRadius.circular(14),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  child: Text(
                                    'Pay now',
                                    style: TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.panelWhite,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color background;

  const _StatusBadge({
    required this.label,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}
