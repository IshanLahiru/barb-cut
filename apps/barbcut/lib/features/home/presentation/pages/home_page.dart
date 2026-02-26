import 'package:flutter/material.dart';
import '../../../../views/home_view.dart';

class HomePage extends StatefulWidget {
  final VoidCallback? onNavigateToHistory;

  const HomePage({super.key, this.onNavigateToHistory});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return HomeView(onNavigateToHistory: _onNavigateToHistory);
  }

  void _onNavigateToHistory() {
    widget.onNavigateToHistory?.call();
  }
}
