import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _avatarImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() => _avatarImage = File(picked.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dashboardPurple,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── HEADER ──────────────────────────────────────
            _buildHeader(context),

            // ── BODY (white card) ───────────────────────────
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // HEADER  — purple top with back arrow + title
  // ═══════════════════════════════════════════════════════════
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: SvgPicture.asset(
              'assets/icon/back.svg',
              width: 35,
              height: 35,
              colorFilter: const ColorFilter.mode(
                AppColors.primaryPurple,
                BlendMode.srcIn,
              ),
            ),
          ),

          // Title centered
          Expanded(
            child: Text(
              'My Profile',
              textAlign: TextAlign.center,
              style: AppTextStyle.heading.copyWith(
                color: AppColors.primaryPurple,
                fontSize: 25,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          // Spacer keeps title centered
          const SizedBox(width: 24),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // BODY  — white rounded card with profile info + menu
  // ═══════════════════════════════════════════════════════════
  Widget _buildBody() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.panelWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: Stack(
          children: [
            // ── Kontur SVG background ──
            Positioned.fill(
              child: Opacity(
                opacity: 0.9,
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

            // ── Content ──
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 120),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // Avatar
                  _buildAvatar(),

                  const SizedBox(height: 16),

                  // Name
                  const Text(
                    'mochi',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryPurple,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Email
                  const Text(
                    'exsmplemochi@gmail.com',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14,
                      color: AppColors.disabled,
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Menu items
                  _buildMenuItem(
                    svgPath: 'assets/icon/add.svg',
                    label: 'Add your wallet',
                    onTap: () {
                      // TODO: navigate to AddWalletPage
                    },
                  ),

                  const SizedBox(height: 14),

                  _buildMenuItem(
                    svgPath: 'assets/icon/question.svg',
                    label: 'Help center',
                    iconSize: 36,
                    onTap: () {},
                  ),

                  const SizedBox(height: 140),

                  // Logout button
                  _buildLogoutButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // AVATAR  — with edit badge
  // ═══════════════════════════════════════════════════════════
  Widget _buildAvatar() {
    return GestureDetector(
      onTap: _pickImage,
      child: Stack(
        children: [
          // Circle avatar
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade300,
              image: _avatarImage != null
                  ? DecorationImage(
                      image: FileImage(_avatarImage!),
                      fit: BoxFit.cover,
                    )
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: _avatarImage == null
                ? const Icon(Icons.person, size: 60, color: Colors.white)
                : null,
          ),

          // Edit badge
          Positioned(
            bottom: 4,
            right: 4,
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: AppColors.badgeDark,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.edit,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // MENU ITEM  — icon + rounded card with label
  // ═══════════════════════════════════════════════════════════
  Widget _buildMenuItem({
    required String svgPath,
    required String label,
    required VoidCallback onTap,
    double iconSize = 28,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          children: [
            // SVG icon
            SvgPicture.asset(
              svgPath,
              width: iconSize,
              height: iconSize,
              colorFilter: const ColorFilter.mode(
                AppColors.primaryPurple,
                BlendMode.srcIn,
              ),
            ),

            const SizedBox(width: 20),

            // Label card
            Expanded(
              child: Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: AppColors.menuItemBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.centerLeft,
                child: Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // LOGOUT BUTTON
  // ═══════════════════════════════════════════════════════════
  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: GestureDetector(
        onTap: () {
          // TODO: handle logout
        },
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.error,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/icon/logout.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Logout',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}