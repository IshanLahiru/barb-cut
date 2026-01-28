import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/theme_controller.dart';
import '../theme/app_spacing.dart';

class AppearanceView extends StatelessWidget {
  const AppearanceView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Appearance', style: textTheme.titleMedium),
        toolbarHeight: 22,
        elevation: 0,
      ),
      body: ListView(
        padding: AppSpacing.paddingLG,
        children: [
          Text('Theme', style: textTheme.labelSmall),
          const SizedBox(height: AppSpacing.sm),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border.all(color: theme.colorScheme.outline, width: 1.0),
            ),
            child: SwitchListTile(
              title: Text('Dark mode', style: textTheme.titleMedium),
              subtitle: Text(
                'Use dark appearance across the app',
                style: textTheme.bodySmall,
              ),
              value: context.watch<ThemeController>().isDarkMode,
              onChanged: (value) =>
                  context.read<ThemeController>().toggleDarkMode(value),
            ),
          ),
        ],
      ),
    );
  }
}
