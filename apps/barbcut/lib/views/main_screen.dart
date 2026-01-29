import 'package:flutter/material.dart';
import 'package:barbcut/views/explore_view.dart';
import 'package:barbcut/views/home_view.dart';
import 'package:barbcut/views/profile_view.dart';
import 'package:barbcut/views/products_view.dart';
import '../theme/adaptive_theme_colors.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomeView(),
    ExploreView(),
    ProductsView(),
    ProfileView(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
              color: AdaptiveThemeColors.neonCyan(context).withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.explore),
              label: 'Explore',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag),
              label: 'Products',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: AdaptiveThemeColors.neonCyan(context),
          unselectedItemColor: AdaptiveThemeColors.textSecondary(context).withValues(alpha: 0.6),
          backgroundColor: AdaptiveThemeColors.backgroundSecondary(context),
          onTap: _onItemTapped,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
      ),
    );
  }
}
