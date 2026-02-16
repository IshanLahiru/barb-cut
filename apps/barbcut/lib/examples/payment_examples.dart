import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:barbcut/controllers/payment_controller.dart';
import 'package:barbcut/views/paywall_screen.dart';
import 'package:barbcut/widgets/payment_widgets.dart';

/// Example 1: Simple subscription check
class SubscriptionCheckExample extends StatelessWidget {
  const SubscriptionCheckExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PaymentController>(
      builder: (context, paymentController, _) {
        if (paymentController.hasActiveSubscription) {
          return const Text('Premium user');
        }
        return ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PaywallScreen()),
            );
          },
          child: const Text('Go Premium'),
        );
      },
    );
  }
}

/// Example 2: Premium feature with lock
class PremiumFeatureExample extends StatelessWidget {
  const PremiumFeatureExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PaymentController>(
      builder: (context, paymentController, _) {
        return PremiumFeatureLock(
          isLocked: !paymentController.hasActiveSubscription,
          onUnlock: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PaywallScreen()),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue,
            child: const Text(
              'Premium Content',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    );
  }
}

/// Example 3: Subscription status display
class SubscriptionStatusExample extends StatelessWidget {
  const SubscriptionStatusExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PaymentController>(
      builder: (context, paymentController, _) {
        final subscriptions =
            paymentController.customerInfo?.subscriptions ?? [];

        if (subscriptions.isEmpty) {
          return const Text('No active subscriptions');
        }

        return ListView.builder(
          itemCount: subscriptions.length,
          itemBuilder: (context, index) {
            final sub = subscriptions[index];
            return Card(
              child: ListTile(
                leading: const SubscriptionBadge(),
                title: Text(sub.title),
                subtitle: Text(sub.description),
                trailing: Text('\$${sub.price}'),
              ),
            );
          },
        );
      },
    );
  }
}

/// Example 4: Payment method selection
class PaymentMethodExample extends StatefulWidget {
  const PaymentMethodExample({super.key});

  @override
  State<PaymentMethodExample> createState() => _PaymentMethodExampleState();
}

class _PaymentMethodExampleState extends State<PaymentMethodExample> {
  @override
  Widget build(BuildContext context) {
    return PaymentMethodSelector(
      initialMethod: 'credit_card',
      onMethodSelected: (method) {
        debugPrint('Selected payment method: $method');
      },
    );
  }
}

/// Example 5: Restore purchases button
class RestorePurchasesExample extends StatelessWidget {
  const RestorePurchasesExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PaymentController>(
      builder: (context, paymentController, _) {
        return ElevatedButton(
          onPressed: paymentController.isLoading
              ? null
              : () async {
                  final success = await paymentController.restorePurchases();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? 'Purchases restored'
                              : 'Failed to restore purchases',
                        ),
                      ),
                    );
                  }
                },
          child: const Text('Restore Purchases'),
        );
      },
    );
  }
}
