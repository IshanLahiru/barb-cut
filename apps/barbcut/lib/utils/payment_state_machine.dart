import 'package:barbcut/models/subscription_model.dart';

/// Payment state machine for managing subscription states
class PaymentStateMachine {
  static const String stateNoSubscription = 'no_subscription';
  static const String stateActiveSubscription = 'active_subscription';
  static const String stateExpiringSoon = 'expiring_soon';
  static const String stateExpired = 'expired';

  /// Get current state based on subscriptions
  static String getCurrentState(List<SubscriptionModel> subscriptions) {
    if (subscriptions.isEmpty) {
      return stateNoSubscription;
    }

    for (var sub in subscriptions) {
      if (!sub.isActive) continue;

      if (sub.expirationDate == null) {
        return stateActiveSubscription;
      }

      final daysUntilExpiration = sub.expirationDate!
          .difference(DateTime.now())
          .inDays;

      if (daysUntilExpiration <= 0) {
        return stateExpired;
      } else if (daysUntilExpiration <= 7) {
        return stateExpiringSoon;
      } else {
        return stateActiveSubscription;
      }
    }

    return stateExpired;
  }

  /// Get appropriate UI action for state
  static String getActionForState(String state) {
    switch (state) {
      case stateNoSubscription:
        return 'View Plans';
      case stateActiveSubscription:
        return 'Manage Subscription';
      case stateExpiringSoon:
        return 'Renew Subscription';
      case stateExpired:
        return 'Resubscribe';
      default:
        return 'Unknown';
    }
  }

  /// Check if action is available for state
  static bool isActionAvailable(String state) {
    return state != stateNoSubscription;
  }
}
