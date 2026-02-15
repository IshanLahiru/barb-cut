import 'package:flutter/material.dart';

/// RevenueCat Paywall Widget placeholder
/// To be configured with actual RevenueCat Paywall UI when dashboard is set up
class RevenueCatPaywallWidget extends StatefulWidget {
  final String displayName;
  final VoidCallback? onDismiss;
  final VoidCallback? onPurchased;

  const RevenueCatPaywallWidget({
    super.key,
    required this.displayName,
    this.onDismiss,
    this.onPurchased,
  });

  @override
  State<RevenueCatPaywallWidget> createState() =>
      _RevenueCatPaywallWidgetState();
}

class _RevenueCatPaywallWidgetState extends State<RevenueCatPaywallWidget> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'RevenueCat Paywall',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'Configure in RevenueCat dashboard to display paywall',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

/// Paywall Display Options
enum PaywallDisplayType { revenueCat, custom }

/// Helper to display paywall as modal
Future<void> showPaywallModal(
  BuildContext context, {
  PaywallDisplayType displayType = PaywallDisplayType.custom,
  String displayName = 'default',
}) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: displayType == PaywallDisplayType.revenueCat
          ? RevenueCatPaywallWidget(
              displayName: displayName,
              onDismiss: () => Navigator.of(context).pop(),
            )
          : const SizedBox.shrink(),
    ),
  );
}
