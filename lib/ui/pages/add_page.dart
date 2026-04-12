import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import '../../models/transaction_model.dart';
import '../../theme/colors.dart';
import '../../theme/text_style.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  TransactionType _type = TransactionType.income;
  String _amountString = '0';
  int _selectedCategoryIndex = -1;
  String? _selectedWallet;
  final TextEditingController _titleController = TextEditingController();

  static const List<String> _wallets = ['Gopay', 'ShopeePay', 'BCA', 'Cash'];

  static final List<_CategoryItem> _categories = [
    _CategoryItem('Entertainment', Icons.tv_rounded),
    _CategoryItem('Food & Drink', Icons.restaurant_rounded),
    _CategoryItem('Transportation', Icons.directions_car_rounded),
    _CategoryItem('Shop', Icons.shopping_cart_rounded),
    _CategoryItem('More', Icons.more_horiz_rounded),
  ];

  // ── Amount formatting ──

  String get _formattedAmount {
    String toParse = _amountString;
    if (toParse.endsWith('.')) {
      toParse = toParse.substring(0, toParse.length - 1);
    }
    final amount = double.tryParse(toParse) ?? 0;
    final formatter = NumberFormat('#,##0', 'id_ID');
    return 'Rp. ${formatter.format(amount)}';
  }

  // ── Numpad logic ──

  void _onKeyTap(String key) {
    setState(() {
      if (_amountString == '0' && key != '.') {
        _amountString = key;
      } else if (key == '.') {
        if (!_amountString.contains('.')) {
          _amountString += '.';
        }
      } else if (key == '000') {
        if (_amountString != '0' && !_amountString.contains('.')) {
          _amountString += '000';
        }
      } else {
        if (_amountString.length < 15) {
          _amountString += key;
        }
      }
    });
    FocusScope.of(context).unfocus();
  }

  void _onBackspace() {
    setState(() {
      if (_amountString.length > 1) {
        _amountString = _amountString.substring(0, _amountString.length - 1);
      } else {
        _amountString = '0';
      }
    });
  }

  void _onConfirm() {
    final amount = double.tryParse(_amountString) ?? 0;
    if (amount <= 0) return;

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Transaction added successfully!',
          style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  // ── Build ──

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.80,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: const ShapeDecoration(
          gradient: AppColors.primaryGradient,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
              bottomLeft: Radius.circular(50),
              bottomRight: Radius.circular(50),
            ),
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // ≈29% gradient, ≈71% content (matching Figma 194/479 of 673)
            final totalH = constraints.maxHeight;
            final gradientH = totalH * 0.29;

            return Stack(
              children: [
                // ── Decorative circles ──
                Positioned(
                  right: -40,
                  top: -46,
                  child: Container(
                    width: 168,
                    height: 168,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.white2.withValues(alpha: 0.05),
                    ),
                  ),
                ),
                Positioned(
                  left: -56,
                  top: 89,
                  child: Container(
                    width: 168,
                    height: 168,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.white2.withValues(alpha: 0.05),
                    ),
                  ),
                ),

                // ── Gradient content (top 29%) ──
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  height: gradientH,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 16, 0),
                    child: Column(
                      children: [
                        // Top bar: back, toggle, mic
                        Row(
                          children: [
                            _buildCircleButton(
                              onTap: () => Navigator.of(context).pop(),
                              size: 42,
                              opacity: 0.05,
                              child: SvgPicture.asset(
                                'assets/icon/back.svg',
                                width: 22,
                                height: 22,
                                colorFilter: const ColorFilter.mode(
                                  Colors.white,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                            const Spacer(),
                            _buildTypeToggle(),
                            const Spacer(),
                            _buildCircleButton(
                              size: 40,
                              opacity: 0.1,
                              child: const Icon(
                                Icons.mic_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ],
                        ),

                        const Spacer(),

                        // Amount + camera
                        Padding(
                          padding: const EdgeInsets.only(left: 8, bottom: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    _formattedAmount,
                                    style: const TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 43,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.backgroundWhite,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              _buildCircleButton(
                                size: 40,
                                opacity: 0.1,
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Content area (bottom 71%) ──
                Positioned(
                  left: 0,
                  right: 0,
                  top: gradientH,
                  bottom: 0,
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: const BoxDecoration(
                      color: AppColors.backgroundWhite,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                        bottomLeft: Radius.circular(50),
                        bottomRight: Radius.circular(50),
                      ),
                    ),
                    child: Column(
                      children: [
                        // ── Category icons ──
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                          child: _buildCategoryRow(),
                        ),

                        // ── Title + Wallet ──
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: _buildInputRow(),
                        ),

                        const SizedBox(height: 28),

                        // ── Numpad ──
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(30, 0, 30, 56),
                            child: _buildNumpad(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ── Reusable circle button (back, mic, camera) ──

  Widget _buildCircleButton({
    VoidCallback? onTap,
    required double size,
    required double opacity,
    required Widget child,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: opacity),
        ),
        child: Center(child: child),
      ),
    );
  }

  // ── Income / Expense toggle ──

  Widget _buildTypeToggle() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildToggleButton('Income', TransactionType.income),
        const SizedBox(width: 8),
        _buildToggleButton('Expense', TransactionType.expense),
      ],
    );
  }

  Widget _buildToggleButton(String label, TransactionType type) {
    final isActive = _type == type;
    return GestureDetector(
      onTap: () => setState(() => _type = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 86,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isActive ? Colors.white : AppColors.disabled,
            width: isActive ? 1.0 : 0.21,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 16,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: AppColors.white2,
          ),
        ),
      ),
    );
  }

  // ── Category row ──

  Widget _buildCategoryRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(_categories.length, (index) {
        final cat = _categories[index];
        final isSelected = _selectedCategoryIndex == index;

        return GestureDetector(
          onTap: () => setState(() => _selectedCategoryIndex = index),
          child: SizedBox(
            width: 64,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  cat.icon,
                  size: 28,
                  color: isSelected
                      ? AppColors.primaryPurple
                      : AppColors.textSecondary,
                ),
                const SizedBox(height: 6),
                Text(
                  cat.name,
                  style: AppTextStyle.caption.copyWith(
                    fontSize: 10,
                    color: isSelected
                        ? AppColors.primaryPurple
                        : AppColors.textSecondary,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ── Title + Wallet inputs ──

  Widget _buildInputRow() {
    return SizedBox(
      height: 28,
      child: Row(
        children: [
          // Add Title
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white2,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _titleController,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12,
                  color: AppColors.textPrimary,
                ),
                decoration: const InputDecoration(
                  hintText: 'Add Title',
                  hintStyle: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    color: AppColors.disabled,
                  ),
                  prefixIcon: Icon(
                    Icons.description_outlined,
                    size: 14,
                    color: AppColors.disabled,
                  ),
                  prefixIconConstraints: BoxConstraints(
                    minWidth: 32,
                    minHeight: 28,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(top: 6, bottom: 5),
                  isDense: true,
                ),
              ),
            ),
          ),

          const SizedBox(width: 21),

          // Choose Wallet
          PopupMenuButton<String>(
            onSelected: (value) => setState(() => _selectedWallet = value),
            offset: const Offset(0, 30),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            itemBuilder: (context) => _wallets.map((w) {
              return PopupMenuItem<String>(
                value: w,
                child: Text(
                  w,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
              );
            }).toList(),
            child: Container(
              width: 100,
              decoration: BoxDecoration(
                color: AppColors.white2,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _selectedWallet ?? 'Choose Wallet',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    color: _selectedWallet != null
                        ? AppColors.textPrimary
                        : AppColors.disabled,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Numpad ──

  Widget _buildNumpad() {
    const double gap = 11;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availH = constraints.maxHeight;
        final btnH = (availH - 3 * gap) / 4;
        final confirmH = 2 * btnH + gap;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left 3 columns
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  SizedBox(height: btnH, child: _numRow(['1', '2', '3'], gap)),
                  const SizedBox(height: gap),
                  SizedBox(height: btnH, child: _numRow(['4', '5', '6'], gap)),
                  const SizedBox(height: gap),
                  SizedBox(height: btnH, child: _numRow(['7', '8', '9'], gap)),
                  const SizedBox(height: gap),
                  SizedBox(
                      height: btnH, child: _numRow(['.', '0', '000'], gap)),
                ],
              ),
            ),
            const SizedBox(width: gap),
            // Right column
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  // ⌫ Backspace
                  SizedBox(
                    height: btnH,
                    child: _specialKey(
                      child: Icon(Icons.backspace_outlined,
                          color: AppColors.error, size: 22),
                      color: AppColors.error.withValues(alpha: 0.15),
                      onTap: _onBackspace,
                    ),
                  ),
                  const SizedBox(height: gap),
                  // Empty slot
                  SizedBox(
                    height: btnH,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.white2,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: gap),
                  // ✓ Confirm (tall — rows 3‑4)
                  SizedBox(
                    height: confirmH,
                    child: _specialKey(
                      child: Icon(Icons.check_rounded,
                          color: AppColors.success, size: 28),
                      color: AppColors.success.withValues(alpha: 0.25),
                      onTap: _onConfirm,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _numRow(List<String> keys, double gap) {
    return Row(
      children: List.generate(keys.length * 2 - 1, (i) {
        if (i.isOdd) return SizedBox(width: gap);
        return Expanded(child: _numKey(keys[i ~/ 2]));
      }),
    );
  }

  Widget _numKey(String key) {
    return GestureDetector(
      onTap: () => _onKeyTap(key),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white2,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            key,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 25,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111111),
            ),
          ),
        ),
      ),
    );
  }

  Widget _specialKey({
    required Widget child,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _CategoryItem {
  final String name;
  final IconData icon;
  const _CategoryItem(this.name, this.icon);
}
