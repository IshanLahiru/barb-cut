/// Payment exception classes for proper error handling

class PaymentException implements Exception {
  final String message;
  final dynamic originalException;

  PaymentException(this.message, [this.originalException]);

  @override
  String toString() => 'PaymentException: $message';
}

class PurchaseFailedException extends PaymentException {
  final String packageId;

  PurchaseFailedException(this.packageId, String message, [dynamic exception])
      : super(message, exception);

  @override
  String toString() => 'PurchaseFailedException: $message (Package: $packageId)';
}

class RestorePurchasesFailedException extends PaymentException {
  RestorePurchasesFailedException(String message, [dynamic exception])
      : super(message, exception);

  @override
  String toString() => 'RestorePurchasesFailedException: $message';
}

class RevenueCatInitializationException extends PaymentException {
  RevenueCatInitializationException(String message, [dynamic exception])
      : super(message, exception);

  @override
  String toString() => 'RevenueCatInitializationException: $message';
}

class CustomerInfoFetchException extends PaymentException {
  CustomerInfoFetchException(String message, [dynamic exception])
      : super(message, exception);

  @override
  String toString() => 'CustomerInfoFetchException: $message';
}

class PackagesFetchException extends PaymentException {
  PackagesFetchException(String message, [dynamic exception])
      : super(message, exception);

  @override
  String toString() => 'PackagesFetchException: $message';
}

class InvalidPackageException extends PaymentException {
  final String packageId;

  InvalidPackageException(this.packageId, String message, [dynamic exception])
      : super(message, exception);

  @override
  String toString() => 'InvalidPackageException: $message (Package: $packageId)';
}

class NetworkException extends PaymentException {
  NetworkException(String message, [dynamic exception])
      : super(message, exception);

  @override
  String toString() => 'NetworkException: $message';
}

class TimeoutException extends PaymentException {
  final Duration timeout;

  TimeoutException(this.timeout, String message, [dynamic exception])
      : super(message, exception);

  @override
  String toString() =>
      'TimeoutException: $message (Timeout: ${timeout.inSeconds}s)';
}
