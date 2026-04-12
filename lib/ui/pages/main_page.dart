
import 'package:flutter/material.dart';
import 'package:monefy/ui/pages/add_wallet_page.dart';
import 'package:monefy/ui/pages/profile_page.dart';
import '../widgets/navbar/navbar.dart';
import 'bills_page.dart';
import 'home_page.dart';
import 'history_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  static const Duration _pageTransitionDuration = Duration(milliseconds: 520);
  int _selectedIndex = 0;
  late final PageController _pageController;
  List<Widget> _buildPages() {
    return [
      HomePage(onNavigate: _onItemTapped),
      HistoryPage(),
      BillsPage(),
      AddWalletPage(),
      ProfilePage(),
      _PlaceholderPage(label: 'Add'),
      _PlaceholderPage(label: 'Analytic'),
      _PlaceholderPage(label: 'Profile'),
    ];
  }

  @override
  void initState() {
    super.initState();
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