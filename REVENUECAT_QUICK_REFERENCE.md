# RevenueCat SDK - Quick Reference

Quick lookup guide for RevenueCat implementation in BarbCut.

## File Locations

```
lib/
├── services/
│   ├── revenue_cat_service.dart       # Core SDK wrapper
│   └── subscription_service.dart      # Business logic layer
├── controllers/
│   └── subscription_controller.dart   # State management (Provider)
└── widgets/
    ├── custom_paywall_widget.dart     # Custom paywall UI
    ├── revenue_cat_paywall_widget.dart # RevenueCat paywall
    ├── entitlement_widgets.dart       # Pro feature widgets
    └── customer_center_widget.dart    # Subscription management
```

## API Reference

### RevenueCatService (Core SDK)

**Singleton Service**
```dart
final service = RevenueCatService();
```

**Main Methods**
```dart
// Initialization
await RevenueCatService().initialize();

// User Management
await service.setCustomerId(userId);
await service.logout();

// Product Info
Offerings? offerings = await service.getOfferings();
List<Package> packages = await service.getPackages();
Package? package = await service.getPackage('monthly');

// Purchasing
CustomerInfo? info = await service.purchasePackage(package);

// Entitlements
bool hasPro = service.hasProAccess();
EntitlementInfo? entitlement = service.getProEntitlement();
List<String> active = service.getActiveEntitlements();

// Customer Info
PurchasesUserInfo? userInfo = service.userInfo;
await service.refreshCustomerInfo();
await service.restorePurchases();

// Dates
DateTime? renewalDate = service.getProRenewalDate();
bool inTrial = service.isProInTrial();
```

### SubscriptionService (Business Logic)

**Singleton Service**
```dart
final service = SubscriptionService();
```

**Main Methods**
```dart
// Status
SubscriptionStatus status = await service.getSubscriptionStatus();
bool canAccess = await service.canAccessPro();

// Products
List<AvailableProduct> products = await service.getAvailableProducts();
AvailableProduct? product = await service.getProduct('monthly');

// Purchasing
PurchaseResult result = await service.purchaseProduct('monthly');

// Account
await service.setUserId(userId);
await service.logout();
await service.restorePurchases();
```

### SubscriptionController (Provider)

**Usage in widgets**
```dart
Consumer<SubscriptionController>(
  builder: (context, ctrl, _) {
    // Access subscription data
  },
)
```

**Key Properties**
```dart
// Status
SubscriptionStatus? subscriptionStatus
List<AvailableProduct> availableProducts
bool hasProAccess
bool isSubscriptionActive
bool isInTrial

// UI State
bool isLoading
bool isPurchasing
String? errorMessage
String? successMessage
```

**Key Methods**
```dart
// Initialization
await controller.initialize();

// Loading Data
await controller.loadSubscriptionStatus();
await controller.loadAvailableProducts();

// Purchasing
await controller.purchasePackage('monthly');

// Account
await controller.setUserId(userId);
await controller.logout();
await controller.restorePurchases();

// Messages
controller.clearError();
controller.clearSuccess();
```

## Common UI Patterns

### Check Pro Access

```dart
if (subscriptionCtrl.hasProAccess) {
  // Show pro content
} else {
  // Show free content
}
```

### Wrap Pro Features

```dart
ProFeatureWidget(
  child: ProContent(),
  onUpgradeRequired: () => showPaywall(context),
)
```

### Show Paywall

```dart
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  builder: (context) => DraggableScrollableSheet(
    expand: false,
    builder: (context, controller) => CustomPaywallWidget(),
  ),
);
```

### Display Products

```dart
ListView.builder(
  itemCount: subscriptionCtrl.availableProducts.length,
  itemBuilder: (context, index) {
    final product = subscriptionCtrl.availableProducts[index];
    return ProductTile(
      product: product,
      onPurchase: () => subscriptionCtrl.purchasePackage(
        product.identifier,
      ),
    );
  },
)
```

## Entitlement Widgets

### ProFeatureWidget
Shows content only if user has pro access, otherwise prompts upgrade

```dart
ProFeatureWidget(child: AdvancedFeature())
```

### EntitlementBuilder
Conditional rendering based on pro access

