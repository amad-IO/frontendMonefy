// ===========================================================
// custom_navbar.dart
// Bottom Navigation Bar kustom bergaya fintech (Monefy-style)
// Bisa langsung dipakai di project Flutter kamu
// ===========================================================

import 'package:flutter/material.dart';
import 'dart:math' as math;

// ─────────────────────────────────────────────
// 1. KONSTANTA WARNA & TEMA
// ─────────────────────────────────────────────
class AppColors {
  static const Color primary = Color(0xFF6C5CE7);   // Ungu utama
  static const Color inactive = Color(0xFF9E9E9E);  // Abu-abu item tidak aktif
  static const Color navBg   = Color(0xFFFFFFFF);   // Background navbar (putih)
  static const Color scaffold = Color(0xFF1A1A2E);  // Background layar (gelap)
}

// ─────────────────────────────────────────────
// 2. MODEL DATA ITEM NAVBAR
// ─────────────────────────────────────────────
class NavItem {
  final IconData icon;
  final String label;

  const NavItem({required this.icon, required this.label});
}

// Daftar 5 item navbar (index 2 = FAB, dikosongkan)
final List<NavItem?> navItems = [
  NavItem(icon: Icons.home_rounded,         label: 'Home'),
  NavItem(icon: Icons.access_time_rounded,  label: 'History'),
  null,  // Slot kosong untuk FAB di tengah
  NavItem(icon: Icons.trending_up_rounded,  label: 'Analytic'),
  NavItem(icon: Icons.person_rounded,       label: 'Profile'),
];

// ─────────────────────────────────────────────
// 3. CUSTOM SHAPE — Kurva Cekung (Notch) Halus
// ─────────────────────────────────────────────
/// Membuat lekukan cekung di tengah-atas navbar menggunakan Bezier curve.
/// Ini adalah inti dari tampilan "floating FAB menyatu dengan navbar".
class SmoothNotchedShape extends NotchedShape {
  const SmoothNotchedShape();

  @override
  Path getOuterPath(Rect host, Rect? guest) {
    if (guest == null || !host.overlaps(guest)) {
      return Path()..addRRect(RRect.fromRectAndRadius(host, const Radius.circular(40)));
    }

    // Ukuran lekukan — sedikit lebih lebar dari FAB agar ada jarak napas
    final double notchRadius = guest.width / 2.0 + 12;
    final double cx = guest.center.dx; // titik tengah horizontal

    // Titik-titik kurva Bezier untuk lekukan halus
    final double curveStartX = cx - notchRadius - 28;
    final double curveEndX   = cx + notchRadius + 28;
    final double notchBottom = host.top + notchRadius * 0.85;
    final double notchTop    = host.top - 6;

    final path = Path();

    // Mulai dari pojok kiri bawah dengan sudut rounded
    path.moveTo(host.left, host.bottom);
    path.lineTo(host.left, host.top + 40);
    path.quadraticBezierTo(host.left, host.top, host.left + 40, host.top);

    // Garis lurus ke awal kurva notch
    path.lineTo(curveStartX, host.top);

    // Kurva Bezier kubik masuk ke lekukan (sisi kiri)
    path.cubicTo(
      curveStartX + 22, notchTop,   // control point 1
      cx - notchRadius, notchTop,   // control point 2
      cx, notchBottom,              // titik tengah bawah lekukan
    );

    // Kurva Bezier kubik keluar dari lekukan (sisi kanan)
    path.cubicTo(
      cx + notchRadius, notchTop,   // control point 1
      curveEndX - 22, notchTop,     // control point 2
      curveEndX, host.top,          // keluar di sisi kanan
    );

    // Lanjut ke pojok kanan atas dengan sudut rounded
    path.lineTo(host.right - 40, host.top);
    path.quadraticBezierTo(host.right, host.top, host.right, host.top + 40);
    path.lineTo(host.right, host.bottom);

    path.close();
    return path;
  }
}

// ─────────────────────────────────────────────
// 4. WIDGET ITEM NAVBAR (satu tombol)
// ─────────────────────────────────────────────
class NavItemWidget extends StatelessWidget {
  final NavItem item;
  final bool isActive;
  final VoidCallback onTap;

