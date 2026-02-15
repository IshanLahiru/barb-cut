import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:barbcut/controllers/subscription_controller.dart';
import 'package:barbcut/services/subscription_service.dart';

/// Custom Paywall UI Widget
/// Displays subscription packages and handles purchases
class CustomPaywallWidget extends StatefulWidget {
  final VoidCallback? onDismiss;
  final bool showCloseButton;

  const CustomPaywallWidget({
    super.key,
    this.onDismiss,
    this.showCloseButton = true,
  });

  @override
  State<CustomPaywallWidget> createState() => _CustomPaywallWidgetState();
}

class _CustomPaywallWidgetState extends State<CustomPaywallWidget> {
  String? _selectedPackage;

  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionController>(
      builder: (context, subscriptionCtrl, child) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                if (widget.showCloseButton)
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: widget.onDismiss ?? Navigator.of(context).pop,
                    ),
                  ),

                const SizedBox(height: 16),

                // Title
                const Text(
                  'Unlock BarbCut Pro',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                // Subtitle
                Text(
                  'Get exclusive features & unlimited access',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // Features List
                _buildFeaturesList(),

                const SizedBox(height: 32),

                // Product Selection
                if (subscriptionCtrl.availableProducts.isEmpty)
                  const Center(child: CircularProgressIndicator())
                else
                  _buildPackageSelection(subscriptionCtrl),

                const SizedBox(height: 24),

                // Purchase Button
                _buildPurchaseButton(subscriptionCtrl),

                const SizedBox(height: 16),

                // Restore Purchases Button
                if (!subscriptionCtrl.hasProAccess)
                  TextButton(
                    onPressed: subscriptionCtrl.isPurchasing
                        ? null
                        : () => subscriptionCtrl.restorePurchases(),
                    child: const Text('Restore Purchases'),
                  ),

                const SizedBox(height: 16),

                // Error Message
                if (subscriptionCtrl.errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Text(
                      subscriptionCtrl.errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ),

                // Success Message
                if (subscriptionCtrl.successMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Text(
                      subscriptionCtrl.successMessage!,
                      style: const TextStyle(color: Colors.green, fontSize: 14),
                    ),
                  ),

                const SizedBox(height: 16),

                // Terms Text
                Text(
                  'Subscription renews automatically. Cancel anytime in app settings.',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeaturesList() {
    const features = [
      'Unlimited styles access',
      'Advanced customer management',
      'Sales analytics & reports',
      'Priority support',
      'Custom branding options',
    ];

    return Column(
      children: features
          .map(
            (feature) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(feature, style: const TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildPackageSelection(SubscriptionController subscriptionCtrl) {
    return Column(
      children: subscriptionCtrl.availableProducts.map((product) {
        final isSelected = _selectedPackage == product.identifier;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: GestureDetector(
            onTap: () => setState(() => _selectedPackage = product.identifier),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.grey[300]!,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(12),
                color: isSelected
                    ? Colors.blue.withOpacity(0.05)
                    : Colors.transparent,
              ),
              child: Row(
                children: [
                  Radio<String>(
                    value: product.identifier,
                    groupValue: _selectedPackage,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedPackage = value);
                      }
                    },
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.displayName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (product.getSavingsText().isNotEmpty)
                          Text(
                            product.getSavingsText(),
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    product.price,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPurchaseButton(SubscriptionController subscriptionCtrl) {
    return ElevatedButton(
      onPressed: subscriptionCtrl.isPurchasing || _selectedPackage == null
          ? null
          : () => subscriptionCtrl.purchasePackage(_selectedPackage!),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: subscriptionCtrl.isPurchasing
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Text(
              'Subscribe Now',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
    );
  }
}
