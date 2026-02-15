import 'package:flutter/foundation.dart';

class PaymentEvent {
  final String type;
  final DateTime timestamp;
  final Map<String, dynamic> data;

  PaymentEvent({required this.type, required this.data})
    : timestamp = DateTime.now();

  @override
  String toString() =>
      'PaymentEvent(type: $type, timestamp: $timestamp, data: $data)';
}

class PaymentEventBus {
  static final PaymentEventBus _instance = PaymentEventBus._internal();

  final ValueNotifier<List<PaymentEvent>> _events = ValueNotifier([]);
  final List<Function(PaymentEvent)> _listeners = [];

  factory PaymentEventBus() {
    return _instance;
  }

  PaymentEventBus._internal();

  ValueNotifier<List<PaymentEvent>> get events => _events;

  void subscribe(Function(PaymentEvent) listener) {
    _listeners.add(listener);
  }

  void unsubscribe(Function(PaymentEvent) listener) {
    _listeners.remove(listener);
  }

  void emit(PaymentEvent event) {
    _events.value = [..._events.value, event];
    for (var listener in _listeners) {
      listener(event);
    }
    debugPrint('Payment Event: ${event.type} - ${event.data}');
  }

  void clear() {
    _events.value = [];
  }

  List<PaymentEvent> getEventsByType(String type) {
    return _events.value.where((event) => event.type == type).toList();
  }
}

// Event type constants
class PaymentEventTypes {
  static const String purchaseInitiated = 'purchase_initiated';
  static const String purchaseCompleted = 'purchase_completed';
  static const String purchaseFailed = 'purchase_failed';
  static const String restoreInitiated = 'restore_initiated';
  static const String restoreCompleted = 'restore_completed';
  static const String subscriptionActive = 'subscription_active';
  static const String subscriptionExpired = 'subscription_expired';
  static const String subscriptionRenewed = 'subscription_renewed';
}
