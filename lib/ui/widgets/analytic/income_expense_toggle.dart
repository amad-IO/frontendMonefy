import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Toggle between Income and Expense views
class IncomeExpenseToggle extends StatelessWidget {
  final bool isExpenseSelected;
  final ValueChanged<bool> onChanged;

  const IncomeExpenseToggle({
    super.key,
    required this.isExpenseSelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 48,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.dashboardPurple.withValues(alpha: 0.62),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeInOutCubic,
              alignment: isExpenseSelected
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: 0.5,
                heightFactor: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.panelWhite,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.lightShadow,
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Row(
              children: [
                _ToggleItem(
                  label: 'Income',
                  icon: Icons.arrow_downward_rounded,
                  selected: !isExpenseSelected,
                  selectedColor: AppColors.incomeGreen,
                  onTap: () => onChanged(false),
                ),
                _ToggleItem(
                  label: 'Expense',
                  icon: Icons.arrow_upward_rounded,
                  selected: isExpenseSelected,
                  selectedColor: AppColors.expenseRed,
                  onTap: () => onChanged(true),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color selectedColor;
  final VoidCallback onTap;

  const _ToggleItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.selectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: selected
                      ? selectedColor.withValues(alpha: 0.14)
                      : AppColors.panelWhite.withValues(alpha: 0.55),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 13,
                  color: selected ? selectedColor : AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 7),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: selected ? selectedColor : AppColors.textSecondary,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
