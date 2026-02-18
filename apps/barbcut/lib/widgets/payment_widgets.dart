import 'package:flutter/material.dart';
import 'package:barbcut/models/subscription_model.dart';

/// Displays subscription badge when user has active subscription
class SubscriptionBadge extends StatelessWidget {
  final SubscriptionModel subscription;
  final double size;

  const SubscriptionBadge({
    super.key,
    required this.subscription,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(size / 8),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.2),
        borderRadius: BorderRadius.circular(size / 2),
        border: Border.all(color: Colors.green),
      ),
      child: Icon(Icons.check_circle, size: size, color: Colors.green),
    );
  }
}

/// Premium feature lock overlay
class PremiumFeatureLock extends StatelessWidget {
  final bool isLocked;
  final Widget child;
  final VoidCallback? onUnlock;
  final String? lockMessage;

  const PremiumFeatureLock({
    super.key,
    required this.isLocked,
    required this.child,
    this.onUnlock,
    this.lockMessage = 'Premium feature',
  });

  @override
  Widget build(BuildContext context) {
    if (!isLocked) {
      return child;
    }

    return Stack(
      children: [
        Opacity(opacity: 0.5, child: child),
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.3),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock, size: 48, color: Colors.white),
                const SizedBox(height: 12),
                Text(
                  lockMessage ?? 'Premium feature',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                if (onUnlock != null)
                  ElevatedButton(
                    onPressed: onUnlock,
                    child: const Text('Unlock'),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Payment method selector widget
class PaymentMethodSelector extends StatefulWidget {
  final Function(String) onMethodSelected;
  final String initialMethod;

  const PaymentMethodSelector({
    super.key,
    required this.onMethodSelected,
    this.initialMethod = 'credit_card',
  });

  @override
  State<PaymentMethodSelector> createState() => _PaymentMethodSelectorState();
}

class _PaymentMethodSelectorState extends State<PaymentMethodSelector> {
  late String _selectedMethod;

  @override
  void initState() {
    super.initState();
    _selectedMethod = widget.initialMethod;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Method',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildPaymentOption('credit_card', 'Credit Card', Icons.credit_card),
        _buildPaymentOption('debit_card', 'Debit Card', Icons.credit_card),
        _buildPaymentOption('paypal', 'PayPal', Icons.wallet_membership),
      ],
    );
  }

  Widget _buildPaymentOption(String id, String label, IconData icon) {
    final isSelected = _selectedMethod == id;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMethod = id;
          widget.onMethodSelected(id);
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.blue : Colors.grey),
            const SizedBox(width: 12),
            Text(label),
            const Spacer(),
            if (isSelected) const Icon(Icons.check_circle, color: Colors.blue),
          ],
        ),
      ),
    );
  }
}
