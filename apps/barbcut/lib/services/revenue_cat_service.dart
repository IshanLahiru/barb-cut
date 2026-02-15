import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RevenueCatService {
  static late final String _apiKey;

  // Entitlements
  static const String _proEntitlementId = 'BarbCut Pro';

  static final RevenueCatService _instance = RevenueCatService._internal();

  bool _isInitialized = false;
  CustomerInfo? _customerInfo;
  Map<String, Package>? _packages;

  RevenueCatService._internal();

  factory RevenueCatService() {
    return _instance;
  }

  bool get isInitialized => _isInitialized;
  CustomerInfo? get customerInfo => _customerInfo;
  Map<String, Package>? get packages => _packages;

  /// Initialize RevenueCat SDK
  /// Call this in main() before running the app
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('RevenueCat already initialized');
      return;
    }

    try {
      // Load API key from environment, with fallback to hardcoded test key
      _apiKey =
          dotenv.env['REVENUECAT_API_KEY'] ??
          'test_ZganEtcwwIUiOsXPGkyoiEYxzJP';

      if (_apiKey == 'test_ZganEtcwwIUiOsXPGkyoiEYxzJP') {
        debugPrint('⚠️ Using fallback test API key - .env file not loaded');
      } else {
        debugPrint('✅ Loaded API key from .env file');
      }

      // Configure Purchases
      await Purchases.configure(
        PurchasesConfiguration(_apiKey)
          ..appUserID = null, // Anonymous user, will be set when authenticated
      );

      _isInitialized = true;
      debugPrint('✅ RevenueCat SDK initialized successfully');

      // Load initial customer info
      await _loadCustomerInfo();
    } catch (e) {
      debugPrint('❌ Failed to initialize RevenueCat: $e');
      rethrow;
    }
  }

  /// Set customer ID (call after user authentication)
  Future<void> setCustomerId(String userId) async {
    try {
      await Purchases.logIn(userId);
      debugPrint('✅ User logged in to RevenueCat: $userId');
      await _loadCustomerInfo();
    } catch (e) {
      debugPrint('❌ Failed to log in user: $e');
      rethrow;
    }
  }

  /// Logout customer
  Future<void> logout() async {
    try {
      await Purchases.logOut();
      _customerInfo = null;
      debugPrint('✅ User logged out from RevenueCat');
    } catch (e) {
      debugPrint('❌ Failed to logout: $e');
      rethrow;
    }
  }

  /// Load and cache customer info
  @protected
  Future<void> _loadCustomerInfo() async {
    try {
      _customerInfo = await Purchases.getCustomerInfo();
      debugPrint(
        '✅ Customer info loaded: ${_customerInfo?.entitlements.active.keys}',
      );
    } catch (e) {
      debugPrint('❌ Failed to load customer info: $e');
    }
  }

  /// Get offerings (products configuration)
  Future<Offerings?> getOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      debugPrint('✅ Offerings loaded: ${offerings.current?.identifier}');
      return offerings;
    } catch (e) {
      debugPrint('❌ Failed to get offerings: $e');
      return null;
    }
  }

  /// Get current offering (default offering)
  Future<Offering?> getCurrentOffering() async {
    try {
      final offerings = await Purchases.getOfferings();
      return offerings.current;
    } catch (e) {
      debugPrint('❌ Failed to get current offering: $e');
      return null;
    }
  }

  /// Get packages for current offering
  Future<List<Package>> getPackages() async {
    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;

      if (current != null) {
        _packages = {
          for (var pkg in current.availablePackages) pkg.identifier: pkg,
        };
        return current.availablePackages;
      }

      return [];
    } catch (e) {
      debugPrint('❌ Failed to get packages: $e');
      return [];
    }
  }

  /// Get specific package
  Future<Package?> getPackage(String packageIdentifier) async {
    try {
      final packages = await getPackages();
      return packages.firstWhere(
        (p) => p.identifier == packageIdentifier,
        orElse: () => throw Exception('Package not found: $packageIdentifier'),
      );
    } catch (e) {
      debugPrint('❌ Failed to get package: $e');
      return null;
    }
  }

  /// Purchase a package
  Future<CustomerInfo?> purchasePackage(Package package) async {
    try {
      final purchaseResult = await Purchases.purchasePackage(package);
      final customerInfo = purchaseResult.customerInfo;
      debugPrint('✅ Purchase successful for ${package.identifier}');
      _customerInfo = customerInfo;
      return customerInfo;
    } on PurchasesErrorCode catch (e) {
      debugPrint('❌ Purchase error: $e');
      return null;
    } catch (e) {
      if (e.toString().contains('PurchaseCancelledError') ||
          e.toString().contains('cancelled')) {
        debugPrint('⚠️ Purchase cancelled by user');
      } else if (e.toString().contains('PurchaseNotAllowedError')) {
        debugPrint('❌ Purchases not allowed on this device');
      } else {
        debugPrint('❌ Purchase failed: $e');
      }
      return null;
    }
  }

  /// Refresh customer info (call this when needed to sync)
  Future<void> refreshCustomerInfo() async {
    try {
      await _loadCustomerInfo();
    } catch (e) {
      debugPrint('❌ Failed to refresh customer info: $e');
    }
  }

  /// Check if user has pro entitlement
  bool hasProEntitlement() {
    return _customerInfo?.entitlements.all[_proEntitlementId]?.isActive ??
        false;
  }

  /// Get pro entitlement info
  EntitlementInfo? getProEntitlement() {
    return _customerInfo?.entitlements.all[_proEntitlementId];
  }

  /// Get all active entitlements
  List<String> getActiveEntitlements() {
    return _customerInfo?.entitlements.active.keys.toList() ?? [];
  }

  /// Get subscription renewal date
  DateTime? getProRenewalDate() {
    final entitlement = getProEntitlement();
    if (entitlement?.expirationDate != null) {
      return DateTime.parse(entitlement!.expirationDate!);
    }
    return null;
  }

  /// Check if subscription is in trial
  bool isProInTrial() {
    return getProEntitlement()?.isActive == true &&
        (getProEntitlement()?.isSandbox ?? false);
  }

  /// Restore purchases (for when user reinstalls app)
  Future<void> restorePurchases() async {
    try {
      await Purchases.restorePurchases();
      await _loadCustomerInfo();
      debugPrint('✅ Purchases restored');
    } catch (e) {
      debugPrint('❌ Failed to restore purchases: $e');
      rethrow;
    }
  }
}
