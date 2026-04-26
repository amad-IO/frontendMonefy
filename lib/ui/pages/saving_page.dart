import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/saving_card.dart';
import '../widgets/saving_list.dart';

class SavingPage extends StatelessWidget {
  const SavingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,

      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.all(16),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const Text(
                    "Saving",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryPurple,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            const SavingCard(),

            const SizedBox(height: 16),

            // 🔥 INI YANG SCROLL
            const Expanded(
              child: SavingList(),
            ),
          ],
        ),
      ),
    );
  }
}