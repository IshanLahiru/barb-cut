import 'package:barbcut/models/subscription_model.dart';

/// Provides pre-built UI constants for payment screens
class PaymentUIConstants {
  // Paywall UI Constants
  static const String paywallTitle = 'Unlock Premium Features';
  static const String paywallSubtitle = 'Choose your perfect plan';
  static const String choosePlanText = 'Choose Your Plan';
  static const String benefitsTitle = 'Premium Benefits';

  static const List<String> premiumBenefits = [
    'Unlimited hairstyle consultations',
    'Advanced style recommendations',
    'Custom color palette options',
    'Priority customer support',
    'Monthly style trends',
  ];

  // Subscription Management UI Constants
  static const String subscriptionTitle = 'Manage Subscription';
  static const String noSubscriptionTitle = 'No Active Subscriptions';
  static const String noSubscriptionMessage =
      'Subscribe to unlock premium features';
  static const String viewPlansButton = 'View Plans';
  static const String renewsOnLabel = 'Renews on';
  static const String cancelSubscriptionButton = 'Cancel Subscription';
  static const String restorePurchasesButton = 'Restore Purchases';

  // Purchase Buttons
  static const String subscribeButton = 'Subscribe';
  static const String purchaseButton = 'Purchase';
  static const String renewButton = 'Renew';
  static const String upgradeButton = 'Upgrade';

  // Dialog Texts
  static const String cancelDialogTitle = 'Cancel Subscription?';
  static const String cancelDialogMessage =
      'Are you sure you want to cancel your subscription? You\'ll lose access to premium features.';
  static const String keepSubscriptionButton = 'Keep Subscription';
  static const String confirmCancelButton = 'Cancel';

  // Error Messages
  static const String genericErrorMessage =
      'Something went wrong. Please try again.';
  static const String networkErrorMessage =
      'Network error. Please check your connection.';
  static const String purchaseFailedMessage =
      'Purchase failed. Please try again.';
  static const String restoreFailedMessage = 'Failed to restore purchases.';

  // Success Messages
  static const String purchaseSuccessMessage = 'Purchase successful!';
  static const String restoreSuccessMessage =
      'Purchases restored successfully.';
  static const String subscriptionCancelledMessage = 'Subscription cancelled.';

  // Loading States
  static const String loadingText = 'Loading...';
  static const String processingText = 'Processing...';
  static const String pleasewaitText = 'Please wait...';

  // Status Labels
  static const String activeLabel = 'Active';
  static const String expiringLabel = 'Expiring Soon';
  static const String expiredLabel = 'Expired';
  static const String trialLabel = 'Trial';

  // Duration Display
  static const String expiresTodayText = 'Expires today';
  static const String expiresTomorrowText = 'Expires tomorrow';
  static const String expiresSoonText = 'Expires soon';
}
