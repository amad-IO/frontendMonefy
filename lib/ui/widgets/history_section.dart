import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../data/models/transaction_model.dart';
import 'card_history.dart';

class HistorySection extends StatefulWidget {
  final List<TransactionModel> transactions;
  final bool isLoading;
  final bool showPendingSkeleton;

  final void Function(TransactionFilter filter)? onFilterChanged;

  final VoidCallback? onSeeAll;

  final int maxItems;

  const HistorySection({
    super.key,
    required this.transactions,
    this.isLoading = false,
    this.showPendingSkeleton = false,
    this.onFilterChanged,
    this.onSeeAll,
    this.maxItems = 8,
  });

  @override
  State<HistorySection> createState() => _HistorySectionState();
}

class _HistorySectionState extends State<HistorySection> {
  TransactionFilter _activeFilter = TransactionFilter.all;

  static const Map<TransactionFilter, String> _filterLabels = {
    TransactionFilter.day: 'Day',
    TransactionFilter.week: 'Week',
    TransactionFilter.month: 'Month',
    TransactionFilter.year: 'Year',
    TransactionFilter.all: 'All',
  };

  void _onFilterTap(TransactionFilter filter) {
    setState(() => _activeFilter = filter);
    widget.onFilterChanged?.call(filter);
  }

  Alignment _alignmentForFilter(TransactionFilter filter) {
    final filters = TransactionFilter.values;
    final index = filters.indexOf(filter);
    if (filters.length <= 1) return Alignment.center;
    final x = -1.0 + (2.0 * index / (filters.length - 1));
    return Alignment(x, 0);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final mediaBottom = MediaQuery.of(context).padding.bottom;
    final visibleTransactionLimit = widget.showPendingSkeleton
        ? widget.maxItems - 1
        : widget.maxItems;
    final clampedLimit = visibleTransactionLimit < 0
        ? 0
        : visibleTransactionLimit;
    final bool showSeeAll = widget.transactions.length > clampedLimit;
    final displayList = widget.transactions.length > clampedLimit
        ? widget.transactions.sublist(0, clampedLimit)
        : widget.transactions;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(0, 18, 0, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final pillWidth = constraints.maxWidth /
                          TransactionFilter.values.length;
                      return AnimatedAlign(
                        duration: const Duration(milliseconds: 320),
                        curve: Curves.easeInOutCubic,
                        alignment: _alignmentForFilter(_activeFilter),
                        child: Container(
                          width: pillWidth,
                          margin: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      );
                    },
                  ),
                  Row(
                    children: TransactionFilter.values.map((filter) {
                      final isActive = filter == _activeFilter;
                      return Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => _onFilterTap(filter),
                          child: Center(
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeOut,
                              style: (textTheme.bodySmall ?? const TextStyle())
                                  .copyWith(
                                fontSize: 13,
                                color: isActive
                                    ? colorScheme.onPrimary
                                    : colorScheme.onSurface.withValues(
                                        alpha: 0.7,
                                      ),
                                fontWeight: isActive
                                    ? FontWeight.w800
                                    : FontWeight.w700,
                              ),
                              child: Text(_filterLabels[filter] ?? 'All'),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          Expanded(
            child: widget.isLoading
                ? const _HistorySkeletonList()
                : displayList.isEmpty && !widget.showPendingSkeleton
                    ? _EmptyState()
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.only(bottom: 120 + mediaBottom),
                        itemCount: displayList.length +
                            (widget.showPendingSkeleton ? 1 : 0) +
                            (showSeeAll ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (widget.showPendingSkeleton && index == 0) {
                            return const _PendingHistorySkeletonItem();
                          }

                          final transactionIndex = index -
                              (widget.showPendingSkeleton ? 1 : 0);

                          if (showSeeAll &&
                              transactionIndex == displayList.length) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: GestureDetector(
                                onTap: widget.onSeeAll,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'See all transactions',
                                      style:
                                          (textTheme.bodySmall ??
                                                  const TextStyle())
                                              .copyWith(
                                        color: colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 14,
                                      color: colorScheme.primary,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          return CardHistory(
                            transaction: displayList[transactionIndex],
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _PendingHistorySkeletonItem extends StatelessWidget {
  const _PendingHistorySkeletonItem();

  @override
  Widget build(BuildContext context) {
    final dummy = TransactionModel(
      id: 'pending',
      category: 'Processing',
      title: 'Syncing',
      amount: 150000,
      date: DateTime.now(),
      walletName: 'Main Wallet',
      type: TransactionType.expense,
    );

    return IgnorePointer(
      child: Skeletonizer(
        enabled: true,
        child: CardHistory(transaction: dummy),
      ),
    );
  }
}

class _HistorySkeletonList extends StatelessWidget {
  const _HistorySkeletonList();

  @override
  Widget build(BuildContext context) {
    final dummy = TransactionModel(
      id: '0',
      category: 'Shopping',
      title: 'Loading',
      amount: 150000,
      date: DateTime.now(),
      walletName: 'Main Wallet',
      type: TransactionType.expense,
    );

    return IgnorePointer(
      child: Skeletonizer(
        enabled: true,
        child: ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.only(
            bottom: 120 + MediaQuery.of(context).padding.bottom,
          ),
          itemCount: 6,
          itemBuilder: (_, __) => CardHistory(transaction: dummy),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_rounded,
              size: 48,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.45),
            ),
            const SizedBox(height: 8),
            Text(
              'No transaction yet',
              style: (Theme.of(context).textTheme.bodySmall ??
                      const TextStyle())
                  .copyWith(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
