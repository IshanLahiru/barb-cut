import 'package:flutter/material.dart';
import '../theme/ai_colors.dart';
import '../theme/adaptive_theme_colors.dart';
import '../theme/ai_spacing.dart';
import '../widgets/ai_buttons.dart';

class ProductsView extends StatefulWidget {
  const ProductsView({super.key});

  @override
  State<ProductsView> createState() => _ProductsViewState();
}

class _ProductsViewState extends State<ProductsView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int? _selectedProductIndex;

  final List<Map<String, dynamic>> _products = [
    {
      'name': 'Hair Gel Premium',
      'price': '\$15.99',
      'rating': 4.5,
      'description': 'Premium styling gel for powerful hold',
      'icon': Icons.palette,
      'accentColor': AiColors.neonCyan,
    },
    {
      'name': 'Beard Oil Deluxe',
      'price': '\$12.99',
      'rating': 4.7,
      'description': 'Natural beard conditioning oil',
      'icon': Icons.face_retouching_natural,
      'accentColor': AiColors.sunsetCoral,
    },
    {
      'name': 'Pro Clippers',
      'price': '\$89.99',
      'rating': 4.9,
      'description': 'Professional hair clippers',
      'icon': Icons.content_cut,
      'accentColor': AiColors.neonPurple,
    },
    {
      'name': 'Premium Shampoo',
      'price': '\$9.99',
      'rating': 4.4,
      'description': 'Gentle hair shampoo',
      'icon': Icons.water_drop,
      'accentColor': AiColors.neonCyan,
    },
    {
      'name': 'Straight Razor',
      'price': '\$24.99',
      'rating': 4.8,
      'description': 'Precision straight razor',
      'icon': Icons.content_cut,
      'accentColor': AiColors.sunsetCoral,
    },
    {
      'name': 'Styling Wax',
      'price': '\$11.99',
      'rating': 4.6,
      'description': 'Professional hair styling wax',
      'icon': Icons.brush,
      'accentColor': AiColors.neonPurple,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts = _products
        .where(
          (p) => p['name'].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ),
        )
        .toList();

    return Scaffold(
      backgroundColor: AdaptiveThemeColors.backgroundDeep(context),
      appBar: AppBar(
        backgroundColor: AdaptiveThemeColors.backgroundDark(context),
        elevation: 0,
        toolbarHeight: 48,
        title: Text(
          'Shop',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AdaptiveThemeColors.textPrimary(context),
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header with gradient
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AiSpacing.lg,
                vertical: AiSpacing.md,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AdaptiveThemeColors.backgroundDark(context),
                    AdaptiveThemeColors.backgroundSecondary(context),
                  ],
                ),
                border: Border(
                  bottom: BorderSide(
                    color: AdaptiveThemeColors.borderLight(context),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Find Premium Products',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AdaptiveThemeColors.textSecondary(context),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: AiSpacing.sm),
                  // Search field with neon cyan focus
                  TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AdaptiveThemeColors.textPrimary(context),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Hair gel, clippers, shampoo...',
                      hintStyle: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(
                            color: AdaptiveThemeColors.textTertiary(context),
                          ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: AdaptiveThemeColors.textTertiary(context),
                        size: 20,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: AdaptiveThemeColors.textTertiary(
                                  context,
                                ),
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: AdaptiveThemeColors.backgroundSecondary(
                        context,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AiSpacing.md,
                        vertical: AiSpacing.md,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AiSpacing.radiusLarge,
                        ),
                        borderSide: BorderSide(
                          color: AdaptiveThemeColors.borderLight(context),
                          width: 1.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AiSpacing.radiusLarge,
                        ),
                        borderSide: BorderSide(
                          color: AdaptiveThemeColors.borderLight(context),
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AiSpacing.radiusLarge,
                        ),
                        borderSide: BorderSide(
                          color: AdaptiveThemeColors.neonCyan(context),
                          width: 2,
                        ),
                      ),
                    ),
                    cursorColor: AdaptiveThemeColors.neonCyan(context),
                  ),
                  const SizedBox(height: AiSpacing.md),
                  Wrap(
                    spacing: AiSpacing.sm,
                    runSpacing: AiSpacing.sm,
                    children: [
                      _buildCategoryChip(
                        context,
                        label: 'Hair Care',
                        color: AdaptiveThemeColors.neonCyan(context),
                      ),
                      _buildCategoryChip(
                        context,
                        label: 'Beard Care',
                        color: AdaptiveThemeColors.sunsetCoral(context),
                      ),
                      _buildCategoryChip(
                        context,
                        label: 'Tools',
                        color: AdaptiveThemeColors.neonPurple(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Products Grid
            Expanded(
              child: filteredProducts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_bag_outlined,
                            size: 64,
                            color: AdaptiveThemeColors.textTertiary(context),
                          ),
                          const SizedBox(height: AiSpacing.md),
                          Text(
                            'No products found',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: AdaptiveThemeColors.textPrimary(
                                    context,
                                  ),
                                ),
                          ),
                          const SizedBox(height: AiSpacing.sm),
                          Text(
                            'Try a different search term',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AdaptiveThemeColors.textTertiary(
                                    context,
                                  ),
                                ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AiSpacing.lg,
                        vertical: AiSpacing.md,
                      ),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        final isSelected = _selectedProductIndex == index;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AiSpacing.md),
                          child: _buildAiProductCard(
                            context,
                            product,
                            isSelected,
                            () {
                              setState(() {
                                _selectedProductIndex = isSelected
                                    ? null
                                    : index;
                              });
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(
    BuildContext context, {
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AiSpacing.md,
        vertical: AiSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AdaptiveThemeColors.backgroundSecondary(context),
        borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: AdaptiveThemeColors.textPrimary(context),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildAiProductCard(
    BuildContext context,
    Map<String, dynamic> product,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final accentColor = product['accentColor'] as Color;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: isSelected
              ? AdaptiveThemeColors.surface(context)
              : AdaptiveThemeColors.backgroundSecondary(context),
          borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
          border: Border.all(
            color: isSelected
                ? accentColor
                : AdaptiveThemeColors.borderLight(context),
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: accentColor.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AiSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: Icon + Title + Price
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon container
                  Container(
                    padding: const EdgeInsets.all(AiSpacing.md),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        AiSpacing.radiusLarge,
                      ),
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      product['icon'] as IconData,
                      color: accentColor,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: AiSpacing.md),
                  // Title + Description
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product['name'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: AdaptiveThemeColors.textPrimary(context),
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: AiSpacing.xs),
                        Text(
                          product['description'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AdaptiveThemeColors.textTertiary(
                                  context,
                                ),
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AiSpacing.md),
                  // Price badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AiSpacing.sm,
                      vertical: AiSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(
                        AiSpacing.radiusSmall,
                      ),
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      product['price'],
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: accentColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AiSpacing.md),
              // Rating or Action buttons
              if (!isSelected)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AiSpacing.sm,
                    vertical: AiSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AdaptiveThemeColors.backgroundDeep(context),
                    borderRadius: BorderRadius.circular(AiSpacing.radiusSmall),
                    border: Border.all(
                      color: AdaptiveThemeColors.borderLight(context),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star_rounded,
                        size: 16,
                        color: AdaptiveThemeColors.neonCyan(context),
                      ),
                      const SizedBox(width: AiSpacing.xs),
                      Text(
                        product['rating'].toString(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AdaptiveThemeColors.textSecondary(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: AiSecondaryButton(
                          label: 'View',
                          onPressed: () {},
                          accentColor: AdaptiveThemeColors.neonCyan(context),
                        ),
                      ),
                    ),
                    const SizedBox(width: AiSpacing.sm),
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: AiPrimaryButton(
                          label: 'Add',
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${product['name']} added to cart!',
                                  style: TextStyle(
                                    color: AdaptiveThemeColors.textPrimary(
                                      context,
                                    ),
                                  ),
                                ),
                                backgroundColor: AdaptiveThemeColors.success(
                                  context,
                                ),
                                duration: const Duration(milliseconds: 1500),
                              ),
                            );
                            setState(() {
                              _selectedProductIndex = null;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
