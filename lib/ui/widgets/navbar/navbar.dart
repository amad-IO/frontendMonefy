import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../theme/colors.dart';

class CustomNavbar extends StatelessWidget {
  const CustomNavbar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double bottomInset = MediaQuery.paddingOf(context).bottom;
    final double scale = (screenWidth / 430).clamp(0.82, 1.0);
    final double iconSize = 27 * scale;
    final double activeIconScale = 1.02;
    final double labelSize = 14 * scale;
    final double addLabelSize = 13 * scale;
    final double itemSpacing = 1 * scale;
    final double indicatorHeight = 10 * scale;
    final double indicatorSpacing = 1 * scale;
    final double estimatedTextHeight = labelSize * 1.05;
    final double addLabelHeight = addLabelSize;
    final double requiredItemHeight =
      indicatorHeight +
      indicatorSpacing +
      (iconSize * activeIconScale) +
      itemSpacing +
      estimatedTextHeight;
    final double rowBottomPadding = (1.5 * scale) + bottomInset;
    final double navContentHeight =
      (requiredItemHeight + addLabelHeight + rowBottomPadding + (6 * scale));
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final Color addLabelColor = selectedIndex == 2
        ? colorScheme.primary
        : colorScheme.onSurface.withValues(alpha: 0.45);

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.09),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: BottomAppBar(
        color: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
        shadowColor: Colors.transparent,
        notchMargin: 16,
        shape: const CircularNotchedRectangle(),
        child: SizedBox(
          height: navContentHeight,
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(8 * scale, 4 * scale, 8 * scale, rowBottomPadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildNavItem(
                      context: context,
                      index: 0,
                      label: 'Home',
                      asset: 'assets/icon/home.svg',
                      scale: scale,
                      iconSize: iconSize,
                      labelSize: labelSize,
                      activeIconScale: activeIconScale,
                    ),
                    SizedBox(width: 10 * scale),
                    Transform.translate(
                      offset: Offset(-6 * scale, 0),
                      child: _buildNavItem(
                        context: context,
                        index: 1,
                        label: 'History',
                        asset: 'assets/icon/history.svg',
                        scale: scale,
                        iconSize: iconSize,
                        labelSize: labelSize,
                        activeIconScale: activeIconScale,
                      ),
                    ),
                    SizedBox(width: 74 * scale),
                    Transform.translate(
                      offset: Offset(6 * scale, 0),
                      child: _buildNavItem(
                        context: context,
                        index: 3,
                        label: 'Analytic',
                        asset: 'assets/icon/Analytic.svg',
                        scale: scale,
                        iconSize: iconSize,
                        labelSize: labelSize,
                        activeIconScale: activeIconScale,
                      ),
                    ),
                    SizedBox(width: 10 * scale),
                    _buildNavItem(
                      context: context,
                      index: 4,
                      label: 'Profile',
                      asset: 'assets/icon/Profile.svg',
                      scale: scale,
                      iconSize: iconSize,
                      labelSize: labelSize,
                      activeIconScale: activeIconScale,
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 1 * scale + bottomInset,
                child: Text(
                  'Add',
                  textAlign: TextAlign.center,
                  textScaler: TextScaler.noScaling,
                  style: (textTheme.bodySmall ?? const TextStyle()).copyWith(
                    color: addLabelColor,
                    fontSize: addLabelSize,
                    fontWeight: FontWeight.w800,
                    height: 1.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required String label,
    required String asset,
    required double scale,
    required double iconSize,
    required double labelSize,
    required double activeIconScale,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final bool isActive = selectedIndex == index;
    final Color itemColor = isActive
      ? colorScheme.primary
      : colorScheme.onSurface.withValues(alpha: 0.45);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onItemTapped(index),
      child: SizedBox(
        width: 58 * scale,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double maxHeight = constraints.maxHeight.isFinite
                ? constraints.maxHeight
                : (56 * scale);
            final double baseIndicatorHeight = 10 * scale;
            final double baseGap = 1 * scale;
            final double baseIconSize = iconSize;
            final double baseLabelHeight = labelSize * 1.05;
            final double neededHeight =
                baseIndicatorHeight +
                baseGap +
                (baseIconSize * activeIconScale) +
                baseGap +
                baseLabelHeight;
            final double fit = (maxHeight / neededHeight).clamp(0.88, 1.0);

            final double indicatorHeight = baseIndicatorHeight * fit;
            final double gap = baseGap * fit;
            final double iconSizeAdaptive = baseIconSize * fit;
            final double labelFontSize = labelSize * fit;

            return Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: indicatorHeight,
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      switchInCurve: Curves.easeOutBack,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: ScaleTransition(scale: animation, child: child),
                        );
                      },
                      child: isActive
                          ? SvgPicture.asset(
                              'assets/icon/navActive.svg',
                              key: const ValueKey('active-dot'),
                              width: 9 * scale * fit,
                              height: 9 * scale * fit,
                            )
                          : const SizedBox(key: ValueKey('inactive-dot')),
                    ),
                  ),
                ),
                SizedBox(height: gap),
                AnimatedScale(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutBack,
                  scale: isActive
                      ? (1.0 + ((activeIconScale - 1.0) * fit))
                      : 1.0,
                  child: SizedBox(
                    width: iconSizeAdaptive,
                    height: iconSizeAdaptive,
                    child: SvgPicture.asset(
                      asset,
                      colorFilter: ColorFilter.mode(itemColor, BlendMode.srcIn),
                    ),
                  ),
                ),
                SizedBox(height: gap),
                Flexible(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    style: (textTheme.bodySmall ?? const TextStyle()).copyWith(
                      fontSize: labelFontSize,
                      fontWeight: isActive ? FontWeight.w800 : FontWeight.w700,
                      color: itemColor,
                      height: 1.0,
                    ),
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      textScaler: TextScaler.noScaling,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class CustomAddFab extends StatelessWidget {
  const CustomAddFab({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70,
      height: 70,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: onPressed,
          backgroundColor: AppColors.primaryPurple,
          elevation: 0,
          highlightElevation: 0,
          shape: const CircleBorder(),
          child: SvgPicture.asset(
            'assets/icon/add.svg',
            width: 30,
            height: 30,
            colorFilter: ColorFilter.mode(
              Theme.of(context).colorScheme.onPrimary,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}
