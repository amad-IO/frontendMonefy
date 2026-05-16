import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/wallet_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/wallet_provider.dart';
import '../widgets/input_add_wallet.dart';
import '../widgets/transaction_type_selector.dart';

class CreateWalletPage extends StatefulWidget {
  const CreateWalletPage({super.key});

  @override
  State<CreateWalletPage> createState() => _CreateWalletPageState();
}

class _CreateWalletPageState extends State<CreateWalletPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers untuk membaca nilai dari form
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();

  // Kategori yang dipilih dari tab selector — default "Cash"
  String _selectedCategory = 'Cash';

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  // Map tab label → WalletCategory enum
  WalletCategory _toWalletCategory(String tab) {
    switch (tab) {
      case 'Bank':
        return WalletCategory.bankAccount;
      case 'E-Wallet':
        return WalletCategory.eWallet;
      default:
        return WalletCategory.cash;
    }
  }

  Future<void> _handleSimpan() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final walletProvider = context.read<WalletProvider>();
    final token = auth.token ?? '';

    setState(() => _isLoading = true);

    final success = await walletProvider.addWalletToBackend(
      name: _nameController.text.trim(),
      balance: double.tryParse(_balanceController.text) ?? 0.0,
      token: token,
      category: _toWalletCategory(_selectedCategory),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Wallet berhasil ditambahkan!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(walletProvider.error ?? 'Gagal menambahkan wallet'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: SafeArea(
        child: Column(
          children: [

            /// HEADER UNGU
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              color: AppColors.primaryPurple.withValues(alpha: 0.3),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'Add New Wallet',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryPurple,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            /// BODY
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                ),
                child: Stack(
                  children: [

                    /// BACKGROUND SVG
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.9,
                        child: SvgPicture.asset(
                          'assets/images/kontur.svg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    /// FORM
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            const SizedBox(height: 10),

                            const Text(
                              'Wallet Details',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryPurple,
                              ),
                            ),

                            const SizedBox(height: 12),

                            /// TAB KATEGORI — Cash | Bank | E-Wallet
                            TransactionTypeSelector(
                              initialValue: 'Cash',
                              onChanged: (value) {
                                setState(() => _selectedCategory = value);
                              },
                            ),

                            const SizedBox(height: 20),

                            /// Wallet Name
                            InputAddWallet(
                              label: 'Wallet Name',
                              hint: 'e.g., BCA, GoPay, Cash',
                              isTextOnly: true,
                              controller: _nameController,
                            ),

                            /// Initial Balance
                            InputAddWallet(
                              label: 'Initial Balance',
                              hint: '0',
                              isNumber: true,
                              controller: _balanceController,
                            ),

                            const SizedBox(height: 24),

                            /// BUTTON SIMPAN
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleSimpan,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryPurple,
                                  minimumSize: const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        'Simpan',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}