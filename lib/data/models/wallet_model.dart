import '../../core/theme/app_colors.dart';

// ══════════════════════════════════════════════════════════════
/// Kategori wallet — dipilih saat user menambah wallet baru.
// ══════════════════════════════════════════════════════════════
enum WalletCategory { cash, eWallet, bankAccount }

extension WalletCategoryX on WalletCategory {
  String get label {
    switch (this) {
      case WalletCategory.cash:
        return 'Cash';
      case WalletCategory.eWallet:
        return 'E-wallets';
      case WalletCategory.bankAccount:
        return 'Bank Accounts';
    }
  }
}

// ══════════════════════════════════════════════════════════════
/// WalletModel — representasi satu wallet milik user.
///
/// Ketika backend sudah siap, cukup ganti [fromJson] / [toJson]
/// tanpa perlu mengubah widget atau provider yang sudah ada.
// ══════════════════════════════════════════════════════════════
class WalletModel {
  final String id;
  final String name;
  final double balance;
  final WalletCategory category;
  final WalletTheme theme;

  const WalletModel({
    required this.id,
    required this.name,
    required this.balance,
    required this.category,
    required this.theme,
  });

  // ── Backend integration hook ──────────────────────────────
  /// Parsing JSON dari backend.
  /// [themeIndex] merujuk ke posisi di [WalletTheme.all].
  factory WalletModel.fromJson(Map<String, dynamic> json) {
    // Backend menyimpan nama wallet di field 'name_wallet' (bukan 'name')
    final themeIndex = (json['theme_index'] as int?) ?? 0;
    final categoryStr = json['category']?.toString() ?? 'cash';

    return WalletModel(
      id: json['id'].toString(),
      name: json['name_wallet']?.toString() ?? '',   // ✅ sesuai backend
      balance: double.tryParse(json['balance'].toString()) ?? 0.0,
      category: _categoryFromString(categoryStr),
      theme: WalletTheme.all[themeIndex.clamp(0, WalletTheme.all.length - 1)],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_wallet': name,       // ✅ backend expect 'name_wallet'
      'balance': balance,
      'category': _categoryToString(category),
      'theme_index': WalletTheme.all.indexOf(theme),
    };
  }

  static WalletCategory _categoryFromString(String value) {
    // Backend mengirim: 'Bank Account', 'Cash', 'E-Wallet'
    switch (value.toLowerCase().trim()) {
      case 'bank account':
      case 'bank_account':
        return WalletCategory.bankAccount;
      case 'e-wallet':
      case 'e_wallet':
      case 'ewallet':
        return WalletCategory.eWallet;
      case 'cash':
      default:
        return WalletCategory.cash;
    }
  }

  static String _categoryToString(WalletCategory cat) {
    // Nilai yang dikirim ke backend harus sesuai enum: 'Bank Account', 'Cash', 'E-Wallet'
    switch (cat) {
      case WalletCategory.eWallet:
        return 'E-Wallet';
      case WalletCategory.bankAccount:
        return 'Bank Account';
      case WalletCategory.cash:
        return 'Cash';
    }
  }

  // ── Dummy data — hapus setelah backend ready ──────────────
  static List<WalletModel> dummyList() {
    return [
      WalletModel(
        id: '1',
        name: 'Cash',
        balance: 1000000,
        category: WalletCategory.cash,
        theme: WalletTheme.nebula,
      ),
      WalletModel(
        id: '2',
        name: 'BSI',
        balance: 1000000,
        category: WalletCategory.bankAccount,
        theme: WalletTheme.sunset,
      ),
      WalletModel(
        id: '3',
        name: 'BCA',
        balance: 500000,
        category: WalletCategory.bankAccount,
        theme: WalletTheme.midnight,
      ),
      WalletModel(
        id: '4',
        name: 'ShopeePay',
        balance: 1000000,
        category: WalletCategory.eWallet,
        theme: WalletTheme.volcano,
      ),
      WalletModel(
        id: '5',
        name: 'GoPay',
        balance: 500000,
        category: WalletCategory.eWallet,
        theme: WalletTheme.cosmos,
      ),
    ];
  }
}
