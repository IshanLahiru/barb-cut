class PaymentConstants {
  // RevenueCat Configuration
  static const String revenuecatApiKey = 'goog_ApYcEmNqTqQlKlAmBrQlZbKKqzS';

  // Product Identifiers
  static const String monthlySubscriptionId = 'monthly_subscription';
  static const String annualSubscriptionId = 'annual_subscription';
  static const String premiumMonthlyId = 'premium_monthly';
  static const String premiumAnnualId = 'premium_annual';

  // Pricing
  static const double monthlyPrice = 9.99;
  static const double annualPrice = 99.99;
  static const double premiumMonthlyPrice = 19.99;
  static const double premiumAnnualPrice = 199.99;

  // Subscription Tiers
  static const Map<String, String> subscriptionTiers = {
    monthlySubscriptionId: 'Monthly Plan',
    annualSubscriptionId: 'Annual Plan',
    premiumMonthlyId: 'Premium Monthly',
    premiumAnnualId: 'Premium Annual',
  };

  // Feature Availability by Tier
  static const Map<String, List<String>> tierFeatures = {
    monthlySubscriptionId: [
      'Unlimited hairstyle consultations',
      'Monthly style trends',
      'Email support',
    ],
    annualSubscriptionId: [
      'Unlimited hairstyle consultations',
      'Monthly style trends',
      'Email support',
      'Priority support',
      'Exclusive content',
    ],
    premiumMonthlyId: [
      'All basic features',
      'Advanced analytics',
      'Custom color palettes',
      'Premium support',
    ],
    premiumAnnualId: [
      'All premium features',
      'Lifetime updates',
      'VIP support',
      'Exclusive events access',
    ],
  };

  // Error Messages
  static const String purchaseFailedError =
      'Purchase failed. Please try again.';
  static const String restoreFailedError = 'Failed to restore purchases.';
  static const String initializationError =
      'Failed to initialize payment system.';
  static const String networkError =
      'Network error. Please check your connection.';

  // UI Text
  static const String unlockPremium = 'Unlock Premium Features';
  static const String manageSubscription = 'Manage Subscription';
  static const String selectPlan = 'Choose Your Plan';
  static const String activeSubscription = 'Active Subscription';
  static const String noSubscription = 'No Active Subscriptions';
  static const String restorePurchases = 'Restore Purchases';
  static const String subscribe = 'Subscribe';
  static const String renews = 'Renews on';

  // Notification Messages
  static const String purchaseSuccess = 'Purchase successful!';
  static const String purchaseCancelled = 'Purchase cancelled.';
  static const String restoreSuccess = 'Purchases restored successfully.';
}
