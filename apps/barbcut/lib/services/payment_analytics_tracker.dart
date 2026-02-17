/// Analytics event models for payment tracking
class PaymentAnalyticsEvent {
  final String eventName;
  final DateTime timestamp;
  final Map<String, dynamic> properties;

  PaymentAnalyticsEvent({required this.eventName, required this.properties})
    : timestamp = DateTime.now();

  Map<String, dynamic> toJson() => {
    'event_name': eventName,
    'timestamp': timestamp.toIso8601String(),
    'properties': properties,
  };

  @override
  String toString() => 'PaymentAnalyticsEvent($eventName, $timestamp)';
}

/// Analytics event types
class AnalyticsEventType {
  static const String purchaseInitiated = 'purchase_initiated';
  static const String purchaseCompleted = 'purchase_completed';
  static const String purchaseFailed = 'purchase_failed';
  static const String purchaseCancelled = 'purchase_cancelled';
  static const String restorePurchasesInitiated = 'restore_purchases_initiated';
  static const String restorePurchasesCompleted = 'restore_purchases_completed';
  static const String restorePurchasesFailed = 'restore_purchases_failed';
  static const String paywallViewed = 'paywall_viewed';
  static const String subscriptionManagementViewed =
      'subscription_management_viewed';
  static const String subscriptionActiveChecked = 'subscription_active_checked';
  static const String error = 'error';
}

/// Analytics tracker for payment metrics
class PaymentAnalyticsTracker {
  static final PaymentAnalyticsTracker _instance =
      PaymentAnalyticsTracker._internal();

  final List<PaymentAnalyticsEvent> _events = [];

  factory PaymentAnalyticsTracker() {
    return _instance;
  }

  PaymentAnalyticsTracker._internal();

  /// Track event
  void trackEvent(String eventName, {Map<String, dynamic>? properties}) {
    final event = PaymentAnalyticsEvent(
      eventName: eventName,
      properties: properties ?? {},
    );
    _events.add(event);
  }

  /// Track purchase initiated
  void trackPurchaseInitiated(String packageId, double amount) {
    trackEvent(
      AnalyticsEventType.purchaseInitiated,
      properties: {'package_id': packageId, 'amount': amount},
    );
  }

  /// Track purchase completed
  void trackPurchaseCompleted(String packageId, double amount) {
    trackEvent(
      AnalyticsEventType.purchaseCompleted,
      properties: {'package_id': packageId, 'amount': amount},
    );
  }

  /// Track purchase failed
  void trackPurchaseFailed(String packageId, String error) {
    trackEvent(
      AnalyticsEventType.purchaseFailed,
      properties: {'package_id': packageId, 'error': error},
    );
  }

  /// Get all events
  List<PaymentAnalyticsEvent> getEvents() => List.from(_events);

  /// Get events by type
  List<PaymentAnalyticsEvent> getEventsByType(String eventType) {
    return _events.where((e) => e.eventName == eventType).toList();
  }

  /// Clear events
  void clearEvents() {
    _events.clear();
  }

  /// Get event count
  int get eventCount => _events.length;
}
