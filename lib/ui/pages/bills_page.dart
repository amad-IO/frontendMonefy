import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/bill_provider.dart';
import '../widgets/bills_input.dart';

class BillsPage extends StatefulWidget {
  const BillsPage({super.key});

  @override
  State<BillsPage> createState() => _BillsPageState();
}

class _BillsPageState extends State<BillsPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController billNameController = TextEditingController();
  final TextEditingController accountController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController dueDateController = TextEditingController();

  String? billingCycle;
  bool _isLoading = false;

  @override
  void dispose() {
    billNameController.dispose();
    accountController.dispose();
    amountController.dispose();
    dueDateController.dispose();
    super.dispose();
  }

  Future<void> _handleSimpan() async {
    if (!_formKey.currentState!.validate()) return;

    final token = context.read<AuthProvider>().token ?? '';

    setState(() => _isLoading = true);

    await context.read<BillProvider>().addBill({
      "provider": billNameController.text,
      "account_number": accountController.text,
      "amount": double.tryParse(amountController.text) ?? 0,
      "due_date": dueDateController.text,
      "cycle": billingCycle ?? "Bulanan",
    }, token);

    if (!mounted) return;

    setState(() => _isLoading = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,

      body: SafeArea(
        child: Column(
          children: [

            /// 🔥 HEADER (SAMA PERSIS)
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
                      'Bills',
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

            /// 🔥 BODY (INI YANG KAMU MAU)
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

                    /// 🔥 KONTUR (SAMA PERSIS WALLET)
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.9,
                        child: SvgPicture.asset(
                          'assets/images/kontur.svg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    /// 🔥 FORM
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            const SizedBox(height: 10),

                            /// 🔥 TITLE
                            const Text(
                              'Bills Details',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryPurple,
                              ),
                            ),

                            const SizedBox(height: 20),

                            /// 🔥 INPUT (INI PENTING)
                            BillsInput(
                              billNameController: billNameController,
                              accountController: accountController,
                              amountController: amountController,
                              dueDateController: dueDateController,
                              onCycleChanged: (value) {
                                billingCycle = value;
                              },
                            ),

                            const SizedBox(height: 24),

                            /// 🔥 BUTTON (SAMA POLA)
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