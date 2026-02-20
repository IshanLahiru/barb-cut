import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

/// Service for fetching data from Firebase Firestore
class FirebaseDataService {
  FirebaseDataService._();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Cache for data
  static List<Map<String, dynamic>>? _cachedHaircuts;
  static List<Map<String, dynamic>>? _cachedBeardStyles;
  static List<Map<String, dynamic>>? _cachedProducts;
  static Map<String, dynamic>? _cachedProfile;
  static List<Map<String, dynamic>>? _cachedHistory;

  /// Fetch haircuts from Firestore
  static Future<List<Map<String, dynamic>>> fetchHaircuts({
    bool forceRefresh = false,
  }) async {
    if (_cachedHaircuts != null && !forceRefresh) {
      developer.log(
        '📦 Using cached haircuts (${_cachedHaircuts!.length} items)',
        name: 'FirebaseData',
      );
      return _cachedHaircuts!;
    }

    try {
      developer.log('🔄 Fetching haircuts from Firebase...', name: 'FirebaseData');
      final snapshot = await _firestore.collection('haircuts').get();
      _cachedHaircuts = snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();
      developer.log(
        '✅ Fetched ${_cachedHaircuts!.length} haircuts from Firestore',
        name: 'FirebaseData',
      );
      
      // Log image URLs from first item for debugging
      if (_cachedHaircuts!.isNotEmpty) {
        final firstItem = _cachedHaircuts!.first;
        final imageUrl = firstItem['image'] ?? firstItem['images']?['front'] ?? 'N/A';
        developer.log(
          '   Sample image URL: ${imageUrl.toString().substring(0, 80)}...',
          name: 'FirebaseData',
        );
      }
      
      return _cachedHaircuts!;
    } catch (e) {
      developer.log(
        '❌ Error fetching haircuts from Firestore: $e',
        name: 'FirebaseData',
        error: e,
        level: 1000,
      );
      rethrow;
    }
  }

  /// Fetch beard styles from Firestore
  static Future<List<Map<String, dynamic>>> fetchBeardStyles({
    bool forceRefresh = false,
  }) async {
    if (_cachedBeardStyles != null && !forceRefresh) {
      return _cachedBeardStyles!;
    }

    try {
      developer.log(
        'Fetching beard styles from Firebase...',
        name: 'FirebaseData',
      );
      final snapshot = await _firestore.collection('beard_styles').get();
      _cachedBeardStyles = snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();
      developer.log(
        '✓ Fetched ${_cachedBeardStyles!.length} beard styles',
        name: 'FirebaseData',
      );
      return _cachedBeardStyles!;
    } catch (e) {
      developer.log(
        '✗ Error fetching beard styles: $e',
        name: 'FirebaseData',
        error: e,
        level: 1000,
      );
      rethrow;
    }
  }

  /// Fetch products from Firestore
  static Future<List<Map<String, dynamic>>> fetchProducts({
    bool forceRefresh = false,
  }) async {
    if (_cachedProducts != null && !forceRefresh) {
      return _cachedProducts!;
    }

    try {
      developer.log('Fetching products from Firebase...', name: 'FirebaseData');
      final snapshot = await _firestore.collection('products').get();
      _cachedProducts = snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();
      developer.log(
        '✓ Fetched ${_cachedProducts!.length} products',
        name: 'FirebaseData',
      );
      return _cachedProducts!;
    } catch (e) {
      developer.log(
        '✗ Error fetching products: $e',
        name: 'FirebaseData',
        error: e,
        level: 1000,
      );
      rethrow;
    }
  }

  /// Fetch profile data from Firestore
  static Future<Map<String, dynamic>> fetchProfile({
    bool forceRefresh = false,
  }) async {
    if (_cachedProfile != null && !forceRefresh) {
      return _cachedProfile!;
    }

    try {
      developer.log('Fetching profile from Firebase...', name: 'FirebaseData');
      final snapshot = await _firestore.collection('profile').doc('data').get();

      if (snapshot.exists) {
        _cachedProfile = snapshot.data()!;
        developer.log('✓ Fetched profile data', name: 'FirebaseData');
        return _cachedProfile!;
      } else {
        // Return default profile if not found
        developer.log(
          '⚠ Profile not found, using defaults',
          name: 'FirebaseData',
        );
        _cachedProfile = {'name': 'User', 'email': 'user@barbcut.com'};
        return _cachedProfile!;
      }
    } catch (e) {
      developer.log(
        '✗ Error fetching profile: $e',
        name: 'FirebaseData',
        error: e,
        level: 1000,
      );
      rethrow;
    }
  }

  /// Fetch history from Firestore
  static Future<List<Map<String, dynamic>>> fetchHistory({
    bool forceRefresh = false,
  }) async {
    if (_cachedHistory != null && !forceRefresh) {
      return _cachedHistory!;
    }

    try {
      developer.log('Fetching history from Firebase...', name: 'FirebaseData');
      final snapshot = await _firestore.collection('history').get();
      _cachedHistory = snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();
      developer.log(
        '✓ Fetched ${_cachedHistory!.length} history items',
        name: 'FirebaseData',
      );
      return _cachedHistory!;
    } catch (e) {
      developer.log(
        '✗ Error fetching history: $e',
        name: 'FirebaseData',
        error: e,
        level: 1000,
      );
      rethrow;
    }
  }

  /// Fetch all data from Firebase
  static Future<void> fetchAllData({bool forceRefresh = false}) async {
    try {
      developer.log('Fetching all data from Firebase...', name: 'FirebaseData');

      await Future.wait([
        fetchHaircuts(forceRefresh: forceRefresh),
        fetchBeardStyles(forceRefresh: forceRefresh),
        fetchProducts(forceRefresh: forceRefresh),
        fetchProfile(forceRefresh: forceRefresh),
        fetchHistory(forceRefresh: forceRefresh),
      ]);

      developer.log('✓ All data fetched successfully', name: 'FirebaseData');
    } catch (e) {
      developer.log(
        '✗ Error fetching all data: $e',
        name: 'FirebaseData',
        error: e,
        level: 1000,
      );
      rethrow;
    }
  }

  /// Clear all cached data
  static void clearCache() {
    _cachedHaircuts = null;
    _cachedBeardStyles = null;
    _cachedProducts = null;
    _cachedProfile = null;
    _cachedHistory = null;
    developer.log('Cache cleared', name: 'FirebaseData');
  }

  /// Check if data is cached
  static bool get isDataCached =>
      _cachedHaircuts != null &&
      _cachedBeardStyles != null &&
      _cachedProducts != null &&
      _cachedProfile != null &&
      _cachedHistory != null;
}
