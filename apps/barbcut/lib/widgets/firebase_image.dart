import 'package:flutter/material.dart';
import '../services/firebase_storage_helper.dart';
import 'lazy_network_image.dart';

/// A widget that automatically handles Firebase Storage paths and URLs.
///
/// Resolves Firebase Storage paths (e.g. `styles/haircuts/xyz.png`) and
/// Firebase HTTP URLs via [FirebaseStorageHelper.getDownloadUrl], then
/// displays the image using [LazyNetworkImage] for caching and fade-in.
///
/// Use [loadingWidget] for a custom loading state (e.g. shimmer); when null,
/// a shimmer placeholder is shown. Use [errorWidget] for failed loads.
///
/// Optimized with lazy loading - only fetches URL when the widget is visible.
class FirebaseImage extends StatefulWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final Color? color;
  final BlendMode? colorBlendMode;
  final bool enableLazyLoading;

  const FirebaseImage(
    this.imageUrl, {
    super.key,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.loadingWidget,
    this.errorWidget,
    this.color,
    this.colorBlendMode,
    this.enableLazyLoading = true,
  });

  @override
  State<FirebaseImage> createState() => _FirebaseImageState();
}

class _FirebaseImageState extends State<FirebaseImage> {
  String? _downloadUrl;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    // Defer URL fetching to allow widget to render first
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _checkAndLoadImage();
      }
    });
  }

  void _checkAndLoadImage() {
    // Check visibility before loading
    if (!mounted) return;

    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) {
      // Defer loading until size is available
      Future.delayed(const Duration(milliseconds: 50), () {
        if (mounted) _checkAndLoadImage();
      });
      return;
    }

    if (!_isLoading && _downloadUrl != null) return;

    final mediaQuery = MediaQuery.maybeOf(context);
    if (mediaQuery == null) {
      _loadImage();
      return;
    }

    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    const double preloadMargin = 100;
    final double viewportTop = -preloadMargin;
    final double viewportBottom = mediaQuery.size.height + preloadMargin;
    final double widgetTop = offset.dy;
    final double widgetBottom = widgetTop + size.height;

    final bool isInViewport =
        widgetBottom > viewportTop && widgetTop < viewportBottom;

    if (isInViewport) {
      _loadImage();
    } else {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted && _downloadUrl == null) {
          _checkAndLoadImage();
        }
      });
    }
  }

  @override
  void didUpdateWidget(FirebaseImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _downloadUrl = null;
      _isLoading = true;
      _hasError = false;
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      if (widget.imageUrl.trim().isEmpty) {
        if (mounted) {
          setState(() {
            _downloadUrl = null;
            _hasError = true;
            _isLoading = false;
          });
        }
        return;
      }

      final url = await FirebaseStorageHelper.getDownloadUrl(widget.imageUrl);
      if (mounted) {
        setState(() {
          _downloadUrl = url;
          _hasError = url.trim().isEmpty;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  /// Builds the default shimmer placeholder used when [loadingWidget] is null.
  static Widget buildDefaultShimmer({
    double? width,
    double? height,
    Color? baseColor,
    Color? highlightColor,
  }) {
    final base = baseColor ?? Colors.white.withValues(alpha: 0.06);
    final highlight = highlightColor ?? Colors.white.withValues(alpha: 0.14);
    return ShimmerPlaceholder(
      width: width,
      height: height,
      baseColor: base,
      highlightColor: highlight,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return widget.loadingWidget ??
          LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth.isFinite && constraints.maxWidth > 0
                  ? constraints.maxWidth
                  : widget.width;
              final h = constraints.maxHeight.isFinite && constraints.maxHeight > 0
                  ? constraints.maxHeight
                  : widget.height;
              return buildDefaultShimmer(width: w, height: h);
            },
          );
    }

    if (_hasError || _downloadUrl == null || _downloadUrl!.trim().isEmpty) {
      return widget.errorWidget ??
          Center(
            child: Icon(
              Icons.broken_image_outlined,
              size: 48,
              color: Colors.grey[600],
            ),
          );
    }

    // Use LazyNetworkImage for optimized loading (caching, fade-in, shimmer)
    return LazyNetworkImage(
      imageUrl: _downloadUrl,
      fit: widget.fit,
      width: widget.width,
      height: widget.height,
      customErrorWidget:
          widget.errorWidget ??
          Center(
            child: Icon(
              Icons.broken_image_outlined,
              size: 48,
              color: Colors.grey[600],
            ),
          ),
    );
  }
}

/// A grid-friendly Firebase image for MasonryGridView and ListView items.
/// Resolves Firebase Storage paths via [FirebaseStorageHelper] and displays
/// with shimmer loading and error handling. Use for product tiles, style grids, etc.
class FirebaseGridLazyImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final VoidCallback? onTap;

  const FirebaseGridLazyImage(
    this.imageUrl, {
    super.key,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.loadingWidget,
    this.errorWidget,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final image = FirebaseImage(
      imageUrl,
      fit: fit,
      width: width,
      height: height,
      loadingWidget: loadingWidget,
      errorWidget: errorWidget,
    );
    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: image);
    }
    return image;
  }
}
