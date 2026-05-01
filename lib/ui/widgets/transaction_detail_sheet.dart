import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import '../../data/models/transaction_model.dart';
import '../../core/theme/app_colors.dart';

/// ══════════════════════════════════════════════════════════════
/// TransactionDetailSheet — Bottom sheet detail satu transaksi.
///
/// Menampilkan: icon, nominal, dan baris detail
/// (Category, Title (jika More), Wallet, Date, Time).
/// Background menggunakan SVG kontur.
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

  IconData get _typeIcon =>
      _isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;

  String get _formattedAmount {
    final formatter = NumberFormat('#,##0', 'id_ID');
    final prefix = _isIncome ? '+' : '-';
    return '$prefix Rp${formatter.format(transaction.amount)},00';
  }

  String get _formattedDate =>
      DateFormat('d MMM yyyy', 'id_ID').format(transaction.date);

  String get _formattedTime =>
      DateFormat('HH:mm').format(transaction.date);

  /// Title hanya tampil jika category == 'More' dan title tidak kosong
  bool get _showTitle =>
      transaction.category == 'More' && transaction.title.isNotEmpty;

  // ── Build ──────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.of(context).padding.bottom;

    return FractionallySizedBox(
      heightFactor: 0.65,
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
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
              child: Row(
                children: [
                  // Tombol close — plain icon seperti di mockup
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(
                      Icons.close_rounded,
                      color: AppColors.primaryPurple,
                      size: 24,
                    ),
                  ),

                  // Judul tengah
                  const Expanded(
                    child: Text(
                      'Transaction detail',
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
                  const SizedBox(width: 24),
                ],
              ),
            ),

            // ── Body (white + kontur bg) ───────────────────
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // White base
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(28),
                        topRight: Radius.circular(28),
                      ),
                    ),
                  ),

                  // SVG kontur overlay
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(28),
                        topRight: Radius.circular(28),
                      ),
                      child: Opacity(
                        opacity: 0.55,
                        child: SvgPicture.asset(
                          'assets/images/kontur.svg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),

                  // Scrollable content di atas overlay
                  SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.only(bottom: safeBottom + 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 36),

                        // ── Amount Card (glassmorphism) ──────────
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 28, horizontal: 20),
                                decoration: BoxDecoration(
                                  color: AppColors.dashboardPurple
                                      .withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppColors.primaryPurple.withValues(alpha: 0.5),
                                    width: 1.5,
                                  ),
                                ),

                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Icon bulat berwarna
                                    Container(
                                      width: 52,
                                      height: 52,
                                      decoration: BoxDecoration(
                                        color: _typeColor,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        _typeIcon,
                                        color: Colors.white,
                                        size: 26,
                                      ),
                                    ),

                                    const SizedBox(height: 14),

                                    // Nominal
                                    Text(
                                      _formattedAmount,
                                      style: TextStyle(
                                        fontFamily: 'Nunito',
                                        fontSize: 26,
                                        fontWeight: FontWeight.w800,
                                        color: _typeColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),


                        const SizedBox(height: 44),

                        // ── Info Rows ─────────────────────────
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 28),
                          child: Column(
                            children: [
                              _InfoRow(
                                label: 'Category',
                                value: transaction.category.isEmpty
                                    ? '-'
                                    : transaction.category,
                              ),

                              // Title hanya muncul jika category == 'More'
                              if (_showTitle)
                                _InfoRow(
                                  label: 'Title',
                                  value: transaction.title,
                                ),

                              _InfoRow(
                                label: 'Wallet',
                                value: transaction.walletName.isEmpty
                                    ? '-'
                                    : transaction.walletName,
                              ),
                              _InfoRow(
                                label: 'Date',
                                value: _formattedDate,
                              ),
                              _InfoRow(
                                label: 'Time',
                                value: _formattedTime,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Info row ─────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
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
    );
  }
}
