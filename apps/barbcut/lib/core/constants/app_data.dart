import 'package:flutter/services.dart';
import 'dart:convert';

/// Centralized data source for all application content
/// Loads data from JSON files in assets/data/
class AppData {
  AppData._();

  // Cached data
  static List<Map<String, dynamic>>? _haircuts;
  static List<Map<String, dynamic>>? _beardStyles;
  static List<Map<String, dynamic>>? _products;
  static Map<String, dynamic>? _profile;

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

      print('✓ AppData loaded successfully');
    } catch (e) {
      print('✗ Error loading AppData: $e');
      rethrow;
    }
  }

  /// Check if data is loaded
  static bool get isLoaded =>
      _haircuts != null &&
      _beardStyles != null &&
      _products != null &&
      _profile != null;

  // ========== HISTORY / GENERATION DATA ==========
  static List<Map<String, dynamic>> generateHistory() {
    return [
      {
        'id': '1',
        'imageUrl':
            'https://images.unsplash.com/photo-1622286342621-4bd786c2447c?w=400&h=400&fit=crop',
        'haircut': 'Classic Fade',
        'beard': 'Full Beard',
        'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
      },
      {
        'id': '2',
        'imageUrl':
            'https://images.unsplash.com/photo-1621605815971-fbc98d665033?w=400&h=400&fit=crop',
        'haircut': 'Buzz Cut',
        'beard': 'Stubble',
        'timestamp': DateTime.now().subtract(const Duration(hours: 5)),
      },
      {
        'id': '3',
        'imageUrl':
            'https://images.unsplash.com/photo-1605497788044-5a32c7078486?w=400&h=400&fit=crop',
        'haircut': 'Pompadour',
        'beard': 'Goatee',
        'timestamp': DateTime.now().subtract(const Duration(hours: 12)),
      },
      {
        'id': '4',
        'imageUrl':
            'https://images.unsplash.com/photo-1599351431202-1e0f0137899a?w=400&h=400&fit=crop',
        'haircut': 'Undercut',
        'beard': 'Full Beard',
        'timestamp': DateTime.now().subtract(const Duration(days: 1)),
      },
      {
        'id': '5',
        'imageUrl':
            'https://images.unsplash.com/photo-1564564321837-a57b7070ac4f?w=400&h=400&fit=crop',
        'haircut': 'Crew Cut',
        'beard': 'Clean Shaven',
        'timestamp': DateTime.now().subtract(const Duration(days: 2)),
      },
      {
        'id': '6',
        'imageUrl':
            'https://images.unsplash.com/photo-1599351431202-1e0f0137899a?w=400&h=400&fit=crop',
        'haircut': 'Textured Top',
        'beard': 'Stubble',
        'timestamp': DateTime.now().subtract(const Duration(days: 3)),
      },
    ];
  }
}
