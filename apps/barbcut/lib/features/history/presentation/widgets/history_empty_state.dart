import 'package:flutter/material.dart';
import '../../../../theme/theme.dart';

class HistoryEmptyState extends StatelessWidget {
  const HistoryEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.8 + (value * 0.2),
                child: Opacity(opacity: value, child: child),
              );
            },
            child: Container(
              padding: EdgeInsets.all(AiSpacing.xl),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AdaptiveThemeColors.neonCyan(context).withValues(alpha: 0.15),
                    AdaptiveThemeColors.neonPurple(context).withValues(alpha: 0.15),
                  ],
                ),
                border: Border.all(
                  color: AdaptiveThemeColors.neonCyan(context).withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              child: Icon(
                Icons.history_rounded,
                size: 64,
                color: AdaptiveThemeColors.neonCyan(context),
              ),
            ),
          ),
          SizedBox(height: AiSpacing.xl),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 900),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 10 * (1 - value)),
                child: Opacity(opacity: value, child: child),
              );
            },
            child: Column(
              children: [
                Text(
                  'No generation history yet',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AdaptiveThemeColors.textPrimary(context),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),
                SizedBox(height: AiSpacing.md),
                Text(
                  'Generate your first style to see it here',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AdaptiveThemeColors.textTertiary(context),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
