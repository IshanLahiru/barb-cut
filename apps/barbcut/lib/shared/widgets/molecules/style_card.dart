import 'package:flutter/material.dart';
import '../../../theme/ai_colors.dart';
import '../../../theme/ai_spacing.dart';
import '../../../theme/adaptive_theme_colors.dart';
import '../../../widgets/firebase_image.dart';

class StyleCard extends StatelessWidget {
  final Map<String, dynamic> style;
  final VoidCallback onChangePressed;
  final VoidCallback onRemovePressed;

  const StyleCard({
    super.key,
    required this.style,
    required this.onChangePressed,
    required this.onRemovePressed,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor =
        (style['accentColor'] as Color?) ??
        AdaptiveThemeColors.neonCyan(context);
    final tips = (style['tips'] as String?)?.trim();
    final hasTips = tips != null && tips.isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AiSpacing.radiusMedium),
      child: Container(
        color: AiColors.backgroundSecondary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Text(
                style['name'] as String,
                style: TextStyle(
                  color: AiColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),

            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Stack(
                  children: [
                    FirebaseImage(
                      style['image'] as String,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorWidget: Container(
                        height: 120,
                        color: AiColors.backgroundSecondary.withValues(
                          alpha: 0.5,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.image_not_supported,
                            color: AiColors.textTertiary,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              accentColor.withValues(alpha: 0.15),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    style['name'] as String,
                    style: TextStyle(
                      color: AiColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6),
                  if (hasTips)
                    Text(
                      tips,
                      style: TextStyle(
                        color: AiColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    )
                  else
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: accentColor.withValues(alpha: 0.15),
                          ),
                          child: Text(
                            '₹${style['price']}',
                            style: TextStyle(
                              color: accentColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        SizedBox(width: 6),
                        Text(
                          '${style['duration'] ?? 45}min',
                          style: TextStyle(
                            color: AiColors.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  SizedBox(height: 10),

                  // Buttons stacked vertically
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: onChangePressed,
                      icon: Icon(Icons.edit_outlined, size: 14),
                      label: Text('Change', style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: accentColor,
                        side: BorderSide(
                          color: accentColor.withValues(alpha: 0.4),
                          width: 1,
                        ),
                        padding: EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 6),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: onRemovePressed,
                      icon: Icon(Icons.close_outlined, size: 14),
                      label: Text('Remove', style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AiColors.textSecondary,
                        side: BorderSide(
                          color: AiColors.borderLight.withValues(alpha: 0.3),
                          width: 1,
                        ),
                        padding: EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
