import 'package:flutter/material.dart';
import '../widgets/profile_menu_item.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),

      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // 🔙 BACK BUTTON (optional)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // 👤 AVATAR
            Stack(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, size: 50, color: Colors.white),
                ),

                // ✏️ EDIT ICON
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(6),
                    child: const Icon(
                      Icons.edit,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 👤 NAME
            const Text(
              "mochi",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF694EDA),
              ),
            ),

            const SizedBox(height: 4),

            // 📧 EMAIL
            const Text(
              "example@gmail.com",
              style: TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 24),

            // 📋 MENU
            ProfileMenuItem(
              icon: Icons.account_balance_wallet,
              title: "Add your wallet",
              onTap: () {
                // TODO: arahkan ke AddWalletPage
              },
            ),

            ProfileMenuItem(
              icon: Icons.help_outline,
              title: "Help Center",
              onTap: () {},
            ),

            ProfileMenuItem(
              icon: Icons.logout,
              title: "Logout",
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}