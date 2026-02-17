import 'package:barbcut/models/subscription_model.dart';

/// Adapter for mock RevenueCat responses in testing
class MockPaymentDataAdapter {
  static List<PackageModel> getMockPackages() {
    return [
      PackageModel(
        identifier: 'monthly_subscription',
        title: 'Monthly Haircut Plan',
        description: 'Get unlimited monthly haircuts and consultations',
        price: 9.99,
        currencyCode: 'USD',
        introPrice: 'Free for 7 days',
        billingPeriod: 'P1M',
      ),
      PackageModel(
        identifier: 'annual_subscription',
        title: 'Annual Haircut Plan',
        description: 'Get unlimited yearly service with priority support',
        price: 99.99,
        currencyCode: 'USD',
        introPrice: '50% off first month',
        billingPeriod: 'P1Y',
      ),
    ];
  }

  static CustomerInfo getMockCustomerInfo() {
    return CustomerInfo(
      customerId: 'test_customer_123',
      subscriptions: [
        SubscriptionModel(
          id: 'monthly_subscription',
          title: 'Monthly Haircut Plan',
          description: 'Get unlimited monthly haircuts',
          price: 9.99,
          currencyCode: 'USD',
          billingPeriod: 'MONTHLY',
          isActive: true,
          expirationDate: DateTime.now().add(const Duration(days: 25)),
        ),
      ],
      hasActiveSubscription: true,
      requestDate: DateTime.now(),
    );
  }

  static SubscriptionModel getMockSubscription() {
    return SubscriptionModel(
      id: 'monthly_subscription',
      title: 'Monthly Plan',
      description: 'Monthly subscription plan',
      price: 9.99,
      currencyCode: 'USD',
      billingPeriod: 'MONTHLY',
      isActive: true,
      expirationDate: DateTime.now().add(const Duration(days: 30)),
    );
  }
}
