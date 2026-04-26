import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class FilterExpanse extends StatefulWidget {
  final double sx;
  final double sy;
  final Function(String categoryName)? onCategorySelected;

  const FilterExpanse({
    super.key,
    required this.sx,
    required this.sy,
    this.onCategorySelected,
  });

  @override
  State<FilterExpanse> createState() => _FilterExpanseState();
}

class _FilterExpanseState extends State<FilterExpanse> {
  int _selectedCategoryIndex = -1;

  static final List<_CategoryItem> _categories = [
    _CategoryItem('Entertainment', 'assets/icon/entertainment.svg'),
    _CategoryItem('Food & Drink', 'assets/icon/foods.svg'),
    _CategoryItem('Transportation', 'assets/icon/transportation.svg'),
    _CategoryItem('Shop', 'assets/icon/shop.svg'),
    _CategoryItem('More', 'assets/icon/more.svg'),
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
                      child: SvgPicture.asset(
                        cat.iconAsset,
                        width: 22 * sx,
                        height: 22 * sy,
                        colorFilter: ColorFilter.mode(
                          isSelected
                              ? AppColors.primaryPurple
                              : AppColors.primaryPurple.withValues(alpha: 0.9),
                          BlendMode.srcIn,
                        ),
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

class _CategoryItem {
  final String name;
  final String iconAsset;
  const _CategoryItem(this.name, this.iconAsset);
}
