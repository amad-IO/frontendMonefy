import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class TransactionTypeSelector extends StatefulWidget {
  final Function(String) onChanged;
  final String initialValue; // ← tambah initial value

  const TransactionTypeSelector({
    super.key,
    required this.onChanged,
    this.initialValue = 'Income', // default 'Income' agar backward compat
  });

  @override
  State<TransactionTypeSelector> createState() =>
      _TransactionTypeSelectorState();
}

class _TransactionTypeSelectorState
    extends State<TransactionTypeSelector> {
  late String selected;

  final List<String> types = ["Cash", "Bank", "E-Wallet"];

  @override
  void initState() {
    super.initState();
    selected = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.primaryPurple.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: AppColors.primaryPurple.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: types.map((type) => _buildItem(type)).toList(),
      ),
    );
  }

  Widget _buildItem(String type) {
    final isActive = selected == type;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selected = type;
          });
          widget.onChanged(type);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primaryPurple
                : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Center(
            child: Text(
              type,
              style: TextStyle(
                color: isActive
                    ? Colors.white
                    : AppColors.primaryPurple,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}