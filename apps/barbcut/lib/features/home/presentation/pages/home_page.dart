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
  static final ValueNotifier<bool> generationNotifier = ValueNotifier(false);
  static final ValueNotifier<Map<String, dynamic>?> generatedStyleNotifier =
      ValueNotifier(null);
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
