import 'package:purchases_flutter/purchases_flutter.dart';
import 'revenue_cat_service.dart';

/// High-level subscription service providing business logic
class SubscriptionService {
  final RevenueCatService _revenueCatService = RevenueCatService();

  static final SubscriptionService _instance = SubscriptionService._internal();

  SubscriptionService._internal();

  factory SubscriptionService() {
    return _instance;
  }

  bool get isInitialized => _revenueCatService.isInitialized;

  /// Initialize subscription service (call after RevenueCat is initialized)
  Future<void> initialize() async {
    // RevenueCat initialization happens in RevenueCatService
    // This method can be extended if needed for additional setup
  }

  /// Get subscription status
  Future<SubscriptionStatus> getSubscriptionStatus() async {
    await _revenueCatService.refreshCustomerInfo();

    final hasProAccess = _revenueCatService.hasProEntitlement();
    final entitlement = _revenueCatService.getProEntitlement();
    final renewalDate = _revenueCatService.getProRenewalDate();

    return SubscriptionStatus(
      hasPro: hasProAccess,
      isActive: hasProAccess,
      entitlementId: entitlement?.identifier ?? 'BarbCut Pro',
      expirationDate: renewalDate,
      isInTrial: _revenueCatService.isProInTrial(),
      isSandbox: entitlement?.isSandbox ?? false,
    );
  }

  /// Check if user can access pro features
  Future<bool> canAccessPro() async {
    await _revenueCatService.refreshCustomerInfo();
    return _revenueCatService.hasProEntitlement();
  }

  /// Purchase a specific product
  Future<PurchaseResult> purchaseProduct(String packageIdentifier) async {
    try {
      final package = await _revenueCatService.getPackage(packageIdentifier);

      if (package == null) {
        return PurchaseResult.failure('Package not found');
      }

      final customerInfo = await _revenueCatService.purchasePackage(package);

      if (customerInfo == null) {
        return PurchaseResult.cancelled();
      }

      return PurchaseResult.success(
        hasProAccess: _revenueCatService.hasProEntitlement(),
        message: 'Successfully purchased ${package.identifier}',
      );
    } catch (e) {
      return PurchaseResult.failure('Purchase failed: $e');
    }
  }

  /// Get available products for purchase
  Future<List<AvailableProduct>> getAvailableProducts() async {
    try {
      final packages = await _revenueCatService.getPackages();

      return packages
          .map(
            (pkg) => AvailableProduct(
              identifier: pkg.identifier,
              name: pkg.packageType.name,
              displayName: _getProductDisplayName(pkg.identifier),
              storeProduct: pkg.storeProduct,
              price: pkg.storeProduct.priceString,
              currencyCode: pkg.storeProduct.currencyCode ?? 'USD',
              package: pkg,
            ),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get specific product
  Future<AvailableProduct?> getProduct(String packageIdentifier) async {
    try {
      final products = await getAvailableProducts();
      return products.firstWhere(
        (p) => p.identifier == packageIdentifier,
        orElse: () => throw Exception('Product not found'),
      );
    } catch (e) {
      return null;
    }
  }

  /// Restore purchases
  Future<void> restorePurchases() async {
    await _revenueCatService.restorePurchases();
  }

  /// Set user ID for tracking
  Future<void> setUserId(String userId) async {
    await _revenueCatService.setCustomerId(userId);
  }

  /// Logout user
  Future<void> logout() async {
    await _revenueCatService.logout();
  }

  /// Helper to get user-friendly product names
  String _getProductDisplayName(String packageId) {
    switch (packageId) {
      case 'monthly':
        return 'Monthly Pro';
      case 'yearly':
        return 'Yearly Pro';
      default:
        return packageId;
    }
  }
}

/// Result of a purchase operation
class PurchaseResult {
  final bool success;
  final bool cancelled;
  final String message;
  final bool? hasProAccess;

  PurchaseResult({
    required this.success,
    required this.cancelled,
    required this.message,
    this.hasProAccess,
  });

  factory PurchaseResult.success({
    required bool hasProAccess,
    String message = 'Purchase successful',
  }) {
    return PurchaseResult(
      success: true,
      cancelled: false,
      message: message,
      hasProAccess: hasProAccess,
    );
  }

  factory PurchaseResult.failure(String message) {
    return PurchaseResult(success: false, cancelled: false, message: message);
  }

  factory PurchaseResult.cancelled() {
    return PurchaseResult(
      success: false,
      cancelled: true,
      message: 'Purchase cancelled',
    );
  }
}

/// Subscription status model
class SubscriptionStatus {
  final bool hasPro;
  final bool isActive;
  final String entitlementId;
  final DateTime? expirationDate;
  final bool isInTrial;
  final bool isSandbox;

  SubscriptionStatus({
    required this.hasPro,
    required this.isActive,
    required this.entitlementId,
    this.expirationDate,
    required this.isInTrial,
    required this.isSandbox,
  });

  /// Get days until subscription expires
  int? getDaysUntilExpiration() {
    if (expirationDate == null) return null;
    final daysLeft = expirationDate!.difference(DateTime.now()).inDays;
    return daysLeft > 0 ? daysLeft : 0;
  }

  /// Check if subscription is about to expire (within 7 days)
  bool get isExpiringSoon {
    final daysLeft = getDaysUntilExpiration();
    return daysLeft != null && daysLeft <= 7 && daysLeft > 0;
  }
}

/// Available product model
class AvailableProduct {
  final String identifier;
  final String name;
  final String displayName;
  final StoreProduct storeProduct;
  final String price;
  final String currencyCode;
  final Package package;

  AvailableProduct({
    required this.identifier,
    required this.name,
    required this.displayName,
    required this.storeProduct,
    required this.price,
    required this.currencyCode,
    required this.package,
  });

  /// Get monthly equivalent price (for comparison)
  double get monthlyPrice {
    if (identifier == 'monthly') {
      return double.tryParse(storeProduct.price.toString()) ?? 0.0;
    }
    if (identifier == 'yearly') {
      // Divide yearly by 12 for monthly equivalent
      final yearlyPrice = double.tryParse(storeProduct.price.toString()) ?? 0.0;
      return yearlyPrice / 12;
    }
    return 0.0;
  }

  /// Get savings compared to monthly
  String getSavingsText() {
    if (identifier != 'yearly') return '';

    // Calculate savings (e.g., "Save 10%")
    final monthlyPrice = double.tryParse(storeProduct.price.toString()) ?? 0.0;
    final yearlyPrice = monthlyPrice * 12;
    final actualYearlyPrice =
        double.tryParse(storeProduct.price.toString()) ?? 0.0;

    if (actualYearlyPrice >= yearlyPrice) return '';

    final savingsPercent =
        ((yearlyPrice - actualYearlyPrice) / yearlyPrice * 100).round();
    return 'Save $savingsPercent%';
  }
}
