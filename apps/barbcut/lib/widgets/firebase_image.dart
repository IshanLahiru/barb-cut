import 'package:flutter/material.dart';
import '../services/firebase_storage_helper.dart';

/// A widget that automatically handles Firebase Storage URLs with tokens
/// For regular URLs (e.g., Unsplash), it works like a normal Image.network
class FirebaseImage extends StatefulWidget {
  final String imageUrl;
  final BoxFit? fit;
  final double? width;
  final double? height;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final Color? color;
  final BlendMode? colorBlendMode;

  const FirebaseImage(
    this.imageUrl, {
    super.key,
    this.fit,
    this.width,
    this.height,
    this.loadingWidget,
    this.errorWidget,
    this.color,
    this.colorBlendMode,
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
    _loadImage();
  }

  @override
  void didUpdateWidget(FirebaseImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final url = await FirebaseStorageHelper.getDownloadUrl(widget.imageUrl);
      if (mounted) {
        setState(() {
          _downloadUrl = url;
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

    if (_hasError || _downloadUrl == null) {
      return widget.errorWidget ??
          Center(
            child: Icon(
              Icons.broken_image_outlined,
              size: 48,
              color: Colors.grey[600],
            ),
          );
    }

    return Image.network(
      _downloadUrl!,
      fit: widget.fit,
      width: widget.width,
      height: widget.height,
      color: widget.color,
      colorBlendMode: widget.colorBlendMode,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return widget.loadingWidget ??
            Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
      },
      errorBuilder: (context, error, stackTrace) {
        return widget.errorWidget ??
            Center(
              child: Icon(
                Icons.broken_image_outlined,
                size: 48,
                color: Colors.grey[600],
              ),
            );
      },
    );
  }
}