```dart
EntitlementBuilder(
  proBuilder: (ctx) => ProVersion(),
  freeBuilder: (ctx) => FreeVersion(),
)
```

### ProBadge
Badge indicating pro-only feature

```dart
ProBadge(label: 'Pro')
```

### ProActionButton
Button that shows paywall if not pro

```dart
ProActionButton(
  label: 'Unlock',
  onPressed: handleAction,
)
```

### FeatureLockOverlay
Overlay for locked features

```dart
FeatureLockOverlay(
  isLocked: !hasProAccess,
  child: LockedFeature(),
)
```

### SubscriptionStatusBanner
Shows subscription status/expiration warning

```dart
SubscriptionStatusBanner()
```

## Configuration

### API Key
Location: `revenue_cat_service.dart`
```dart
static const String _apiKey = 'test_ZganEtcwwIUiOsXPGkyoiEYxzJP';
```

### Entitlement ID
Location: `revenue_cat_service.dart`
```dart
static const String _proEntitlementId = 'BarbCut Pro';
```

### Product IDs
Location: `revenue_cat_service.dart`
```dart
static const String _monthlyProductId = 'monthly';
static const String _yearlyProductId = 'yearly';
```

## Error Handling

```dart
Consumer<SubscriptionController>(
  builder: (context, ctrl, _) {
    if (ctrl.errorMessage != null) {
      return ErrorBanner(message: ctrl.errorMessage!);
    }
    if (ctrl.isLoading) {
      return LoadingSpinner();
    }
    return SuccessContent();
  },
)
```

## Best Practices

✅ Do This
- Always check `isLoading` before showing content
- Handle `errorMessage` and show user-friendly errors
- Initialize `SubscriptionController` early in app lifecycle
- Link user ID with `setUserId()` after authentication
- Call `refreshCustomerInfo()` when subscription might have changed
- Show paywall when accessing pro features
- Test on real devices with sandbox accounts

❌ Don't Do This
- Don't initialize RevenueCat multiple times
- Don't show paywall on every screen load
- Don't assume purchase succeeded without checking status
- Don't hide error messages from users
- Don't assume network is always available
- Don't store API keys in version control
- Don't use real API key in development

## Testing Checklist

- [ ] Install packages successfully
- [ ] RevenueCat initializes without errors
- [ ] User ID is set on authentication
- [ ] Products load and display
- [ ] Can tap to purchase
- [ ] Purchase flow completes
- [ ] Entitlements update correctly
- [ ] Pro features unlock
- [ ] Paywall dismisses properly
- [ ] Error handling works
- [ ] Loading states display
- [ ] Restore purchases works

## Integration Steps

1. ✅ Install packages
2. ✅ Create RevenueCatService
3. ✅ Create SubscriptionService
4. ✅ Create SubscriptionController
5. ✅ Create paywall widgets  
6. ✅ Create entitlement widgets
7. ✅ Create customer center widget
8. ✅ Update main.dart
9. ⬜ Configure RevenueCat dashboard
10. ⬜ Configure app stores
11. ⬜ Create test accounts
12. ⬜ Test on real devices
13. ⬜ Update to production API key

## Troubleshooting

### Products Not Loading
```dart
// Force reload
await subscriptionCtrl.loadAvailableProducts();

// Check for errors
if (subscriptionCtrl.errorMessage != null) {
  debugPrint(subscriptionCtrl.errorMessage);
}
```

### Purchase Not Working
1. Check products configured in app stores
2. Ensure test account is set up
3. Check network connectivity
4. Verify bundle ID matches

### Entitlements Not Updating
```dart
// Force refresh after purchase
await subscriptionCtrl.loadSubscriptionStatus();
```

### User ID Not Set
```dart
// Ensure called after authentication
await subscriptionCtrl.setUserId(user.uid);
```

## Resources

- [Guides](../REVENUECAT_INTEGRATION_GUIDE.md) - Full integration guide
- [Examples](../REVENUECAT_EXAMPLES.md) - Code examples
- [Dashboard Config](../REVENUECAT_DASHBOARD_CONFIG.md) - Dashboard setup
- [RevenueCat Docs](https://www.revenuecat.com/docs)

## Support

For issues or questions:
1. Check error messages in console
2. Review integration guide
3. Check examples for similar use case
4. Contact RevenueCat support
