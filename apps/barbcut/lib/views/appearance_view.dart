import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/theme_controller.dart';
import '../theme/theme.dart';

class AppearanceView extends StatelessWidget {
  const AppearanceView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdaptiveThemeColors.backgroundDeep(context),
      appBar: AppBar(
        backgroundColor: AdaptiveThemeColors.backgroundDark(context),
        elevation: 0,
        title: Text(
          'Appearance',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AdaptiveThemeColors.textPrimary(context),
          ),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: EdgeInsets.all(AiSpacing.lg),
        children: [
          Text(
            'Theme',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AdaptiveThemeColors.textSecondary(context),
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: AiSpacing.md),
          Container(
            decoration: BoxDecoration(
              color: AdaptiveThemeColors.backgroundSecondary(context),
              borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
              border: Border.all(
                color: AdaptiveThemeColors.neonCyan(
                  context,
                ).withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: SwitchListTile(
              title: Text(
                'Dark mode',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AdaptiveThemeColors.textPrimary(context),
                ),
              ),
              subtitle: Text(
                'Use dark appearance across the app',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AdaptiveThemeColors.textSecondary(context),
                ),
              ),
              value: context.watch<ThemeController>().isDarkMode,
              activeThumbColor: AdaptiveThemeColors.neonCyan(context),
              onChanged: (value) {
                context.read<ThemeController>().toggleDarkMode(value);
              },
            ),
          ),
        ],
      ),
    );
  }
}
