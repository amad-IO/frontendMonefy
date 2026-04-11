import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/summary_model.dart';
import '../../theme/colors.dart';
import '../../theme/text_style.dart';

class SummaryCard extends StatefulWidget {
  /// Data ringkasan saldo.
  final SummaryModel summary;

  const SummaryCard({
    super.key,
    required this.summary,
  });

  @override
  State<SummaryCard> createState() => _SummaryCardState();
}

class _SummaryCardState extends State<SummaryCard>
    with SingleTickerProviderStateMixin {
  bool _isHidden = false;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleVisibility() {
    setState(() => _isHidden = !_isHidden);
    if (_isHidden) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  /// Ubah angka ke format Rupiah.
  String _formatRupiah(double amount) {
    final formatter = NumberFormat('#,##0', 'id_ID');
    return 'Rp. ${formatter.format(amount)},00';
  }

  String _maskedOrReal(double amount) {
    return _isHidden ? '••••••••' : _formatRupiah(amount);
  }

  /// Label periode ringkasan.
  String get _filterLabel {
    switch (widget.summary.filterLabel) {
      case 'day':
        return '/ day';
      case 'week':
        return '/ week';
      case 'month':
        return '/ month';
      case 'year':
        return '/ year';
      default:
        return '/ month';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          // Dekorasi latar.
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.onPrimary.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.onPrimary.withValues(alpha: 0.06),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Total Balance',
                      style: AppTextStyle.caption.copyWith(
                        color: colorScheme.onPrimary.withValues(alpha: 0.85),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _toggleVisibility,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: Icon(
                          _isHidden
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          key: ValueKey(_isHidden),
                          color: colorScheme.onPrimary.withValues(alpha: 0.85),
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    _maskedOrReal(widget.summary.totalBalance),
                    key: ValueKey(_isHidden),
                    style: AppTextStyle.heading.copyWith(
                      color: colorScheme.onPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: _GlassSubCard(
                        label: 'Income',
                        filterLabel: _filterLabel,
                        amount: _maskedOrReal(widget.summary.totalIncome),
                        isIncome: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _GlassSubCard(
                        label: 'Expense',
                        filterLabel: _filterLabel,
                        amount: _maskedOrReal(widget.summary.totalExpense),
                        isIncome: false,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Kartu kecil untuk income/expense.
class _GlassSubCard extends StatelessWidget {
  final String label;
  final String filterLabel;
  final String amount;
  final bool isIncome;

  const _GlassSubCard({
    required this.label,
    required this.filterLabel,
    required this.amount,
    required this.isIncome,
  });

  Color get _arrowColor =>
      isIncome ? AppColors.success : AppColors.error;

  IconData get _arrowIcon =>
      isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        // Efek blur tipis.
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: colorScheme.onPrimary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.onPrimary.withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: _arrowColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _arrowIcon,
                      color: colorScheme.onPrimary,
                      size: 13,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: AppTextStyle.caption.copyWith(
                      color: colorScheme.onPrimary.withValues(alpha: 0.85),
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    filterLabel,
                    style: AppTextStyle.caption.copyWith(
                      color: colorScheme.onPrimary.withValues(alpha: 0.5),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Padding(
                padding: const EdgeInsets.only(left: 2),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    amount,
                    key: ValueKey(amount),
                    style: AppTextStyle.title.copyWith(
                      color: colorScheme.onPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}