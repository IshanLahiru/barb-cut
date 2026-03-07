import 'package:flutter/material.dart';
import '../../../../views/home_view.dart';

class HomePage extends StatefulWidget {
  final int currentIndex;
  final int tabIndex;
  final VoidCallback? onNavigateToHistory;

  const HomePage({
    super.key,
    required this.currentIndex,
    required this.tabIndex,
    this.onNavigateToHistory,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return HomeView(
      currentIndex: widget.currentIndex,
      tabIndex: widget.tabIndex,
      onNavigateToHistory: _onNavigateToHistory,
    );
  }

  void _onNavigateToHistory() {
    widget.onNavigateToHistory?.call();
  }
}
