import 'package:flutter/material.dart';

/// ══════════════════════════════════════════════════════════════
/// Shared card wrapper untuk semua analytic cards.
///
/// Menggantikan duplikasi dekorasi Container yang sama
/// di 4 widget: DonutChart, CategoryBreakdown, DailyOverview,
/// MonthlyComparison.
/// ══════════════════════════════════════════════════════════════
class AnalyticCardWrapper extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const AnalyticCardWrapper({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: padding ?? const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
