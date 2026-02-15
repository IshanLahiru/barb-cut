import 'package:flutter/material.dart';
import 'package:barbcut/services/subscription_service.dart';

/// Provider for managing subscription state and logic
class SubscriptionController extends ChangeNotifier {
  final SubscriptionService _subscriptionService = SubscriptionService();

  // State
  SubscriptionStatus? _subscriptionStatus;
  List<AvailableProduct> _availableProducts = [];
  bool _isLoading = false;
  bool _isPurchasing = false;
  String? _errorMessage;
  String? _successMessage;

  // Getters
  SubscriptionStatus? get subscriptionStatus => _subscriptionStatus;
  List<AvailableProduct> get availableProducts => _availableProducts;
  bool get isLoading => _isLoading;
  bool get isPurchasing => _isPurchasing;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  // Convenience getters
  bool get hasProAccess => _subscriptionStatus?.hasPro ?? false;
  bool get isSubscriptionActive => _subscriptionStatus?.isActive ?? false;
  bool get isInTrial => _subscriptionStatus?.isInTrial ?? false;

  SubscriptionController();

  /// Initialize subscription controller
  /// Call this early in app lifecycle (after RevenueCat init)
  Future<void> initialize() async {
    _setLoading(true);
    try {
      await _subscriptionService.initialize();
      await loadSubscriptionStatus();
      await loadAvailableProducts();
      _clearError();
    } catch (e) {
      _setError('Failed to initialize subscriptions: $e');
      debugPrint('Subscription initialization error: $e');
      // Don't rethrow - allow app to continue with free plan
    } finally {
      _setLoading(false);
    }
  }

  /// Check if subscriptions are available before using
  bool get isSubscriptionAvailable => _subscriptionService.isInitialized;

  /// Load current subscription status
  Future<void> loadSubscriptionStatus() async {
    try {
      _subscriptionStatus = await _subscriptionService.getSubscriptionStatus();
      debugPrint('Subscription status loaded: ${_subscriptionStatus?.hasPro}');
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load subscription status: $e');
      debugPrint('Status loading error: $e');
    }
  }

  /// Load available products
  Future<void> loadAvailableProducts() async {
    try {
      _availableProducts = await _subscriptionService.getAvailableProducts();
      debugPrint('Available products loaded: ${_availableProducts.length}');
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load products: $e');
      debugPrint('Products loading error: $e');
    }
  }

  /// Check if user can access pro features
  Future<bool> canAccessPro() async {
    return await _subscriptionService.canAccessPro();
  }

  /// Purchase a package
  Future<void> purchasePackage(String packageIdentifier) async {
    _setPurchasing(true);
    _clearMessages();

    try {
      final result = await _subscriptionService.purchaseProduct(
        packageIdentifier,
      );

      if (result.success) {
        _setSuccess('Subscription activated! Enjoy BarbCut Pro.');
        // Reload subscription status after successful purchase
        await loadSubscriptionStatus();
      } else if (result.cancelled) {
        _setError('Purchase was cancelled');
      } else {
        _setError(result.message);
      }

      notifyListeners();
    } catch (e) {
      _setError('Purchase failed: $e');
      debugPrint('Purchase error: $e');
    } finally {
      _setPurchasing(false);
    }
  }

  /// Restore purchases
  Future<void> restorePurchases() async {
    _setLoading(true);
    _clearMessages();

    try {
      await _subscriptionService.restorePurchases();
      await loadSubscriptionStatus();
      _setSuccess('Purchases restored successfully');
    } catch (e) {
      _setError('Failed to restore purchases: $e');
      debugPrint('Restore error: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Set user ID for tracking
  Future<void> setUserId(String userId) async {
    try {
      await _subscriptionService.setUserId(userId);
      debugPrint('User ID set: $userId');
    } catch (e) {
      _setError('Failed to set user ID: $e');
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      await _subscriptionService.logout();
      _subscriptionStatus = null;
      _clearMessages();
      notifyListeners();
      debugPrint('User logged out');
    } catch (e) {
      _setError('Failed to logout: $e');
    }
  }

  /// Get product by identifier
  AvailableProduct? getProduct(String identifier) {
    try {
      return _availableProducts.firstWhere((p) => p.identifier == identifier);
    } catch (e) {
      return null;
    }
  }

  /// Clear error message
  void clearError() {
    _clearError();
  }

  /// Clear success message
  void clearSuccess() {
    _successMessage = null;
    notifyListeners();
  }

  // Private helpers
  void _setLoading(bool value) {
    _isLoading = value;
  }

  void _setPurchasing(bool value) {
    _isPurchasing = value;
  }

  void _setError(String message) {
    _errorMessage = message;
    _successMessage = null;
    debugPrint('❌ Error: $message');
  }

  void _setSuccess(String message) {
    _successMessage = message;
    _errorMessage = null;
    debugPrint('✅ Success: $message');
  }

  void _clearError() {
    _errorMessage = null;
  }

  void _clearMessages() {
    _errorMessage = null;
    _successMessage = null;
  }
}
