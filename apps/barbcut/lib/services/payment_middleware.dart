import 'package:barbcut/models/subscription_model.dart';
import 'package:barbcut/services/payment_event_bus.dart';

/// Payment middleware for intercepting and logging payment operations
class PaymentMiddleware {
  final PaymentEventBus _eventBus = PaymentEventBus();

  void logPurchaseAttempt(String packageId, double amount) {
    _eventBus.emit(
      PaymentEvent(
        type: PaymentEventTypes.purchaseInitiated,
        data: {
          'package_id': packageId,
          'amount': amount,
        },
      ),
    );
  }

  void logPurchaseSuccess(String packageId) {
    _eventBus.emit(
      PaymentEvent(
        type: PaymentEventTypes.purchaseCompleted,
        data: {
          'package_id': packageId,
        },
      ),
    );
  }

  void logPurchaseFailure(String packageId, String error) {
    _eventBus.emit(
      PaymentEvent(
        type: PaymentEventTypes.purchaseFailed,
        data: {
          'package_id': packageId,
          'error': error,
        },
      ),
    );
  }

  void logRestoreAttempt() {
    _eventBus.emit(
      PaymentEvent(
        type: PaymentEventTypes.restoreInitiated,
        data: {},
      ),
    );
  }

  void logRestoreSuccess(List<SubscriptionModel> subscriptions) {
    _eventBus.emit(
      PaymentEvent(
        type: PaymentEventTypes.restoreCompleted,
        data: {
          'subscription_count': subscriptions.length,
        },
      ),
    );
  }

  void logSubscriptionActive(SubscriptionModel subscription) {
    _eventBus.emit(
      PaymentEvent(
        type: PaymentEventTypes.subscriptionActive,
        data: {
          'subscription_id': subscription.id,
          'title': subscription.title,
        },
      ),
    );
  }

  void logSubscriptionExpired(SubscriptionModel subscription) {
    _eventBus.emit(
      PaymentEvent(
        type: PaymentEventTypes.subscriptionExpired,
        data: {
          'subscription_id': subscription.id,
        },
      ),
    );
  }

  void logSubscriptionRenewed(SubscriptionModel subscription) {
    _eventBus.emit(
      PaymentEvent(
        type: PaymentEventTypes.subscriptionRenewed,
        data: {
          'subscription_id': subscription.id,
          'renewal_date': subscription.expirationDate,
        },
      ),
    );
  }
}
