import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/bills_input.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BillsPage extends StatefulWidget {
  const BillsPage({super.key});

  @override
  State<BillsPage> createState() => _BillsPageState();
}

class _BillsPageState extends State<BillsPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,

      body: SafeArea(
        child: Column(
          children: [

            /// 🔵 BACKGROUND ATAS (UNGU)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              color: AppColors.primaryPurple.withOpacity(0.3),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          Navigator.pop(context);
                        },
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
                ],
              ),
            ),

            /// ⚪ CONTAINER PUTIH + KONTUR
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

                    /// 🔥 KONTUR BACKGROUND
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

                            const Text(
                              'Bills Details',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryPurple,
                              ),
                            ),

                            const SizedBox(height: 16),

                            BillsInput(
                              label: 'Bill Name',
                              hint: 'e.g., PLN, Internet',
                              isTextOnly: true,
                            ),

                            BillsInput(
                              label: 'Account Number',
                              hint: '0',
                              isNumber: true,
                            ),

                            BillsInput(
                              label: 'Amount',
                              hint: 'e.g., 100000',
                              isNumber: true,
                            ),

                            const SizedBox(height: 24),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    Navigator.pop(context);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryPurple,
                                  minimumSize: const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Simpan',
                                  style: TextStyle(fontWeight: FontWeight.bold),
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