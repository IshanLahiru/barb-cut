import 'package:flutter/material.dart';
import 'package:barbcut/models/subscription_model.dart';

/// Extension methods for SubscriptionModel
extension SubscriptionModelExt on SubscriptionModel {
  /// Check if subscription is expiring soon (within 7 days)
  bool get expiringsSoon {
    if (expirationDate == null) return false;
    final daysRemaining = expirationDate!.difference(DateTime.now()).inDays;
    return daysRemaining > 0 && daysRemaining <= 7;
  }

  /// Get days remaining until expiration
  int get daysRemaining {
    if (expirationDate == null) return -1;
    return expirationDate!.difference(DateTime.now()).inDays;
  }

  /// Get percentage of remaining time (as decimal 0-1)
  double get remainingPercentage {
    if (expirationDate == null || !isActive) return 0;
    // Assuming 30 day period, calculate percentage remaining
    final remaining = daysRemaining;
    return remaining > 0 ? (remaining / 30).clamp(0, 1) : 0;
  }

  /// Get formatted remaining time string
  String get formattedRemaining {
    if (!isActive) return 'Inactive';
    if (expirationDate == null) return 'Eternal';

    final days = daysRemaining;
    if (days < 0) return 'Expired';
    if (days == 0) return 'Expires today';
    if (days == 1) return 'Expires tomorrow';
    if (days <= 7) return 'Expires in $days days';
    return 'Active';
  }

  /// Get appropriate color for status
  Color get statusColor {
    if (!isActive) return Colors.grey;
    if (daysRemaining < 0) return Colors.red;
    if (daysRemaining <= 7) return Colors.orange;
    return Colors.green;
  }
}

/// Extension methods for CustomerInfo
extension CustomerInfoExt on CustomerInfo {
  /// Get active subscriptions only
  List<SubscriptionModel> get activeSubscriptions {
    return subscriptions.where((sub) => sub.isActive).toList();
  }

  /// Get expiring soon subscriptions
  List<SubscriptionModel> get expiringSoonSubscriptions {
    return subscriptions.where((sub) => sub.expiringsSoon).toList();
  }

  /// Get expired subscriptions
  List<SubscriptionModel> get expiredSubscriptions {
    return subscriptions
        .where((sub) => !sub.isActive || (sub.daysRemaining < 0))
        .toList();
  }

  /// Check if any subscription needs attention
  bool get needsAttention {
    return expiringSoonSubscriptions.isNotEmpty ||
        expiredSubscriptions.isNotEmpty;
  }

  /// Get the subscription with closest expiration date
  SubscriptionModel? get nextExpiringSubscription {
    if (activeSubscriptions.isEmpty) return null;
    return activeSubscriptions.reduce((a, b) {
      if (a.expirationDate == null) return b;
      if (b.expirationDate == null) return a;
      return a.expirationDate!.isBefore(b.expirationDate!) ? a : b;
    });
  }
}

/// Extension methods for PackageModel
extension PackageModelExt on PackageModel {
  /// Get monthly price (convert annual to monthly if needed)
  double get monthlyPrice {
    if (billingPeriod.contains('P1Y') || billingPeriod.contains('ANNUAL')) {
      return price / 12;
    }
    return price;
  }

  /// Get human readable period
  String get readablePeriod {
    if (billingPeriod.contains('P1Y')) return 'per year';
    if (billingPeriod.contains('P1M')) return 'per month';
    if (billingPeriod.contains('P1W')) return 'per week';
    return billingPeriod;
  }

  /// Check if has intro price
  bool get hasIntroPrice {
    return introPrice.isNotEmpty;
  }

  /// Get savings if applicable
  String? get monthlySavings {
    if (!billingPeriod.contains('P1Y')) return null;
    final monthlyPrice = (price / 12).toStringAsFixed(2);
    return 'Save vs monthly: only \$${(double.parse(monthlyPrice)).toStringAsFixed(2)}/mo';
  }
}
