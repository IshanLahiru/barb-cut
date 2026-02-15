import 'package:barbcut/models/subscription_model.dart';

class PaymentAnalytics {
  static final PaymentAnalytics _instance = PaymentAnalytics._internal();

  final Map<String, int> _eventCounts = {};
  final List<PurchaseMetric> _purchaseHistory = [];
  DateTime? _lastPurchaseTime;

  factory PaymentAnalytics() {
    return _instance;
  }

  PaymentAnalytics._internal();

  void recordPurchase(String packageId, double amount) {
    _lastPurchaseTime = DateTime.now();
    _purchaseHistory.add(
      PurchaseMetric(
        packageId: packageId,
        amount: amount,
        timestamp: _lastPurchaseTime!,
      ),
    );
    _incrementEventCount('purchase');
  }

  void recordRestorePurchases() {
    _incrementEventCount('restore_purchases');
  }

  void recordSubscriptionView() {
    _incrementEventCount('subscription_view');
  }

  void recordPaywallView() {
    _incrementEventCount('paywall_view');
  }

  void _incrementEventCount(String eventName) {
    _eventCounts[eventName] = (_eventCounts[eventName] ?? 0) + 1;
  }

  Map<String, int> getEventCounts() => Map.from(_eventCounts);

  List<PurchaseMetric> getPurchaseHistory() => List.from(_purchaseHistory);

  DateTime? getLastPurchaseTime() => _lastPurchaseTime;

  double getTotalRevenue() {
    return _purchaseHistory.fold(0.0, (sum, metric) => sum + metric.amount);
  }

  int getPurchaseCount() => _purchaseHistory.length;

  void clear() {
    _eventCounts.clear();
    _purchaseHistory.clear();
    _lastPurchaseTime = null;
  }
}

class PurchaseMetric {
  final String packageId;
  final double amount;
  final DateTime timestamp;

  PurchaseMetric({
    required this.packageId,
    required this.amount,
    required this.timestamp,
  });

  @override
  String toString() =>
      'PurchaseMetric(packageId: $packageId, amount: $amount, timestamp: $timestamp)';
}

class SubscriptionMetrics {
  static final SubscriptionMetrics _instance = SubscriptionMetrics._internal();

  final Map<String, int> _subscriptionCounts = {};

  factory SubscriptionMetrics() {
    return _instance;
  }

  SubscriptionMetrics._internal();

  void updateSubscriptionMetrics(List<SubscriptionModel> subscriptions) {
    for (var subscription in subscriptions) {
      _subscriptionCounts[subscription.id] =
          (_subscriptionCounts[subscription.id] ?? 0) + 1;
    }
  }

  Map<String, int> getSubscriptionCounts() => Map.from(_subscriptionCounts);

  int getActiveSubscriptionCount() {
    return _subscriptionCounts.values.fold(0, (sum, count) => sum + count);
  }

  void clear() {
    _subscriptionCounts.clear();
  }
}
