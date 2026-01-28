import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/theme_controller.dart';
import '../theme/ai_colors.dart';
import '../theme/ai_spacing.dart';

class AppearanceView extends StatelessWidget {
  const AppearanceView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AiColors.backgroundDeep,
      appBar: AppBar(
        backgroundColor: AiColors.backgroundDark,
        elevation: 0,
        title: Text(
          'Appearance',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: AiColors.textPrimary),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: EdgeInsets.all(AiSpacing.lg),
        children: [
          Text(
            'Theme',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AiColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: AiSpacing.md),
          Container(
            decoration: BoxDecoration(
              color: AiColors.backgroundSecondary,
              borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
              border: Border.all(
                color: AiColors.neonCyan.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: SwitchListTile(
              title: Text(
                'Dark mode',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: AiColors.textPrimary),
              ),
              subtitle: Text(
                'Use dark appearance across the app',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AiColors.textSecondary),
              ),
              value: context.watch<ThemeController>().isDarkMode,
              activeThumbColor: AiColors.neonCyan,
              onChanged: (value) =>
                  context.read<ThemeController>().toggleDarkMode(value),
            ),
          ),
        ],
      ),
    );
  }
}
