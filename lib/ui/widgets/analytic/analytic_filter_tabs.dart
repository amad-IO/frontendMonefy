import 'package:flutter/material.dart';
import '../../../theme/colors.dart';

/// Enum untuk periode filter analytics.
/// Index-nya sesuai urutan tab di UI.
enum AnalyticPeriod {
  weekly,  // 0
  monthly, // 1
  yearly,  // 2
}

/// Filter tabs: Weekly · Monthly · Yearly
class AnalyticFilterTabs extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  static const List<String> _labels = ['Weekly', 'Monthly', 'Yearly'];

  const AnalyticFilterTabs({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Animated pill indicator
            LayoutBuilder(
              builder: (context, constraints) {
                final pillWidth = constraints.maxWidth / _labels.length;
                return AnimatedAlign(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOutCubic,
                  alignment: Alignment(
                    -1.0 + (2.0 * selectedIndex / (_labels.length - 1)),
                    0,
                  ),
                  child: Container(
                    width: pillWidth,
                    margin: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: AppColors.primaryPurple,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                );
              },
            ),

            // Labels
            Row(
              children: List.generate(_labels.length, (i) {
                final isActive = i == selectedIndex;
                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onChanged(i),
                    child: Center(
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 13,
                          fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                          color: isActive ? Colors.white : AppColors.textSecondary,
                        ),
                        child: Text(_labels[i]),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
