import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/add_page_helper.dart';
import '../../data/models/scan_result.dart';
import '../../data/models/transaction_model.dart';
import '../../providers/bill_provider.dart';
import '../../providers/saving_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/wallet_provider.dart';
import '../ui/components/wallet_selector_popup.dart';
import '../ui/pages/scan_page.dart';
import '../ui/widgets/notifikasi__transaction.dart';

class AddPageController extends ChangeNotifier {
  final TransactionModel? editTransaction;
  final TickerProvider vsync;

  /// Data bills jika dibuka dari Pay Now (opsional)
  final Map<String, dynamic>? billData;

  /// Data wishlist jika dibuka dari Buy Now (opsional)
  final Map<String, dynamic>? savingData;

  AddPageController({
    this.editTransaction,
    this.billData,
    this.savingData,
    required this.vsync,
  }) {
    _init();
  }

  // ── Mode Flag ──
  bool get isEditMode => editTransaction != null;

  // ── State Variables ──
  int _typeIndex = 0;
  int get typeIndex => _typeIndex;

  TransactionType get type {
    switch (_typeIndex) {
      case 1:
        return TransactionType.expense;
      case 2:
        return TransactionType.transfer;
      default:
        return TransactionType.income;
    }
  }

  String? _selectedCategory;
  String? get selectedCategory => _selectedCategory;

  String? _selectedWallet;
  String? get selectedWallet => _selectedWallet;

  String? _selectedWalletId;
  String? get selectedWalletId => _selectedWalletId;

  String? _selectedToWallet;
  String? get selectedToWallet => _selectedToWallet;

  String? _selectedToWalletId;
  String? get selectedToWalletId => _selectedToWalletId;

  final TextEditingController amountController = TextEditingController();
  final TextEditingController titleController = TextEditingController();

  late final AnimationController walletShakeController;
  bool _walletError = false;
  bool get walletError => _walletError;
  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  Key _filterTransferKey = UniqueKey();
  Key get filterTransferKey => _filterTransferKey;

