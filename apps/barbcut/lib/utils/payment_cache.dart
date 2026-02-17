import 'package:barbcut/models/subscription_model.dart';

/// Cache for payment data to reduce API calls
class PaymentCache {
  static final PaymentCache _instance = PaymentCache._internal();

  late final Map<String, dynamic> _cache;
  late final Map<String, DateTime> _cacheTimestamps;
  late final int _cacheDurationSeconds;

  factory PaymentCache({int cacheDurationSeconds = 3600}) {
    _instance._cacheDurationSeconds = cacheDurationSeconds;
    return _instance;
  }

  PaymentCache._internal() {
    _cache = {};
    _cacheTimestamps = {};
    _cacheDurationSeconds = 3600;
  }

  /// Cache key constants
  static const String customerInfoKey = 'customer_info';
  static const String availablePackagesKey = 'available_packages';
  static const String subscriptionsKey = 'subscriptions';

  /// Store value in cache
  void set<T>(String key, T value) {
    _cache[key] = value;
    _cacheTimestamps[key] = DateTime.now();
  }

  /// Get value from cache if not expired
  T? get<T>(String key) {
    if (!_cache.containsKey(key)) {
      return null;
    }

    final timestamp = _cacheTimestamps[key];
    if (timestamp == null) {
      _cache.remove(key);
      return null;
    }

    final difference = DateTime.now().difference(timestamp).inSeconds;
    if (difference > _cacheDurationSeconds) {
      _cache.remove(key);
      _cacheTimestamps.remove(key);
      return null;
    }

    return _cache[key] as T?;
  }

  /// Check if key exists and is not expired
  bool containsKey(String key) {
    return get(key) != null;
  }

  /// Clear specific key
  void remove(String key) {
    _cache.remove(key);
    _cacheTimestamps.remove(key);
  }

  /// Clear all cache
  void clear() {
    _cache.clear();
    _cacheTimestamps.clear();
  }

  /// Get cache size
  int get size => _cache.keys.length;

  /// Get all keys
  Set<String> get keys => _cache.keys.toSet();
}
