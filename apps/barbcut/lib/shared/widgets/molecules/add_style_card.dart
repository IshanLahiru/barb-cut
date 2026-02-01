import 'package:flutter/material.dart';
import '../../../theme/theme.dart';

class AddStyleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color accentColor;
  final VoidCallback onPressed;

  const AddStyleCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: 200,
        height: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AiSpacing.radiusMedium),
          border: Border.all(
            color: accentColor.withValues(alpha: 0.3),
            width: 2,
          ),
          color: accentColor.withValues(alpha: 0.05),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor.withValues(alpha: 0.15),
              ),
              child: Icon(
                Icons.add_circle_outline,
                color: accentColor,
                size: 32,
              ),
            ),
            SizedBox(height: AiSpacing.md),
            Text(
              title,
              style: TextStyle(
                color: ThemeAdapter.getTextPrimary(context),
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            SizedBox(height: 4),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                subtitle,
                style: TextStyle(color: ThemeAdapter.getTextSecondary(context), fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
