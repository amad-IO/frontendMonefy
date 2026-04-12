
import 'package:flutter/material.dart';
import 'package:monefy/ui/pages/add_wallet_page.dart';
import 'package:monefy/ui/pages/profile_page.dart';
import '../widgets/navbar/navbar.dart';
import 'bills_page.dart';
import 'home_page.dart';
import 'history_page.dart';

class MainPage extends StatefulWidget {
  final int initialIndex;
  final Widget? extraPage;

  const MainPage({
    super.key,
    this.initialIndex = 0,
    this.extraPage,
  });

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  static const Duration _pageTransitionDuration = Duration(milliseconds: 520);
  int _selectedIndex = 0;
  late final PageController _pageController;
  List<Widget> _buildPages() {
    final pages = [
      HomePage(onNavigate: _onItemTapped), // 0
      HistoryPage(),                      // 1
      AddWalletPage(),                    // 2
      _PlaceholderPage(label: 'Analytic'),                   // 3
      ProfilePage(),                      // 4
    ];

    // halaman tambahan (Bills)
    if (widget.extraPage != null) {
      pages.add(widget.extraPage!); // jadi index terakhir
    }

    return pages;
  }
  @override
  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;

    setState(() => _selectedIndex = index);
    _pageController.animateToPage(
      index,
      duration: _pageTransitionDuration,
      curve: Curves.easeInOutCubicEmphasized,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,

      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          if (_selectedIndex != index) {
            setState(() => _selectedIndex = index);
          }
        },
        children: _buildPages(),
      ),

      bottomNavigationBar: CustomNavbar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),

      floatingActionButton: CustomAddFab(
        onPressed: () => _onItemTapped(2),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
class _PlaceholderPage extends StatelessWidget {
  final String label;
  const _PlaceholderPage({required this.label});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),
      body: Center(
        child: Text(
          '$label Page\n(coming soon)',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 16,
            color: Color(0xFF6D6D6D),
          ),
        ),
      ),
    );
  }
}