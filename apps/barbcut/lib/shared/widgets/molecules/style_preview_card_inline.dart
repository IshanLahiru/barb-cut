import 'package:flutter/material.dart';
import '../../../theme/theme.dart';
import '../../../widgets/firebase_image.dart';

class StylePreviewCardInline extends StatelessWidget {
  final Map<String, dynamic> style;

  const StylePreviewCardInline({super.key, required this.style});

  @override
  Widget build(BuildContext context) {
    final tips = (style['tips'] as String?)?.trim();
    final hasTips = tips != null && tips.isNotEmpty;

    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AiSpacing.radiusMedium),
          child: FirebaseImage(
            style['image'] as String,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
            errorWidget: Container(
              width: 100,
              height: 100,
              color: ThemeAdapter.getBackgroundSecondary(
                context,
              ).withValues(alpha: 0.5),
              child: Center(
                child: Icon(
                  Icons.image_not_supported,
                  color: ThemeAdapter.getTextTertiary(context),
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
                  color: ThemeAdapter.getTextPrimary(context),
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              SizedBox(height: 4),
              if (hasTips)
                Text(
                  tips,
                  style: TextStyle(
                    color: ThemeAdapter.getTextSecondary(context),
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
