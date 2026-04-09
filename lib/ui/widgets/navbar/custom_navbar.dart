import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../theme/colors.dart';
import '../../theme/text_style.dart';

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
    final double estimatedTextHeight = labelSize * 1.05;
    final double addLabelHeight = addLabelSize;
    final double requiredItemHeight =
        (iconSize * activeIconScale) + itemSpacing + estimatedTextHeight;
    final double rowBottomPadding = (3 * scale) + bottomInset;
    final double navContentHeight =
        (requiredItemHeight + addLabelHeight + rowBottomPadding + (8 * scale));
    final Color addLabelColor = selectedIndex == 2
        ? AppColors.primaryPurple
        : AppColors.disabled;

    return BottomAppBar(
      color: Colors.white,
      elevation: 8,
      notchMargin: 16,
      shape: const CircularNotchedRectangle(),
      child: SizedBox(
        height: navContentHeight,
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(8 * scale, 4 * scale, 8 * scale, rowBottomPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    index: 0,
                    label: 'Home',
                    asset: 'assets/icon/home.svg',
                    scale: scale,
                    iconSize: iconSize,
                    labelSize: labelSize,
                    activeIconScale: activeIconScale,
                  ),
                  _buildNavItem(
                    index: 1,
                    label: 'History',
                    asset: 'assets/icon/history.svg',
                    scale: scale,
                    iconSize: iconSize,
                    labelSize: labelSize,
                    activeIconScale: activeIconScale,
                  ),
                  SizedBox(width: 52 * scale),
                  _buildNavItem(
                    index: 3,
                    label: 'Analytic',
                    asset: 'assets/icon/Analytic.svg',
                    scale: scale,
                    iconSize: iconSize,
                    labelSize: labelSize,
                    activeIconScale: activeIconScale,
                  ),
                  _buildNavItem(
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
              bottom: 0.5 * scale + bottomInset,
              child: Text(
                'Add',
                textAlign: TextAlign.center,
                textScaler: TextScaler.noScaling,
                style: TextStyle(
                  color: addLabelColor,
                  fontSize: addLabelSize,
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w800,
                  height: 1.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String label,
    required String asset,
    required double scale,
    required double iconSize,
    required double labelSize,
    required double activeIconScale,
  }) {
    final bool isActive = selectedIndex == index;
    final Color itemColor = isActive
        ? AppColors.primaryPurple
        : AppColors.disabled;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onItemTapped(index),
      child: SizedBox(
        width: 58 * scale,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 1 * scale),
            AnimatedScale(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutBack,
              scale: isActive ? activeIconScale : 1.0,
              child: SizedBox(
                width: iconSize,
                height: iconSize,
                child: SvgPicture.asset(
                  asset,
                  colorFilter: ColorFilter.mode(itemColor, BlendMode.srcIn),
                ),
              ),
            ),
            SizedBox(height: 1 * scale),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              style: (isActive ? AppTextStyle.navbarActive : AppTextStyle.navbar)
                  .copyWith(
                fontSize: labelSize,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w700,
                color: itemColor,
                height: 1.05,
              ),
              child: Text(
                label,
                textAlign: TextAlign.center,
                textScaler: TextScaler.noScaling,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
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
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: AppColors.primaryPurple,
        elevation: 8,
        highlightElevation: 8,
        shape: const CircleBorder(),
        child: SvgPicture.asset(
          'assets/icon/add.svg',
          width: 30,
          height: 30,
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        ),
      ),
    );
  }
}
