import 'package:firebase_storage/firebase_storage.dart';
import 'dart:developer' as developer;

/// Helper for handling Firebase Storage image URLs
class FirebaseStorageHelper {
  FirebaseStorageHelper._();

  /// Check if a URL is a Firebase Storage URL
  static bool isFirebaseStorageUrl(String url) {
    return url.contains('storage.googleapis.com') ||
        url.contains('firebasestorage.googleapis.com');
  }

  /// Get a download URL with token for a Firebase Storage path
  /// If it's a Firebase Storage or GCS URL, converts it to a storage path
  static Future<String> getDownloadUrl(String urlOrPath) async {
    try {
      developer.log(
        '📥 Processing image URL/path: $urlOrPath',
        name: 'FirebaseStorage',
      );

      final normalizedPath = _extractStoragePath(urlOrPath);
      if (normalizedPath != null) {
        developer.log(
          '✓ Extracted storage path: $normalizedPath',
          name: 'FirebaseStorage',
        );
        final ref = FirebaseStorage.instance.ref(normalizedPath);
        final downloadUrl = await ref.getDownloadURL();
        developer.log(
          '✅ Got download URL (length: ${downloadUrl.length})',
          name: 'FirebaseStorage',
        );
        return downloadUrl;
      }

      if (!urlOrPath.startsWith('http')) {
        developer.log(
          '✓ Treating as Firebase Storage path: $urlOrPath',
          name: 'FirebaseStorage',
        );
        final ref = FirebaseStorage.instance.ref(urlOrPath);
        final downloadUrl = await ref.getDownloadURL();
        developer.log(
          '✅ Got download URL for storage path',
          name: 'FirebaseStorage',
        );
        return downloadUrl;
      }

      developer.log(
        '➡️ Using as regular URL (external image): $urlOrPath',
        name: 'FirebaseStorage',
      );
      return urlOrPath;
    } catch (e) {
      developer.log(
        '❌ Error getting download URL: $e\n📌 Falling back to original URL',
        name: 'FirebaseStorage',
        error: e,
        level: 900,
      );
      // Fallback to original URL
      return urlOrPath;
    }
  }

  static String? _extractStoragePath(String value) {
    try {
      // Handle gs:// URLs (Google Storage)
      if (value.startsWith('gs://')) {
        final withoutScheme = value.replaceFirst('gs://', '');
        final slashIndex = withoutScheme.indexOf('/');
        if (slashIndex != -1) {
          final path = withoutScheme.substring(slashIndex + 1);
          developer.log(
            '🔍 Extracted gs:// path: $path',
            name: 'FirebaseStorage',
          );
          return path;
        }
        return null;
      }

      // Skip if not a URL
      if (!value.startsWith('http')) {
        return null;
      }

      final uri = Uri.parse(value);

      // Handle firebasestorage.googleapis.com URLs
      if (uri.host.contains('firebasestorage.googleapis.com')) {
        final segments = uri.pathSegments;
        final oIndex = segments.indexOf('o');
        if (oIndex != -1 && segments.length > oIndex + 1) {
          final path = Uri.decodeComponent(segments[oIndex + 1]);
          developer.log(
            '🔍 Extracted Firebase Storage path: $path',
            name: 'FirebaseStorage',
          );
          return path;
        }
      }

      // Handle storage.googleapis.com URLs (GCS)
      if (uri.host.contains('storage.googleapis.com')) {
        final segments = uri.pathSegments;
        if (segments.length >= 2) {
          final path = segments.skip(1).join('/');
          developer.log(
            '🔍 Extracted GCS path: $path',
            name: 'FirebaseStorage',
          );
          return path;
        }
      }

      return null;
    } catch (e) {
      developer.log(
        '⚠️ Error parsing storage path: $e',
        name: 'FirebaseStorage',
        error: e,
      );
      return null;
    }
  }

  /// Preload multiple image URLs (converts to download URLs with tokens)
  static Future<Map<String, String>> preloadImageUrls(
    Map<String, String> imageUrls,
  ) async {
    final Map<String, String> result = {};

    await Future.wait(
      imageUrls.entries.map((entry) async {
        result[entry.key] = await getDownloadUrl(entry.value);
      }),
    );

    return result;
  }

  /// Preload a list of image URLs
  static Future<List<String>> preloadImageList(List<String> imageUrls) async {
    return Future.wait(imageUrls.map((url) => getDownloadUrl(url)));
  }
}
