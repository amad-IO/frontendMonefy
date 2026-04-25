import 'package:flutter/material.dart';
import '../../../utils/sentiment_helper.dart';

/// Alert card showing change percentage from last period.
///
/// Logika warna **terbalik** antara Income dan Expense
/// (menggunakan shared [sentimentHelper]):
///   • Expense naik  → 🔴 BURUK (pengeluaran bertambah)
///   • Expense turun → 🟢 BAGUS (pengeluaran berkurang)
///   • Income naik   → 🟢 BAGUS (pemasukan bertambah)
///   • Income turun  → 🔴 BURUK (pemasukan berkurang)
class ExpenseAlertCard extends StatelessWidget {
  final double changePercent;

  /// true = mode Expense, false = mode Income.
  final bool isExpense;

  const ExpenseAlertCard({
    super.key,
    required this.changePercent,
    this.isExpense = true,
  });

  @override
  Widget build(BuildContext context) {
    final typeLabel = isExpense ? 'Expenses' : 'Income';

    // ── Case 1: Tidak ada data periode lalu ──────────────────
    if (changePercent.isInfinite) {
      return _buildCard(
        bgColor: const Color(0xFFE3F2FD),
        textColor: const Color(0xFF1565C0),
        icon: Icons.info_outline_rounded,
        label: 'First period with $typeLabel — no previous data to compare.',
      );
    }

    // ── Case 2: Tidak ada perubahan (0%) ─────────────────────
    if (changePercent == 0.0) {
      return _buildCard(
        bgColor: const Color(0xFFF5F5F5),
        textColor: const Color(0xFF757575),
        icon: Icons.remove_circle_outline_rounded,
        label: 'No $typeLabel change from last period.',
      );
    }

    // ── Case 3: Ada data perbandingan ────────────────────────
    final isUp = changePercent >= 0;
    final positive = isPositiveSentiment(isExpense: isExpense, isUp: isUp);

    final icon = isUp
        ? Icons.trending_up_rounded
        : Icons.trending_down_rounded;
    final direction = isUp ? 'up' : 'down';
    final label =
        '$typeLabel $direction ${changePercent.abs().toStringAsFixed(1)}% from last period';

    return _buildCard(
      bgColor: sentimentBgColor(positive),
      textColor: sentimentColor(positive),
      icon: icon,
      label: label,
    );
  }

  /// Widget builder yang di-reuse untuk semua case.
  Widget _buildCard({
    required Color bgColor,
    required Color textColor,
    required IconData icon,
    required String label,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: textColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: textColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
