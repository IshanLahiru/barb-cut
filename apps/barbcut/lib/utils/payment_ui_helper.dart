import 'package:flutter/material.dart';
import 'package:barbcut/models/subscription_model.dart';
import 'package:barbcut/utils/payment_formatter.dart';

/// Payment UI helper for building premium feature widgets
class PaymentUIHelper {
  /// Build subscription status widget
  static Widget buildSubscriptionStatus(SubscriptionModel subscription) {
    final statusColor = _getStatusColor(subscription);
    final statusText = PaymentFormatter.formatSubscriptionStatus(subscription);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getStatusIcon(subscription), color: statusColor, size: 16),
          const SizedBox(width: 6),
          Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  /// Build price display widget
  static Widget buildPriceDisplay(PackageModel package) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '\$${package.price.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          package.billingPeriod.toLowerCase(),
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        if (package.introPrice.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              package.introPrice,
              style: TextStyle(
                fontSize: 12,
                color: Colors.green[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  /// Build feature list widget
  static Widget buildFeatureList(List<String> features) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: features
          .map(
            (feature) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 18),
                  const SizedBox(width: 10),
                  Expanded(child: Text(feature)),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  /// Get status color based on subscription state
  static Color _getStatusColor(SubscriptionModel subscription) {
    if (!subscription.isActive) return Colors.grey;
    if (subscription.expirationDate != null) {
      final daysRemaining = subscription.expirationDate!
          .difference(DateTime.now())
          .inDays;
      if (daysRemaining < 0) return Colors.red;
      if (daysRemaining <= 7) return Colors.orange;
    }
    return Colors.green;
  }

  static IconData _getStatusIcon(SubscriptionModel subscription) {
    if (!subscription.isActive) return Icons.block;
    if (subscription.expirationDate != null) {
      final daysRemaining = subscription.expirationDate!
          .difference(DateTime.now())
          .inDays;
      if (daysRemaining < 0) return Icons.error;
      if (daysRemaining <= 7) return Icons.warning;
    }
    return Icons.check_circle;
  }
}
