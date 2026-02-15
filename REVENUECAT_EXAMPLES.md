# RevenueCat Implementation Examples

Practical examples for common BarbCut subscription scenarios.

## Example 1: Add Pro Badge to Feature

```dart
class StyleCardWidget extends StatelessWidget {
  final String styleId;
  final bool isProOnly;

  const StyleCardWidget({
    required this.styleId,
    required this.isProOnly,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Card(
          child: ListTile(
            title: Text('Style $styleId'),
          ),
        ),
        if (isProOnly)
          Positioned(
            top: 8,
            right: 8,
            child: ProBadge(label: 'Premium'),
          ),
      ],
    );
  }
}
```

## Example 2: Lock Advanced Editing Features

```dart
class StyleEditorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Basic editor (free)
        BasicStyleEditor(),

        // Advanced features (pro)
        ProFeatureWidget(
          showPaywallAutomatically: true,
          child: AdvancedStyleEditor(),
        ),
      ],
    );
  }
}

// Alternative: Show/hide based on subscription
class AlternativeExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return EntitlementBuilder(
      proBuilder: (context) => AdvancedStyleEditor(),
      freeBuilder: (context) => BasicStyleEditor(),
    );
  }
}
```

## Example 3: Gallery View with Pro Unlock

```dart
class StyleGalleryScreen extends StatelessWidget {
  final List<String> premiumStyles = [
    'fade_pro',
    'fade_burst_pro',
    'hard_part_pro',
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionController>(
      builder: (context, subscriptionCtrl, _) {
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
          ),
          itemBuilder: (context, index) {
            final styleId = allStyles[index];
            final isPro = premiumStyles.contains(styleId);
            final hasAccess = subscriptionCtrl.hasProAccess;

            return GestureDetector(
              onTap: isPro && !hasAccess
                  ? () => _showPaywall(context)
                  : () => selectStyle(styleId),
              child: Stack(
                children: [
                  StyleCard(styleId: styleId),
                  if (isPro && !hasAccess)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(0.4),
                        child: const Center(
                          child: Icon(
                            Icons.lock,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showPaywall(BuildContext context) {
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
  }
}
```

## Example 4: Analytics Dashboard (Pro Only)

```dart
class AnalyticsDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProFeatureWidget(
      showPaywallAutomatically: true,
      onUpgradeRequired: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Upgrade to BarbCut Pro to access analytics'),
          ),
        );
      },
      child: Column(
        children: [
          const SizedBox(height: 16),
          AnalyticsCard(title: 'Total Customers', value: '1,204'),
          AnalyticsCard(title: 'This Month', value: '\$4,832'),
          AnalyticsCard(title: 'Avg Service', value: '\$45.50'),
        ],
      ),
    );
  }
}
```

## Example 5: Settings Page with Subscription Management

```dart
class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        // Account Settings
        ListTile(
          title: const Text('Account'),
          subtitle: const Text('Manage your profile'),
        ),

        // Subscription Management
        SubscriptionStatusBanner(),

        const Divider(),

        SubscriptionSettingsSection(),

        const Divider(),

        // Other Settings
        ListTile(
          title: const Text('Notifications'),
          onTap: () {},
        ),

        ListTile(
          title: const Text('Appearance'),
          onTap: () {},
        ),

        ListTile(
          title: const Text('Help & Support'),
          onTap: () {},
        ),
      ],
    );
  }
}
```

## Example 6: Product Selection and Purchase

```dart
class UpgradeScreen extends StatefulWidget {
  @override
  State<UpgradeScreen> createState() => _UpgradeScreenState();
}

class _UpgradeScreenState extends State<UpgradeScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionController>(
      builder: (context, subscriptionCtrl, _) {
        if (subscriptionCtrl.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const Text(
                      'Upgrade to Pro',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Unlock advanced features',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              // Features
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    FeatureRow(icon: Icons.star, text: 'Advanced analytics'),
                    FeatureRow(icon: Icons.people, text: 'Unlimited clients'),
                    FeatureRow(icon: Icons.photo, text: 'Custom gallery'),
                    FeatureRow(icon: Icons.palette, text: 'Style creation'),
                  ],
                ),
              ),

              // Product Cards
              if (subscriptionCtrl.availableProducts.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: subscriptionCtrl.availableProducts
                        .map((product) => ProductCard(
                              product: product,
                              onPurchase: () {
                                subscriptionCtrl
                                    .purchasePackage(product.identifier);
                              },
                            ))
                        .toList(),
                  ),
                ),

              // Error
              if (subscriptionCtrl.errorMessage != null)
                Container(
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(subscriptionCtrl.errorMessage!),
                ),

              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}

class FeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const FeatureRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.green),
          const SizedBox(width: 12),
          Text(text),
        ],
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final AvailableProduct product;
  final VoidCallback onPurchase;

  const ProductCard({
    required this.product,
    required this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  product.displayName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  product.price,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            if (product.getSavingsText().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  product.getSavingsText(),
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onPurchase,
                child: const Text('Subscribe'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Example 7: After-First-Use Paywall

```dart
class FirstTimePaywallScheduler {
  static Future<void> showFirstTimePaywall(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final hasShownPaywall = prefs.getBool('has_shown_paywall') ?? false;

    if (!hasShownPaywall) {
      // Show after delay
      await Future.delayed(const Duration(seconds: 2));

      if (!context.mounted) return;

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => DraggableScrollableSheet(
          expand: false,
          builder: (context, controller) => CustomPaywallWidget(
            onDismiss: () {
              Navigator.of(context).pop();
              prefs.setBool('has_shown_paywall', true);
            },
          ),
        ),
      );

      await prefs.setBool('has_shown_paywall', true);
    }
  }
}

