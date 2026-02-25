import 'package:flutter/material.dart';
import '../services/firebase_storage_helper.dart';
import 'lazy_network_image.dart';

/// A widget that automatically handles Firebase Storage URLs with tokens
/// For regular URLs (e.g., Unsplash), it works like a normal Image.network
///
/// Optimized with lazy loading - only fetches URL and loads image when visible
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
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) {
      // Defer loading until size is available
      Future.delayed(const Duration(milliseconds: 50), () {
        if (mounted) _checkAndLoadImage();
      });
      return;
    }

    // No viewport logic: just load immediately
    _loadImage();
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return widget.loadingWidget ??
          Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
            ),
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

    // Use LazyNetworkImage for optimized loading
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
