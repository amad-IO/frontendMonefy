import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/summary_model.dart';
import '../../theme/colors.dart';
import '../../theme/text_style.dart';

class SummaryCard extends StatefulWidget {
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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
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
  String _formatRupiah(double amount) {
    final formatter = NumberFormat('#,##0', 'id_ID');
    return 'Rp. ${formatter.format(amount)},00';
  }

  String _maskedOrReal(double amount) {
    return _isHidden ? '••••••••' : _formatRupiah(amount);
  }
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 360;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Stack(
            children: [
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
                padding: EdgeInsets.all(isCompact ? 16 : 22),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Total Balance',
                          style: AppTextStyle.caption.copyWith(
                            color: colorScheme.onPrimary.withValues(alpha: 0.85),
                            fontSize: isCompact ? 12 : 13,
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
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          _maskedOrReal(widget.summary.totalBalance),
                          key: ValueKey(_isHidden),
                          maxLines: 1,
                          style: AppTextStyle.heading.copyWith(
                            color: colorScheme.onPrimary,
                            fontSize: isCompact ? 22 : 26,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    if (isCompact)
                      Column(
                        children: [
                          _GlassSubCard(
                            label: 'Income',
                            filterLabel: _filterLabel,
                            amount: _maskedOrReal(widget.summary.totalIncome),
                            isIncome: true,
                            isCompact: true,
                          ),
                          const SizedBox(height: 10),
                          _GlassSubCard(
                            label: 'Expense',
                            filterLabel: _filterLabel,
                            amount: _maskedOrReal(widget.summary.totalExpense),
                            isIncome: false,
                            isCompact: true,
                          ),
                        ],
                      )
                    else
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
      },
    );
  }
}
class _GlassSubCard extends StatelessWidget {
  final String label;
  final String filterLabel;
  final String amount;
  final bool isIncome;
  final bool isCompact;

  const _GlassSubCard({
    required this.label,
    required this.filterLabel,
    required this.amount,
    required this.isIncome,
    this.isCompact = false,
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
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 12 : 14,
            vertical: isCompact ? 10 : 12,
          ),
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
                  Expanded(
                    child: Wrap(
                      spacing: 3,
                      runSpacing: 0,
                      children: [
                        Text(
                          label,
                          style: AppTextStyle.caption.copyWith(
                            color: colorScheme.onPrimary.withValues(alpha: 0.85),
                            fontSize: isCompact ? 10 : 11,
                          ),
                        ),
                        Text(
                          filterLabel,
                          style: AppTextStyle.caption.copyWith(
                            color: colorScheme.onPrimary.withValues(alpha: 0.5),
                            fontSize: isCompact ? 9 : 10,
                          ),
                        ),
                      ],
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
                    maxLines: 1,
                    style: AppTextStyle.title.copyWith(
                      color: colorScheme.onPrimary,
                      fontSize: isCompact ? 12 : 13,
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