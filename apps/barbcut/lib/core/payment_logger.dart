import 'dart:developer' as developer;
import 'package:barbcut/services/payment_analytics_tracker.dart';

/// Handles payment-related logging and debugging
class PaymentLogger {
  static const String _logPrefix = '[Payment]';

  static void logInfo(String message) {
    developer.log('$_logPrefix [INFO] $message', name: 'Payment');
  }

  static void logDebug(String message) {
    developer.log('$_logPrefix [DEBUG] $message', name: 'Payment');
  }

  static void logWarning(String message) {
    developer.log(
      '$_logPrefix [WARNING] $message',
      name: 'Payment',
      level: 900,
    );
  }

  static void logError(
    String message, [
    dynamic error,
    StackTrace? stackTrace,
  ]) {
    developer.log(
      '$_logPrefix [ERROR] $message',
      name: 'Payment',
      error: error,
      stackTrace: stackTrace,
      level: 1000,
    );
    if (error != null) {
      developer.log('$_logPrefix Error: $error', name: 'Payment', level: 1000);
    }
    if (stackTrace != null) {
      developer.log(
        '$_logPrefix Stack: $stackTrace',
        name: 'Payment',
        level: 1000,
      );
    }
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
