import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class FilterExpanse extends StatefulWidget {
  final double sx;
  final double sy;
  final String? selectedCategory;
  final Function(String categoryName)? onCategorySelected;

  const FilterExpanse({
    super.key,
    required this.sx,
    required this.sy,
    this.selectedCategory,
    this.onCategorySelected,
  });

  @override
  State<FilterExpanse> createState() => _FilterExpanseState();
}

class _FilterExpanseState extends State<FilterExpanse> {
  int _selectedCategoryIndex = -1;

  static final List<_CategoryItem> _categories = [
    _CategoryItem('Entertainment', 'assets/icon/entertainment.svg', [
      Color(0xFFFF7C9A),
      AppColors.confettiRed,
    ]),
    _CategoryItem('Food & Drink', 'assets/icon/foods.svg', [
      Color(0xFFFFB15C),
      AppColors.transferOrange,
    ]),
    _CategoryItem('Transportation', 'assets/icon/transportation.svg', [
      Color(0xFF60A5FA),
      AppColors.confettiBlue,
    ]),
    _CategoryItem('Shop', 'assets/icon/shop.svg', [
      Color(0xFF4ADE80),
      AppColors.incomeGreen,
    ]),
    _CategoryItem('More', 'assets/icon/more.svg', [
      Color(0xFFB29CF6),
      AppColors.primaryPurple,
    ]),
  ];

  @override
  void initState() {
    super.initState();
    _syncSelectedCategory();
  }

  @override
  void didUpdateWidget(covariant FilterExpanse oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedCategory != widget.selectedCategory) {
      _syncSelectedCategory();
    }
  }

  void _syncSelectedCategory() {
    _selectedCategoryIndex = _categories.indexWhere(
      (category) => category.name == widget.selectedCategory,
    );
  }

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
        separatorBuilder: (_, _) => SizedBox(width: 8 * sx),
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
                  AnimatedScale(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutBack,
                    scale: isSelected ? 1.08 : 1,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 50 * sx,
                      height: 50 * sy,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isSelected
                              ? cat.gradient
                              : [
                                  cat.gradient.first.withValues(alpha: 0.18),
                                  cat.gradient.last.withValues(alpha: 0.08),
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.panelWhite
                              : cat.gradient.last.withValues(alpha: 0.12),
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: cat.gradient.last.withValues(
                              alpha: isSelected ? 0.30 : 0.12,
                            ),
                            blurRadius: isSelected ? 14 : 9,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: cat.name == 'More'
                          ? SvgPicture.asset(
                              'assets/icon/category_more_outline.svg',
                              width: 22 * sx,
                              height: 22 * sy,
                              fit: BoxFit.scaleDown,
                              colorFilter: ColorFilter.mode(
                                isSelected
                                    ? AppColors.panelWhite
                                    : cat.gradient.last,
                                BlendMode.srcIn,
                              ),
                            )
                          : SvgPicture.asset(
                              cat.iconAsset,
                              width: 23 * sx,
                              height: 23 * sy,
                              fit: BoxFit.scaleDown,
                              colorFilter: ColorFilter.mode(
                                isSelected
                                    ? AppColors.panelWhite
                                    : cat.gradient.last,
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
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w600,
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
  final List<Color> gradient;
  const _CategoryItem(this.name, this.iconAsset, this.gradient);
}
