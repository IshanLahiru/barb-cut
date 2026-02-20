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
      final normalizedPath = _extractStoragePath(urlOrPath);
      if (normalizedPath != null) {
        developer.log(
          'Getting download URL for storage path: $normalizedPath',
          name: 'FirebaseStorage',
        );
        final ref = FirebaseStorage.instance.ref(normalizedPath);
        return await ref.getDownloadURL();
      }

      if (!urlOrPath.startsWith('http')) {
        developer.log(
          'Getting download URL for storage path: $urlOrPath',
          name: 'FirebaseStorage',
        );
        final ref = FirebaseStorage.instance.ref(urlOrPath);
        return await ref.getDownloadURL();
      }

      developer.log('Using regular URL: $urlOrPath', name: 'FirebaseStorage');
      return urlOrPath;
    } catch (e) {
      developer.log(
        '✗ Error getting download URL, using original: $e',
        name: 'FirebaseStorage',
        error: e,
        level: 900, // Warning level
      );
      // Fallback to original URL
      return urlOrPath;
    }
  }

  static String? _extractStoragePath(String value) {
    try {
      if (value.startsWith('gs://')) {
        final withoutScheme = value.replaceFirst('gs://', '');
        final slashIndex = withoutScheme.indexOf('/');
        if (slashIndex != -1) {
          return withoutScheme.substring(slashIndex + 1);
        }
        return null;
      }

      if (!value.startsWith('http')) {
        return null;
      }

      final uri = Uri.parse(value);

      if (uri.host.contains('firebasestorage.googleapis.com')) {
        final segments = uri.pathSegments;
        final oIndex = segments.indexOf('o');
        if (oIndex != -1 && segments.length > oIndex + 1) {
          return Uri.decodeComponent(segments[oIndex + 1]);
        }
      }

      if (uri.host.contains('storage.googleapis.com')) {
        final segments = uri.pathSegments;
        if (segments.length >= 2) {
          return segments.skip(1).join('/');
        }
      }

      return null;
    } catch (_) {
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
