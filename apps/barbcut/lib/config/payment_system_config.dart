// This file can be used to house any additional payment-related constants
// or configurations that don't fit in other modules

/// Additional payment system constants
const String paymentSystemVersion = '1.0.0';
const String paymentSystemName = 'RevenueCat Integration';
const String lastUpdated = '2026-02-18';

/// Payment system features
const List<String> enabledFeatures = [
  'subscriptions',
  'purchase_restoration',
  'analytics',
  'event_tracking',
  'renewal_reminders',
  'caching',
  'error_handling',
];

/// Payment system compatibility
const Map<String, String> supportedPlatforms = {
  'iOS': '16.0+',
  'Android': '10+',
};

/// Payment processing information
const String paymentProcessorName = 'RevenueCat';
const String paymentProcessorVersion = '7.8.0';
const bool sandboxMode = true; // Set to false in production
