import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/saving_provider.dart';
import '../../providers/wallet_provider.dart';
import '../widgets/saving/saving_list.dart';
import '../widgets/saving/create_saving_modal.dart';
import 'package:intl/intl.dart';

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
        context.read<WalletProvider>().loadWalletsFromApi(token);
      }
    });
  }

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

            // FIX TOTAL
            final total = provider.savings
                .where((e) => e.status != "terbeli")
                .fold<int>(0, (sum, item) => sum + item.target);

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
                        "Wishlist",
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

                /// TOTAL CARD
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Skeletonizer(
                    enabled: provider.isLoading,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Total Wishlist"),
                        const SizedBox(height: 5),
                        Text(
                          "Rp ${NumberFormat('#,##0', 'id_ID').format(total)}",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryPurple,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                /// TITLE
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "Wishlist",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryPurple,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                /// LIST
                Expanded(
                  child: Skeletonizer(
                    enabled: provider.isLoading,
                    child: SavingList(
                      items: provider.savings.map((e) => {
                        "id": e.id,
                        "name": e.name,
                        "amount": e.amount,
                        "target": e.target,
                        "date": e.date,
                        "isDone": e.status == "terbeli",
                      }).toList(),
                      onAddTap: _openCreateModal,
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