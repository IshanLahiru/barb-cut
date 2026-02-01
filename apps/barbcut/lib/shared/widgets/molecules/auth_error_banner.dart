import 'package:flutter/material.dart';
import '../../../theme/ai_colors.dart';
import '../../../theme/ai_spacing.dart';

class AuthErrorBanner extends StatelessWidget {
  final String message;

  const AuthErrorBanner({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AiSpacing.md),
      decoration: BoxDecoration(
        color: AiColors.danger.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(
          AiSpacing.radiusMedium,
        ),
        border: Border.all(
          color: AiColors.danger.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AiColors.danger,
        ),
      ),
    );
  }
}
