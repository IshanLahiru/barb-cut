import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// Persists haircut and beard style data to disk for cold start and offline use.
class StylesDiskCache {
  static const String _haircutsFileName = 'haircuts.json';
  static const String _beardStylesFileName = 'beard_styles.json';

  Future<String> _getCacheDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory(p.join(dir.path, 'styles_cache'));
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return cacheDir.path;
  }

  Future<List<Map<String, dynamic>>?> readHaircuts() async {
    try {
      final dir = await _getCacheDir();
      final file = File(p.join(dir, _haircutsFileName));
      if (!await file.exists()) return null;
      final contents = await file.readAsString();
      final decoded = jsonDecode(contents) as List<dynamic>;
      return decoded
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } catch (_) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> readBeardStyles() async {
    try {
      final dir = await _getCacheDir();
      final file = File(p.join(dir, _beardStylesFileName));
      if (!await file.exists()) return null;
      final contents = await file.readAsString();
      final decoded = jsonDecode(contents) as List<dynamic>;
      return decoded
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> writeHaircuts(List<Map<String, dynamic>> data) async {
    final dir = await _getCacheDir();
    final file = File(p.join(dir, _haircutsFileName));
    await file.writeAsString(jsonEncode(data));
  }

  Future<void> writeBeardStyles(List<Map<String, dynamic>> data) async {
    final dir = await _getCacheDir();
    final file = File(p.join(dir, _beardStylesFileName));
    await file.writeAsString(jsonEncode(data));
  }
}
