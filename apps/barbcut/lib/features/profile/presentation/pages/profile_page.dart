import 'package:flutter/material.dart';
import '../../../../views/management_view.dart';

class ProfilePage extends StatelessWidget {
  final int currentIndex;
  final int tabIndex;

  const ProfilePage({
    super.key,
    required this.currentIndex,
    required this.tabIndex,
  });

  @override
  Widget build(BuildContext context) {
    return ProfileView(
      currentIndex: currentIndex,
      tabIndex: tabIndex,
    );
  }
}
