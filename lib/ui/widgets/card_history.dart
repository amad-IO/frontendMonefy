import 'package:flutter/material.dart';
import '../../models/transaction_model.dart';
import '../../theme/colors.dart';
import 'package:intl/intl.dart';

class CardHistory extends StatelessWidget {
  final TransactionModel transaction;

  const CardHistory({
    super.key,
    required this.transaction,
  });

  String get _formattedAmount {
    final formatter = NumberFormat('#,##0', 'id_ID');
    final prefix = transaction.type == TransactionType.income ? '+' : '-';
    return '$prefix Rp.${formatter.format(transaction.amount)}';
  }

  String get _formattedDate {
    return DateFormat('d MMMM yyyy', 'id_ID').format(transaction.date);
  }

  Color get _amountColor => transaction.type == TransactionType.income
      ? AppColors.success
      : AppColors.error;

    IconData get _historyIcon => transaction.type == TransactionType.income
      ? Icons.arrow_downward_rounded
      : Icons.arrow_upward_rounded;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _amountColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _historyIcon,
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.category,
                  style: (Theme.of(context).textTheme.titleMedium ??
                          const TextStyle())
                      .copyWith(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _formattedDate,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formattedAmount,
                style: (Theme.of(context).textTheme.titleMedium ??
                        const TextStyle())
                    .copyWith(
                  fontSize: 13,
                  color: _amountColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                transaction.walletName,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
