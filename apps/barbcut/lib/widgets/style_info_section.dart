import 'package:flutter/material.dart';
import '../features/home/domain/entities/style_entity.dart';
import '../theme/theme.dart';

class StyleInfoSection extends StatelessWidget {
  final StyleEntity style;

  const StyleInfoSection({super.key, required this.style});

  @override
  Widget build(BuildContext context) {
    // Get userId and favourite state from HomeView if available.
    // Use dynamic here so we don't need to reference the private state type.
    final dynamic homeState = context.findAncestorStateOfType();
    final String? userId = homeState?._currentUserId as String?;
    final bool isFavourite =
        (homeState?._favouriteIds.contains(style.id) as bool?) ?? false;
    final bool isLoading = (homeState?._favouritesLoading as bool?) ?? false;

    return Container(
      padding: EdgeInsets.all(AiSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: AiColors.borderLight.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description Section with favourite star
          Row(
            children: [
              Expanded(
                child: Text(
                  'Description',
                  style: TextStyle(
                    color: AiColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (userId != null)
                IconButton(
                  icon: Icon(
                    isFavourite ? Icons.star : Icons.star_border,
                    color: isFavourite ? Colors.amber : AiColors.textTertiary,
                  ),
                  tooltip: isFavourite
                      ? 'Remove from favourites'
                      : 'Add to favourites',
                  onPressed: isLoading
                      ? null
                      : () {
                          final styleType =
                              style.type == StyleType.beard ? 'beard' : 'haircut';
                          homeState?._toggleFavourite(<String, dynamic>{
                            'id': style.id,
                            'name': style.name,
                            'description': style.description,
                            'image': style.imageUrl,
                            'images': style.images,
                            'suitableFaceShapes': style.suitableFaceShapes,
                            'maintenanceTips': style.maintenanceTips,
                          }, styleType);
                        },
                ),
            ],
          ),
          SizedBox(height: AiSpacing.sm),
          Text(
            style.description,
            style: TextStyle(
              color: AiColors.textSecondary,
              fontSize: 15,
              height: 1.5,
            ),
          ),
          SizedBox(height: AiSpacing.lg),

          // Suitable Face Shapes Section
          if (style.suitableFaceShapes.isNotEmpty) ...[
            Text(
              'Suitable Face Shapes',
              style: TextStyle(
                color: AiColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AiSpacing.md),
            _buildFaceShapesRow(context),
            SizedBox(height: AiSpacing.lg),
          ],

          // Maintenance Tips Section
          if (style.maintenanceTips.isNotEmpty) ...[
            Text(
              'Maintenance Tips',
              style: TextStyle(
                color: AiColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AiSpacing.md),
            _buildMaintenanceTips(context),
          ],

          // Price and Duration Info
          if (style.price != null || style.duration != null) ...[
            SizedBox(height: AiSpacing.lg),
            Container(
              padding: EdgeInsets.all(AiSpacing.md),
              decoration: BoxDecoration(
                color: AdaptiveThemeColors.neonCyan(
                  context,
                ).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AiSpacing.radiusMedium),
                border: Border.all(
                  color: AdaptiveThemeColors.neonCyan(
                    context,
                  ).withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (style.price != null)
                    _buildInfoChip(
                      context,
                      icon: Icons.attach_money,
                      label: 'Price',
                      value: style.price!,
                    ),
                  if (style.duration != null)
                    _buildInfoChip(
                      context,
                      icon: Icons.access_time,
                      label: 'Duration',
                      value: style.duration!,
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFaceShapesRow(BuildContext context) {
    return Wrap(
      spacing: AiSpacing.sm,
      runSpacing: AiSpacing.sm,
      children: style.suitableFaceShapes.map((shape) {
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: AiSpacing.md,
            vertical: AiSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: AdaptiveThemeColors.neonPurple(
              context,
            ).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
            border: Border.all(
              color: AdaptiveThemeColors.neonPurple(
                context,
              ).withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getFaceShapeIcon(shape),
                size: 16,
                color: AdaptiveThemeColors.neonPurple(context),
              ),
              SizedBox(width: AiSpacing.xs),
              Text(
                shape,
                style: TextStyle(
                  color: AiColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMaintenanceTips(BuildContext context) {
    return Column(
      children: style.maintenanceTips.asMap().entries.map((entry) {
        final index = entry.key;
        final tip = entry.value;
        return Padding(
          padding: EdgeInsets.only(bottom: AiSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(top: 4),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AdaptiveThemeColors.neonCyan(
                    context,
                  ).withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: AdaptiveThemeColors.neonCyan(context),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: AiSpacing.sm),
              Expanded(
                child: Text(
                  tip,
                  style: TextStyle(
                    color: AiColors.textSecondary,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInfoChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: AdaptiveThemeColors.neonCyan(context), size: 24),
        SizedBox(height: AiSpacing.xs),
        Text(
          label,
          style: TextStyle(color: AiColors.textTertiary, fontSize: 12),
        ),
        SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: AiColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  IconData _getFaceShapeIcon(String shape) {
    switch (shape.toLowerCase()) {
      case 'oval':
        return Icons.face;
      case 'square':
        return Icons.square_rounded;
      case 'round':
        return Icons.circle_outlined;
      case 'heart':
        return Icons.favorite_border;
      case 'diamond':
        return Icons.change_history;
      case 'triangle':
        return Icons.details;
      default:
        return Icons.face;
    }
  }
}
