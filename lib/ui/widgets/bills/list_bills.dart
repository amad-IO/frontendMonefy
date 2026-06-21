import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../providers/bill_provider.dart';
import '../../pages/add_page.dart';
import '../loading_spinner.dart';
import 'bill_card.dart';
import 'bill_detail_modal.dart';

class ListBills extends StatefulWidget {
  final VoidCallback? onAddTap;
  final bool showSectionHeader;

  const ListBills({super.key, this.onAddTap, this.showSectionHeader = false});

  @override
  State<ListBills> createState() => _ListBillsState();
}

class _ListBillsState extends State<ListBills> {
  bool _showUnpaid = true;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BillProvider>();
    final unpaidCount = provider.bills
        .where((bill) => bill.status.toLowerCase() == 'unpaid')
        .length;
    final paidCount = provider.bills
        .where((bill) => bill.status.toLowerCase() == 'paid')
        .length;
    final bills = provider.bills.where((bill) {
      final status = bill.status.toLowerCase();
      return _showUnpaid ? status == 'unpaid' : status == 'paid';
    }).toList();

    return Stack(
      children: [
        Positioned.fill(
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            child: Opacity(
              opacity: 0.18,
              child: SvgPicture.asset(
                'assets/images/kontur.svg',
                fit: BoxFit.cover,
                colorFilter: const ColorFilter.mode(
                  AppColors.decorativePurple,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
        Column(
          children: [
            if (widget.showSectionHeader)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Bills',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryPurple,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Keep every payment on your radar',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _AddBillButton(onTap: widget.onAddTap),
                  ],
                ),
              ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                widget.showSectionHeader ? 12 : 18,
                20,
                12,
              ),
              child: _BillSegmentedControl(
                showUnpaid: _showUnpaid,
                unpaidCount: unpaidCount,
                paidCount: paidCount,
                onChanged: (value) => setState(() => _showUnpaid = value),
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: provider.isLoading
                    ? const Center(
                        key: ValueKey('loading'),
                        child: LoadingSpinner(),
                      )
                    : bills.isEmpty
                    ? _BillsEmptyState(
                        key: ValueKey('empty-$_showUnpaid'),
                        isUnpaid: _showUnpaid,
                        onAddTap: widget.onAddTap,
                      )
                    : ListView.builder(
                        key: ValueKey('list-$_showUnpaid'),
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
                        itemCount: bills.length,
                        itemBuilder: (context, index) {
                          final bill = bills[index];
                          return BillCard(
                            title: bill.provider,
                            accountNumber: bill.accountNumber,
                            amount: rupiahFormatter.format(bill.amount),
                            dueDate: bill.dueDate,
                            cycle: bill.cycle,
                            isPaid: bill.status.toLowerCase() == 'paid',
                            onTap: () => showBillDetailModal(context, {
                              'id': bill.id,
                              'name': bill.provider,
                              'account': bill.accountNumber,
                              'amount': bill.amount,
                              'due_date': bill.dueDate,
                              'cycle': bill.cycle,
                              'status': bill.status,
                            }),
                            onPay: () => showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => AddPage(
                                billData: {
                                  'id': bill.id,
                                  'provider': bill.provider,
                                  'amount': bill.amount,
                                  'cycle': bill.cycle,
                                },
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AddBillButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _AddBillButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primaryPurple,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 13, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_rounded, size: 18, color: AppColors.panelWhite),
              SizedBox(width: 5),
              Text(
                'Add Bill',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.panelWhite,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BillSegmentedControl extends StatelessWidget {
  final bool showUnpaid;
  final int unpaidCount;
  final int paidCount;
  final ValueChanged<bool> onChanged;

  const _BillSegmentedControl({
    required this.showUnpaid,
    required this.unpaidCount,
    required this.paidCount,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.dashboardPurple.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          _SegmentItem(
            label: 'Unpaid',
            count: unpaidCount,
            selected: showUnpaid,
            onTap: () => onChanged(true),
          ),
          _SegmentItem(
            label: 'Paid',
            count: paidCount,
            selected: !showUnpaid,
            onTap: () => onChanged(false),
          ),
        ],
      ),
    );
  }
}

class _SegmentItem extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const _SegmentItem({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: selected ? AppColors.panelWhite : Colors.transparent,
            borderRadius: BorderRadius.circular(15),
            boxShadow: selected
                ? const [
                    BoxShadow(
                      color: AppColors.lightShadow,
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: selected
                        ? AppColors.primaryPurple
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  constraints: const BoxConstraints(minWidth: 22),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primaryPurple
                        : AppColors.panelWhite.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$count',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: selected
                          ? AppColors.panelWhite
                          : AppColors.textSecondary,
                    ),
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

class _BillsEmptyState extends StatelessWidget {
  final bool isUnpaid;
  final VoidCallback? onAddTap;

  const _BillsEmptyState({
    super.key,
    required this.isUnpaid,
    required this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(28, 20, 28, 120),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: (constraints.maxHeight - 140).clamp(220, 420),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isUnpaid ? 'Nothing due right now!' : 'No paid bills yet',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  isUnpaid
                      ? 'Add your recurring payments and we will help keep them on your radar.'
                      : 'Bills you have completed will happily live here.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    height: 1.45,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (isUnpaid) ...[
                  const SizedBox(height: 20),
                  Material(
                    color: AppColors.primaryPurple,
                    borderRadius: BorderRadius.circular(18),
                    child: InkWell(
                      onTap: onAddTap,
                      borderRadius: BorderRadius.circular(18),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 11,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.add_rounded,
                              color: AppColors.panelWhite,
                              size: 18,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Add your first bill',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: AppColors.panelWhite,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
