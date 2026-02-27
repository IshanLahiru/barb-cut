import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'firebase_storage_helper.dart';

/// Precaches critical hero images (first few style cards) to eliminate
/// flicker when the user first views the home carousel.
class HeroImagePrecache {
  HeroImagePrecache._();

  static const int _maxStylesToPrecache = 2;
  static const int _maxImagesPerStyle = 2;

  /// Extract image paths from a style map (haircut or beard).
  static List<String> _extractImagePaths(Map<String, dynamic> style) {
    final images = style['images'];
    if (images is List) {
      return images.map((e) => e.toString()).where((s) => s.isNotEmpty).toList();
    }
    if (images is Map) {
      final list = <String>[];
      for (final key in ['front', 'left', 'left_side', 'leftSide', 'right', 'right_side', 'rightSide', 'back']) {
        final v = images[key]?.toString();
        if (v != null && v.isNotEmpty) list.add(v);
      }
      if (list.isNotEmpty) return list;
    }
    final image = style['image']?.toString();
    return image != null && image.isNotEmpty ? [image] : [];
  }

  /// Resolve Firebase Storage paths to download URLs.
  static Future<List<String>> _resolveUrls(List<String> paths) async {
    final urls = <String>[];
    for (final path in paths) {
      if (path.startsWith('http')) {
        urls.add(path);
      } else {
        final url = await FirebaseStorageHelper.getDownloadUrl(path);
        if (url.isNotEmpty) urls.add(url);
      }
    }
    return urls;
  }

  /// Precache hero images from the first few haircut and beard styles.
  /// Call this when home data loads to eliminate flicker on first view.
  static Future<void> precacheHeroImages(
    BuildContext context, {
    required List<Map<String, dynamic>> haircuts,
    required List<Map<String, dynamic>> beardStyles,
  }) async {
    final pathsToPrecache = <String>[];
    for (var i = 0; i < _maxStylesToPrecache && i < haircuts.length; i++) {
      pathsToPrecache.addAll(
        _extractImagePaths(haircuts[i]).take(_maxImagesPerStyle),
      );
    }
    for (var i = 0; i < _maxStylesToPrecache && i < beardStyles.length; i++) {
      pathsToPrecache.addAll(
        _extractImagePaths(beardStyles[i]).take(_maxImagesPerStyle),
      );
    }
    if (pathsToPrecache.isEmpty) return;

    final urls = await _resolveUrls(pathsToPrecache);
    if (!context.mounted) return;

    for (final url in urls) {
      try {
        await precacheImage(
          CachedNetworkImageProvider(url),
          context,
        );
      } catch (_) {
        // Ignore precache failures - images will load on demand
      }
    }
  }
}
