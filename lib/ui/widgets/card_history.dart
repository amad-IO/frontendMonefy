import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/transaction_model.dart';
import '../../core/theme/app_colors.dart';
import 'transaction_detail_sheet.dart';

class CardHistory extends StatelessWidget {
  final TransactionModel transaction;

  const CardHistory({
    super.key,
    required this.transaction,
  });


  String get _formattedAmount {
    final formatter = NumberFormat('#,##0', 'id_ID');
    if (transaction.type == TransactionType.transfer) {
      // Transfer: tanpa +/- prefix
      return 'Rp.${formatter.format(transaction.amount)}';
    }
    final prefix = transaction.type == TransactionType.income ? '+' : '-';
    return '$prefix Rp.${formatter.format(transaction.amount)}';
  }

  String get _formattedDate {
    return DateFormat('d MMMM yyyy', 'id_ID').format(transaction.date);
  }

  Color get _amountColor {
    switch (transaction.type) {
      case TransactionType.income:
        return AppColors.incomeGreen;
      case TransactionType.expense:
        return AppColors.expenseRed;
      case TransactionType.transfer:
        return AppColors.transferOrange;
    }
  }

  /// BoxDecoration gradient untuk semua tipe transaksi
  BoxDecoration get _iconDecoration {
    final LinearGradient gradient;
    switch (transaction.type) {
      case TransactionType.income:
        gradient = AppColors.incomeGradient;
        break;
      case TransactionType.expense:
        gradient = AppColors.expenseGradient;
        break;
      case TransactionType.transfer:
        gradient = AppColors.transferGradient;
        break;
    }
    return BoxDecoration(gradient: gradient, shape: BoxShape.circle);
  }

  IconData get _historyIcon {
    switch (transaction.type) {
      case TransactionType.income:
        return Icons.arrow_downward_rounded;
      case TransactionType.expense:
        return Icons.arrow_upward_rounded;
      case TransactionType.transfer:
        return Icons.swap_horiz_rounded;
    }
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => TransactionDetailSheet.show(
        context: context,
        transaction: transaction,
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon lingkaran
            Container(
              width: 44,
              height: 44,
              decoration: _iconDecoration, // ← gradient untuk transfer
              child: Icon(
                _historyIcon,
                color: Colors.white,
                size: 20,
              ),
            ),

            const SizedBox(width: 12),

            // Kategori + tanggal
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.category.isEmpty
                        ? 'Unknown'
                        : transaction.category,
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

            // Nominal + wallet
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
                  transaction.type == TransactionType.transfer
                      ? '${transaction.walletName} → ${transaction.toWalletName}'
                      : transaction.walletName.isEmpty
                          ? 'Unknown Wallet'
                          : transaction.walletName,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}