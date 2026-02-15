# RevenueCat Dashboard Configuration Guide

Step-by-step guide to configure RevenueCat dashboard for BarbCut.

## Prerequisites

1. RevenueCat account created
2. Apple Developer Account
3. Google Play Developer Account
4. Project in RevenueCat dashboard

## Dashboard Setup Steps

### Step 1: Create Products in RevenueCat Dashboard

1. Log in to [RevenueCat Dashboard](https://app.revenuecat.com)
2. Navigate to Products
3. Create two products:

#### Monthly Product
- **Product ID**: `monthly`
- **Display Name**: Monthly Pro
- **Type**: Subscription
- **Prices**: 
  - US: $9.99/month
  - Adjust based on region
- **Trial Period**: 7 days (optional)
- **Billing Cycle**: Monthly

#### Yearly Product
- **Product ID**: `yearly`
- **Display Name**: Yearly Pro
- **Type**: Subscription
- **Prices**: 
  - US: $99.99/year
  - Adjust based on region
- **Trial Period**: 7 days (optional)
- **Billing Cycle**: Yearly

### Step 2: Create Entitlements

1. Navigate to Entitlements
2. Create entitlement:
   - **Entitlement ID**: `BarbCut Pro`
   - **Display Name**: BarbCut Pro

### Step 3: Create Offering

1. Navigate to Offering
2. Create offering:
   - **Offering ID**: `default`
   - **Display Name**: Default
   - **Description**: Default offering for BarbCut

3. Add Products to Offering:
   - Add both `monthly` and `yearly` products
   - Set monthly as first option

4. Link to Entitlements:
   - Both products → `BarbCut Pro` entitlement

### Step 4: Configure App Store Integration

#### iOS Setup

1. In RevenueCat Dashboard:
   - Go to Apps
   - Select iOS
   - Navigate to App Store Configuration

2. Enter Shared Secret:
   - Go to Apple App Store Connect
   - Apps > BarbCut
   - App Information > App Shared Secret
   - Copy and paste into RevenueCat

3. Enter App Bundle ID:
   - `com.barbcut.app` (or your actual bundle ID)

#### Android Setup

1. In RevenueCat Dashboard:
   - Go to Apps
   - Select Android
   - Navigate to Google Play Configuration

2. Create Service Account:
   - Go to Google Cloud Console
   - Create new project or select existing
   - Create Service Account
   - Create key (JSON format)
   - Download key

3. Add Service Account JSON:
   - In RevenueCat, upload the JSON file
   - Or paste the service account email

4. Enter Package Name:
   - `com.barbcut.app` (or your actual package name)

### Step 5: Configure Products in App Stores

#### iOS Products

1. Go to App Store Connect
2. Go to In-App Purchases
3. Create two subscriptions:

**Monthly Subscription**
- Reference Name: `monthly`
- Product ID: `com.barbcut.app.monthly`
- Subscription Duration: Monthly
- Free Trial: 7 Days (optional)
- Price: $9.99

**Yearly Subscription**
- Reference Name: `yearly`
- Product ID: `com.barbcut.app.yearly`
- Subscription Duration: Annual
- Free Trial: 7 Days (optional)
- Price: $99.99

#### Google Play Products

1. Go to Google Play Console
2. Go to Products > Subscriptions
3. Create two subscriptions:

**Monthly Subscription**
- SKU: `monthly`
- Title: Monthly Pro
- Billing Period: Monthly
- Default Price: $9.99

**Yearly Subscription**
- SKU: `yearly`
- Title: Yearly Pro
- Billing Period: Annual
- Default Price: $99.99

## Configuration in Code

### Check Current Configuration

All configuration is in `lib/services/revenue_cat_service.dart`:

```dart
// API Key
static const String _apiKey = 'test_ZganEtcwwIUiOsXPGkyoiEYxzJP';

// Entitlements
static const String _proEntitlementId = 'BarbCut Pro';

// Product IDs
static const String _monthlyProductId = 'monthly';
static const String _yearlyProductId = 'yearly';
```

### Update to Production

Before release:

1. Get production API key from RevenueCat dashboard
2. Update `_apiKey` in `revenue_cat_service.dart`
3. Ensure all products are configured in app stores
4. Test thoroughly with sandbox accounts

## Environment-Specific Configuration

### Development (Current)
- API Key: Test key
- Products: Test products
- Entitlements: Test entitlements
- Pricing: $0 (test mode)

### Production
- API Key: Production key
- Products: Live products in app stores
- Entitlements: Live entitlements
- Pricing: Real prices

## Testing Configuration

### Test Accounts

#### iOS
1. Go to App Store Connect
2. Users and Access > Sandbox Testers
3. Create test account
   - Email: `test-monthly@example.com`
   - Password: Generate secure password

#### Android
1. Go to Google Play Console
2. Settings > License Testing
3. Add test accounts
   - Use Gmail accounts
   - Should be different from developer account

### Test Devices

#### iOS
1. Add test device to Xcode
2. Run on test device
3. Use test account to make purchases
4. Purchases won't be charged

#### Android
1. Install app on Android device/emulator
2. Add test Gmail account to device
3. Use test account for purchases
4. Purchases won't be charged

## Validation Checklist

- [ ] API Key configured in code
- [ ] Products created in RevenueCat
- [ ] Entitlements created in RevenueCat
- [ ] Offering created and linked
- [ ] iOS products created in App Store Connect
- [ ] Android products created in Google Play
- [ ] App Store shared secret configured
- [ ] Google Play service account configured
- [ ] Test accounts created
- [ ] Products link correctly to entitlements

## Common Issues & Solutions

### Products Not Showing

**Issue**: `availableProducts` returns empty list

**Solutions**:
1. Verify products exist in RevenueCat dashboard
2. Verify offering is configured and published
3. Check API key is correct
4. Ensure products are linked to offering
5. Make sure app bundle ID matches in both places

### Entitlements Not Updating

**Issue**: `hasProAccess` is false after purchase

**Solutions**:
1. Verify products link to entitlements
2. Verify entitlement ID matches in code
3. Call `loadSubscriptionStatus()` after purchase
4. Check network connectivity
5. Verify purchase succeeded (not just initiated)

### Purchases Fail

**Issue**: Purchase returns error or null

**Solutions**:
1. Verify products exist in app store
2. Check test account is valid
3. Verify device network connectivity
4. Check app store configuration
5. Ensure user is authenticated with app store

### Sandbox/Test Mode Issues

**Issue**: Purchases in sandbox but not working

**Solutions**:
1. Ensure using test account on device
2. Clear app cache and reinstall
3. Check test account permissions
4. Verify app store configuration
5. Review RevenueCat logs

## Next Actions

1. **Create RevenueCat Account**
   - Sign up at revenuecat.com
   - Create new project

2. **Set Up Products**
   - Create monthly and yearly products
   - Create BarbCut Pro entitlement
   - Create default offering

3. **Configure App Stores**
   - Set up iOS in App Store Connect
   - Set up Android in Google Play
   - Create products in both stores

4. **Integrate with RevenueCat**
   - Enter shared secret (iOS)
   - Upload service account (Android)
   - Configure in RevenueCat dashboard

5. **Test Configuration**
   - Create test accounts
   - Add test devices
   - Run purchase flow

6. **Go to Production**
   - Update API key
   - Ensure all products configured
   - Submit to app stores

## Resources

- [RevenueCat Official Setup Guide](https://www.revenuecat.com/docs/getting-started)
- [App Store Connect In-App Purchases](https://developer.apple.com/app-store-connect/)
- [Google Play Console](https://play.google.com/console)
- [RevenueCat Dashboard](https://app.revenuecat.com)

## Support

For RevenueCat-specific questions:
- [RevenueCat Docs](https://www.revenuecat.com/docs)
- [Support Chat](https://app.revenuecat.com/support)
- [Community Slack](https://revenuecat.slack.com)
