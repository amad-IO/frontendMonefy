import 'package:flutter/material.dart';
import '../../data/models/transaction_model.dart';
import '../../core/theme/app_colors.dart';
import 'transaction_loading_widget.dart';
import 'transaction_success_widget.dart';

/// Helper untuk menampilkan panel loading & sukses transaksi (47% layar).
///
/// Cara pakai:
/// ```dart
/// await NotifikasiTransaction.show(
///   context: context,
///   type: TransactionType.income,
///   amount: 'Rp 250.000',
///   category: 'Salary',
///   walletName: 'BCA',
///   apiWork: () => provider.addTransactionWithApi(...),
///   onSuccess: () => navigator.pop(),
/// );
/// ```
class NotifikasiTransaction {
  static Future<void> show({
    required BuildContext context,
    required TransactionType type,
    required Future<void> Function() apiWork,
    required VoidCallback onSuccess,
    String? amount,
    String? category,
    String? walletName,
    String? toWalletName,
    // Legacy param, diabaikan — digantikan category + walletName
    String? subtitle,
  }) async {
    final amountText = amount ?? '';
    final cat = category ?? '';
    final wallet = walletName ?? '';
    final toWallet = toWalletName ?? '';

    // Subtitle versi loading & versi success berbeda
    final loadingSubtitle = _buildLoadingSubtitle(type, cat, wallet, toWallet, amountText);
    final successSubtitle = _buildSuccessSubtitle(type, cat, wallet, toWallet);
    final loadingTitle   = _buildLoadingTitle(type);

    // 1. Tampilkan panel loading (tidak di-await — API jalan bersamaan)
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (_, anim, __, child) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
        child: child,
      ),
      pageBuilder: (_, __, ___) => _BottomPanel(
        child: TransactionLoadingWidget(
          transactionType: type,
          size: 165,
          label: loadingTitle,
          subtitle: loadingSubtitle,
        ),
      ),
    );

    try {
      await apiWork();
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      rethrow;
    }

    if (!context.mounted) return;

    // 2. Tutup loading
    Navigator.of(context, rootNavigator: true).pop();

    if (!context.mounted) return;

    // 3. Tampilkan panel success (await sampai dismiss)
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (_, anim, __, child) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
        child: child,
      ),
      pageBuilder: (_, __, ___) => _BottomPanel(
        child: TransactionSuccessWidget(
          transactionType: type,
          amount: amountText,
          subtitle: successSubtitle,
          size: 165,
          onComplete: () => Future.delayed(
            const Duration(milliseconds: 800),
            () {
              if (context.mounted) {
                Navigator.of(context, rootNavigator: true).pop();
              }
            },
          ),
        ),
      ),
    );

    // 4. Jalankan callback (tutup AddPage, dll)
    onSuccess();
  }

  // ── Loading title ──
  static String _buildLoadingTitle(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return 'Processing Income...';
      case TransactionType.expense:
        return 'Processing Expense...';
      case TransactionType.transfer:
        return 'Processing Transfer...';
    }
  }

  // ── Loading subtitle: kategori + wallet + nominal ──
  static String _buildLoadingSubtitle(
    TransactionType type,
    String category,
    String wallet,
    String toWallet,
    String amount,
  ) {
    final cat = category.isNotEmpty ? category : 'Transaction';
    final amtPart = amount.isNotEmpty ? ' · $amount' : '';
    switch (type) {
      case TransactionType.income:
        final w = wallet.isNotEmpty ? ' to $wallet' : '';
        return 'Adding $cat income$w$amtPart';
      case TransactionType.expense:
        final w = wallet.isNotEmpty ? ' from $wallet' : '';
        return 'Recording $cat expense$w$amtPart';
      case TransactionType.transfer:
        final route = (wallet.isNotEmpty && toWallet.isNotEmpty)
            ? '$wallet → $toWallet'
            : wallet.isNotEmpty
                ? 'from $wallet'
                : 'Transfer';
        return 'Moving $amount${ wallet.isNotEmpty ? "\n$route" : ""}';
    }
  }

  // ── Success subtitle: konfirmasi setelah berhasil ──
  static String _buildSuccessSubtitle(
    TransactionType type,
    String category,
    String wallet,
    String toWallet,
  ) {
    final cat = category.isNotEmpty ? category : 'Transaction';
    switch (type) {
      case TransactionType.income:
        final w = wallet.isNotEmpty ? 'your $wallet wallet' : 'your wallet';
        return '$cat has been added to $w';
      case TransactionType.expense:
        final w = wallet.isNotEmpty ? 'your $wallet wallet' : 'your wallet';
        return '$cat expense recorded from $w';
      case TransactionType.transfer:
        if (wallet.isNotEmpty && toWallet.isNotEmpty) {
          return 'Money moved from $wallet to $toWallet';
        }
        return 'Transfer completed successfully';
    }
  }
}

// ══════════════════════════════════════════════════════════════
// Panel bawah — 47% tinggi layar, rounded top corners
// ══════════════════════════════════════════════════════════════
class _BottomPanel extends StatelessWidget {
  final Widget child;
  const _BottomPanel({required this.child});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: 0.47,
        widthFactor: 1.0,
        child: Material(
          color: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          elevation: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              const SizedBox(height: 14),
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.disabled,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 10),
              // Konten widget
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: child,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
