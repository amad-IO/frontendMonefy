import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/bill_provider.dart';
import '../widgets/bills/bills_input.dart';

class BillsPage extends StatefulWidget {
  const BillsPage({super.key});

  @override
  State<BillsPage> createState() => _BillsPageState();
}

class _BillsPageState extends State<BillsPage> {
  final _formKey = GlobalKey<FormState>();
  final billNameController = TextEditingController();
  final accountController = TextEditingController();
  final amountController = TextEditingController();
  final dueDateController = TextEditingController();

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

  Future<void> _addBill() async {
    if (!_formKey.currentState!.validate()) return;

    final token = context.read<AuthProvider>().token;
    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your session has expired. Please sign in again.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    await context.read<BillProvider>().addBill({
      'provider': billNameController.text.trim(),
      'account_number': accountController.text.trim(),
      'amount': double.tryParse(amountController.text.replaceAll('.', '')) ?? 0,
      'due_date': dueDateController.text,
      // Internal values remain compatible with recurring notification logic.
      'cycle': billingCycle ?? 'Bulanan',
    }, token);

    if (!mounted) return;
    setState(() => _isLoading = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryPurple,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _AddBillHeader(onBack: () => Navigator.pop(context)),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.backgroundWhite,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(34),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.panelShadow,
                        blurRadius: 18,
                        offset: Offset(0, -4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(34),
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Opacity(
                            opacity: 0.16,
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
                        Form(
                          key: _formKey,
                          child: ListView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                            children: [
                              const _FormIntroduction(),
                              const SizedBox(height: 22),
                              BillsInput(
                                billNameController: billNameController,
                                accountController: accountController,
                                amountController: amountController,
                                dueDateController: dueDateController,
                                onCycleChanged: (value) {
                                  billingCycle = value;
                                },
                              ),
                              const SizedBox(height: 22),
                              SizedBox(
                                height: 56,
                                child: FilledButton(
                                  onPressed: _isLoading ? null : _addBill,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.primaryPurple,
                                    disabledBackgroundColor: AppColors
                                        .primaryPurple
                                        .withValues(alpha: 0.55),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            color: AppColors.panelWhite,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      : const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.add_card_rounded,
                                              color: AppColors.panelWhite,
                                              size: 20,
                                            ),
                                            SizedBox(width: 9),
                                            Text(
                                              'Add Bill',
                                              style: TextStyle(
                                                fontFamily: 'Nunito',
                                                fontSize: 15,
                                                fontWeight: FontWeight.w800,
                                                color: AppColors.panelWhite,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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

class _AddBillHeader extends StatelessWidget {
  final VoidCallback onBack;

  const _AddBillHeader({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 18),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onBack,
              customBorder: const CircleBorder(),
              child: const Padding(
                padding: EdgeInsets.all(11),
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.panelWhite,
                  size: 23,
                ),
              ),
            ),
          ),
          const Expanded(
            child: Column(
              children: [
                Text(
                  'Add Bill',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.panelWhite,
                  ),
                ),
                Text(
                  'Never miss another payment',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.panelWhite,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 45),
        ],
      ),
    );
  }
}

class _FormIntroduction extends StatelessWidget {
  const _FormIntroduction();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryPurple.withValues(alpha: 0.24),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Icon(
            Icons.receipt_long_rounded,
            color: AppColors.panelWhite,
            size: 25,
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bill details',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryPurple,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Tell us what to track and when it is due.',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