  const NavItemWidget({
    super.key,
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.primary : AppColors.inactive;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 70,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Titik indikator aktif (di atas ikon)
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: isActive ? 5 : 0,
              height: isActive ? 5 : 0,
              margin: const EdgeInsets.only(bottom: 4),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
            // Ikon
            AnimatedScale(
              scale: isActive ? 1.15 : 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              child: Icon(item.icon, color: color, size: 26),
            ),
            const SizedBox(height: 4),
            // Label teks
            Text(
              item.label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                // Ganti 'Nunito' jika sudah dikonfigurasi di pubspec.yaml
                fontFamily: 'Nunito',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 5. WIDGET NAVBAR UTAMA
// ─────────────────────────────────────────────
class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final VoidCallback onAddPressed;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,

      // ── FAB (Tombol Tambah di Tengah) ──────────────
      floatingActionButton: GestureDetector(
        onTap: onAddPressed,
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.45),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            // Ikon dua kartu bertumpuk (mirip logo Monefy)
            Icons.credit_card_rounded,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // ── BottomAppBar dengan notch halus ─────────────
      bottomNavigationBar: BottomAppBar(
        color: AppColors.navBg,
        elevation: 12,
        notchMargin: 10,
        shape: const SmoothNotchedShape(),
        child: SizedBox(
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Sisi KIRI: Home & History
              ...List.generate(2, (i) {
                final item = navItems[i]!;
                return NavItemWidget(
                  item: item,
                  isActive: selectedIndex == i,
                  onTap: () => onItemSelected(i),
                );
              }),

              // Slot kosong untuk FAB
              const SizedBox(width: 70),

              // Sisi KANAN: Analytic & Profile (index asli 3 & 4)
              ...List.generate(2, (i) {
                final realIndex = i + 3;
                final item = navItems[realIndex]!;
                return NavItemWidget(
                  item: item,
                  isActive: selectedIndex == realIndex,
                  onTap: () => onItemSelected(realIndex),
                );
              }),
            ],
          ),
        ),
      ),

      // Body kosong — widget ini hanya navbar, bukan halaman penuh
      body: const SizedBox.shrink(),
    );
  }
}

// ─────────────────────────────────────────────
// 6. CONTOH PEMAKAIAN — halaman demo lengkap
// ─────────────────────────────────────────────
void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Monefy-Style Navbar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.scaffold,
        fontFamily: 'Nunito',
      ),
      home: const MainScreen(),
    );
  }
}

// ─────────────────────────────────────────────
// 7. LAYAR UTAMA (StatefulWidget — menyimpan state tab)
// ─────────────────────────────────────────────
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // Tab aktif awal: Home

  // Daftar halaman per tab
  static const List<Widget> _pages = [
    _PlaceholderPage(label: 'Home',     icon: Icons.home_rounded),
    _PlaceholderPage(label: 'History',  icon: Icons.access_time_rounded),
    _PlaceholderPage(label: 'Analytic', icon: Icons.trending_up_rounded),
    _PlaceholderPage(label: 'Profile',  icon: Icons.person_rounded),
  ];

  // Mapping: index navbar (0,1,3,4) → index halaman (0,1,2,3)
  int _pageIndex(int navIndex) {
    if (navIndex >= 3) return navIndex - 1; // lewati slot FAB
    return navIndex;
  }

  void _onItemSelected(int index) {
    setState(() => _selectedIndex = index);
  }

  void _onAddPressed() {
    // Aksi tombol Add — bisa navigate ke halaman tambah transaksi
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: 200,
        decoration: const BoxDecoration(
          color: Color(0xFF2D2D44),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: const Center(
          child: Text(
            '+ Tambah Transaksi',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      extendBody: true, // Penting! Agar body bisa di-extend ke bawah navbar

      // Konten halaman aktif
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pages[_pageIndex(_selectedIndex)],
      ),

      // FAB
      floatingActionButton: GestureDetector(
        onTap: _onAddPressed,
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.45),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.credit_card_rounded,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // Bottom Navbar
      bottomNavigationBar: SafeArea(
        child: Padding(
          // Padding horizontal agar navbar tidak menempel ke tepi layar
          // (efek pill / kapsul seperti gambar)
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: BottomAppBar(
            color: AppColors.navBg,
            elevation: 16,
            notchMargin: 10,
            shape: const SmoothNotchedShape(),
            clipBehavior: Clip.antiAlias,
            child: SizedBox(
              height: 68,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Kiri: Home, History
                  NavItemWidget(
                    item: navItems[0]!,
                    isActive: _selectedIndex == 0,
                    onTap: () => _onItemSelected(0),
                  ),
                  NavItemWidget(
                    item: navItems[1]!,
                    isActive: _selectedIndex == 1,
                    onTap: () => _onItemSelected(1),
                  ),

                  // Slot FAB
                  const SizedBox(width: 70),

                  // Kanan: Analytic, Profile
                  NavItemWidget(
                    item: navItems[3]!,
                    isActive: _selectedIndex == 3,
                    onTap: () => _onItemSelected(3),
                  ),
                  NavItemWidget(
                    item: navItems[4]!,
                    isActive: _selectedIndex == 4,
                    onTap: () => _onItemSelected(4),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 8. PLACEHOLDER HALAMAN (untuk demo)
// ─────────────────────────────────────────────
class _PlaceholderPage extends StatelessWidget {
  final String label;
  final IconData icon;

  const _PlaceholderPage({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primary, size: 64),
          const SizedBox(height: 16),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Nunito',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Halaman $label',
            style: const TextStyle(
              color: AppColors.inactive,
              fontSize: 14,
              fontFamily: 'Nunito',
            ),
          ),
        ],
      ),
    );
  }
}