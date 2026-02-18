/// Payment error codes and messages
class PaymentErrorCode {
  // Purchase errors
  static const int purchaseFailed = 1001;
  static const int purchaseCancelled = 1002;
  static const int purchaseInvalid = 1003;
  static const int purchaseTimeout = 1004;

  // Restore errors
  static const int restoreFailed = 2001;
  static const int restoreCancelled = 2002;
  static const int restoreTimeout = 2003;

  // Customer info errors
  static const int customerInfoFetchFailed = 3001;
  static const int customerInfoTimeout = 3002;

  // Package errors
  static const int packagesFetchFailed = 4001;
  static const int packagesTimeout = 4002;
  static const int invalidPackage = 4003;

  // Network errors
  static const int networkError = 5001;
  static const int networkTimeout = 5002;
  static const int connectionLost = 5003;

  // RevenueCat SDK errors
  static const int sdkInitializationFailed = 6001;
  static const int sdkNotInitialized = 6002;
  static const int sdkError = 6003;

  // Validation errors
  static const int invalidInput = 7001;
  static const int missingData = 7002;

  // Unknown errors
  static const int unknownError = 9999;
}

/// Maps error codes to user-friendly messages
class PaymentErrorMessage {
  static const Map<int, String> messages = {
    // Purchase errors
    PaymentErrorCode.purchaseFailed: 'Purchase failed. Please try again.',
    PaymentErrorCode.purchaseCancelled: 'Purchase was cancelled.',
    PaymentErrorCode.purchaseInvalid:
        'This purchase is no longer available.',
    PaymentErrorCode.purchaseTimeout:
        'Purchase took too long. Please check your internet and try again.',

    // Restore errors
    PaymentErrorCode.restoreFailed:
        'Failed to restore purchases. Please try again.',
    PaymentErrorCode.restoreCancelled: 'Restore was cancelled.',
    PaymentErrorCode.restoreTimeout:
        'Restore took too long. Please check your connection.',

    // Customer info errors
    PaymentErrorCode.customerInfoFetchFailed:
        'Could not fetch subscription info.',
    PaymentErrorCode.customerInfoTimeout:
        'Request timed out. Please check connection.',

    // Package errors
    PaymentErrorCode.packagesFetchFailed:
        'Could not load available plans.',
    PaymentErrorCode.packagesTimeout:
        'Loading plans took too long.',
    PaymentErrorCode.invalidPackage:
        'This plan is not available.',

    // Network errors
    PaymentErrorCode.networkError:
        'Network error. Please check your connection.',
    PaymentErrorCode.networkTimeout:
        'Connection timeout. Please try again.',
    PaymentErrorCode.connectionLost:
        'Internet connection was lost.',

    // RevenueCat SDK errors
    PaymentErrorCode.sdkInitializationFailed:
        'Payment system failed to initialize.',
    PaymentErrorCode.sdkNotInitialized:
        'Payment system is not ready yet.',
    PaymentErrorCode.sdkError:
        'Payment system error occurred.',

    // Validation errors
    PaymentErrorCode.invalidInput: 'Invalid information provided.',
    PaymentErrorCode.missingData: 'Required information is missing.',

    // Unknown errors
    PaymentErrorCode.unknownError: 'An unexpected error occurred.',
  };

  static String getMessage(int errorCode) {
    return messages[errorCode] ?? messages[PaymentErrorCode.unknownError]!;
  }
}
