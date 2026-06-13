import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/help_center/help_search_bar.dart';
import '../widgets/help_center/help_category_selector.dart';
import '../widgets/help_center/faq_card.dart';

class HelpCenterPage extends StatefulWidget {
  const HelpCenterPage({super.key});

  @override
  State<HelpCenterPage> createState() => _HelpCenterPageState();
}

class _HelpCenterPageState extends State<HelpCenterPage> {
  String _searchQuery = "";
  String _selectedCategory = "Umum";

  final List<String> _categories = ["Umum", "Transaksi", "Dompet", "Akun"];

  final List<Map<String, String>> _faqs = [
    // ... isi FAQ yang sama persis seperti sebelumnya
  ];

  @override
  Widget build(BuildContext context) {
    final filteredFaqs = _faqs.where((faq) {
      final matchesCategory = faq["category"] == _selectedCategory;
      final matchesSearch = faq["question"]!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          faq["answer"]!.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFB7AEEB),
      body: SafeArea(
        child: Column(
          children: [
            /// HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppColors.primaryPurple),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const Text(
                    "Help Center",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryPurple,
                      fontFamily: 'Nunito',
                    ),
                  ),
                ],
              ),
            ),

            /// SEARCH BAR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: HelpSearchBar(
                onChanged: (val) => setState(() => _searchQuery = val),
              ),
            ),

            /// CATEGORY SELECTOR (PILLS)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: HelpCategorySelector(
                categories: _categories,
                selectedCategory: _selectedCategory,
                onCategorySelected: (cat) => setState(() => _selectedCategory = cat),
              ),
            ),

            const SizedBox(height: 10),

            /// LIST PANEL FAQ
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F1F1),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Pertanyaan Populer",
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryPurple,
                        ),
                      ),
                      const SizedBox(height: 12),

                      if (filteredFaqs.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: Text(
                              "Tidak ada pertanyaan yang sesuai.",
                              style: TextStyle(fontFamily: 'Nunito', color: Colors.grey),
                            ),
                          ),
                        )
                      else
                        ...filteredFaqs.map((faq) {
                          return FaqCard(
                            question: faq["question"]!,
                            answer: faq["answer"]!,
                          );
                        }).toList(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}