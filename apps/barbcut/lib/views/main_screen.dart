import 'package:flutter/material.dart';
import 'package:barbcut/features/home/presentation/pages/home_page.dart';
import 'package:barbcut/features/history/presentation/pages/history_page.dart';
import 'package:barbcut/features/products/presentation/pages/products_page.dart';
import 'package:barbcut/features/profile/presentation/pages/profile_page.dart';
import '../theme/theme.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    HistoryPage(),
    ProductsPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildNavIcon(IconData icon, int index) {
    return Icon(icon);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AdaptiveThemeColors.backgroundSecondary(context),
          boxShadow: [
            BoxShadow(
              color: AdaptiveThemeColors.neonCyan(
                context,
              ).withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.home, 0),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.history, 1),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.shopping_bag, 2),
              label: 'Products',
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.person, 3),
              label: 'Profile',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: AdaptiveThemeColors.neonCyan(context),
          unselectedItemColor: AdaptiveThemeColors.textSecondary(context),
          backgroundColor: AdaptiveThemeColors.backgroundSecondary(context),
          onTap: _onItemTapped,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedIconTheme: IconThemeData(size: 28),
          unselectedIconTheme: IconThemeData(size: 24),
        ),
      ),
    );
  }
}
