import 'package:flutter/material.dart';
import '../../../../views/history_view.dart';

class HistoryPage extends StatelessWidget {
  final int currentIndex;
  final int tabIndex;

  const HistoryPage({
    super.key,
    required this.currentIndex,
    required this.tabIndex,
  });

  @override
  Widget build(BuildContext context) {
    return HistoryView(
      currentIndex: currentIndex,
      tabIndex: tabIndex,
    );
  }
}
