import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/home/domain/entities/style_entity.dart';
import '../controllers/style_selection_controller.dart';
import '../theme/theme.dart';

class MultiAngleCarousel extends StatefulWidget {
  final StyleEntity style;
  final double height;
  final ValueChanged<int>? onAngleChanged;

  const MultiAngleCarousel({
    super.key,
    required this.style,
    this.height = 500,
    this.onAngleChanged,
  });

  @override
  State<MultiAngleCarousel> createState() => _MultiAngleCarouselState();
}

class _MultiAngleCarouselState extends State<MultiAngleCarousel> {
  late PageController _pageController;
  int _currentIndex = 0;

  final List<String> _angleLabels = [
    'Front',
    'Left Side',
    'Right Side',
    'Back',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    widget.onAngleChanged?.call(index);
    context.read<StyleSelectionController>().selectAngle(index);
  }

  void _navigateToAngle(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.style.styleImages.toList();

    return Container(
      height: widget.height,
      color: AiColors.backgroundDark,
      child: Stack(
        children: [
          // Main Carousel
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: images.length,
            itemBuilder: (context, index) {
              return _buildImageCard(images[index], _angleLabels[index]);
            },
          ),

          // Angle Indicators
          Positioned(
            top: AiSpacing.md,
            left: 0,
            right: 0,
            child: _buildAngleIndicators(),
          ),

          // Navigation Arrows
          Positioned(
            left: AiSpacing.md,
            top: 0,
            bottom: 0,
            child: _buildNavigationButton(
              icon: Icons.arrow_back_ios,
              onTap: () {
                if (_currentIndex > 0) {
                  _navigateToAngle(_currentIndex - 1);
                }
              },
              enabled: _currentIndex > 0,
            ),
          ),
          Positioned(
            right: AiSpacing.md,
            top: 0,
            bottom: 0,
            child: _buildNavigationButton(
              icon: Icons.arrow_forward_ios,
              onTap: () {
                if (_currentIndex < images.length - 1) {
                  _navigateToAngle(_currentIndex + 1);
                }
              },
              enabled: _currentIndex < images.length - 1,
            ),
          ),

          // Bottom Angle Selector
          Positioned(
            bottom: AiSpacing.lg,
            left: 0,
            right: 0,
            child: _buildAngleSelector(),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCard(String imageUrl, String angleLabel) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AiSpacing.md,
        vertical: AiSpacing.lg,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                        : null,
                    color: AdaptiveThemeColors.neonCyan(context),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AiColors.backgroundDark,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.broken_image,
                          size: 64,
                          color: AiColors.textTertiary,
                        ),
                        SizedBox(height: AiSpacing.sm),
                        Text(
                          'Image not available',
                          style: TextStyle(
                            color: AiColors.textTertiary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Gradient Overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAngleIndicators() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AiSpacing.md),
      padding: EdgeInsets.symmetric(
        horizontal: AiSpacing.md,
        vertical: AiSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AiColors.backgroundDark.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
        border: Border.all(
          color: AiColors.borderLight.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: List.generate(4, (index) {
          final isActive = index == _currentIndex;
          return GestureDetector(
            onTap: () => _navigateToAngle(index),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 4),
              width: isActive ? 32 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: isActive
                    ? AdaptiveThemeColors.neonCyan(context)
                    : AiColors.textTertiary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildNavigationButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool enabled,
  }) {
    return Center(
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: enabled
                ? AiColors.backgroundDark.withValues(alpha: 0.8)
                : AiColors.backgroundDark.withValues(alpha: 0.3),
            shape: BoxShape.circle,
            border: Border.all(
              color: AiColors.borderLight.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: enabled ? AiColors.textPrimary : AiColors.textTertiary,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildAngleSelector() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AiSpacing.lg),
      padding: EdgeInsets.all(AiSpacing.sm),
      decoration: BoxDecoration(
        color: AiColors.backgroundDark.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
        border: Border.all(
          color: AiColors.borderLight.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(4, (index) {
          final isActive = index == _currentIndex;
          return GestureDetector(
            onTap: () => _navigateToAngle(index),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AiSpacing.md,
                vertical: AiSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: isActive
                    ? AdaptiveThemeColors.neonCyan(
                        context,
                      ).withValues(alpha: 0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AiSpacing.radiusMedium),
                border: isActive
                    ? Border.all(
                        color: AdaptiveThemeColors.neonCyan(context),
                        width: 1,
                      )
                    : null,
              ),
              child: Text(
                _angleLabels[index],
                style: TextStyle(
                  color: isActive
                      ? AiColors.textPrimary
                      : AiColors.textSecondary,
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
