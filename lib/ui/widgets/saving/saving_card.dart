import 'package:flutter/material.dart';
import 'package:monefy/ui/widgets/saving/wallet_picker_modal.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/saving_provider.dart';
import '../../../providers/wallet_provider.dart';
import '../../../core/utils/currency_formatter.dart';

class SavingCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback? onTap;

  const SavingCard({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = item["isDone"] ?? false;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              blurRadius: 6,
              color: Colors.black12,
            )
          ],
        ),
        child: Row(
          children: [
            /// ICON
            Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: const Color(0xFFD5CEF5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.attach_money,
                color: Color(0xFF694EDA),
                size: 18,
              ),
            ),

            const SizedBox(width: 10),

            /// TITLE
            Expanded(
              child: Text(
                item["name"],
                style: const TextStyle(
                  color: Color(0xFF694EDA),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),

            /// PRICE + BUTTON
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  rupiahFormatter.format(item["target"]),
                  style: const TextStyle(
                    color: Color(0xFF694EDA),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),

                GestureDetector(
                  onTap: isDone
                      ? null
                      : () async {
                    final token =
                    context.read<AuthProvider>().token!;
                    context.read<WalletProvider>().loadWalletsFromApi(token);
                    final walletProvider =
                    context.read<WalletProvider>();
                    // wallets tersedia melalui Consumer di wallet_picker_modal

                    final walletId = await showWalletPicker(context);

                    if (walletId != null) {
                      context.read<SavingProvider>().buySaving(
                        item["id"],
                        walletId,
                        token,
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDone
                          ? Colors.grey
                          : const Color(0xFF694EDA),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isDone ? "Done" : "Buy",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}