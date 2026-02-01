import 'package:flutter/material.dart';
import 'dart:ui';
import '../theme/theme.dart';

/// AI Image Card - Display generated images with overlay actions
/// One-handed use: Actions positioned at bottom with thumb-friendly spacing
class AiImageCard extends StatefulWidget {
  final String imagePath;
  final String prompt;
  final VoidCallback onDownload;
  final VoidCallback onUpscale;
  final VoidCallback onRemix;
  final Duration generationTime;

  const AiImageCard({
    super.key,
    required this.imagePath,
    required this.prompt,
    required this.onDownload,
    required this.onUpscale,
    required this.onRemix,
    this.generationTime = const Duration(seconds: 5),
  });

  @override
  State<AiImageCard> createState() => _AiImageCardState();
}

class _AiImageCardState extends State<AiImageCard> {
  bool _showOverlay = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _showOverlay = !_showOverlay),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.2),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Background Image
              Container(
                color: ThemeAdapter.getSurface(context),
                child: Center(
                  child: Icon(
                    Icons.image_outlined,
                    color: ThemeAdapter.getTextTertiary(context),
                    size: 48,
                  ),
                ),
              ),
              // Gradient Overlay (Glass effect)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      ThemeAdapter.getBackgroundDark(
                        context,
                      ).withValues(alpha: 0.4),
                      ThemeAdapter.getBackgroundDark(
                        context,
                      ).withValues(alpha: 0.7),
                    ],
                    stops: const [0.0, 0.6, 1.0],
                  ),
                ),
              ),
              // Metadata (Prompt & Generation Time)
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: _AnimatedMetadata(
                  prompt: widget.prompt,
                  generationTime: widget.generationTime,
                  isVisible: !_showOverlay,
                ),
              ),
              // Action Buttons Overlay
              if (_showOverlay)
                Positioned.fill(
                  child: Container(
                    color: ThemeAdapter.getBackgroundDark(
                      context,
                    ).withValues(alpha: 0.7),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                      child: Center(
                        child: _ActionButtonRow(
                          onDownload: widget.onDownload,
                          onUpscale: widget.onUpscale,
                          onRemix: widget.onRemix,
                        ),
                      ),
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

class _AnimatedMetadata extends StatelessWidget {
  final String prompt;
  final Duration generationTime;
  final bool isVisible;

  const _AnimatedMetadata({
    required this.prompt,
    required this.generationTime,
    required this.isVisible,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: isVisible
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  prompt.length > 60 ? '${prompt.substring(0, 60)}...' : prompt,
                  style: const TextStyle(
                    color: AiColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  'Generated in ${generationTime.inSeconds}s',
                  style: const TextStyle(
                    color: AiColors.textTertiary,
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            )
          : const SizedBox.shrink(),
    );
  }
}

class _ActionButtonRow extends StatelessWidget {
  final VoidCallback onDownload;
  final VoidCallback onUpscale;
  final VoidCallback onRemix;

  const _ActionButtonRow({
    required this.onDownload,
    required this.onUpscale,
    required this.onRemix,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _AiActionButton(
          icon: Icons.download_outlined,
          label: 'Save',
          onPressed: onDownload,
          accentColor: AiColors.neonCyan,
        ),
        _AiActionButton(
          icon: Icons.zoom_out_map_outlined,
          label: 'Upscale',
          onPressed: onUpscale,
          accentColor: AiColors.sunsetCoral,
        ),
        _AiActionButton(
          icon: Icons.refresh_outlined,
          label: 'Remix',
          onPressed: onRemix,
          accentColor: AiColors.neonPurple,
        ),
      ],
    );
  }
}

class _AiActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color accentColor;

  const _AiActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.accentColor,
  });

  @override
  State<_AiActionButton> createState() => _AiActionButtonState();
}

class _AiActionButtonState extends State<_AiActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _controller.forward();
        setState(() => _isPressed = true);
      },
      onTapUp: (_) {
        _controller.reverse();
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () {
        _controller.reverse();
        setState(() => _isPressed = false);
      },
      child: ScaleTransition(
        scale: Tween<double>(
          begin: 1.0,
          end: 0.9,
        ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: widget.accentColor.withValues(alpha: 0.15),
                border: Border.all(
                  color: widget.accentColor.withValues(alpha: 0.6),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: _isPressed
                    ? [
                        BoxShadow(
                          color: widget.accentColor.withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Icon(widget.icon, color: widget.accentColor, size: 22),
            ),
            const SizedBox(height: 6),
            Text(
              widget.label,
              style: TextStyle(
                color: widget.accentColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
