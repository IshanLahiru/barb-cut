import 'package:flutter/material.dart';
import '../../../../views/home_view.dart';

class HomePage extends StatefulWidget {
  final VoidCallback? onNavigateToHistory;

  const HomePage({super.key, this.onNavigateToHistory});

  @override
  State<HomePage> createState() => _HomePageState();

  // Static state for inter-page communication
  static bool isGenerating = false;
  static Map<String, dynamic>? generatedStyleData;
  static Function(Map<String, dynamic>)? onAddToHistory;
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return HomeView(onNavigateToHistory: _onNavigateToHistory);
  }

  void _onNavigateToHistory() {
    HomePage.isGenerating = true;
    widget.onNavigateToHistory?.call();

    // Create history item after generation "completes" (after animation)
    Future.delayed(Duration(seconds: 5), () {
      if (mounted && HomePage.generatedStyleData != null) {
        // Trigger callback to add to history
        HomePage.onAddToHistory?.call(HomePage.generatedStyleData!);
      }
      if (mounted) {
        setState(() {
          HomePage.isGenerating = false;
        });
      }
    });
  }
}
