import 'package:barbcut/models/subscription_model.dart';

class PaymentValidator {
  /// Validates if a subscription is still active
  static bool isSubscriptionActive(SubscriptionModel subscription) {
    if (!subscription.isActive) return false;

    if (subscription.expirationDate != null) {
      return subscription.expirationDate!.isAfter(DateTime.now());
    }

    return true;
  }

  /// Validates if a package is valid for purchase
  static bool isPackageValid(PackageModel package) {
    return package.identifier.isNotEmpty &&
        package.title.isNotEmpty &&
        package.price >= 0;
  }

  /// Validates subscription list
  static bool hasValidSubscriptions(List<SubscriptionModel> subscriptions) {
    return subscriptions.isNotEmpty &&
        subscriptions.any((sub) => isSubscriptionActive(sub));
  }

  /// Validates if user can purchase
  static bool canUserPurchase(CustomerInfo? customerInfo) {
    if (customerInfo == null) return true;

    // User can always purchase, but might have active subscriptions
    return true;
  }

  /// Gets subscription status
  static SubscriptionStatus getSubscriptionStatus(
    SubscriptionModel subscription,
  ) {
    if (!subscription.isActive) {
      return SubscriptionStatus.inactive;
    }

    if (subscription.expirationDate != null) {
      final daysUntilExpiration = subscription.expirationDate!
          .difference(DateTime.now())
          .inDays;

      if (daysUntilExpiration <= 0) {
        return SubscriptionStatus.expired;
      } else if (daysUntilExpiration <= 7) {
        return SubscriptionStatus.expiringsoon;
      }
    }

    return SubscriptionStatus.active;
  }

  /// Validates customer info
  static bool isCustomerInfoValid(CustomerInfo? customerInfo) {
    return customerInfo != null && customerInfo.customerId.isNotEmpty;
  }
}

enum SubscriptionStatus { active, expiringsoon, expired, inactive }

extension SubscriptionStatusExtension on SubscriptionStatus {
  String get displayName {
    switch (this) {
      case SubscriptionStatus.active:
        return 'Active';
      case SubscriptionStatus.expiringoon:
        return 'Expiring Soon';
      case SubscriptionStatus.expired:
        return 'Expired';
      case SubscriptionStatus.inactive:
        return 'Inactive';
    }
  }

  bool get isActive => this == SubscriptionStatus.active;
  bool get needsAttention => this != SubscriptionStatus.active;
}
