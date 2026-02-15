# RevenueCat SDK Integration Guide for BarbCut

Complete implementation guide for RevenueCat subscription management in the BarbCut Flutter app.

## Overview

RevenueCat is integrated to manage subscriptions with the following components:

- **RevenueCatService**: Core SDK initialization and RevenueCat API calls
- **SubscriptionService**: High-level business logic for subscriptions
- **SubscriptionController**: Provider for managing subscription state in UI
- **Custom Paywall Widget**: Beautiful subscription UI
- **Entitlement Checking Widgets**: Tools for conditional feature access
- **Customer Center**: User subscription management interface

## Configuration

### API Key
- Production Key: `test_ZganEtcwwIUiOsXPGkyoiEYxzJP` (Test key)
- Update to production key before release
- Location: `lib/services/revenue_cat_service.dart`

### Entitlements
- **Entitlement ID**: `BarbCut Pro`
- Used to check pro feature access

### Products
- **monthly** - Monthly subscription
- **yearly** - Yearly subscription

## Architecture

```
UI Layer (Widgets)
    ↓
SubscriptionController (Provider)
    ↓
SubscriptionService (Business Logic)
    ↓
RevenueCatService (SDK Wrapper)
    ↓
RevenueCat SDK
```

## Usage Examples

### 1. Check Pro Access

```dart
// In a widget
Consumer<SubscriptionController>(
  builder: (context, subscriptionCtrl, _) {
    if (subscriptionCtrl.hasProAccess) {
      // Show pro features
    } else {
      // Show paywall or free features
    }
  },
)
```

### 2. Show Paywall

**Option A: Custom Paywall**
```dart
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  builder: (context) => DraggableScrollableSheet(
    expand: false,
    builder: (context, controller) => CustomPaywallWidget(
      onDismiss: () => Navigator.of(context).pop(),
    ),
  ),
);
```

**Option B: RevenueCat Paywall**
```dart
// Configure in RevenueCat dashboard first
showPaywallModal(context);
```

### 3. Wrap Pro Features

Use `ProFeatureWidget` to automatically show paywall for locked features:

```dart
ProFeatureWidget(
  child: MyProFeature(),
)
```

Or use `EntitlementBuilder` for conditional rendering:

```dart
EntitlementBuilder(
  proBuilder: (context) => ProFeatureWidget(),
  freeBuilder: (context) => FreeFeatureWidget(),
)
```

### 4. Pro-Only Buttons

```dart
ProActionButton(
  label: 'Unlock Advanced Features',
  icon: Icons.star,
  onPressed: () {
    // Handle pro action
  },
)
```

### 5. Subscription Status

```dart
Consumer<SubscriptionController>(
  builder: (context, subscriptionCtrl, _) {
    final status = subscriptionCtrl.subscriptionStatus;
    
    if (status != null) {
      print('Active: ${status.isActive}');
      print('Days until renewal: ${status.getDaysUntilExpiration()}');
      print('In trial: ${status.isInTrial}');
    }
  },
)
```

### 6. Manage Subscription (Customer Center)

```dart
// In settings page
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  builder: (context) => DraggableScrollableSheet(
    expand: false,
    builder: (context, controller) => CustomerCenterWidget(),
  ),
);
```

Or use the subscription settings section:

```dart
SubscriptionSettingsSection()
```

### 7. Purchase a Package

```dart
Consumer<SubscriptionController>(
  builder: (context, subscriptionCtrl, _) {
    return ElevatedButton(
      onPressed: () {
        subscriptionCtrl.purchasePackage('monthly');
      },
      child: const Text('Subscribe Monthly'),
    );
  },
)
```

### 8. Restore Purchases

```dart
Consumer<SubscriptionController>(
  builder: (context, subscriptionCtrl, _) {
    return TextButton(
      onPressed: () => subscriptionCtrl.restorePurchases(),
      child: const Text('Restore Purchases'),
    );
  },
)
```

## Best Practices

### 1. Initialize Subscriptions Early

Already handled in `main.dart`:
```dart
// RevenueCat initializes before app runs
await _initializeRevenueCat();
```

### 2. Link Authentication

Automatically handled when user authenticates:
```dart
// In MyAppState.build():
if (snapshot.hasData) {
  // RevenueCat user ID is set automatically
  await subscriptionCtrl.setUserId(user.uid);
}
```

