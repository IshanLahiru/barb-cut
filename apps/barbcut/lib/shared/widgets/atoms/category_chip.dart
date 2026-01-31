import 'package:flutter/material.dart';
import '../../../theme/adaptive_theme_colors.dart';
import '../../../theme/ai_spacing.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final Color color;

  const CategoryChip({
    super.key,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AiSpacing.md,
        vertical: AiSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AdaptiveThemeColors.backgroundSecondary(context),
        borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: AdaptiveThemeColors.textPrimary(context),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
