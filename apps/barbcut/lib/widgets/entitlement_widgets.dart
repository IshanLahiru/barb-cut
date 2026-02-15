import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:barbcut/controllers/subscription_controller.dart';
import 'package:barbcut/widgets/custom_paywall_widget.dart';

/// Widget that renders content only if user has Pro access
/// Otherwise shows paywall
class ProFeatureWidget extends StatelessWidget {
  final Widget child;
  final VoidCallback? onUpgradeRequired;
  final bool showPaywallAutomatically;

  const ProFeatureWidget({
    super.key,
    required this.child,
    this.onUpgradeRequired,
    this.showPaywallAutomatically = true,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionController>(
      builder: (context, subscriptionCtrl, _) {
        if (subscriptionCtrl.hasProAccess) {
          return child;
        }

        if (showPaywallAutomatically) {
          onUpgradeRequired?.call();
          // Show paywall automatically
          return _buildPaywallRequest(context);
        }

        return child;
      },
    );
  }

  Widget _buildPaywallRequest(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'This feature requires\nBarbCut Pro',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _showPaywall(context),
            child: const Text('Upgrade to Pro'),
          ),
        ],
      ),
    );
  }

  void _showPaywall(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        builder: (BuildContext context, ScrollController scrollController) {
          return CustomPaywallWidget(
            onDismiss: () => Navigator.of(context).pop(),
          );
        },
      ),
    );
  }
}

/// Builder widget for conditional rendering based on pro access
class EntitlementBuilder extends StatelessWidget {
  final Widget Function(BuildContext context) proBuilder;
  final Widget Function(BuildContext context) freeBuilder;

  const EntitlementBuilder({
    super.key,
    required this.proBuilder,
    required this.freeBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionController>(
      builder: (context, subscriptionCtrl, _) {
        if (subscriptionCtrl.hasProAccess) {
          return proBuilder(context);
        }
        return freeBuilder(context);
      },
    );
  }
}

/// Badge to indicate pro-only feature
class ProBadge extends StatelessWidget {
  final String? label;

  const ProBadge({super.key, this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.amber.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 12, color: Colors.amber),
          const SizedBox(width: 4),
          Text(
            label ?? 'Pro',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.amber,
            ),
          ),
        ],
      ),
    );
  }
}

/// Button that triggers paywall if user doesn't have pro access
class ProActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool requiresPro;

  const ProActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.requiresPro = true,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionController>(
      builder: (context, subscriptionCtrl, _) {
        final isProContent = requiresPro && !subscriptionCtrl.hasProAccess;

        return ElevatedButton.icon(
          onPressed: isProContent ? () => _showProPaywall(context) : onPressed,
          icon: Icon(icon ?? Icons.check),
          label: Text(label),
        );
      },
    );
  }

  void _showProPaywall(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        builder: (BuildContext context, ScrollController scrollController) {
          return CustomPaywallWidget(
            onDismiss: () => Navigator.of(context).pop(),
          );
        },
      ),
    );
  }
}

/// Overlay for locked features
class FeatureLockOverlay extends StatelessWidget {
  final Widget child;
  final bool isLocked;
  final String? message;

  const FeatureLockOverlay({
    super.key,
    required this.child,
    this.isLocked = false,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Opacity(opacity: isLocked ? 0.5 : 1.0, child: child),
        if (isLocked)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock, size: 48, color: Colors.white),
                    const SizedBox(height: 16),
                    Text(
                      message ?? 'Pro feature',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) => DraggableScrollableSheet(
                            expand: false,
                            builder:
                                (
                                  BuildContext context,
                                  ScrollController scrollController,
                                ) {
                                  return CustomPaywallWidget(
                                    onDismiss: () =>
                                        Navigator.of(context).pop(),
                                  );
                                },
                          ),
                        );
                      },
                      child: const Text('Upgrade'),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Subscription status banner
class SubscriptionStatusBanner extends StatelessWidget {
  const SubscriptionStatusBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionController>(
      builder: (context, subscriptionCtrl, _) {
        final status = subscriptionCtrl.subscriptionStatus;

        if (status == null || !status.hasPro) {
          return const SizedBox.shrink();
        }

        if (status.isExpiringSoon) {
          final daysLeft = status.getDaysUntilExpiration();
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info, color: Colors.orange, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your subscription expires in $daysLeft days. Renew to continue enjoying Pro features.',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
