import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../providers/auth_provider.dart';
import '../../providers/saving_provider.dart';
import 'saving_card.dart';
import 'package:provider/provider.dart';
import 'saving_detail_modal.dart';

class SavingList extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final VoidCallback? onAddTap;

  const SavingList({
    super.key,
    this.items = const [],
    this.onAddTap,
  });

  @override
  State<SavingList> createState() => _SavingListState();
}

class _SavingListState extends State<SavingList> {
  bool isDone = false;

  @override
  Widget build(BuildContext context) {
    /// 🔥 FILTER DATA
    final savings = widget.items.where((item) {
      return item["isDone"] == isDone;
    }).toList();

    return Container(
      height: double.infinity,
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1F1),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),
      child: Stack(
        children: [
          /// BACKGROUND
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: SvgPicture.asset(
                "assets/images/kontur.svg",
                fit: BoxFit.cover,
              ),
            ),
          ),

          /// CONTENT
          ListView(
            padding: const EdgeInsets.only(top: 20),
            children: [
              /// ADD WISHLIST
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: widget.onAddTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD5CEF5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, size: 16, color: Colors.white),
                          SizedBox(width: 5),
                          Text(
                            "Add Wishlist",
                            style: TextStyle(
                              color: Color(0xFF694EDA),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// TOGGLE (ONGOING / DONE)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0x33694EDA),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    /// ONGOING
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() => isDone = false);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: !isDone
                                ? Colors.white
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Center(
                            child: Text(
                              "Ongoing",
                              style: TextStyle(
                                color: Color(0xFF694EDA),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    /// DONE
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() => isDone = true);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isDone
                                ? Colors.white
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Center(
                            child: Text(
                              "Done",
                              style: TextStyle(
                                color: Color(0xFF694EDA),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// EMPTY
              if (savings.isEmpty)
                const Center(
                  child: Text("No Wishlist"),
                ),

              /// LIST DATA
              ...savings.map((item) {
                return SavingCard(
                  item: item,
                  onTap: () {
                    showSavingDetailModal(context, item);
                  },
                );
              }).toList(),

              const SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }
}