### 3. Error Handling

Always check for errors from RevenueCat:

```dart
Consumer<SubscriptionController>(
  builder: (context, subscriptionCtrl, _) {
    if (subscriptionCtrl.errorMessage != null) {
      return ErrorBanner(message: subscriptionCtrl.errorMessage!);
    }
    return YourContent();
  },
)
```

### 4. Loading States

```dart
Consumer<SubscriptionController>(
  builder: (context, subscriptionCtrl, _) {
    if (subscriptionCtrl.isLoading) {
      return const CircularProgressIndicator();
    }
    return YourContent();
  },
)
```

### 5. Refresh Subscription Status

Call when you suspect changes:

```dart
// After purchase, logout, etc.
await subscriptionCtrl.loadSubscriptionStatus();
```

### 6. Handle Trial Expiration

```dart
SubscriptionStatusBanner() // Shows warning if expiring soon
```

## Integration Checklist

- [x] Install RevenueCat packages
- [x] Create RevenueCatService (SDK wrapper)
- [x] Create SubscriptionService (business logic)
- [x] Create SubscriptionController (state management)
- [x] Create paywall UI widgets
- [x] Create entitlement checking widgets
- [x] Create customer center widget
- [x] Initialize in main.dart
- [x] Link with Firebase Auth
- [ ] Configure offerings in RevenueCat dashboard
- [ ] Set up Apple App Store billing
- [ ] Set up Google Play billing
- [ ] Test on iOS device/simulator
- [ ] Test on Android device/emulator
- [ ] Migration to production API key

## API Key Management

### Current Setup
Using test API key: `test_ZganEtcwwIUiOsXPGkyoiEYxzJP`

### Before Release
1. Create project in RevenueCat dashboard
2. Configure offerings and products
3. Set up Apple App Store and Google Play connections
4. Get production API key
5. Update in `revenue_cat_service.dart`:
   ```dart
   static const String _apiKey = 'YOUR_PRODUCTION_API_KEY';
   ```

## Testing

### Test Subscriptions

Use RevenueCat sandbox/test mode:

```dart
// All purchases in test mode are free
// No real charges occur
```

### Manual Testing

1. **Purchase Flow**
   - Open paywall
   - Select package
   - Complete purchase
   - Verify hasProAccess = true

2. **Restoration**
   - Purchase subscription
   - Uninstall/reinstall app
   - Tap "Restore Purchases"
   - Verify subscription restored

3. **Entitlement Checking**
   - Lock features behind `ProFeatureWidget`
   - Verify locked until purchased
   - Unlock and verify access

## Troubleshooting

### RevenueCat Not Initializing
- Check API key is correct
- Ensure internet connection
- Check iOS/Android SDK configurations

### Purchases Not Working
- Verify offerings configured in RevenueCat
- Check product IDs match configuration
- Ensure test account on test sandbox

### Customer Info Not Updating
- Call `loadSubscriptionStatus()` after changes
- Check network connectivity
- Verify user authentication

## File Structure

```
lib/
├── services/
│   ├── revenue_cat_service.dart      # RevenueCat SDK wrapper
│   └── subscription_service.dart     # Business logic
├── controllers/
│   └── subscription_controller.dart  # State management
└── widgets/
    ├── custom_paywall_widget.dart    # Custom paywall UI
    ├── revenue_cat_paywall_widget.dart # RevenueCat paywall
    ├── entitlement_widgets.dart      # Pro feature widgets
    └── customer_center_widget.dart   # Subscription management
```

## Next Steps

1. **Configure RevenueCat Dashboard**
   - Create offerings
   - Set up products (monthly, yearly)
   - Configure Apple/Google connections

2. **iOS Configuration**
   - Add StoreKit capabilities
   - Configure signing

3. **Android Configuration**
   - Configure Google Play billing

4. **Testing**
   - Test on real devices
   - Test all purchase flows

5. **Production Launch**
   - Update to production API key
   - Configure production offerings
   - Submit to app stores

## Additional Resources

- [RevenueCat Docs](https://www.revenuecat.com/docs)
- [RevenueCat Flutter SDK](https://www.revenuecat.com/docs/getting-started/installation/flutter)
- [RevenueCat Paywalls](https://www.revenuecat.com/docs/tools/paywalls)
- [RevenueCat Customer Center](https://www.revenuecat.com/docs/tools/customer-center)
