# Payment Testing Guide

This guide covers testing for the RevenueCat payment integration in the BarBcut app.

## Unit Tests

### Running Tests

```bash
flutter test test/payment_utils_test.dart
```

### Test Categories

#### PaymentValidator Tests
- `isSubscriptionActive()` - Validates subscription expiration
- `isPackageValid()` - Verifies package integrity
- `getSubscriptionStatus()` - Checks subscription status
- `hasValidSubscriptions()` - Validates subscription list

#### PaymentFormatter Tests
- `formatPrice()` - Currency formatting
- `formatBillingPeriod()` - Period display
- `formatExpirationDate()` - Date formatting
- `getSubscriptionDaysRemaining()` - Duration calculation

## Widget Tests

Test payment UI components:
```bash
flutter test test/payment_widgets_test.dart
```

## Integration Tests

### Test Prerequisites
1. TestFlight access (iOS)
2. Google Play internal testing (Android)
3. RevenueCat sandbox environment

### Running Integration Tests
```bash
flutter drive --target=test_driver/app.dart
```

## Manual Testing Checklist

### Paywall Screen
- [ ] Displays all available packages
- [ ] Package prices show correctly
- [ ] Purchase buttons are responsive
- [ ] Error messages display properly
- [ ] Loading states show correctly

### Subscription Management
- [ ] Shows active subscriptions
- [ ] Displays renewal dates
- [ ] Cancel button works
- [ ] Empty state shows when no subscriptions

### Purchase Flow
- [ ] Purchase initiates successfully
- [ ] Success message displays
- [ ] Subscription updates immediately
- [ ] Customer info refreshes

### Restore Purchases
- [ ] Finds previously purchased subscriptions
- [ ] Updates customer info
- [ ] Shows success/error messages

## Debugging Tips

### Enable RevenueCat Logs
```dart
await Purchases.setLogLevel(LogLevel.debug);
```

### Check Customer Info
```dart
final customerInfo = await Purchases.getCustomerInfo();
print(customerInfo.allPurchasedProductIdentifiers);
```

### Monitor Purchase Events
```dart
PaymentEventBus().subscribe((event) {
  debugPrint('Event: ${event.type}');
  debugPrint('Data: ${event.data}');
});
```

## CI/CD Testing

Test payments in CI pipeline:
```yaml
test:
  stage: test
  script:
    - flutter test
    - flutter test integration_test/
```

## Performance Testing

Monitor payment operation timing:
```dart
final stopwatch = Stopwatch()..start();
await revenuecatService.purchasePackage(package);
print('Purchase took ${stopwatch.elapsedMilliseconds}ms');
```

## Common Issues and Solutions

### Issue: Tests timeout
**Solution**: Increase timeout in integration tests

### Issue: Mock RevenueCat fails
**Solution**: Use actual test API keys

### Issue: Package not found
**Solution**: Verify product IDs match RevenueCat dashboard

## References

- [Flutter Testing Documentation](https://flutter.dev/docs/testing)
- [RevenueCat Testing Guide](https://docs.revenuecat.com/docs/testing)
- [TestFlight Guide](https://developer.apple.com/testflight/)
