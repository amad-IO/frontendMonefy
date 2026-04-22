import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/text_style.dart';

/// Income category selector — mirrors [FilterExpanse] but with
/// income-specific categories using Material icons.
class FilterIncome extends StatefulWidget {
  final double sx;
  final double sy;
  final Function(String categoryName)? onCategorySelected;

  const FilterIncome({
    super.key,
    required this.sx,
    required this.sy,
    this.onCategorySelected,
  });

  @override
  State<FilterIncome> createState() => _FilterIncomeState();
}

class _FilterIncomeState extends State<FilterIncome> {
  int _selectedCategoryIndex = -1;

  static final List<_IncomeCategoryItem> _categories = [
    _IncomeCategoryItem('Salary', Icons.account_balance_wallet_rounded),
    _IncomeCategoryItem('Freelance', Icons.work_rounded),
    _IncomeCategoryItem('Gift', Icons.card_giftcard_rounded),
    _IncomeCategoryItem('Investment', Icons.trending_up_rounded),
    _IncomeCategoryItem('More', Icons.more_horiz_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final double sx = widget.sx;
    final double sy = widget.sy;
    final double itemWidth = 64 * sx;

    return SizedBox(
      height: 88 * sy,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        clipBehavior: Clip.none,
        padding: EdgeInsets.symmetric(horizontal: 12 * sx),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => SizedBox(width: 8 * sx),
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _selectedCategoryIndex == index;

          return GestureDetector(
            onTap: () {
              setState(() => _selectedCategoryIndex = index);
              if (widget.onCategorySelected != null) {
                widget.onCategorySelected!(cat.name);
              }
            },
            child: SizedBox(
              width: itemWidth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 48 * sx,
                    height: 48 * sy,
                    decoration: ShapeDecoration(
                      color: isSelected
                          ? AppColors.dashboardPurple
                          : AppColors.white2,
                      shape: OvalBorder(
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.primaryPurple
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      shadows: const [
                        BoxShadow(
                          color: AppColors.subtleShadow,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        cat.icon,
                        size: 22 * sx,
                        color: isSelected
                            ? AppColors.primaryPurple
                            : AppColors.primaryPurple.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                  SizedBox(height: 6 * sy),
                  Text(
                    cat.name,
                    style: AppTextStyle.caption.copyWith(
                      fontSize: 10 * sx,
                      color: AppColors.textPrimary,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _IncomeCategoryItem {
  final String name;
  final IconData icon;
  const _IncomeCategoryItem(this.name, this.icon);
}
