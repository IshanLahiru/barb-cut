import 'package:flutter/material.dart';
import '../theme/theme.dart';
import '../views/face_photo_upload_view.dart';

/// Inline card widget shown when generation fails, with retry + upload options
class GenerationErrorCard extends StatelessWidget {
  final String? errorMessage;
  final String? jobId;
  final VoidCallback onRetry;

  const GenerationErrorCard({
    super.key,
    this.errorMessage,
    this.jobId,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final errorColor = Theme.of(context).colorScheme.error;
    final surface = Theme.of(context).colorScheme.surface;

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
        border: Border.all(
          color: errorColor.withValues(alpha: 0.3),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: errorColor.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(AiSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: errorColor.withValues(alpha: 0.15),
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  color: errorColor,
                  size: 24,
                ),
              ),
              SizedBox(width: AiSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Generation Failed',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Let\'s get this back on track',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AiSpacing.md),

          // Error message (if available)
          if (errorMessage != null && errorMessage!.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AiSpacing.md,
                vertical: AiSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: errorColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AiSpacing.radiusMedium),
              ),
              child: Text(
                errorMessage!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: errorColor,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),

          SizedBox(height: AiSpacing.lg),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => const FacePhotoUploadView(),
                      ),
                    );
                  },
                  icon: Icon(Icons.camera_alt_rounded, size: 18),
                  label: const Text('Upload Photos'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    side: BorderSide(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.4),
                      width: 1,
                    ),
                    padding: EdgeInsets.symmetric(vertical: AiSpacing.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AiSpacing.radiusMedium,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: AiSpacing.md),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onRetry,
                  icon: Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Try Again'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: EdgeInsets.symmetric(vertical: AiSpacing.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AiSpacing.radiusMedium,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Help text
          SizedBox(height: AiSpacing.md),
          Text(
            'Need help? Make sure you have uploaded clear face photos from different angles.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
