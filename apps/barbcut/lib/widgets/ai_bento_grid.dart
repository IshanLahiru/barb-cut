import 'package:flutter/material.dart';
import '../theme/theme.dart';

/// Bento Grid Layout - Modern dashboard pattern
/// Scannable, visual hierarchy with varied sizes
class AiBentoGrid extends StatelessWidget {
  final List<AiBentoItem> items;
  final int crossAxisCount;

  const AiBentoGrid({super.key, required this.items, this.crossAxisCount = 2});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 1.0,
        mainAxisSpacing: 12, // 8pt grid
        crossAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _BentoItemWidget(item: item);
      },
    );
  }
}

/// Individual Bento Item
class AiBentoItem {
  final String title;
  final String? subtitle;
  final Widget icon;
  final Color? accentColor;
  final VoidCallback? onTap;
  final int widthSpan; // 1 = normal, 2 = double width
  final int heightSpan; // 1 = normal, 2 = double height
  final bool isHighlight;

  AiBentoItem({
    required this.title,
    this.subtitle,
    required this.icon,
    this.accentColor = AiColors.neonCyan,
    this.onTap,
    this.widthSpan = 1,
    this.heightSpan = 1,
    this.isHighlight = false,
  });
}

class _BentoItemWidget extends StatefulWidget {
  final AiBentoItem item;

  const _BentoItemWidget({required this.item});

  @override
  State<_BentoItemWidget> createState() => _BentoItemWidgetState();
}

class _BentoItemWidgetState extends State<_BentoItemWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.item.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: widget.item.isHighlight
                ? AiColors.surface
                : AiColors.surface.withValues(alpha: 0.6),
            border: Border.all(
              color: _isHovered
                  ? (widget.item.accentColor ?? AiColors.neonCyan)
                  : AiColors.borderLight,
              width: _isHovered ? 2.0 : 1.5,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: (widget.item.accentColor ?? AiColors.neonCyan)
                          .withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: AiColors.neonCyan.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Icon
                DefaultTextStyle(
                  style: const TextStyle(),
                  child: IconTheme(
                    data: IconThemeData(
                      color: widget.item.accentColor ?? AiColors.neonCyan,
                      size: widget.item.isHighlight ? 48 : 32,
                    ),
                    child: widget.item.icon,
                  ),
                ),
                // Title & Subtitle
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.title,
                      style: const TextStyle(
                        color: AiColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (widget.item.subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        widget.item.subtitle!,
                        style: const TextStyle(
                          color: AiColors.textTertiary,
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Bento Image Gallery - For displaying generated images
class AiBentoImageGallery extends StatelessWidget {
  final List<String> imagePaths;
  final Function(int) onImageTap;

  const AiBentoImageGallery({
    super.key,
    required this.imagePaths,
    required this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.0,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: imagePaths.length,
      itemBuilder: (context, index) {
        return _BentoImageTile(
          imagePath: imagePaths[index],
          onTap: () => onImageTap(index),
          index: index,
        );
      },
    );
  }
}

class _BentoImageTile extends StatefulWidget {
  final String imagePath;
  final VoidCallback onTap;
  final int index;

  const _BentoImageTile({
    required this.imagePath,
    required this.onTap,
    required this.index,
  });

  @override
  State<_BentoImageTile> createState() => _BentoImageTileState();
}

class _BentoImageTileState extends State<_BentoImageTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final accentColors = [
      AiColors.neonCyan,
      AiColors.sunsetCoral,
      AiColors.neonPurple,
      AiColors.neonCyan,
    ];
    final accent = accentColors[widget.index % accentColors.length];

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AiColors.surface,
            border: Border.all(
              color: _isHovered ? accent : AiColors.borderLight,
              width: _isHovered ? 2.0 : 1.5,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Stack(
            children: [
              // Image placeholder
              Container(
                color: AiColors.backgroundSecondary,
                child: Center(
                  child: Icon(
                    Icons.image_outlined,
                    color: AiColors.textTertiary.withValues(alpha: 0.5),
                    size: 36,
                  ),
                ),
              ),
              // Hover overlay
              if (_isHovered)
                Container(
                  decoration: BoxDecoration(
                    color: AiColors.backgroundDark.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.open_in_full_rounded,
                      color: accent,
                      size: 32,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
