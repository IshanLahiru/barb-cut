import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme.dart';
import '../controllers/subscription_controller.dart';
import '../services/subscription_service.dart';

class PaywallView extends StatefulWidget {
  const PaywallView({super.key});

  @override
  State<PaywallView> createState() => _PaywallViewState();
}

class _PaywallViewState extends State<PaywallView> {
  String? _selectedPackageId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final subscriptionCtrl = Provider.of<SubscriptionController>(
      context,
      listen: false,
    );
    await subscriptionCtrl.loadAvailableProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdaptiveThemeColors.backgroundDark(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: AdaptiveThemeColors.textPrimary(context),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: _restorePurchases,
            child: Text(
              'Restore',
              style: TextStyle(
                color: AdaptiveThemeColors.neonCyan(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Consumer<SubscriptionController>(
        builder: (context, subscriptionCtrl, _) {
          if (subscriptionCtrl.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final products = subscriptionCtrl.availableProducts;

          if (products.isEmpty) {
            return _buildEmptyState();
          }

          // Auto-select first product if none selected
          if (_selectedPackageId == null && products.isNotEmpty) {
            Future.microtask(() {
              setState(() {
                _selectedPackageId = products.first.identifier;
              });
            });
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(AiSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Header
                _buildHeader(),
                SizedBox(height: AiSpacing.xl),

                // Features list
                _buildFeaturesList(),
                SizedBox(height: AiSpacing.xl),

                // Subscription plans
                _buildPlansList(products),
                SizedBox(height: AiSpacing.lg),

                // Error/Success messages
                if (subscriptionCtrl.errorMessage != null)
                  _buildErrorBanner(subscriptionCtrl.errorMessage!),
                if (subscriptionCtrl.successMessage != null)
                  _buildSuccessBanner(subscriptionCtrl.successMessage!),

                SizedBox(height: AiSpacing.md),

                // Purchase button
                _buildPurchaseButton(subscriptionCtrl),
                SizedBox(height: AiSpacing.md),

                // Terms and conditions
                _buildTermsText(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Pro badge
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AiSpacing.md,
            vertical: AiSpacing.sm,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AdaptiveThemeColors.neonCyan(context),
                AdaptiveThemeColors.neonPurple(context),
              ],
            ),
            borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star, color: Colors.white, size: 20),
              SizedBox(width: AiSpacing.xs),
              Text(
                'BarbCut Pro',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
        ),
        SizedBox(height: AiSpacing.md),

        // Title
        Text(
          'Unlock Premium Features',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AdaptiveThemeColors.textPrimary(context),
                fontWeight: FontWeight.w800,
              ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AiSpacing.sm),

        // Subtitle
        Text(
          'Get unlimited access to all styles, products and premium features',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AdaptiveThemeColors.textSecondary(context),
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFeaturesList() {
    final features = [
      {
        'icon': Icons.style,
        'title': 'Unlimited Style Access',
        'description': 'Access all premium hairstyles and beard styles',
      },
      {
        'icon': Icons.shopping_bag,
        'title': 'Exclusive Products',
        'description': 'Shop pro-only hair and beard care products',
      },
      {
        'icon': Icons.auto_awesome,
        'title': 'AI-Powered Recommendations',
        'description': 'Get personalized style suggestions',
      },
      {
        'icon': Icons.update,
        'title': 'Priority Updates',
        'description': 'Get early access to new features',
      },
    ];

    return Column(
      children: features.map((feature) {
        return Padding(
          padding: EdgeInsets.only(bottom: AiSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(AiSpacing.sm),
                decoration: BoxDecoration(
                  color: AdaptiveThemeColors.neonCyan(context)
                      .withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AiSpacing.radiusMedium),
                ),
                child: Icon(
                  feature['icon'] as IconData,
                  color: AdaptiveThemeColors.neonCyan(context),
                  size: 24,
                ),
              ),
              SizedBox(width: AiSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feature['title'] as String,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AdaptiveThemeColors.textPrimary(context),
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      feature['description'] as String,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AdaptiveThemeColors.textSecondary(context),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPlansList(List<AvailableProduct> products) {
    // Sort products: yearly first (best value), then monthly
    final sortedProducts = List<AvailableProduct>.from(products);
    sortedProducts.sort((a, b) {
      if (a.identifier.contains('year')) return -1;
      if (b.identifier.contains('year')) return 1;
      return 0;
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Your Plan',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AdaptiveThemeColors.textPrimary(context),
                fontWeight: FontWeight.w800,
              ),
        ),
        SizedBox(height: AiSpacing.md),
        ...sortedProducts.map((product) => _buildPlanCard(product)),
      ],
    );
  }

  Widget _buildPlanCard(AvailableProduct product) {
    final isSelected = _selectedPackageId == product.identifier;
    final isYearly = product.identifier.contains('year');
    final accentColor = isYearly
        ? AdaptiveThemeColors.neonPurple(context)
        : AdaptiveThemeColors.neonCyan(context);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPackageId = product.identifier;
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: AiSpacing.md),
        decoration: BoxDecoration(
          color: AdaptiveThemeColors.surface(context),
          borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
          border: Border.all(
            color: isSelected
                ? accentColor
                : AdaptiveThemeColors.textTertiary(context)
                    .withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(AiSpacing.md),
              child: Row(
                children: [
                  // Radio button
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? accentColor
                            : AdaptiveThemeColors.textTertiary(context),
                        width: 2,
                      ),
                      color: isSelected
                          ? accentColor
                          : Colors.transparent,
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check,
                            size: 16,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  SizedBox(width: AiSpacing.md),

                  // Plan details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.displayName,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AdaptiveThemeColors.textPrimary(
                                      context,
                                    ),
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          product.price,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: accentColor,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        if (isYearly) ...[
                          SizedBox(height: 4),
                          Text(
                            'Best Value - Save on yearly plan',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AdaptiveThemeColors.textSecondary(
                                        context,
                                      ),
                                    ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Best value badge
            if (isYearly)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AiSpacing.sm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.amber,
                        Colors.orange,
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(AiSpacing.radiusLarge),
                      bottomLeft: Radius.circular(AiSpacing.radiusMedium),
                    ),
                  ),
                  child: Text(
                    'BEST VALUE',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                        ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPurchaseButton(SubscriptionController subscriptionCtrl) {
    final selectedProduct = subscriptionCtrl.availableProducts.firstWhere(
      (p) => p.identifier == _selectedPackageId,
      orElse: () => subscriptionCtrl.availableProducts.first,
    );

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: (_isLoading || subscriptionCtrl.isPurchasing)
            ? null
            : () => _handlePurchase(selectedProduct),
        style: ElevatedButton.styleFrom(
          backgroundColor: AdaptiveThemeColors.neonCyan(context),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
          ),
          elevation: 0,
        ),
        child: (_isLoading || subscriptionCtrl.isPurchasing)
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : Text(
                'Start Free Trial',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
              ),
      ),
    );
  }

  Widget _buildTermsText() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AiSpacing.md),
      child: Text(
        'Cancel anytime. By subscribing, you agree to our Terms of Service and Privacy Policy. Payment will be charged to your account at confirmation of purchase.',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AdaptiveThemeColors.textTertiary(context),
              fontSize: 11,
            ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: EdgeInsets.all(AiSpacing.md),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AiSpacing.radiusMedium),
        border: Border.all(
          color: Colors.red.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 20),
          SizedBox(width: AiSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.red,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessBanner(String message) {
    return Container(
      padding: EdgeInsets.all(AiSpacing.md),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AiSpacing.radiusMedium),
        border: Border.all(
          color: Colors.green.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
          SizedBox(width: AiSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.green,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_off,
            size: 64,
            color: AdaptiveThemeColors.textTertiary(context),
          ),
          SizedBox(height: AiSpacing.md),
          Text(
            'Unable to load subscription plans',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AdaptiveThemeColors.textSecondary(context),
                ),
          ),
          SizedBox(height: AiSpacing.sm),
          TextButton(
            onPressed: _loadProducts,
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePurchase(AvailableProduct product) async {
    setState(() {
      _isLoading = true;
    });

    final subscriptionCtrl = Provider.of<SubscriptionController>(
      context,
      listen: false,
    );

    await subscriptionCtrl.purchasePackage(product.identifier);

    setState(() {
      _isLoading = false;
    });

    // If purchase was successful, close the paywall
    if (subscriptionCtrl.hasProAccess && mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _restorePurchases() async {
    setState(() {
      _isLoading = true;
    });

    final subscriptionCtrl = Provider.of<SubscriptionController>(
      context,
      listen: false,
    );

    await subscriptionCtrl.restorePurchases();

    setState(() {
      _isLoading = false;
    });

    // If restore was successful, close the paywall
    if (subscriptionCtrl.hasProAccess && mounted) {
      Navigator.of(context).pop();
    }
  }
}
