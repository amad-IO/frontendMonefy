import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../core/theme/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/saving_provider.dart';
import 'saving_card.dart';
import 'saving_detail_modal.dart';

class SavingList extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final bool isLoading;
  final VoidCallback? onAddTap;
  final bool showSectionHeader;

  const SavingList({
    super.key,
    this.items = const [],
    this.isLoading = false,
    this.onAddTap,
    this.showSectionHeader = false,
  });

  @override
  State<SavingList> createState() => _SavingListState();
}

class _SavingListState extends State<SavingList> {
  bool _showCompleted = false;

  @override
  Widget build(BuildContext context) {
    final ongoingCount = widget.items
        .where((item) => item['isDone'] != true)
        .length;
    final completedCount = widget.items
        .where((item) => item['isDone'] == true)
        .length;
    final savings = widget.items
        .where((item) => item['isDone'] == _showCompleted)
        .toList();
    final isInitialLoading = widget.isLoading && widget.items.isEmpty;

    return Stack(
      children: [
        Positioned.fill(
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(38)),
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
                            'Your Wishlist',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryPurple,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Turn little plans into happy milestones',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _AddWishlistButton(onTap: widget.onAddTap),
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
              child: _WishlistSegmentedControl(
                showCompleted: _showCompleted,
                ongoingCount: ongoingCount,
                completedCount: completedCount,
                onChanged: (value) => setState(() => _showCompleted = value),
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.03, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: isInitialLoading
                    ? const _WishlistSkeletonList(key: ValueKey('loading'))
                    : savings.isEmpty
                    ? _WishlistRefreshWrapper(
                        key: ValueKey('empty-$_showCompleted'),
                        child: _WishlistEmptyState(
                          completed: _showCompleted,
                          onAddTap: widget.onAddTap,
                        ),
                      )
                    : _WishlistRefreshWrapper(
                        key: ValueKey('list-$_showCompleted'),
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics(),
                          ),
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
                          itemCount: savings.length,
                          itemBuilder: (context, index) {
                            final item = savings[index];
                            return SavingCard(
                              item: item,
                              onTap: () => showSavingDetailModal(context, item),
                            );
                          },
                        ),
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AddWishlistButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _AddWishlistButton({required this.onTap});

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
                'Add Goal',
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

class _WishlistSegmentedControl extends StatelessWidget {
  final bool showCompleted;
  final int ongoingCount;
  final int completedCount;
  final ValueChanged<bool> onChanged;

  const _WishlistSegmentedControl({
    required this.showCompleted,
    required this.ongoingCount,
    required this.completedCount,
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
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeInOutCubic,
            alignment: showCompleted
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
              _SegmentItem(
                label: 'Ongoing',
                count: ongoingCount,
                selected: !showCompleted,
                onTap: () => onChanged(false),
              ),
              _SegmentItem(
                label: 'Completed',
                count: completedCount,
                selected: showCompleted,
                onTap: () => onChanged(true),
              ),
            ],
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
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: selected
                      ? AppColors.primaryPurple
                      : AppColors.textSecondary,
                ),
                child: Text(label),
              ),
              const SizedBox(width: 6),
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
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
    );
  }
}

class _WishlistRefreshWrapper extends StatelessWidget {
  final Widget child;

  const _WishlistRefreshWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primaryPurple,
      onRefresh: () async {
        final token = context.read<AuthProvider>().token;
        if (token == null || token.isEmpty) return;
        await context.read<SavingProvider>().fetchSavings(token);
      },
      child: child,
    );
  }
}

class _WishlistSkeletonList extends StatelessWidget {
  const _WishlistSkeletonList({super.key});

  @override
  Widget build(BuildContext context) {
    final dummyItem = {
      'id': 0,
      'name': 'New Laptop',
      'amount': 0,
      'target': 7500000,
      'date': '2026-12-31',
      'isDone': false,
    };

    return Skeletonizer(
      enabled: true,
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
        itemCount: 5,
        itemBuilder: (_, __) => SavingCard(item: dummyItem),
      ),
    );
  }
}

class _WishlistEmptyState extends StatelessWidget {
  final bool completed;
  final VoidCallback? onAddTap;

  const _WishlistEmptyState({
    super.key,
    required this.completed,
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
                  completed ? 'No completed goals yet' : 'Dream something lovely',
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
                  completed
                      ? 'Goals you have achieved will be celebrated here.'
                      : 'Create your first wishlist goal and start planning for it.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    height: 1.45,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (!completed) ...[
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: onAddTap,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryPurple,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 11,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text(
                      'Add your first goal',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
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
