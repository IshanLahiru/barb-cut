import 'package:flutter/material.dart';
import '../../../theme/adaptive_theme_colors.dart';
import '../../../theme/ai_spacing.dart';
import '../atoms/ai_buttons.dart';

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onView;
  final VoidCallback onAdd;

  const ProductCard({
    super.key,
    required this.product,
    required this.isSelected,
    required this.onTap,
    required this.onView,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = product['accentColor'] as Color;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: isSelected
              ? AdaptiveThemeColors.surface(context)
              : AdaptiveThemeColors.backgroundSecondary(context),
          borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
          border: Border.all(
            color: isSelected
                ? accentColor
                : AdaptiveThemeColors.borderLight(context),
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: accentColor.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AiSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AiSpacing.md),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        AiSpacing.radiusLarge,
                      ),
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      product['icon'] as IconData,
                      color: accentColor,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: AiSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product['name'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: AdaptiveThemeColors.textPrimary(context),
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: AiSpacing.xs),
                        Text(
                          product['description'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AdaptiveThemeColors.textTertiary(
                                  context,
                                ),
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AiSpacing.md),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AiSpacing.sm,
                      vertical: AiSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(
                        AiSpacing.radiusSmall,
                      ),
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      product['price'],
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: accentColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AiSpacing.md),
              if (!isSelected)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AiSpacing.sm,
                    vertical: AiSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AdaptiveThemeColors.backgroundDeep(context),
                    borderRadius: BorderRadius.circular(AiSpacing.radiusSmall),
                    border: Border.all(
                      color: AdaptiveThemeColors.borderLight(context),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star_rounded,
                        size: 16,
                        color: AdaptiveThemeColors.neonCyan(context),
                      ),
                      const SizedBox(width: AiSpacing.xs),
                      Text(
                        product['rating'].toString(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AdaptiveThemeColors.textSecondary(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: AiSecondaryButton(
                          label: 'View',
                          onPressed: onView,
                          accentColor: AdaptiveThemeColors.neonCyan(context),
                        ),
                      ),
                    ),
                    const SizedBox(width: AiSpacing.sm),
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: AiPrimaryButton(
                          label: 'Add',
                          onPressed: onAdd,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
