# RevenueCat Payments Integration

This document describes the RevenueCat payments implementation for the BarBcut app.

## Overview

The app uses RevenueCat to manage in-app subscriptions and purchases. RevenueCat provides a backend for implementing and managing iOS, Android, and web subscriptions.

## Architecture

### Key Components

1. **RevenueCatService** (`services/revenuecat_service.dart`)
   - Core service for interacting with RevenueCat SDK
   - Handles initialization, package fetching, purchases, and customer info
   - Singleton pattern for single instance across app

2. **PaymentController** (`controllers/payment_controller.dart`)
   - ChangeNotifier-based state management
   - Provides UI-friendly interface to payment operations
   - Manages loading states and errors

3. **PaymentBloc** (`core/payment_bloc.dart`)
   - BLoC pattern for complex payment workflows
   - Handles events and state transitions
   - Used for advanced scenarios

4. **Models**
   - `SubscriptionModel`: Active subscriptions
   - `CustomerInfo`: Customer subscription information
   - `PackageModel`: Available packages for purchase

### Views

1. **PaywallScreen** (`views/paywall_screen.dart`)
   - Displays available subscription packages
   - Handles purchase initiation
   - Shows premium benefits

2. **SubscriptionManagementScreen** (`views/subscription_management_screen.dart`)
   - Shows active subscriptions
   - Allows subscription management
   - Displays renewal information

### Utilities

1. **PaymentValidator** (`utils/payment_validator.dart`)
   - Validates subscriptions, packages, and customer info
   - Determines subscription status

2. **PaymentFormatter** (`utils/payment_formatter.dart`)
   - Formats prices, dates, and subscription periods
   - Provides user-friendly display strings

3. **PaymentConstants** (`utils/payment_constants.dart`)
   - Product IDs and pricing
   - Feature availability by tier
   - UI text constants

4. **PaymentEventBus** (`services/payment_event_bus.dart`)
   - Pub/Sub pattern for payment events
   - Event logging and analytics

5. **PaymentAnalytics** (`services/payment_analytics.dart`)
   - Tracks purchase metrics
   - Subscription analytics
   - Revenue metrics

## Setup Instructions

### 1. Add Dependencies

```yaml
dependencies:
  purchases_flutter: ^7.8.0
```

### 2. RevenueCat Configuration

Update your RevenueCat API key in `revenuecat_service.dart`:

```dart
static const String _apiKey = 'your_revenucat_api_key';
```

### 3. Product Setup

Define your products in the appropriate files:

- `utils/payment_constants.dart` - Product IDs and pricing
- Sync with RevenueCat dashboard

### 4. Initialize in Main

```dart
final paymentController = PaymentController();
await paymentController.initialize();
```

## Usage Examples

### Displaying Paywall

```dart
context.push('/paywall');
```

### Checking Subscription Status

```dart
final controller = Provider.of<PaymentController>(context);
if (controller.hasActiveSubscription) {
  // Show premium content
}
```

### Handling Purchases

```dart
final success = await controller.purchasePackage(package);
if (success) {
  // Show success message
}
```

### Restoring Purchases

```dart
await controller.restorePurchases();
```

## Events

The `PaymentEventBus` emits events for different payment actions:

- `purchase_initiated`
- `purchase_completed`
- `purchase_failed`
- `restore_initiated`
- `restore_completed`
- `subscription_active`
- `subscription_expired`
- `subscription_renewed`

### Listening to Events

```dart
final eventBus = PaymentEventBus();
eventBus.subscribe((event) {
  print('Payment event: ${event.type}');
});
```

## Testing

### Test the Paywall

1. Run the app
2. Navigate to the paywall screen
3. Attempt a purchase (use TestFlight for iOS testing)

### Test Restore Purchases

1. Tap "Restore Purchases" button
2. Verify previous purchases are restored

### Test Entitlements Check

```dart
final customerInfo = await RevenuecatService().fetchCustomerInfo();
if (customerInfo.hasActiveSubscription) {
  // User has active subscription
}
```

## Debugging

Enable debug logging in RevenueCat:

```dart
await Purchases.setLogLevel(LogLevel.debug);
```

View logs in the console to troubleshoot issues.

## Best Practices

1. **Always check for active subscriptions** before showing premium content
2. **Implement restore purchases** for better UX
3. **Handle errors gracefully** with user-friendly messages
4. **Track analytics** for business insights
5. **Test thoroughly** on both iOS and Android
6. **Use ProductIds** from constants file consistently

## Common Issues

### Issue: Purchases not appearing

**Solution**: Ensure users are logged in with Apple ID (iOS) or Google Play account (Android)

### Issue: Wrong subscription showing

**Solution**: Check product ID configuration matches RevenueCat dashboard

### Issue: Customer info not updating

**Solution**: Call `refreshCustomerInfo()` after successful purchase

## References

- [RevenueCat Documentation](https://docs.revenuecat.com/)
- [Flutter Plugin](https://pub.dev/packages/purchases_flutter)
