import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/saving_provider.dart';
import '../widgets/saving_card.dart';
import '../widgets/saving_list.dart';
import '../widgets/create_saving_modal.dart';

class SavingPage extends StatefulWidget {
  const SavingPage({super.key});

  @override
  State<SavingPage> createState() => _SavingPageState();
}

class _SavingPageState extends State<SavingPage> {

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final token = context.read<AuthProvider>().token;
      if (token != null) {
        context.read<SavingProvider>().fetchSavings(token);
      }
    });
  }

  /// Handle create dengan token
  void _handleCreateSaving(String name, int target, String date) {
    final token = context.read<AuthProvider>().token;
    if (token != null) {
      context.read<SavingProvider>().addSaving(name, target, date, token);
    }
  }

  void _openCreateModal() {
    showCreateSavingModal(context, _handleCreateSaving);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB7AEEB),

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryPurple,
        onPressed: _openCreateModal,
        child: const Icon(Icons.add),
      ),

      body: SafeArea(
        child: Consumer<SavingProvider>(
          builder: (context, provider, child) {

            final total = provider.savings.fold<int>(
              0,
              (sum, item) => sum + item.amount,
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// HEADER
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
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

                /// TOTAL CARD dengan skeleton
                Skeletonizer(
                  enabled: provider.isLoading,
                  child: SavingCard(total: provider.isLoading ? 999999 : total),
                ),

                const SizedBox(height: 16),

                /// TITLE
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "Saving list",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryPurple,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                /// LIST dengan skeleton
                Expanded(
                  child: Skeletonizer(
                    enabled: provider.isLoading,
                    child: SavingList(
                      items: provider.isLoading
                          ? _dummySavings
                          : provider.savings.map((e) => {
                              "id": e.id,
                              "name": e.name,
                              "amount": e.amount,
                              "target": e.target,
                              "date": e.date,
                            }).toList(),
                      onCreateTap: _openCreateModal,
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
}

// Dummy data untuk skeleton placeholder
const _dummySavings = [
  {"id": 0, "name": "Laptop Baru", "amount": 1000000, "target": 5000000, "date": "2025-12-31"},
  {"id": 1, "name": "Liburan",    "amount": 500000,  "target": 3000000, "date": "2025-06-30"},
  {"id": 2, "name": "Gadget",     "amount": 200000,  "target": 2000000, "date": "2025-09-01"},
];