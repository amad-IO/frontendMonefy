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
      child: Row(
        children: [
          // Income tab
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                height: 44,
                decoration: BoxDecoration(
                  color: !isExpenseSelected
                      ? AppColors.primaryPurple.withValues(alpha: 0.08)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: !isExpenseSelected
                      ? Border.all(color: AppColors.primaryPurple, width: 1.5)
                      : Border.all(color: Colors.grey.shade300),
                ),
                child: Center(
                  child: Text(
                    'Income',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: !isExpenseSelected
                          ? AppColors.primaryPurple
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Expense tab
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                height: 44,
                decoration: BoxDecoration(
                  color: isExpenseSelected
                      ? AppColors.expenseRedBg
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: isExpenseSelected
                      ? Border.all(color: AppColors.expenseRed, width: 1.5)
                      : Border.all(color: Colors.grey.shade300),
                ),
                child: Center(
                  child: Text(
                    'Expense',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isExpenseSelected
                          ? AppColors.expenseRed
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
