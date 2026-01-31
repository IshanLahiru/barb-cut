import 'package:flutter/material.dart';
import '../../../theme/adaptive_theme_colors.dart';
import '../../../theme/ai_spacing.dart';

class StatItem extends StatelessWidget {
  final String label;
  final String value;

  const StatItem({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AiSpacing.sm,
        vertical: AiSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AdaptiveThemeColors.backgroundDark(
          context,
        ).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AiSpacing.radiusMedium),
        border: Border.all(
          color: AdaptiveThemeColors.borderLight(context),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AdaptiveThemeColors.textPrimary(context),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AdaptiveThemeColors.textTertiary(context),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
