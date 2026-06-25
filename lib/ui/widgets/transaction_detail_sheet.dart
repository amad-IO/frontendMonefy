import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../data/models/transaction_model.dart';
import '../../providers/transaction_provider.dart';
import '../../core/theme/app_colors.dart';
import 'confirm_dialog.dart';
import '../pages/add_page.dart';

/// ══════════════════════════════════════════════════════════════
/// TransactionDetailSheet — Bottom sheet detail satu transaksi.
///
/// Menampilkan: icon, nominal, dan baris detail
/// (Category, Title (jika More), Wallet, Date, Time).
/// Background menggunakan SVG kontur.
///
/// Fitur:
/// - Tombol Delete () di header kanan atas → ConfirmDialog
/// - Tombol Edit full-width di footer → buka AddPage mode edit
///
/// Cara pakai:
/// ```dart
/// TransactionDetailSheet.show(
///   context: context,
///   transaction: transaction,
/// );
/// ```
/// ══════════════════════════════════════════════════════════════
class TransactionDetailSheet extends StatefulWidget {
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

  @override
  State<TransactionDetailSheet> createState() => _TransactionDetailSheetState();
}

class _TransactionDetailSheetState extends State<TransactionDetailSheet> {
  bool _isDeleting = false;

  // ── Helpers ────────────────────────────────────────────────
  bool get _isIncome   => widget.transaction.type == TransactionType.income;
  bool get _isTransfer => widget.transaction.type == TransactionType.transfer;

  Color get _typeColor {
    switch (widget.transaction.type) {
      case TransactionType.income:
        return AppColors.incomeGreen;
      case TransactionType.expense:
        return AppColors.expenseRed;
      case TransactionType.transfer:
        return AppColors.transferOrange;
    }
  }

  /// Decoration untuk icon bubble — gradient untuk semua tipe
  BoxDecoration get _iconDecoration {
    final LinearGradient gradient;
    switch (widget.transaction.type) {
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

  IconData get _typeIcon {
    switch (widget.transaction.type) {
      case TransactionType.income:
        return Icons.arrow_downward_rounded;
      case TransactionType.expense:
        return Icons.arrow_upward_rounded;
      case TransactionType.transfer:
        return Icons.swap_horiz_rounded;
    }
  }

  String get _formattedAmount {
    final formatter = NumberFormat('#,##0', 'id_ID');
    if (_isTransfer) {
      return 'Rp${formatter.format(widget.transaction.amount)},00';
    }
    final prefix = _isIncome ? '+' : '-';
    return '$prefix Rp${formatter.format(widget.transaction.amount)},00';
  }

  String get _formattedDate =>
      DateFormat('d MMM yyyy', 'id_ID').format(widget.transaction.date);

  String get _formattedTime =>
      DateFormat('HH:mm').format(widget.transaction.date);

  /// Title hanya tampil jika category == 'More' dan title tidak kosong
  bool get _showTitle =>
      widget.transaction.category == 'More' &&
      widget.transaction.title.isNotEmpty;

  // ── Actions ────────────────────────────────────────────────

  void _onDeleteTap() {
    ConfirmDialog.show(
      context: context,
      icon: Icons.delete_outline_rounded,
      iconColor: AppColors.expenseRed,
      iconBgColor: AppColors.expenseRed.withValues(alpha: 0.1),
      title: 'Hapus Transaksi?',
      description:
          'Transaksi ini akan dihapus secara permanen dan tidak bisa dikembalikan.',
      confirmLabel: 'Hapus',
      confirmColor: AppColors.expenseRed,
      onConfirm: () async {
        if (_isDeleting) return;
        setState(() => _isDeleting = true);

        // Hapus dari provider (in-memory / akan diganti API call)
        if (mounted) {
          context
              .read<TransactionProvider>()
              .deleteTransaction(widget.transaction.id);

          // Tutup sheet setelah hapus
          Navigator.of(context).pop();

          // Snackbar sukses
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Transaksi berhasil dihapus',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              backgroundColor: AppColors.incomeGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
    );
  }

  void _onEditTap() {
    // Tutup sheet terlebih dahulu, lalu buka AddPage dalam mode edit
    Navigator.of(context).pop();

    // Gunakan Future.delayed agar pop selesai dulu sebelum push
    Future.delayed(const Duration(milliseconds: 180), () {
      if (!mounted) return;
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => AddPage(editTransaction: widget.transaction),
      );
    });
  }

  // ── Build ──────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.of(context).padding.bottom;

    return FractionallySizedBox(
      heightFactor: 0.72, // sedikit lebih tinggi untuk akomodasi tombol Edit
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
                  // Tombol close
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

                  // Tombol Delete () di kanan atas
                  _isDeleting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.expenseRed,
                          ),
                        )
                      : GestureDetector(
                          onTap: _onDeleteTap,
                          child: SvgPicture.asset(
                            'assets/icon/delete.svg',
                            width: 24,
                            height: 24,
                            colorFilter: const ColorFilter.mode(
                              AppColors.expenseRed,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
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
                    padding: EdgeInsets.only(bottom: safeBottom + 24),
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
                                    color: AppColors.primaryPurple
                                        .withValues(alpha: 0.5),
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
                                      decoration: _iconDecoration, // ← gradient untuk transfer
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
                                value: widget.transaction.category.isEmpty
                                    ? '-'
                                    : widget.transaction.category,
                              ),

                              // Title hanya muncul jika category == 'More'
                              if (_showTitle)
                                _InfoRow(
                                  label: 'Title',
                                  value: widget.transaction.title,
                                ),

                              _InfoRow(
                                label: _isTransfer ? 'From Wallet' : 'Wallet',
                                value: widget.transaction.walletName.isEmpty
                                    ? '-'
                                    : widget.transaction.walletName,
                              ),

                              // To Wallet — hanya untuk transfer
                              if (_isTransfer)
                                _InfoRow(
                                  label: 'To Wallet',
                                  value: widget.transaction.toWalletName.isEmpty
                                      ? '-'
                                      : widget.transaction.toWalletName,
                                ),

                              _InfoRow(
                                label: 'Date',
                                value: _formattedDate,
                              ),
                              _InfoRow(
                                label: 'Time',
                                value: _formattedTime,
                              ),

                              // Note — hanya tampil jika ada isinya
                              if (widget.transaction.note.isNotEmpty)
                                _InfoRow(
                                  label: 'Note',
                                  value: widget.transaction.note,
                                ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 28),

                        // ── Tombol Edit (footer full-width) ───
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 28),
                          child: _EditButton(onTap: _onEditTap),
                        ),

                        const SizedBox(height: 8),
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

// ── Edit Button ───────────────────────────────────────────────

class _EditButton extends StatefulWidget {
  final VoidCallback onTap;

  const _EditButton({required this.onTap});

  @override
  State<_EditButton> createState() => _EditButtonState();
}

class _EditButtonState extends State<_EditButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => Future.delayed(
        const Duration(milliseconds: 120),
        () { if (mounted) setState(() => _pressed = false); },
      ),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: double.infinity,
          height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _pressed
                ? AppColors.primaryPurple.withValues(alpha: 0.85)
                : AppColors.primaryPurple,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryPurple.withValues(alpha: 0.30),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.edit_rounded, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text(
                'Edit Transaction',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 15,
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
