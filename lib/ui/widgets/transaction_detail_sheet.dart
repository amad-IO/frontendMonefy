import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../data/models/transaction_model.dart';
import '../../providers/transaction_provider.dart';
import '../../core/theme/app_colors.dart';
import 'confirm_dialog.dart';

/// ══════════════════════════════════════════════════════════════
/// TransactionDetailSheet — Bottom sheet detail satu transaksi.
///
/// Menampilkan: icon, nominal, tipe, dan baris detail
/// (Title, Category, Wallet, Date, Time) + tombol Delete.
///
/// Cara pakai:
/// ```dart
/// TransactionDetailSheet.show(
///   context: context,
///   transaction: transaction,
/// );
/// ```
/// ══════════════════════════════════════════════════════════════
class TransactionDetailSheet extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionDetailSheet({
    super.key,
    required this.transaction,
  });

  /// Tampilkan sebagai modal bottom sheet.
  static Future<void> show({
    required BuildContext context,
    required TransactionModel transaction,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TransactionDetailSheet(transaction: transaction),
    );
  }

  // ── Helpers ────────────────────────────────────────────────
  bool get _isIncome => transaction.type == TransactionType.income;

  Color get _typeColor =>
      _isIncome ? AppColors.incomeGreen : AppColors.expenseRed;

  Color get _typeBgColor =>
      _isIncome ? AppColors.incomeGreenBg : AppColors.expenseRedBg;

  IconData get _typeIcon =>
      _isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;

  String get _typeLabel => _isIncome ? 'Income' : 'Expense';

  String get _formattedAmount {
    final formatter = NumberFormat('#,##0', 'id_ID');
    final prefix = _isIncome ? '+' : '-';
    return '$prefix Rp${formatter.format(transaction.amount)},00';
  }

  String get _formattedDate =>
      DateFormat('d MMMM yyyy', 'id_ID').format(transaction.date);

  String get _formattedTime =>
      DateFormat('HH:mm').format(transaction.date);

  // ── Build ──────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.of(context).padding.bottom;

    return FractionallySizedBox(
      heightFactor: 0.78,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(
          color: AppColors.dashboardPurple,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        child: Column(
          children: [
            // ── Header (purple) ────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
              child: Row(
                children: [
                  // Tombol close
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primaryPurple.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: AppColors.primaryPurple,
                        size: 20,
                      ),
                    ),
                  ),

                  // Judul
                  const Expanded(
                    child: Text(
                      'Transaction Detail',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryPurple,
                      ),
                    ),
                  ),

                  // Spacer biar title tetap center
                  const SizedBox(width: 36),
                ],
              ),
            ),

            // ── Body (white rounded card) ──────────────────
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.backgroundWhite,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(bottom: safeBottom + 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 32),

                      // ── Icon bulat ──────────────────────
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: _typeBgColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _typeIcon,
                          color: _typeColor,
                          size: 36,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── Nominal ─────────────────────────
                      Text(
                        _formattedAmount,
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: _typeColor,
                        ),
                      ),

                      const SizedBox(height: 6),

                      // ── Label tipe ──────────────────────
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: _typeBgColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _typeLabel,
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _typeColor,
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      const Divider(
                          height: 1,
                          color: AppColors.divider,
                          indent: 24,
                          endIndent: 24),

                      const SizedBox(height: 4),

                      // ── Baris detail ────────────────────
                      _DetailRow(
                        label: 'Title',
                        value: transaction.category.isEmpty
                            ? '-'
                            : transaction.category,
                      ),
                      _DetailRow(
                        label: 'Category',
                        value: transaction.category.isEmpty
                            ? '-'
                            : transaction.category,
                      ),
                      _DetailRow(
                        label: 'Wallet',
                        value: transaction.walletName.isEmpty
                            ? '-'
                            : transaction.walletName,
                      ),
                      _DetailRow(
                        label: 'Date',
                        value: _formattedDate,
                      ),
                      _DetailRow(
                        label: 'Time',
                        value: _formattedTime,
                        isLast: true,
                      ),

                      const SizedBox(height: 32),

                      // ── Tombol Delete ───────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: _DeleteButton(
                          onTap: () {
                            ConfirmDialog.show(
                              context: context,
                              icon: Icons.delete_rounded,
                              iconColor: AppColors.error,
                              iconBgColor: AppColors.expenseRedBg,
                              title: 'Delete Transaction?',
                              description:
                                  'This transaction will be permanently deleted and cannot be recovered.',
                              confirmLabel: 'Delete',
                              confirmColor: AppColors.error,
                              onConfirm: () {
                                context
                                    .read<TransactionProvider>()
                                    .deleteTransaction(transaction.id);
                                Navigator.of(context).pop();
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Detail row ───────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;

  const _DetailRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          child: Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(
            height: 1,
            color: AppColors.divider,
            indent: 24,
            endIndent: 24,
          ),
      ],
    );
  }
}

// ── Delete button ────────────────────────────────────────────

class _DeleteButton extends StatefulWidget {
  final VoidCallback onTap;

  const _DeleteButton({required this.onTap});

  @override
  State<_DeleteButton> createState() => _DeleteButtonState();
}

class _DeleteButtonState extends State<_DeleteButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => Future.delayed(
        const Duration(milliseconds: 120),
        () {
          if (mounted) setState(() => _pressed = false);
        },
      ),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            color: _pressed
                ? AppColors.error.withValues(alpha: 0.87)
                : AppColors.error,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.error.withValues(alpha: 0.28),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.delete_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Delete Transaction',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
