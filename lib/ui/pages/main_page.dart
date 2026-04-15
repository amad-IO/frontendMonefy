
import 'package:flutter/material.dart';
import '../widgets/navbar/navbar.dart';
import 'home_page.dart';
import 'history_page.dart';
import 'add_page.dart';
import 'profile_page.dart';

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
  late int _selectedIndex;
  late final PageController _pageController;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomePage(),
      HistoryPage(onBack: () => _onItemTapped(0)),
      const _PlaceholderPage(label: 'Add'),      // FAB opens AddPage sheet.
      const _PlaceholderPage(label: 'Analytic'),
      const ProfilePage(),
    ];

    if (widget.extraPage != null) {
      _pages.add(widget.extraPage!);
    }

    final maxIndex = _pages.length - 1;
    _selectedIndex = widget.initialIndex.clamp(0, maxIndex);
    _pageController = PageController(initialPage: _selectedIndex);

    // Open the add bottom sheet when requested via initial index.
    if (widget.initialIndex == 2) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showAddOverlay());
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showAddOverlay() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddPage(),
    );
  }

  void _onItemTapped(int index) {
    if (index == 2) {
      _showAddOverlay();
      return;
    }
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
      resizeToAvoidBottomInset: false,

      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          if (_selectedIndex != index) {
            setState(() => _selectedIndex = index);
          }
        },
        children: _pages,
      ),

      bottomNavigationBar: CustomNavbar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),

      floatingActionButton: CustomAddFab(
        onPressed: _showAddOverlay,
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