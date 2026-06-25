import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../data/models/analytic/analytic_models.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/theme/app_colors.dart';
import 'analytic_card_wrapper.dart';

/// Donut chart with total in center + legend on the right
class DonutChartCard extends StatelessWidget {
  final double totalAmount;
  final List<CategoryBreakdown> categories;

  /// true = mode Expense, false = mode Income.
  final bool isExpense;

  const DonutChartCard({
    super.key,
    required this.totalAmount,
    required this.categories,
    this.isExpense = true,
  });

  @override
  Widget build(BuildContext context) {
    return AnalyticCardWrapper(
      padding: const EdgeInsets.all(18),
      child: TweenAnimationBuilder<double>(
        key: ValueKey(
          '${isExpense}_${totalAmount}_${categories.map((c) => '${c.name}:${c.percentage}').join('|')}',
        ),
        tween: Tween<double>(begin: 0, end: 1),
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeOutCubic,
        builder: (context, progress, _) {
          final visibleCategories = categories.take(5).toList();

          return LayoutBuilder(
            builder: (context, constraints) {
              final useStackedLayout = constraints.maxWidth < 330;
              final chart = _DonutVisual(
                totalAmount: totalAmount,
                categories: categories,
                isExpense: isExpense,
                progress: progress,
              );
              final legend = _LegendPanel(
                categories: visibleCategories,
                progress: progress,
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CardHeader(
                    title: isExpense ? 'Spending Breakdown' : 'Income Breakdown',
                    count: categories.length,
                  ),
                  const SizedBox(height: 16),
                  if (useStackedLayout) ...[
                    Center(child: chart),
                    const SizedBox(height: 18),
                    legend,
                  ] else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        chart,
                        const SizedBox(width: 18),
                        Expanded(child: legend),
                      ],
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }

}

class _CardHeader extends StatelessWidget {
  final String title;
  final int count;

  const _CardHeader({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.dashboardPurple.withValues(alpha: 0.52),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            '$count cat.',
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryPurple,
            ),
          ),
        ),
      ],
    );
  }
}

class _DonutVisual extends StatelessWidget {
  final double totalAmount;
  final List<CategoryBreakdown> categories;
  final bool isExpense;
  final double progress;

  const _DonutVisual({
    required this.totalAmount,
    required this.categories,
    required this.isExpense,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final amountColor = isExpense ? AppColors.expenseRed : AppColors.incomeGreen;
    const centerSize = 88.0;

    return SizedBox(
      width: 168,
      height: 168,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 144,
            height: 144,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.dashboardPurple.withValues(alpha: 0.18),
            ),
          ),
          PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 49,
              sections: _buildSections(progress),
              startDegreeOffset: -90,
            ),
          ),
          SizedBox(
            width: centerSize,
            height: centerSize,
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: centerSize,
                      child: Text(
                        isExpense ? 'Total Expense' : 'Total Income',
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.disabled,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 260),
                      child: SizedBox(
                        key: ValueKey('${isExpense}_$totalAmount'),
                        width: centerSize,
                        child: Text(
                          rupiahFormatter.format(totalAmount),
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.visible,
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: amountColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildSections(double progress) {
    final totalPercentage = categories.fold<double>(
      0,
      (total, cat) => total + cat.percentage,
    );

    if (categories.isEmpty || totalPercentage <= 0) {
      return [
        PieChartSectionData(
          value: 1,
          color: AppColors.chartEmpty,
          radius: 24,
          title: '',
          showTitle: false,
        )
      ];
    }

    final visibleProgress = progress <= 0 ? 0.001 : progress;
    return categories.map((cat) {
      final isLeading = cat == _leadingCategory;
      final radiusBoost = isLeading
          ? 3 * progress.clamp(0.0, 1.0).toDouble()
          : 0.0;
      return PieChartSectionData(
        value: cat.percentage * visibleProgress,
        color: cat.color,
        radius: 24 + radiusBoost,
        title: '',
        showTitle: false,
      );
    }).toList();
  }

  CategoryBreakdown? get _leadingCategory {
    if (categories.isEmpty) return null;
    return categories.reduce(
      (current, next) => next.percentage > current.percentage ? next : current,
    );
  }

}

class _LegendPanel extends StatelessWidget {
  final List<CategoryBreakdown> categories;
  final double progress;

  const _LegendPanel({
    required this.categories,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const _EmptyLegend();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ...categories.map((cat) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _LegendRow(category: cat, progress: progress),
          );
        }),
      ],
    );
  }
}

class _LegendRow extends StatelessWidget {
  final CategoryBreakdown category;
  final double progress;

  const _LegendRow({required this.category, required this.progress});

  @override
  Widget build(BuildContext context) {
    final animatedPercent = category.percentage * progress;
    final animatedValue = (category.percentage / 100 * progress)
        .clamp(0.0, 1.0)
        .toDouble();

    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: category.color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                category.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textTertiary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${animatedPercent.toStringAsFixed(0)}%',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: category.color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: animatedValue,
            minHeight: 5,
            backgroundColor: AppColors.divider,
            valueColor: AlwaysStoppedAnimation(category.color),
          ),
        ),
      ],
    );
  }
}

class _EmptyLegend extends StatelessWidget {
  const _EmptyLegend();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.neutralBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Text(
        'No category data yet',
        style: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.disabled,
        ),
      ),
    );
  }
}
