import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:purchases_flutter/purchases_flutter.dart' hide CustomerInfo;
import 'package:barbcut/models/subscription_model.dart';

class RevenuecatService {
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
      final apiKey = dotenv.env['REVENUECAT_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception(
          'RevenueCat API key not found in environment variables',
        );
      }

      await Purchases.setLogLevel(LogLevel.debug);

      // Configure RevenueCat with API Key from environment
      await Purchases.configure(PurchasesConfiguration(apiKey));

      _initialized = true;
      debugPrint('RevenueCat initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize RevenueCat: $e');
      rethrow;
    }
  }

  Future<CustomerInfo> fetchCustomerInfo() async {
    try {
      final revenuecatCustomerInfo = await Purchases.getCustomerInfo();

      final subscriptions = <SubscriptionModel>[];

      // Process all purchased subscriptions
      for (var productId
          in revenuecatCustomerInfo.allPurchasedProductIdentifiers) {
        // Get expiration date from the allExpirationDates map
        final expirationDateStr =
            revenuecatCustomerInfo.allExpirationDates[productId];
        DateTime? expirationDate;
        if (expirationDateStr != null) {
          try {
            expirationDate = DateTime.parse(expirationDateStr);
          } catch (e) {
            debugPrint('Failed to parse expiration date: $expirationDateStr');
          }
        }

        subscriptions.add(
          SubscriptionModel(
            id: productId,
            title: _getSubscriptionTitle(productId),
            description: _getSubscriptionDescription(productId),
            price: 0.0,
            currencyCode: 'USD',
            billingPeriod: _getBillingPeriod(productId),
            isActive: revenuecatCustomerInfo.activeSubscriptions.contains(
              productId,
            ),
            expirationDate: expirationDate,
          ),
        );
      }

      return CustomerInfo(
        customerId: revenuecatCustomerInfo.originalAppUserId,
        subscriptions: subscriptions,
        hasActiveSubscription:
            revenuecatCustomerInfo.activeSubscriptions.isNotEmpty,
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
        final purchaseParams = PurchaseParams.package(storePackage);
        final purchaseResult = await Purchases.purchase(purchaseParams);
        debugPrint(
          'Purchase successful: ${purchaseResult.customerInfo.originalAppUserId}',
        );
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
    final introPriceInfo = product.introductoryPrice;
    if (introPriceInfo == null) {
      return '';
    }
    final billingPeriod = _extractBillingPeriod(product.subscriptionPeriod);
    return 'Start at \$${introPriceInfo.price} for $billingPeriod';
  }

  String _extractBillingPeriod(String? period) {
    if (period == null) return 'ONE_TIME';
    if (period.contains('P1Y')) return 'ANNUAL';
    if (period.contains('P1M')) return 'MONTHLY';
    if (period.contains('P1W')) return 'WEEKLY';
    return period;
  }
}
