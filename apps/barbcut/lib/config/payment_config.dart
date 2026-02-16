/// Configuration for RevenueCat payment system
class PaymentConfig {
  /// Subscription product identifiers mapping
  static const Map<String, String> productIdToName = {
    'monthly_subscription': 'Monthly Haircut Plan',
    'annual_subscription': 'Annual Haircut Plan',
    'premium_monthly': 'Premium Monthly',
    'premium_annual': 'Premium Annual',
  };

  /// Pricing information
  static const Map<String, double> productPricing = {
    'monthly_subscription': 9.99,
    'annual_subscription': 99.99,
    'premium_monthly': 19.99,
    'premium_annual': 199.99,
  };

  /// Feature tiers
  static const Map<String, List<String>> featuresByTier = {
    'monthly_subscription': [
      'Unlimited monthly consultations',
      'Style recommendations',
      'Monthly trends',
      'Email support',
    ],
    'annual_subscription': [
      'Unlimited consultations',
      'Advanced style analytics',
      'Monthly exclusive content',
      'Priority email support',
      'Yearly style guide',
    ],
    'premium_monthly': [
      'Everything in Monthly',
      'Custom color palettes',
      'Advanced analytics',
      'Priority support',
    ],
    'premium_annual': [
      'Everything in Annual',
      'Custom color collections',
      'Advanced team analytics',
      'VIP phone support',
      'Lifetime access to features',
    ],
  };

  /// Trial period configurations
  static const Map<String, int> trialDaysByProduct = {
    'monthly_subscription': 7,
    'annual_subscription': 14,
    'premium_monthly': 3,
    'premium_annual': 7,
  };

  /// Payment gateway timeouts (in milliseconds)
  static const int purchaseTimeout = 30000;
  static const int restorePurchasesTimeout = 30000;
  static const int fetchCustomerInfoTimeout = 30000;

  /// Error retry configuration
  static const int maxRetryAttempts = 3;
  static const int retryDelayMs = 1000;

  /// Feature flag configuration
  static const bool enablePayments = true;
  static const bool enableSubscriptions = true;
  static const bool enableAnalytics = true;
  static const bool enableEventLogging = true;

  /// Logging configuration
  static const bool enableDebugLogging = true;
  static const bool enableAnalyticsLogging = true;
  static const bool enableErrorLogging = true;
}
