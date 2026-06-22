import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../pages/add_page.dart';

class SavingCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback? onTap;

  const SavingCard({super.key, required this.item, this.onTap});

  bool get _isDone => item['isDone'] == true;
  int get _target => item['target'] as int? ?? 0;
  String get _name => item['name']?.toString() ?? 'Wishlist goal';

  String get _dateLabel {
    final date = DateTime.tryParse(item['date']?.toString() ?? '');
    if (date == null) return 'No target date';
    return 'Target ${DateFormat('d MMM yyyy', 'en_US').format(date)}';
  }

  void _openBuyPage(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddPage(
        savingData: {'id': item['id'], 'name': _name, 'amount': _target},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = _isDone ? AppColors.incomeGreen : AppColors.primaryPurple;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.panelWhite,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: accent.withValues(alpha: 0.12)),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.lightShadow,
                  blurRadius: 14,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: _isDone
                        ? AppColors.incomeGradient
                        : AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _isDone ? Icons.check_rounded : Icons.savings_rounded,
                    color: AppColors.panelWhite,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _isDone
                                  ? AppColors.incomeGreenBg
                                  : AppColors.dashboardPurple,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _isDone ? 'Completed' : 'Ongoing',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: accent,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _dateLabel,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 13),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              rupiahFormatter.format(_target),
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: accent,
                              ),
                            ),
                          ),
                          if (!_isDone)
                            Material(
                              color: AppColors.primaryPurple,
                              borderRadius: BorderRadius.circular(14),
                              child: InkWell(
                                onTap: () => _openBuyPage(context),
                                borderRadius: BorderRadius.circular(14),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  child: Text(
                                    'Buy now',
                                    style: TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.panelWhite,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