// Usage in main screen
class MainScreen extends StatefulWidget {
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FirstTimePaywallScheduler.showFirstTimePaywall(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ... rest of main screen
    );
  }
}
```

## Example 8: Pro Feature in Navigation

```dart
class NavigationMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionController>(
      builder: (context, subscriptionCtrl, _) {
        return NavigationRail(
          destinations: [
            NavigationRailDestination(
              icon: Icon(Icons.home),
              label: Text('Home'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.people),
              label: Text('Clients'),
            ),
            // Pro feature
            if (subscriptionCtrl.hasProAccess)
              NavigationRailDestination(
                icon: Icon(Icons.analytics),
                label: Text('Analytics'),
              ),
            // Without Pro: Locked version
            if (!subscriptionCtrl.hasProAccess)
              NavigationRailDestination(
                icon: Icon(Icons.lock),
                label: Text('Analytics'),
                enabled: false,
              ),
          ],
        );
      },
    );
  }
}

// On tap handler
void onNavigationTap(int index, BuildContext context) {
  final subscriptionCtrl = Provider.of<SubscriptionController>(
    context,
    listen: false,
  );

  // If analytics and no pro
  if (index == 2 && !subscriptionCtrl.hasProAccess) {
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
    return;
  }

  // Navigate normally
  navigateTo(index);
}
```

## Example 9: Error Recovery

```dart
class RobustPurchaseFlow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionController>(
      builder: (context, subscriptionCtrl, _) {
        return Column(
          children: [
            if (subscriptionCtrl.errorMessage != null)
              ErrorRecoveryWidget(
                error: subscriptionCtrl.errorMessage!,
                onRetry: () {
                  subscriptionCtrl.clearError();
                  subscriptionCtrl.loadAvailableProducts();
                },
                onDismiss: () => subscriptionCtrl.clearError(),
              ),
            if (subscriptionCtrl.successMessage != null)
              SuccessWidget(
                message: subscriptionCtrl.successMessage!,
                onDismiss: () => subscriptionCtrl.clearSuccess(),
              ),
            // Rest of UI
          ],
        );
      },
    );
  }
}

class ErrorRecoveryWidget extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  final VoidCallback onDismiss;

  const ErrorRecoveryWidget({
    required this.error,
    required this.onRetry,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.red.withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.error, color: Colors.red),
              const SizedBox(width: 12),
              Expanded(child: Text(error)),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: onDismiss,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: onDismiss,
                child: const Text('Dismiss'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Retry'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

## Example 10: Expiration Reminder

```dart
Future<void> checkSubscriptionExpiration(BuildContext context) async {
  final subscriptionCtrl = Provider.of<SubscriptionController>(
    context,
    listen: false,
  );

  final status = subscriptionCtrl.subscriptionStatus;
  if (status == null) return;

  final daysLeft = status.getDaysUntilExpiration();

  // Show reminder if expiring soon
  if (status.isExpiringSoon && daysLeft != null) {
    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Subscription Expiring Soon'),
        content: Text(
          'Your BarbCut Pro subscription expires in $daysLeft days. Renew now to maintain access to premium features.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Show customer center to renew
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => DraggableScrollableSheet(
                  expand: false,
                  builder: (context, controller) =>
                      CustomerCenterWidget(),
                ),
              );
            },
            child: const Text('Renew'),
          ),
        ],
      ),
    );
  }
}
```

## Best Practices Summary

1. **Always handle loading states** - Show spinner while fetching products
2. **Gracefully handle errors** - Don't crash if RevenueCat fails
3. **Link auth and subscriptions** - Set user ID when authenticated
4. **Refresh after changes** - Update status after purchases
5. **Show clear messaging** - Users should understand what they're paying for
6. **Test thoroughly** - Test on real devices with sandbox accounts
7. **Monitor errors** - Log RevenueCat errors for debugging