  // ── Inisialisasi awal ──
  void _init() {
    walletShakeController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 500),
    );
    walletShakeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        walletShakeController.reset();
      }
    });

    if (isEditMode) {
      final t = editTransaction!;
      _typeIndex = t.type == TransactionType.income
          ? 0
          : t.type == TransactionType.expense
          ? 1
          : 2;
      _selectedCategory = t.category;
      _selectedWallet = t.walletName.isEmpty ? null : t.walletName;
      _selectedWalletId = t.walletId.isEmpty ? null : t.walletId;
      _selectedToWallet = t.toWalletName.isEmpty ? null : t.toWalletName;
      _selectedToWalletId = t.toWalletId.isEmpty ? null : t.toWalletId;
      amountController.text = t.amount == t.amount.truncateToDouble()
          ? t.amount.toInt().toString()
          : t.amount.toString();
      titleController.text = t.title;
    }

    // Pre-fill dari bills (Pay Now flow)
    if (billData != null && !isEditMode) {
      _typeIndex = 1; // Expense
      _selectedCategory = 'More';
      final amount = billData!['amount'];
      amountController.text = (amount is double)
          ? amount.toInt().toString()
          : amount.toString();
      titleController.text = 'Bills: ${billData!["provider"] ?? ""}';
    }

    // Pre-fill dari Wishlist (Buy Now flow)
    if (savingData != null && !isEditMode) {
      _typeIndex = 1; // Expense
      _selectedCategory = 'More';
      final amount = savingData!['amount'];
      amountController.text = amount is double
          ? amount.toInt().toString()
          : amount.toString();
      titleController.text = 'Wishlist: ${savingData!["name"] ?? ""}';
    }
  }

  @override
  void dispose() {
    walletShakeController.dispose();
    amountController.dispose();
    titleController.dispose();
    super.dispose();
  }

  // ── Setters ──
  void setTypeIndex(int index) {
    _typeIndex = index;
    _selectedCategory = null;
    _selectedToWallet = null;
    _selectedToWalletId = null;
    titleController.clear();
    _filterTransferKey = UniqueKey();
    notifyListeners();
  }

  void setCategory(String category) {
    if (_selectedCategory == 'More' && category != 'More') {
      titleController.clear();
    }
    _selectedCategory = category;
    notifyListeners();
  }

  void setToWallet(WalletOption wallet) {
    _selectedToWallet = wallet.name;
    _selectedToWalletId = wallet.id;
    notifyListeners();
  }

  void setFromWallet(WalletOption wallet) {
    _selectedWallet = wallet.name;
    _selectedWalletId = wallet.id;
    _walletError = false;
    if (_selectedToWallet == wallet.name) {
      _selectedToWallet = null;
      _selectedToWalletId = null;
    }
    notifyListeners();
  }

  // ── Numpad Actions ──
  void onNumPadKeyTap(String key) {
    final current = amountController.text;
    if (key == '.') {
      if (current.contains('.')) return;
      amountController.text = current.isEmpty ? '0.' : '$current.';
      notifyListeners();
      return;
    }
    if (key == '000') {
      amountController.text = current.isEmpty ? '0' : '$current$key';
      notifyListeners();
      return;
    }
    if (current == '0') {
      amountController.text = key;
      notifyListeners();
      return;
    }
    amountController.text = '$current$key';
    notifyListeners();
  }

  void onNumPadBackspace() {
    final current = amountController.text;
    if (current.isEmpty) return;
    amountController.text = current.substring(0, current.length - 1);
    notifyListeners();
  }

  // ── Camera Scan Action ──
  Future<void> openScanPage(BuildContext context) async {
    final result = await showModalBottomSheet<ScanResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ScanPage(),
    );

    if (result == null) return;

    amountController.text = result.total.toInt().toString();

    if (!isEditMode) {
      _typeIndex = result.isIncome ? 0 : 1;
      _selectedCategory = null;
    }
    notifyListeners();

    // Tampilkan snackbar ringkasan scan
    if (context.mounted) {
      final typeLabel = result.isIncome ? 'Income' : 'Expense';
      _showSnackBar(
        context,
        '📄 ${result.merchantName} · $typeLabel · ${result.category}',
        AppColors.primaryPurple,
        Icons.auto_awesome,
      );
    }
  }

  // ── Confirm / Save Action ──
  Future<void> onConfirm(BuildContext context) async {
    if (_isSubmitting) return;

    final amount = double.tryParse(amountController.text.trim()) ?? 0;

    final validationError = AddPageHelper.validate(
      amount: amount,
      selectedWallet: _selectedWallet,
      type: type,
      selectedToWallet: _selectedToWallet,
    );

    if (validationError != null) {
      if (_selectedWallet == null && amount > 0) {
        _walletError = true;
        walletShakeController.forward(from: 0);
        Future.delayed(const Duration(seconds: 2), () {
          _walletError = false;
          notifyListeners();
        });
      }
      _showSnackBar(
        context,
        validationError,
        AppColors.error,
        Icons.warning_amber_rounded,
      );
      return;
    }

    final category = AddPageHelper.resolveCategory(
      type: type,
      selectedCategory: _selectedCategory,
    );
    final title = AddPageHelper.resolveTitle(
      category: category,
      rawTitle: titleController.text,
      type: type,
    );

    final provider = context.read<TransactionProvider>();
    final walletProvider = context.read<WalletProvider>();
    final savingProvider = savingData != null
        ? context.read<SavingProvider>()
        : null;
    final billProvider = billData != null ? context.read<BillProvider>() : null;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    // Ambil token dari AuthProvider (in-memory) - lebih cepat dari SharedPreferences.
    final token = context.read<AuthProvider>().token;
    if (token == null || token.isEmpty) {
      _showSnackBar(
        context,
        'Token tidak ditemukan. Silakan login ulang.',
        AppColors.error,
        Icons.warning_amber_rounded,
      );
      return;
    }

    // A. Mode Edit
    if (isEditMode) {
      final updated = editTransaction!.copyWith(
        category: category,
        title: title,
        amount: amount,
        walletName: _selectedWallet!,
        toWalletName: type == TransactionType.transfer
            ? (_selectedToWallet ?? '')
            : '',
        type: type,
      );

      try {
        await NotifikasiTransaction.show(
          context: context,
          type: type,
          amount: AddPageHelper.formatAmount(amount.toString()),
          category: category,
          walletName: _selectedWallet ?? '',
          toWalletName: type == TransactionType.transfer
              ? _selectedToWallet
              : null,
          apiWork: () => provider.updateTransactionWithApi(updated, token),
          onSuccess: () {
            navigator.pop();
            Future.wait(
              [
                provider.loadAll(token),
                walletProvider.loadWalletsFromApi(token),
              ],
            ).then((_) => provider.enrichToWalletNames(walletProvider.wallets));
          },
        );
      } catch (e) {
        _showSnackBarOnMessenger(
          messenger,
          'Gagal memperbarui transaksi.',
          AppColors.error,
          Icons.warning_amber_rounded,
        );
      }
      return;
    }

    // B. Mode Tambah Baru
    final walletId = _selectedWalletId ?? '';
    if (walletId.isEmpty) {
      _showSnackBarOnMessenger(
        messenger,
        'Wallet tidak valid.',
        AppColors.error,
        Icons.warning_amber_rounded,
      );
      return;
    }

    final transaction = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      category: category,
      title: title,
      amount: amount,
      date: DateTime.now(),
      walletName: _selectedWallet!,
      toWalletName: type == TransactionType.transfer
          ? (_selectedToWallet ?? '')
          : '',
      type: type,
    );

    _isSubmitting = true;
    notifyListeners();

    try {
      await NotifikasiTransaction.show(
        context: context,
        type: type,
        amount: AddPageHelper.formatAmount(amount.toString()),
        category: category,
        walletName: _selectedWallet ?? '',
        toWalletName: type == TransactionType.transfer
            ? _selectedToWallet
            : null,
        apiWork: () async {
          if (savingData != null) {
            final savingId = savingData!['id'] as int?;
            final parsedWalletId = int.tryParse(walletId);
            if (savingId == null || parsedWalletId == null) {
              throw Exception('Wishlist atau wallet tidak valid.');
            }
            await savingProvider!.buySaving(
              savingId,
              parsedWalletId,
              token,
              amount: amount.toInt(),
            );
          } else {
            await provider.addTransactionWithApi(
              transaction,
              token,
              walletId: walletId,
              toWalletId: _selectedToWalletId,
              optimisticHistory: false,
            );
          }
        },
        onSuccess: () {
          provider.showPendingHistorySkeleton();
          navigator.popUntil((route) => route.isFirst);

          if (billData != null) {
            final billId = billData!['id'] as int?;
            if (billId != null && billProvider != null) {
              billProvider.payBill(billId, token);
            }
          }

          Future.wait([
            provider.loadAll(token),
            walletProvider.loadWalletsFromApi(token),
          ]).then((_) {
            provider.enrichToWalletNames(walletProvider.wallets);
          }).whenComplete(provider.hidePendingHistorySkeleton);
        },
      );
    } catch (e) {
      _showSnackBarOnMessenger(
        messenger,
        'Gagal menyimpan transaksi.',
        AppColors.error,
        Icons.warning_amber_rounded,
      );
    } finally {
      _isSubmitting = false;
    }
  }

  // ── Helpers ──
  void _showSnackBar(
    BuildContext context,
    String message,
    Color color,
    IconData icon,
  ) {
    _showSnackBarOnMessenger(
      ScaffoldMessenger.of(context),
      message,
      color,
      icon,
    );
  }

  void _showSnackBarOnMessenger(
    ScaffoldMessengerState messenger,
    String message,
    Color color,
    IconData icon,
  ) {
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
