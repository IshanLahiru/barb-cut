import 'package:barbcut/models/subscription_model.dart';

/// Payment result wrapper for handling success/failure cases
class PaymentResult<T> {
  final T? data;
  final String? error;
  final Exception? exception;
  final bool isSuccess;

  PaymentResult.success(this.data)
      : error = null,
        exception = null,
        isSuccess = true;

  PaymentResult.failure(this.error, {this.exception})
      : data = null,
        isSuccess = false;

  /// Map success to another type
  PaymentResult<U> map<U>(U Function(T) mapper) {
    if (isSuccess && data != null) {
      try {
        return PaymentResult<U>.success(mapper(data as T));
      } catch (e) {
        return PaymentResult<U>.failure('Mapping failed: $e');
      }
    }
    return PaymentResult<U>.failure(error ?? 'Unknown error');
  }

  /// Handle result  with callbacks
  void when({
    required Function(T) onSuccess,
    required Function(String) onError,
  }) {
    if (isSuccess && data != null) {
      onSuccess(data as T);
    } else {
      onError(error ?? 'Unknown error');
    }
  }

  /// Get data or throw exception
  T getOrThrow() {
    if (isSuccess && data != null) {
      return data as T;
    }
    throw Exception(error ?? 'Unknown error');
  }

  /// Get data or return default
  T getOrDefault(T defaultValue) {
    return data ?? defaultValue;
  }
}

/// Purchase result with additional metadata
class PurchaseResult extends PaymentResult<SubscriptionModel> {
  final DateTime timestamp;
  final double amount;
  final String packageId;

  PurchaseResult.success(
    SubscriptionModel subscription, {
    required this.amount,
    required this.packageId,
  })  : timestamp = DateTime.now(),
        super.success(subscription);

  PurchaseResult.failure(
    String error, {
    required this.amount,
    required this.packageId,
  })  : timestamp = DateTime.now(),
        super.failure(error);

  @override
  String toString() =>
      'PurchaseResult(isSuccess: $isSuccess, package: $packageId, amount: \$$amount)';
}

/// Restore result with metadata
class RestoreResult extends PaymentResult<List<SubscriptionModel>> {
  final int subscribedCount;
  final int restoredCount;
  final DateTime timestamp;

  RestoreResult.success(
    List<SubscriptionModel> subscriptions, {
    required this.restoredCount,
  })  : subscribedCount = subscriptions.length,
        timestamp = DateTime.now(),
        super.success(subscriptions);

  RestoreResult.failure(
    String error, {
    this.restoredCount = 0,
  })  : subscribedCount = 0,
        timestamp = DateTime.now(),
        super.failure(error);

  @override
  String toString() =>
      'RestoreResult(isSuccess: $isSuccess, restored: $restoredCount, active: $subscribedCount)';
}
