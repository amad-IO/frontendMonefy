import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
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
      context.read<SavingProvider>().fetchSavings();
    });
  }

  /// 🔥 HANDLE CREATE (biar gak duplikat)
  void _handleCreateSaving(String name, int amount) {
    context.read<SavingProvider>().addSaving(name, amount);
  }

  /// 🔥 BUKA MODAL
  void _openCreateModal() {
    showCreateSavingModal(context, _handleCreateSaving);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB7AEEB),

      /// 🔥 FLOATING BUTTON
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryPurple,
        onPressed: _openCreateModal,
        child: const Icon(Icons.add),
      ),

      body: SafeArea(
        child: Consumer<SavingProvider>(
          builder: (context, provider, child) {
            print("BUILD UI: ${provider.savings.length}");

            /// 🔄 LOADING
            if (provider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            /// 💰 TOTAL
            final total = provider.savings.fold<int>(
              0,
                  (sum, item) => sum + item.amount,
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// 🔝 HEADER
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

                /// 💳 TOTAL CARD
                SavingCard(total: total),

                const SizedBox(height: 16),

                /// 📋 TITLE
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

                /// 📦 LIST
                Expanded(
                  child: SavingList(
                    items: provider.savings.map((e) => {
                      "name": e.name,
                      "amount": e.amount,
                      "target": e.target,
                    }).toList(),

                    /// 🔥 klik dari card juga bisa buka modal
                    onCreateTap: _openCreateModal,
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