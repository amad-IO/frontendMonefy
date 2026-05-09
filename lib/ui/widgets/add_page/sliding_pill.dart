import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class SlidingPill extends StatelessWidget {
  final int typeIndex;
  final Function(int) onTap;
  final double sx;
  final double sy;

  const SlidingPill({
    super.key,
    required this.typeIndex,
    required this.onTap,
    required this.sx,
    required this.sy,
  });

  static const List<String> tabLabels = ['Income', 'Expense', 'Transfer'];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40 * sy,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.45),
          width: 1.2,
        ),
      ),
      child: Stack(
        children: [
          LayoutBuilder(
            builder: (context, c) {
              final pillW = c.maxWidth / tabLabels.length;
              final alignment = Alignment(
                -1.0 + (2.0 * typeIndex / (tabLabels.length - 1)),
                0,
              );
              return AnimatedAlign(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeInOutCubic,
                alignment: alignment,
                child: Container(
                  width: pillW,
                  margin: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.10),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          Row(
            children: List.generate(tabLabels.length, (index) {
              final isActive = typeIndex == index;

              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(index),
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 220),
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 13 * sx,
                        fontWeight:
                        isActive ? FontWeight.w800 : FontWeight.w500,
                        color: isActive
                            ? AppColors.primaryPurple
                            : Colors.white.withValues(alpha: 0.85),
                      ),
                      child: Text(tabLabels[index]),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}