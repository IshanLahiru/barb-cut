import 'package:barbcut/services/payment_analytics_tracker.dart';

/// Handles payment-related logging and debugging
class PaymentLogger {
  static const String _logPrefix = '[Payment]';

  static void logInfo(String message) {
    print('$_logPrefix [INFO] $message');
  }

  static void logDebug(String message) {
    print('$_logPrefix [DEBUG] $message');
  }

  static void logWarning(String message) {
    print('$_logPrefix [WARNING] $message');
  }

  static void logError(
    String message, [
    dynamic error,
    StackTrace? stackTrace,
  ]) {
    print('$_logPrefix [ERROR] $message');
    if (error != null) print('$_logPrefix Error: $error');
    if (stackTrace != null) print('$_logPrefix Stack: $stackTrace');
  }

  static void logPurchaseEvent(String packageId, String status) {
    logInfo('Purchase event - Package: $packageId, Status: $status');
    PaymentAnalyticsTracker().trackEvent(
      'purchase_event',
      properties: {'package_id': packageId, 'status': status},
    );
  }

  static void logAPICall(String method) {
    logDebug('API Call: $method');
  }

  static void logAPIResponse(String method, bool success) {
    logDebug('API Response: $method - ${success ? 'Success' : 'Failed'}');
  }

  static void logCacheHit(String key) {
    logDebug('Cache hit: $key');
  }

  static void logCacheMiss(String key) {
    logDebug('Cache miss: $key');
  }

  static void logSubscriptionStatus(String id, String status) {
    logInfo('Subscription status - ID: $id, Status: $status');
  }

  static void logPerformanceMetric(String metric, Duration duration) {
    logInfo('Performance - $metric: ${duration.inMilliseconds}ms');
  }

  static void logConfigurationLoaded() {
    logInfo('Payment system initialized and configured');
  }

  static void logShutdown() {
    logInfo('Payment system shutdown');
  }
}
