import 'package:barbcut/models/subscription_model.dart';

class PaymentFormatter {
  /// Formats price with currency
  static String formatPrice(double price, String currencyCode) {
    return '$currencyCode${price.toStringAsFixed(2)}';
  }

  /// Formats subscription period for display
  static String formatBillingPeriod(String period) {
    switch (period.toUpperCase()) {
      case 'MONTHLY':
      case 'P1M':
        return 'Monthly';
      case 'ANNUAL':
      case 'P1Y':
        return 'Annual';
      case 'WEEKLY':
      case 'P1W':
        return 'Weekly';
      default:
        return period;
    }
  }

  /// Formats subscription expires date
  static String formatExpirationDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  /// Gets subscription duration in days
  static int getSubscriptionDaysRemaining(DateTime? expirationDate) {
    if (expirationDate == null) return -1;
    return expirationDate.difference(DateTime.now()).inDays;
  }

  /// Formats subscription duration
  static String formatSubscriptionDuration(String period) {
    if (period.contains('P1Y')) {
      return '1 Year';
    } else if (period.contains('P1M')) {
      return '1 Month';
    } else if (period.contains('P1W')) {
      return '1 Week';
    } else if (period.contains('P3M')) {
      return '3 Months';
    } else if (period.contains('P6M')) {
      return '6 Months';
    }
    return period;
  }

  /// Formats subscription status message
  static String formatSubscriptionStatus(SubscriptionModel subscription) {
    if (!subscription.isActive) {
      return 'Inactive';
    }

    if (subscription.expirationDate != null) {
      final daysRemaining = getSubscriptionDaysRemaining(
        subscription.expirationDate,
      );

      if (daysRemaining < 0) {
        return 'Expired on ${formatExpirationDate(subscription.expirationDate!)}';
      } else if (daysRemaining == 0) {
        return 'Expires today';
      } else if (daysRemaining == 1) {
        return 'Expires tomorrow';
      } else if (daysRemaining <= 7) {
        return 'Expires in $daysRemaining days';
      } else {
        return 'Active until ${formatExpirationDate(subscription.expirationDate!)}';
      }
    }

    return 'Active';
  }

  /// Formats package discount info
  static String formatDiscount(double originalPrice, double discountedPrice) {
    final discountPercent =
        ((originalPrice - discountedPrice) / originalPrice * 100)
            .toStringAsFixed(0);
    return 'Save $discountPercent%';
  }

  /// Formats intro offer
  static String formatIntroOffer(double introPrice, String introPeriod) {
    return 'Starting at \$$introPrice for $introPeriod';
  }
}
