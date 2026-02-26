import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:barbcut/core/di/service_locator.dart';
import 'package:barbcut/features/ai_generation/domain/repositories/ai_job_repository.dart';
import 'package:barbcut/features/ai_generation/presentation/cubit/generation_status_cubit.dart';
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

  List<Widget> get _widgetOptions => <Widget>[
    HomePage(onNavigateToHistory: () => _onItemTapped(1)),
    const HistoryPage(),
    const ProductsPage(),
    const ProfilePage(),
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
    return BlocProvider<GenerationStatusCubit>(
      create: (_) =>
          GenerationStatusCubit(aiJobRepository: getIt<AiJobRepository>()),
      child: Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          final offsetAnimation = Tween<Offset>(
            begin: const Offset(0.08, 0),
            end: Offset.zero,
          ).animate(animation);
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: offsetAnimation, child: child),
          );
        },
        child: KeyedSubtree(
          key: ValueKey<int>(_selectedIndex),
          child: Center(child: _widgetOptions.elementAt(_selectedIndex)),
        ),
      ),
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
              icon: _buildNavIcon(Icons.manage_accounts, 3),
              label: 'Manage',
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
      ),
    );
  }
}
