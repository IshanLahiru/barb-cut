import 'package:flutter/material.dart';
import '../../../theme/ai_colors.dart';
import '../../../theme/ai_spacing.dart';

class StylePreviewCardInline extends StatelessWidget {
  final Map<String, dynamic> style;

  const StylePreviewCardInline({
    super.key,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AiSpacing.radiusMedium),
          child: Image.network(
            style['image'] as String,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 100,
              height: 100,
              color: AiColors.backgroundSecondary.withValues(alpha: 0.5),
              child: Center(
                child: Icon(
                  Icons.image_not_supported,
                  color: AiColors.textTertiary,
                  size: 32,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: AiSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                style['name'] as String,
                style: TextStyle(
                  color: AiColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '₹${style['price']}',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF00E5FF)
                      : const Color(0xFF0097A7),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              SizedBox(height: 2),
              Text(
                '${style['duration'] ?? 45} mins',
                style: TextStyle(color: AiColors.textTertiary, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
