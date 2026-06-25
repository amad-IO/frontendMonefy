import 'package:flutter/material.dart';
import '../../../data/models/analytic/analytic_models.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/theme/app_colors.dart';
import 'analytic_card_wrapper.dart';
import 'category_icon.dart';

/// List of category items with progress bar + percentage + amount
class CategoryBreakdownList extends StatelessWidget {
  final List<CategoryBreakdown> categories;

  const CategoryBreakdownList({
    super.key,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    return AnalyticCardWrapper(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: categories.map((cat) {
          return TweenAnimationBuilder<double>(
            key: ValueKey('${cat.name}_${cat.percentage}_${cat.amount}'),
            tween: Tween<double>(
              begin: 0,
              end: (cat.percentage / 100).clamp(0.0, 1.0).toDouble(),
            ),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  children: [
                    // Category icon — reusable widget
                    CategoryIcon(category: cat),

                    const SizedBox(width: 12),

                    // Name + progress bar
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cat.name,
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Progress bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: value,
                              backgroundColor: AppColors.divider,
                              valueColor: AlwaysStoppedAnimation(cat.color),
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Percentage + amount
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 240),
                          child: Text(
                            '${cat.percentage.toStringAsFixed(0)}%',
                            key: ValueKey('${cat.name}_${cat.percentage}'),
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: cat.color,
                            ),
                          ),
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 240),
                          child: Text(
                            rupiahFormatter.format(cat.amount),
                            key: ValueKey('${cat.name}_${cat.amount}'),
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 11,
                              color: AppColors.disabled,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}
