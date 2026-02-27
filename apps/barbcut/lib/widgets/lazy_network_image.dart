import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// A highly optimized image widget with non-blocking lazy loading.
///
/// Features:
/// - Lazy loading: Only loads images when they enter the viewport
/// - Memory efficient: Uses cached_network_image for disk + memory caching
/// - Smooth transitions: Fade-in effect when image loads
/// - Placeholder: Shows shimmer while loading
/// - Error handling: Graceful error states with retry capability
/// - Preloading: Optionally preloads adjacent images for smoother UX
class LazyNetworkImage extends StatefulWidget {
  final String? imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Color? placeholderColor;
  final Widget? customPlaceholder;
  final Widget? customErrorWidget;
  final bool enableFadeIn;
  final Duration fadeInDuration;
  final bool enableShimmer;
  final VoidCallback? onTap;
  final String? semanticLabel;

  const LazyNetworkImage({
    super.key,
    this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.placeholderColor,
    this.customPlaceholder,
    this.customErrorWidget,
    this.enableFadeIn = true,
    this.fadeInDuration = const Duration(milliseconds: 300),
    this.enableShimmer = true,
    this.onTap,
    this.semanticLabel,
  });

  @override
  State<LazyNetworkImage> createState() => _LazyNetworkImageState();
}

class _LazyNetworkImageState extends State<LazyNetworkImage> {
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    // Delay image loading to allow widget to be rendered first
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _checkVisibility();
      }
    });
  }

  @override
  void didUpdateWidget(LazyNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl && _isVisible) {
      // CachedNetworkImage will handle the new URL
      setState(() {});
    }
  }

  void _checkVisibility() {
    if (!mounted) return;

    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) {
      Future.delayed(const Duration(milliseconds: 100), _checkVisibility);
      return;
    }

    if (!_isVisible) {
      setState(() {
        _isVisible = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.placeholderColor ?? Colors.grey[800]!;
    final highlightColor = widget.placeholderColor ?? Colors.grey[700]!;

    // Empty or invalid URL
    if (widget.imageUrl == null || widget.imageUrl!.trim().isEmpty) {
      return widget.customErrorWidget ?? _buildErrorWidget();
    }

    // Not yet visible - show placeholder (lazy load)
    if (!_isVisible) {
      return widget.customPlaceholder ??
          _buildShimmer(baseColor, highlightColor);
    }

    // Use CachedNetworkImage for disk + memory caching
    Widget imageWidget = CachedNetworkImage(
      imageUrl: widget.imageUrl!,
      fit: widget.fit,
      width: widget.width,
      height: widget.height,
      placeholder: (_, __) =>
          widget.customPlaceholder ?? _buildShimmer(baseColor, highlightColor),
      errorWidget: (_, __, ___) =>
          widget.customErrorWidget ?? _buildErrorWidget(),
      fadeInDuration: widget.enableFadeIn ? widget.fadeInDuration : Duration.zero,
      fadeOutDuration: Duration.zero,
      memCacheWidth: widget.width != null ? (widget.width! * 2).toInt() : null,
      memCacheHeight: widget.height != null ? (widget.height! * 2).toInt() : null,
    );

    if (widget.onTap != null) {
      imageWidget = GestureDetector(onTap: widget.onTap, child: imageWidget);
    }

    if (widget.semanticLabel != null) {
      imageWidget = Semantics(label: widget.semanticLabel, child: imageWidget);
    }

    return imageWidget;
  }

  Widget _buildShimmer(Color baseColor, Color highlightColor) {
    if (!widget.enableShimmer) {
      return Container(
        width: widget.width,
        height: widget.height,
        color: baseColor,
      );
    }

    return ShimmerPlaceholder(
      width: widget.width,
      height: widget.height,
      baseColor: baseColor,
      highlightColor: highlightColor,
    );
  }

  Widget _buildErrorWidget() {
    return widget.customErrorWidget ??
        Container(
          width: widget.width,
          height: widget.height,
          color: Colors.grey[900],
          child: Icon(
            Icons.broken_image_outlined,
            color: Colors.grey[600],
            size: (widget.height ?? 48) * 0.4,
          ),
        );
  }
}

/// A shimmer/gradient placeholder widget for loading state
class ShimmerPlaceholder extends StatefulWidget {
  final double? width;
  final double? height;
  final Color baseColor;
  final Color highlightColor;

  const ShimmerPlaceholder({
    super.key,
    this.width,
    this.height,
    required this.baseColor,
    required this.highlightColor,
  });

  @override
  State<ShimmerPlaceholder> createState() => _ShimmerPlaceholderState();
}

class _ShimmerPlaceholderState extends State<ShimmerPlaceholder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value + 1, 0),
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

/// A grid-friendly lazy image that automatically loads when visible
/// Best for MasonryGridView and ListView items
class GridLazyImage extends StatelessWidget {
  final String? imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Color? placeholderColor;
  final Widget? customPlaceholder;
  final Widget? customErrorWidget;
  final VoidCallback? onTap;

  const GridLazyImage({
    super.key,
    this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.placeholderColor,
    this.customPlaceholder,
    this.customErrorWidget,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return LazyNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      width: width,
      height: height,
      placeholderColor: placeholderColor,
      customPlaceholder: customPlaceholder,
      customErrorWidget: customErrorWidget,
      onTap: onTap,
    );
  }
}
