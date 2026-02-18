import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/services.dart';

/// Centralized data source for all application content
/// Loads data from JSON files in assets/data/
class AppData {
  AppData._();

  // Cached data
  static List<Map<String, dynamic>>? _haircuts;
  static List<Map<String, dynamic>>? _beardStyles;
  static List<Map<String, dynamic>>? _products;
  static Map<String, dynamic>? _profile;
  static List<Map<String, dynamic>>? _history;

  // ========== HAIRCUT STYLES ==========
  static List<Map<String, dynamic>> get haircuts {
    if (_haircuts == null) {
      throw Exception('Haircuts data not loaded. Call loadAppData() first.');
    }
    return _haircuts!;
  }

  // ========== BEARD STYLES ==========
  static List<Map<String, dynamic>> get beardStyles {
    if (_beardStyles == null) {
      throw Exception(
        'Beard styles data not loaded. Call loadAppData() first.',
      );
    }
    return _beardStyles!;
  }

  // ========== PRODUCTS ==========
  static List<Map<String, dynamic>> get products {
    if (_products == null) {
      throw Exception('Products data not loaded. Call loadAppData() first.');
    }
    return _products!;
  }

  // ========== PROFILE DATA ==========
  static Map<String, dynamic> get defaultProfile {
    if (_profile == null) {
      throw Exception('Profile data not loaded. Call loadAppData() first.');
    }
    return _profile!;
  }

  // ========== HISTORY ==========
  static List<Map<String, dynamic>> get history {
    if (_history == null) {
      throw Exception('History data not loaded. Call loadAppData() first.');
    }
    return _history!;
  }

  // ========== DATA LOADING ==========
  /// Load all JSON data files from assets
  static Future<void> loadAppData() async {
    try {
      // Load haircuts
      final haircutsJson = await rootBundle.loadString(
        'assets/data/haircuts.json',
      );
      _haircuts = List<Map<String, dynamic>>.from(jsonDecode(haircutsJson));

      // Load beard styles
      final beardJson = await rootBundle.loadString(
        'assets/data/beard_styles.json',
      );
      _beardStyles = List<Map<String, dynamic>>.from(jsonDecode(beardJson));

      // Load products
      final productsJson = await rootBundle.loadString(
        'assets/data/products.json',
      );
      _products = List<Map<String, dynamic>>.from(jsonDecode(productsJson));

      // Load profile
      final profileJson = await rootBundle.loadString(
        'assets/data/profile.json',
      );
      _profile = jsonDecode(profileJson);

      // Load history
      final historyJson = await rootBundle.loadString(
        'assets/data/history.json',
      );
      _history = List<Map<String, dynamic>>.from(jsonDecode(historyJson));

      developer.log('✓ AppData loaded successfully', name: 'AppData');
    } catch (e) {
      developer.log(
        '✗ Error loading AppData: $e',
        name: 'AppData',
        error: e,
        level: 1000,
      );
      rethrow;
    }
  }

  /// Check if data is loaded
  static bool get isLoaded =>
      _haircuts != null &&
      _beardStyles != null &&
      _products != null &&
      _profile != null &&
      _history != null;
}
