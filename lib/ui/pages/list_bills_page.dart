import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/bill_model.dart';
import '../../data/services/notification_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/bill_provider.dart';
import '../widgets/bills/list_bills.dart';
import 'bills_page.dart';

class ListBillsPage extends StatefulWidget {
  const ListBillsPage({super.key});

  @override
  State<ListBillsPage> createState() => _ListBillsPageState();
}

class _ListBillsPageState extends State<ListBillsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final token = context.read<AuthProvider>().token;
      if (token != null) {
        context.read<BillProvider>().fetchBills(token);
      }
    });
  }

  void _openAddBill() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const BillsPage()),
    );
  }

  Future<void> _sendTestNotification() async {
    await NotificationService.sendTestNotification();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reminder sent. Check your notification bar '),
        backgroundColor: AppColors.primaryPurple,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BillProvider>();
    final unpaid = provider.bills
        .where((bill) => bill.status.toLowerCase() == 'unpaid')
        .toList();
    final totalUnpaid = unpaid.fold<double>(
      0,
      (total, bill) => total + bill.amount,
    );
    final nextBill = _nearestBill(unpaid);

    return Scaffold(
      backgroundColor: AppColors.primaryPurple,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _BillsHero(
                total: totalUnpaid,
                unpaidCount: unpaid.length,
                nextBill: nextBill,
                onNotificationTap: _sendTestNotification,
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.backgroundWhite,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(38),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.panelShadow,
                        blurRadius: 18,
                        offset: Offset(0, -4),
                      ),
                    ],
                  ),
                  child: ListBills(
                    onAddTap: _openAddBill,
                    showSectionHeader: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Bill? _nearestBill(List<Bill> bills) {
    if (bills.isEmpty) return null;
    final sorted = List<Bill>.from(bills)
      ..sort((a, b) {
        final aDate = DateTime.tryParse(a.dueDate) ?? DateTime(9999);
        final bDate = DateTime.tryParse(b.dueDate) ?? DateTime(9999);
        return aDate.compareTo(bDate);
      });
    return sorted.first;
  }
}

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool showTouchEffect;

  const _HeaderButton({
    required this.icon,
    required this.onTap,
    this.showTouchEffect = true,
  });

  @override
  Widget build(BuildContext context) {
    final iconContent = Padding(
      padding: const EdgeInsets.all(11),
      child: Icon(icon, color: AppColors.panelWhite, size: 28),
    );

    if (!showTouchEffect) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: iconContent,
      );
    }

    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: iconContent,
      ),
    );
  }
}

class _BillsHero extends StatelessWidget {
  final double total;
  final int unpaidCount;
  final Bill? nextBill;
  final VoidCallback onNotificationTap;

  const _BillsHero({
    required this.total,
    required this.unpaidCount,
    required this.nextBill,
    required this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##0', 'id_ID');
    final nextDate = DateTime.tryParse(nextBill?.dueDate ?? '');
    final nextDue = nextDate == null
        ? 'No upcoming due date'
        : 'Next due ${DateFormat('d MMM', 'id_ID').format(nextDate)}';

    return SizedBox(
      height: 286,
      width: double.infinity,
      child: Stack(
        children: [
          const Positioned.fill(child: _CheckerDecoration()),
          Positioned(
            left: 36,
            right: 36,
            top: 12,
            child: Row(
              children: [
                _HeaderButton(
                  icon: Icons.arrow_back_rounded,
                  onTap: () => Navigator.maybePop(context),
                ),
                const Expanded(
                  child: Text(
                    'Bills',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.panelWhite,
                    ),
                  ),
                ),
                _HeaderButton(
                  icon: Icons.notifications_active_rounded,
                  onTap: onNotificationTap,
                  showTouchEffect: false,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(46, 102, 36, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Outstanding Payment',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.panelWhite,
                  ),
                ),
                const SizedBox(height: 14),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Rp${formatter.format(total)}',
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 48,
                      fontWeight: FontWeight.w800,
                      color: AppColors.panelWhite,
                      height: 1,
                    ),
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    _SummaryChip(
                      icon: Icons.pending_actions_rounded,
                      label: '$unpaidCount unpaid',
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: _SummaryChip(
                        icon: Icons.event_rounded,
                        label: nextDue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckerDecoration extends StatelessWidget {
  const _CheckerDecoration();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: SizedBox(
        width: 235,
        height: 286,
        child: GridView.builder(
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
          ),
          itemCount: 12,
          itemBuilder: (context, index) {
            final isLight = index.isEven;
            return ColoredBox(
              color: AppColors.panelWhite.withValues(
                alpha: isLight ? 0.035 : 0.012,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SummaryChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.panelWhite.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.panelWhite),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.panelWhite,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
