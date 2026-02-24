import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/services.dart';
import '../../services/firebase_data_service.dart';

/// Centralized data source for all application content
/// Loads data from Firebase Firestore (with JSON fallback)
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
  /// Load all data from Firebase (with JSON fallback)
  static Future<void> loadAppData({bool useJsonFallback = true}) async {
    try {
      developer.log('═' * 60, name: 'AppData');
      developer.log('📦 Starting data load...', name: 'AppData');
      developer.log('═' * 60, name: 'AppData');

      // Try to load from Firebase first
      try {
        developer.log('🔥 Attempting to load from Firebase Firestore...', name: 'AppData');
        await _loadFromFirebase();
        developer.log('✅ SUCCESS: AppData loaded from Firebase', name: 'AppData');
        developer.log('   Haircuts: ${_haircuts?.length ?? 0} items', name: 'AppData');
        developer.log('   Beard styles: ${_beardStyles?.length ?? 0} items', name: 'AppData');
        developer.log('   Products: ${_products?.length ?? 0} items', name: 'AppData');
        developer.log('═' * 60, name: 'AppData');
        return;
      } catch (firebaseError) {
        developer.log(
          '⚠️  Firebase load failed, error details:',
          name: 'AppData',
        );
        developer.log(
          '   ${firebaseError.toString()}',
          name: 'AppData',
          error: firebaseError,
          level: 800,
        );

        // If Firebase fails and fallback is enabled, load from JSON
        if (useJsonFallback) {
          developer.log(
            '📄 Falling back to JSON assets (bundled data)...',
            name: 'AppData',
          );
          await _loadFromJson();
          developer.log(
            '✅ SUCCESS: AppData loaded from JSON fallback',
            name: 'AppData',
          );
          developer.log(
            '   ⚠️  When using JSON fallback, image sources may differ from Firebase Storage.',
            name: 'AppData',
          );
          developer.log('   Haircuts: ${_haircuts?.length ?? 0} items', name: 'AppData');
          developer.log('   Beard styles: ${_beardStyles?.length ?? 0} items', name: 'AppData');
          developer.log('═' * 60, name: 'AppData');
        } else {
          rethrow;
        }
      }
    } catch (e) {
      developer.log(
        '❌ FATAL: Error loading AppData: $e',
        name: 'AppData',
        error: e,
        level: 1000,
      );
      developer.log('═' * 60, name: 'AppData');
      rethrow;
    }
  }

  /// Load data from Firebase Firestore
  static Future<void> _loadFromFirebase() async {
    _haircuts = await FirebaseDataService.fetchHaircuts();
    _beardStyles = await FirebaseDataService.fetchBeardStyles();
    _products = await FirebaseDataService.fetchProducts();
    _profile = await FirebaseDataService.fetchProfile();
    _history = await FirebaseDataService.fetchHistory();
  }

  /// Load data from JSON assets (fallback)
  static Future<void> _loadFromJson() async {
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
    final profileJson = await rootBundle.loadString('assets/data/profile.json');
    _profile = jsonDecode(profileJson);

    // Load history
    final historyJson = await rootBundle.loadString('assets/data/history.json');
    _history = List<Map<String, dynamic>>.from(jsonDecode(historyJson));
  }

  /// Refresh data from Firebase (force reload)
  static Future<void> refreshFromFirebase() async {
    try {
      developer.log('Refreshing data from Firebase...', name: 'AppData');
      await _loadFromFirebase();
      developer.log('✓ Data refreshed successfully', name: 'AppData');
    } catch (e) {
      developer.log(
        '✗ Error refreshing data: $e',
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
