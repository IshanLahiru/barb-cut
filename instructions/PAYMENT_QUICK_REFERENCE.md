# Payment Integration Quick Reference

## Key Files

### Services
- `lib/services/revenuecat_service.dart` - Main RevenueCat integration
- `lib/services/payment_event_bus.dart` - Event publishing system
- `lib/services/payment_analytics.dart` - Metrics tracking

### Controllers & State Management
- `lib/controllers/payment_controller.dart` - ChangeNotifier controller
- `lib/core/payment_bloc.dart` - BLoC pattern implementation
- `lib/core/payment_repository.dart` - Domain layer abstraction

### Models
- `lib/models/subscription_model.dart` - Data models

### Views & UI
- `lib/views/paywall_screen.dart` - Subscription offerings
- `lib/views/subscription_management_screen.dart` - Subscription management
- `lib/widgets/payment_widgets.dart` - Reusable components

### Utilities
- `lib/utils/payment_validator.dart` - Validation logic
- `lib/utils/payment_formatter.dart` - Display formatting
- `lib/utils/payment_constants.dart` - Configuration

### Domain
- `lib/domain/usecases/payment_usecases.dart` - Business logic use cases

## Quick API Reference

### Initialize Payment System
```dart
final paymentController = PaymentController();
```

### Check Active Subscription
```dart
final hasSubscription = paymentController.hasActiveSubscription;
```

### Show Paywall
```dart
Navigator.push(context, MaterialPageRoute(builder: (_) => PaywallScreen()));
```

### Purchase Package
```dart
final success = await paymentController.purchasePackage(package);
```

### Restore Purchases
```dart
await paymentController.restorePurchases();
```

### Listen to Payment Events
```dart
PaymentEventBus().subscribe((event) {
  print('Payment event: ${event.type}');
});
```

### Track Analytics
```dart
PaymentAnalytics().recordPurchase(packageId, amount);
```

## Product IDs

- `monthly_subscription` - Monthly plan
- `annual_subscription` - Annual plan
- `premium_monthly` - Premium monthly
- `premium_annual` - Premium annual

## Feature Flags by Subscription

### Monthly Plan
- Unlimited consultations
- Monthly trends
- Email support

### Annual Plan
- All monthly features
- Priority support
- Exclusive content

### Premium Plans
- Advanced analytics
- Custom colors
- VIP support

## Testing

```bash
flutter test test/payment_utils_test.dart
```

## Common Issues & Fixes

| Issue | Solution |
|-------|----------|
| Purchases not showing | Ensure user is logged in to App Store/Play Store |
| Old subscriptions showing | Call `refreshCustomerInfo()` |
| Network errors | Check internet connection and retry |
| Invalid product ID | Verify IDs match RevenueCat dashboard |

## Best Practices

1. Always check for active subscriptions before allowing premium features
2. Implement proper error handling with user-friendly messages
3. Use analytics to track conversion and retention
4. Test thoroughly on real devices
5. Implement restore purchases for better UX
6. Monitor RevenueCat logs during development

## Related Files

- [Full Integration Guide](REVENUECAT_INTEGRATION.md)
- [Testing Guide](PAYMENT_TESTING.md)
- [Setup Instructions](REVENUECAT_INTEGRATION.md#setup-instructions)
