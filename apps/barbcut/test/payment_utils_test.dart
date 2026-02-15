import 'package:flutter_test/flutter_test.dart';
import 'package:barbcut/utils/payment_validator.dart';
import 'package:barbcut/utils/payment_formatter.dart';
import 'package:barbcut/models/subscription_model.dart';

void main() {
  group('PaymentValidator', () {
    test('isSubscriptionActive returns true for active subscription', () {
      final subscription = SubscriptionModel(
        id: 'monthly',
        title: 'Monthly Plan',
        description: 'Monthly subscription',
        price: 9.99,
        currencyCode: 'USD',
        billingPeriod: 'MONTHLY',
        isActive: true,
        expirationDate: DateTime.now().add(const Duration(days: 30)),
      );

      expect(PaymentValidator.isSubscriptionActive(subscription), true);
    });

    test('isSubscriptionActive returns false for expired subscription', () {
      final subscription = SubscriptionModel(
        id: 'monthly',
        title: 'Monthly Plan',
        description: 'Monthly subscription',
        price: 9.99,
        currencyCode: 'USD',
        billingPeriod: 'MONTHLY',
        isActive: true,
        expirationDate: DateTime.now().subtract(const Duration(days: 1)),
      );

      expect(PaymentValidator.isSubscriptionActive(subscription), false);
    });

    test('isPackageValid returns true for valid package', () {
      final package = PackageModel(
        identifier: 'monthly_package',
        title: 'Monthly Plan',
        description: 'Monthly subscription',
        price: 9.99,
        currencyCode: 'USD',
        introPrice: 'Free for 7 days',
        billingPeriod: 'P1M',
      );

      expect(PaymentValidator.isPackageValid(package), true);
    });

    test('getSubscriptionStatus returns correct status', () {
      final activeSubscription = SubscriptionModel(
        id: 'monthly',
        title: 'Monthly Plan',
        description: 'Monthly subscription',
        price: 9.99,
        currencyCode: 'USD',
        billingPeriod: 'MONTHLY',
        isActive: true,
        expirationDate: DateTime.now().add(const Duration(days: 30)),
      );

      expect(
        PaymentValidator.getSubscriptionStatus(activeSubscription),
        SubscriptionStatus.active,
      );
    });
  });

  group('PaymentFormatter', () {
    test('formatPrice returns correctly formatted price', () {
      final formatted = PaymentFormatter.formatPrice(9.99, 'USD');
      expect(formatted, 'USD9.99');
    });

    test('formatBillingPeriod returns human readable period', () {
      expect(PaymentFormatter.formatBillingPeriod('MONTHLY'), 'Monthly');
      expect(PaymentFormatter.formatBillingPeriod('ANNUAL'), 'Annual');
      expect(PaymentFormatter.formatBillingPeriod('P1M'), 'Monthly');
      expect(PaymentFormatter.formatBillingPeriod('P1Y'), 'Annual');
    });

    test('formatExpirationDate returns formatted date string', () {
      final date = DateTime(2026, 3, 15);
      expect(PaymentFormatter.formatExpirationDate(date), '3/15/2026');
    });

    test('getSubscriptionDaysRemaining calculates days correctly', () {
      final futureDate = DateTime.now().add(const Duration(days: 5));
      final daysRemaining =
          PaymentFormatter.getSubscriptionDaysRemaining(futureDate);
      expect(daysRemaining, greaterThanOrEqualTo(4));
      expect(daysRemaining, lessThanOrEqualTo(5));
    });
  });
}
