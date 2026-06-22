import 'package:flutter/material.dart';
import '../../../providers/wallet_provider.dart';
import 'package:provider/provider.dart';


Future<int?> showWalletPicker(BuildContext context) {
  return showDialog<int>(
      context: context,
      builder: (context) {
        return Consumer<WalletProvider>(
          builder: (context, provider, child) {

            /// LOADING
            if (provider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF694EDA),
                ),
              );
            }

            final wallets = provider.wallets;

            return AlertDialog(
              title: const Text("Pilih Wallet"),
              content: SizedBox(
                height: 300,
                width: double.maxFinite,
                child: wallets.isEmpty
                    ? const Center(child: Text("No Wallet"))
                    : ListView(
                  children: wallets.map((wallet) {
                    return ListTile(
                      leading: const Icon(Icons.account_balance_wallet),
                      title: Text(wallet.name),
                      subtitle: Text("Rp ${wallet.balance}"),
                      onTap: () {
                        Navigator.pop(context, int.parse(wallet.id));
                      },
                    );
                  }).toList(),
                ),
              ),
            );
          },
        );
      }
  );
}