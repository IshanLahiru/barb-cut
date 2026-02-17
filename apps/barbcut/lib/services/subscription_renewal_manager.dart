import 'dart:async';
import 'package:barbcut/models/subscription_model.dart';

/// Manages subscription renewal scheduling and notifications
class SubscriptionRenewalManager {
  static final SubscriptionRenewalManager _instance =
      SubscriptionRenewalManager._internal();

  final Map<String, Timer> _renewalTimers = {};
  final List<Function(SubscriptionModel)> _renewalListeners = [];

  factory SubscriptionRenewalManager() {
    return _instance;
  }

  SubscriptionRenewalManager._internal();

  /// Schedule renewal notification for a subscription
  void scheduleRenewalReminder(SubscriptionModel subscription) {
    if (subscription.expirationDate == null) return;

    final now = DateTime.now();
    final expirationDate = subscription.expirationDate!;

    if (expirationDate.isBefore(now)) {
      _notifyRenewal(subscription);
      return;
    }

    // Cancel existing timer for this subscription
    _renewalTimers[subscription.id]?.cancel();

    // Schedule notification 1 day before expiration
    final notificationTime = expirationDate.subtract(const Duration(days: 1));
    final duration = notificationTime.difference(now);

    if (duration.isNegative) {
      _notifyRenewal(subscription);
      return;
    }

    _renewalTimers[subscription.id] = Timer(duration, () {
      _notifyRenewal(subscription);
    });
  }

  /// Subscribe to renewal notifications
  void onRenewalNeeded(Function(SubscriptionModel) callback) {
    _renewalListeners.add(callback);
  }

  /// Unsubscribe from renewal notifications
  void removeRenewalListener(Function(SubscriptionModel) callback) {
    _renewalListeners.remove(callback);
  }

  void _notifyRenewal(SubscriptionModel subscription) {
    for (var listener in _renewalListeners) {
      listener(subscription);
    }
  }

  /// Cancel timer for a subscription
  void cancelReminder(String subscriptionId) {
    _renewalTimers[subscriptionId]?.cancel();
    _renewalTimers.remove(subscriptionId);
  }

  /// Cancel all timers
  void cancelAllReminders() {
    for (var timer in _renewalTimers.values) {
      timer.cancel();
    }
    _renewalTimers.clear();
  }

  /// Get number of active reminders
  int get activeReminderCount => _renewalTimers.length;
}
