import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:barbcut/models/subscription_model.dart';

class RevenuecatService {
  static const String _apiKey = 'goog_ApYcEmNqTqQlKlAmBrQlZbKKqzS';
  static RevenuecatService? _instance;

  RevenuecatService._();

  factory RevenuecatService() {
    _instance ??= RevenuecatService._();
    return _instance!;
  }

  bool _initialized = false;

  bool get isInitialized => _initialized;

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      await Purchases.setLogLevel(LogLevel.debug);

      // Configure RevenueCat with API Key
      await Purchases.configure(PurchasesConfiguration(_apiKey));

      _initialized = true;
      debugPrint('RevenueCat initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize RevenueCat: $e');
      rethrow;
    }
  }

  Future<CustomerInfo> fetchCustomerInfo() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();

      final subscriptions = <SubscriptionModel>[];

      // Process active subscriptions
      for (var entry in customerInfo.allPurchasedProductIdentifiers) {
        subscriptions.add(
          SubscriptionModel(
            id: entry,
            title: _getSubscriptionTitle(entry),
            description: _getSubscriptionDescription(entry),
            price: 0.0,
            currencyCode: 'USD',
            billingPeriod: _getBillingPeriod(entry),
            isActive: true,
            expirationDate: customerInfo.getExpirationDateForProductIdentifier(
              entry,
            ),
          ),
        );
      }

      return CustomerInfo(
        customerId: customerInfo.originalAppUserId,
        subscriptions: subscriptions,
        hasActiveSubscription:
            customerInfo.allPurchasedProductIdentifiers.isNotEmpty,
        requestDate: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Error fetching customer info: $e');
      rethrow;
    }
  }

  Future<List<PackageModel>> fetchAvailablePackages() async {
    try {
      final offerings = await Purchases.getOfferings();
      final packages = <PackageModel>[];

      if (offerings.current != null) {
        for (var package in offerings.current!.availablePackages) {
          final storeProduct = package.storeProduct;
          packages.add(
            PackageModel(
              identifier: package.identifier,
              title: storeProduct.title,
              description: storeProduct.description,
              price: storeProduct.price,
              currencyCode: storeProduct.currencyCode,
              introPrice: _formatIntroPrice(storeProduct),
              billingPeriod: _extractBillingPeriod(
                storeProduct.subscriptionPeriod,
              ),
            ),
          );
        }
      }

      return packages;
    } catch (e) {
      debugPrint('Error fetching packages: $e');
      rethrow;
    }
  }

  Future<void> purchasePackage(PackageModel package) async {
    try {
      final offerings = await Purchases.getOfferings();

      final storePackage = offerings.current?.availablePackages.firstWhere(
        (p) => p.identifier == package.identifier,
      );

      if (storePackage != null) {
        final purchaserInfo = await Purchases.purchasePackage(storePackage);
        debugPrint('Purchase successful: ${purchaserInfo.originalAppUserId}');
      }
    } catch (e) {
      debugPrint('Error during purchase: $e');
      rethrow;
    }
  }

  Future<void> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      debugPrint(
        'Purchases restored: ${customerInfo.allPurchasedProductIdentifiers}',
      );
    } catch (e) {
      debugPrint('Error restoring purchases: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await Purchases.logOut();
      debugPrint('User logged out from RevenueCat');
    } catch (e) {
      debugPrint('Error logging out: $e');
      rethrow;
    }
  }

  String _getSubscriptionTitle(String productId) {
    const titles = {
      'monthly_subscription': 'Monthly Haircut Plan',
      'annual_subscription': 'Annual Haircut Plan',
      'premium_monthly': 'Premium Monthly',
      'premium_annual': 'Premium Annual',
    };
    return titles[productId] ?? productId;
  }

  String _getSubscriptionDescription(String productId) {
    const descriptions = {
      'monthly_subscription': 'Get unlimited monthly haircuts and beard trims',
      'annual_subscription':
          'Get unlimited annual haircuts with extra benefits',
      'premium_monthly': 'Access all premium features every month',
      'premium_annual': 'Premium access for the entire year',
    };
    return descriptions[productId] ?? 'Subscription plan';
  }

  String _getBillingPeriod(String productId) {
    if (productId.contains('annual')) {
      return 'ANNUAL';
    } else if (productId.contains('monthly')) {
      return 'MONTHLY';
    }
    return 'UNKNOWN';
  }

  String _formatIntroPrice(StoreProduct product) {
    final introPrice = product.introPrice;
    if (introPrice?.price == null) {
      return '';
    }
    return 'Start at \$${introPrice!.price} for ${introPrice.period}';
  }

  String _extractBillingPeriod(String? period) {
    if (period == null) return 'ONE_TIME';
    if (period.contains('P1Y')) return 'ANNUAL';
    if (period.contains('P1M')) return 'MONTHLY';
    if (period.contains('P1W')) return 'WEEKLY';
    return period;
  }
}
