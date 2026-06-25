
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../data/models/transaction_model.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../widgets/card_history.dart';

class HistoryPage extends StatefulWidget {
  final VoidCallback? onBack;

  const HistoryPage({super.key, this.onBack});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  // Default 'all' agar langsung tampil semua transaksi
  TransactionFilter _activeFilter = TransactionFilter.all;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // ── Pagination state ──────────────────────────────────────────
  static const int _pageSize = 20;
  int _visibleCount = _pageSize;
  final ScrollController _scrollController = ScrollController();

  static const Map<TransactionFilter, String> _filterLabels = {
    TransactionFilter.day: 'Day',
    TransactionFilter.week: 'Week',
    TransactionFilter.month: 'Month',
    TransactionFilter.year: 'Year',
    TransactionFilter.all: 'All',
  };

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
        _visibleCount = _pageSize; // reset pagination saat search berubah
      });
    });
    // Load more items saat user mendekati 200px dari bawah list
    _scrollController.addListener(() {
      if (_scrollController.hasClients &&
          _scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200) {
        // Tambah batch berikutnya saat mendekati bawah
        setState(() => _visibleCount += _pageSize);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose(); // penting! cegah memory leak
    super.dispose();
  }

  void _onFilterTap(TransactionFilter filter) {
    setState(() {
      _activeFilter = filter;
      _visibleCount = _pageSize; // reset pagination saat filter berubah
    });
  }

  List<TransactionModel> _getFilteredTransactions(TransactionProvider provider) {
    return provider.getFiltered(_activeFilter, query: _searchQuery);
  }

  Alignment _alignmentForFilter(TransactionFilter filter) {
    final filters = TransactionFilter.values;
    final index = filters.indexOf(filter);
    if (filters.length <= 1) return Alignment.center;
    final x = -1.0 + (2.0 * index / (filters.length - 1));
    return Alignment(x, 0);
  }

  // ── Pull-to-Refresh: force fetch dari server ─────────────────
  Future<void> _onRefresh() async {
    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn) return;
    setState(() => _visibleCount = _pageSize); // reset pagination
    await context.read<TransactionProvider>().loadTransactions(auth.token!);
  }
  @override
  Widget build(BuildContext context) {
    final mediaBottom = MediaQuery.of(context).padding.bottom;
    final provider    = context.watch<TransactionProvider>();
    final filtered    = _getFilteredTransactions(provider);
    final visibleTxs  = filtered.take(_visibleCount).toList();
    final hasMore     = filtered.length > _visibleCount;

    return Scaffold(
      // ── Layer 1: Purple background ──
      backgroundColor: AppColors.dashboardPurple,
      extendBody: true,
      body: Column(
        children: [
          // ── Header on purple background ──
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: widget.onBack,
                    child: SvgPicture.asset(
                      'assets/icon/back.svg',
                      width: 35,
                      height: 35,
                      colorFilter: const ColorFilter.mode(
                        AppColors.primaryPurple,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'History',
                      textAlign: TextAlign.center,
                      style: AppTextStyle.heading.copyWith(
                        color: AppColors.primaryPurple,
                        fontSize: 25,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                ],
              ),
            ),
          ),

          // ── Layer 2: White container with rounded top + shadow ──
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.backgroundWhite,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 18,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // ── Search bar ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: AppTextStyle.body.copyWith(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Search transactions',
                          hintStyle: AppTextStyle.caption.copyWith(fontSize: 13),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: AppColors.primaryPurple,
                            size: 25,
                          ),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? GestureDetector(
                                  onTap: () => _searchController.clear(),
                                  child: Icon(
                                    Icons.close_rounded,
                                    color: AppColors.textSecondary,
                                    size: 18,
                                  ),
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 13,
                            horizontal: 4,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── Filter tabs ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
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
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final pillWidth = constraints.maxWidth /
                                  TransactionFilter.values.length;
                              return AnimatedAlign(
                                duration: const Duration(milliseconds: 320),
                                curve: Curves.easeInOutCubic,
                                alignment:
                                    _alignmentForFilter(_activeFilter),
                                child: Container(
                                  width: pillWidth,
                                  margin: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryPurple,
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                              );
                            },
                          ),
                          Row(
                            children:
                                TransactionFilter.values.map((filter) {
                              final isActive = filter == _activeFilter;
                              return Expanded(
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () => _onFilterTap(filter),
                                  child: Center(
                                    child: AnimatedDefaultTextStyle(
                                      duration:
                                          const Duration(milliseconds: 220),
                                      curve: Curves.easeOut,
                                      style: AppTextStyle.caption.copyWith(
                                        fontSize: 13,
                                        color: isActive
                                            ? Colors.white
                                            : AppColors.textSecondary,
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

                  // ── Transaction list ──
                  Expanded(
                    child: provider.isFreshLoading
                        ? _buildSkeleton()
                        : filtered.isEmpty
                            ? _EmptyState(isSearch: _searchQuery.isNotEmpty)
                            : RefreshIndicator(
                                onRefresh: _onRefresh,
                                color: AppColors.primaryPurple,
                                child: ListView.builder(
                                  controller: _scrollController,
                                  physics: const BouncingScrollPhysics(
                                    parent: AlwaysScrollableScrollPhysics(),
                                  ),
                                  padding: EdgeInsets.only(
                                    top: 4,
                                    bottom: 120 + mediaBottom,
                                  ),
                                  // +1 untuk loading indicator di bawah
                                  itemCount: visibleTxs.length + (hasMore ? 1 : 0),
                                  itemBuilder: (context, index) {
                                    // Loading indicator di akhir list
                                    if (index == visibleTxs.length) {
                                      return const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 16),
                                        child: Center(
                                          child: SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: AppColors.primaryPurple,
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                    return CardHistory(
                                      transaction: visibleTxs[index],
                                    );
                                  },
                                ),
                              ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Skeleton loading: 6 dummy card transaksi ──────────────────
  Widget _buildSkeleton() {
    final dummy = TransactionModel(
      id: '0',
      category: 'Shopping',
      title: 'Loading...',
      amount: 150000,
      date: DateTime.now(),
      walletName: 'BCA',
      type: TransactionType.expense,
    );
    return Skeletonizer(
      enabled: true,
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 4),
        itemCount: 6,
        itemBuilder: (_, __) => CardHistory(transaction: dummy),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isSearch;
  const _EmptyState({required this.isSearch});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSearch ? Icons.search_off_rounded : Icons.receipt_long_rounded,
            size: 52,
            color: AppColors.disabled,
          ),
          const SizedBox(height: 10),
          Text(
            isSearch ? 'No transactions found' : 'No transactions yet',
            style: AppTextStyle.caption.copyWith(fontSize: 13),
          ),
        ],
      ),
    );
  }
}