import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../widgets/confirm_dialog.dart';
import 'create_wallet_page.dart';
import 'help_center_page.dart';
import 'list_bills_page.dart';
import 'saving_page.dart';

class ProfilePage extends StatefulWidget {
  final VoidCallback? onBack;

  const ProfilePage({super.key, this.onBack});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ImagePicker _picker = ImagePicker();
  File? _avatarImage;

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (picked != null && mounted) {
      setState(() => _avatarImage = File(picked.path));
    }
  }

  void _goBack() {
    if (widget.onBack != null) {
      widget.onBack!();
      return;
    }
    Navigator.maybePop(context);
  }

  void _openPage(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final username = auth.username?.trim().isNotEmpty == true
        ? auth.username!
        : 'Monefy User';
    final email = auth.email?.trim().isNotEmpty == true
        ? auth.email!
        : 'Keep your finances beautifully organized';

    return Scaffold(
      backgroundColor: AppColors.primaryPurple,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _ProfileHero(
                username: username,
                email: email,
                avatarImage: _avatarImage,
                onBack: _goBack,
                onEditAvatar: _pickImage,
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.backgroundWhite,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(38),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.panelShadow,
                        blurRadius: 20,
                        offset: Offset(0, -5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(38),
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Opacity(
                            opacity: 0.12,
                            child: SvgPicture.asset(
                              'assets/images/kontur.svg',
                              fit: BoxFit.cover,
                              colorFilter: const ColorFilter.mode(
                                AppColors.decorativePurple,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                        ListView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(20, 25, 20, 135),
                          children: [
                            _ProfileMenuCard(
                              icon: Icons.receipt_long_rounded,
                              title: 'Bills',
                              subtitle: 'Track and manage your payments',
                              onTap: () => _openPage(const ListBillsPage()),
                            ),
                            const SizedBox(height: 11),
                            _ProfileMenuCard(
                              icon: Icons.savings_rounded,
                              title: 'Wishlist',
                              subtitle: 'Keep your saving goals on track',
                              onTap: () => _openPage(const SavingPage()),
                            ),
                            const SizedBox(height: 11),
                            _ProfileMenuCard(
                              icon: Icons.add_card_rounded,
                              title: 'Add wallet',
                              subtitle: 'Connect a new place for your money',
                              onTap: () => _openPage(const CreateWalletPage()),
                            ),
                            const SizedBox(height: 11),
                            _ProfileMenuCard(
                              icon: Icons.help_outline_rounded,
                              title: 'Help center',
                              subtitle: 'Find answers and helpful guidance',
                              onTap: () => _openPage(const HelpCenterPage()),
                            ),
                            const SizedBox(height: 27),
                            _LogoutButton(onTap: _showLogoutConfirmation),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirmation() {
    ConfirmDialog.show(
      context: context,
      icon: Icons.logout_rounded,
      title: 'Log out of your account?',
      description:
          "You'll need to sign in again to access your savings and track your finances.",
      confirmLabel: 'Log Out',
      confirmColor: AppColors.error,
      onConfirm: () async {
        await context.read<AuthProvider>().logout();
        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      },
    );
  }
}

class _ProfileHero extends StatelessWidget {
  final String username;
  final String email;
  final File? avatarImage;
  final VoidCallback onBack;
  final VoidCallback onEditAvatar;

  const _ProfileHero({
    required this.username,
    required this.email,
    required this.avatarImage,
    required this.onBack,
    required this.onEditAvatar,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 255,
      child: Stack(
        children: [
          const Positioned.fill(child: _ProfileCheckerDecoration()),
          Positioned(
            left: 14,
            right: 14,
            top: 8,
            child: Row(
              children: [
                Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: onBack,
                    customBorder: const CircleBorder(),
                    child: const Padding(
                      padding: EdgeInsets.all(11),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.panelWhite,
                        size: 25,
                      ),
                    ),
                  ),
                ),
                const Expanded(
                  child: Text(
                    'My Profile',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                      color: AppColors.panelWhite,
                    ),
                  ),
                ),
                const SizedBox(width: 47),
              ],
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            top: 72,
            child: Row(
              children: [
                _ProfileAvatar(avatarImage: avatarImage, onTap: onEditAvatar),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        username,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 28,
                          height: 1.05,
                          fontWeight: FontWeight.w800,
                          color: AppColors.panelWhite,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.panelWhite.withValues(alpha: 0.82),
                        ),
                      ),
                      const SizedBox(height: 13),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.panelWhite.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.panelWhite.withValues(alpha: 0.22),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified_rounded,
                              size: 15,
                              color: AppColors.panelWhite,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Monefy member',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.panelWhite,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final File? avatarImage;
  final VoidCallback onTap;

  const _ProfileAvatar({required this.avatarImage, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 106,
            height: 106,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.dashboardPurple,
              border: Border.all(color: AppColors.panelWhite, width: 4),
              image: avatarImage != null
                  ? DecorationImage(
                      image: FileImage(avatarImage!),
                      fit: BoxFit.cover,
                    )
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.17),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: avatarImage == null
                ? const Icon(
                    Icons.person_rounded,
                    size: 56,
                    color: AppColors.panelWhite,
                  )
                : null,
          ),
          Positioned(
            right: -2,
            bottom: 2,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.panelWhite, width: 2),
              ),
              child: const Icon(
                Icons.photo_camera_rounded,
                size: 16,
                color: AppColors.panelWhite,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileMenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.panelWhite,
      borderRadius: BorderRadius.circular(19),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(19),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(19),
            border: Border.all(
              color: AppColors.primaryPurple.withValues(alpha: 0.07),
            ),
            boxShadow: const [
              BoxShadow(
                color: AppColors.lightShadow,
                blurRadius: 11,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              SizedBox(
                width: 46,
                height: 46,
                child: Icon(icon, color: AppColors.primaryPurple, size: 23),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 10.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.disabled,
                size: 23,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final VoidCallback onTap;

  const _LogoutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 55,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.logout_rounded, size: 20),
        label: const Text(
          'Log out',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          backgroundColor: AppColors.panelWhite,
          side: BorderSide(color: AppColors.error.withValues(alpha: 0.28)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
      ),
    );
  }
}

class _ProfileCheckerDecoration extends StatelessWidget {
  const _ProfileCheckerDecoration();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: SizedBox(
        width: 150,
        height: 250,
        child: GridView.builder(
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
          ),
          itemCount: 15,
          itemBuilder: (_, index) => ColoredBox(
            color: index.isEven
                ? AppColors.panelWhite.withValues(alpha: 0.035)
                : AppColors.primaryPurple.withValues(alpha: 0.04),
          ),
        ),
      ),
    );
  }
}
