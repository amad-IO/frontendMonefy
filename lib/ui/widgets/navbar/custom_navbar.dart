import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../theme/colors.dart' as theme;

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
    final double scale = (screenWidth / 430).clamp(0.82, 1.0);
    final Color addLabelColor = selectedIndex == 2
        ? theme.AppColors.primaryPurple
        : theme.AppColors.disabled;

    return BottomAppBar(
      color: Colors.white,
      elevation: 8,
      notchMargin: 14,
      shape: const CircularNotchedRectangle(),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: 72 * scale,
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(6 * scale, 2 * scale, 6 * scale, 3 * scale),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(index: 0, label: 'Home', asset: 'assets/icon/home.svg', scale: scale),
                  _buildNavItem(index: 1, label: 'History', asset: 'assets/icon/history.svg', scale: scale),
                  SizedBox(width: 52 * scale),
                  _buildNavItem(index: 3, label: 'Analytic', asset: 'assets/icon/Analytic.svg', scale: scale),
                  _buildNavItem(index: 4, label: 'Profile', asset: 'assets/icon/Profile.svg', scale: scale),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 3 * scale,
              child: Text(
                'Add',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: addLabelColor,
                  fontSize: 11 * scale,
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w700,
                  height: 1.1,
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
  }) {
    final bool isActive = selectedIndex == index;
    final Color itemColor = isActive
        ? theme.AppColors.primaryPurple
        : theme.AppColors.disabled;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onItemTapped(index),
      child: SizedBox(
        width: 54 * scale,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 9 * scale,
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
                          width: 8 * scale,
                          height: 8 * scale,
                        )
                      : const SizedBox(key: ValueKey('inactive-dot')),
                ),
              ),
            ),
            SizedBox(height: 3 * scale),
            AnimatedScale(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutBack,
              scale: isActive ? 1.14 : 1.0,
              child: SizedBox(
                width: 25 * scale,
                height: 25 * scale,
                child: SvgPicture.asset(
                  asset,
                  colorFilter: ColorFilter.mode(itemColor, BlendMode.srcIn),
                ),
              ),
            ),
            SizedBox(height: 6 * scale),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              style: TextStyle(
                color: itemColor,
                fontSize: 10.8 * scale,
                fontFamily: 'Nunito',
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w700,
                height: 1.1,
              ),
              child: Text(
                label,
                textAlign: TextAlign.center,
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
      width: 68,
      height: 68,
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: theme.AppColors.primaryPurple,
        elevation: 8,
        highlightElevation: 8,
        shape: const CircleBorder(),
        child: SvgPicture.asset(
          'assets/icon/add.svg',
          width: 28,
          height: 28,
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        ),
      ),
    );
  }
}
