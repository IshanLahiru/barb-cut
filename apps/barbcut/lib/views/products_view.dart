import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';

class ProductsView extends StatefulWidget {
  const ProductsView({super.key});

  @override
  State<ProductsView> createState() => _ProductsViewState();
}

class _ProductsViewState extends State<ProductsView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, dynamic>> _products = [
    {
      'name': 'Hair Gel',
      'price': '\$15.99',
      'rating': 4.5,
      'description': 'Premium styling gel for hold',
      'image': Icons.palette,
      'color': Colors.blue,
    },
    {
      'name': 'Beard Oil',
      'price': '\$12.99',
      'rating': 4.7,
      'description': 'Natural beard conditioning oil',
      'image': Icons.face_retouching_natural,
      'color': Colors.brown,
    },
    {
      'name': 'Clippers',
      'price': '\$89.99',
      'rating': 4.9,
      'description': 'Professional hair clippers',
      'image': Icons.content_cut,
      'color': Colors.grey,
    },
    {
      'name': 'Shampoo',
      'price': '\$9.99',
      'rating': 4.4,
      'description': 'Gentle hair shampoo',
      'image': Icons.water_drop,
      'color': Colors.cyan,
    },
    {
      'name': 'Razor',
      'price': '\$24.99',
      'rating': 4.8,
      'description': 'Precision straight razor',
      'image': Icons.content_cut,
      'color': Colors.blueGrey,
    },
    {
      'name': 'Wax',
      'price': '\$11.99',
      'rating': 4.6,
      'description': 'Hair styling wax',
      'image': Icons.brush,
      'color': Colors.orange,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final filteredProducts = _products
        .where(
          (p) => p['name'].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Products', style: textTheme.titleMedium),
        toolbarHeight: 22,
        elevation: 0,
      ),
      body: Container(
        color: scheme.background,
        child: Column(
          children: [
            // Search Bar
            Container(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  prefixIcon: Icon(
                    Icons.search,
                    color: scheme.onSurface.withOpacity(0.6),
                    size: 20,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: scheme.onSurface.withOpacity(0.6),
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
                  fillColor: scheme.surface,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.md,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide(color: scheme.outline, width: 1.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide(color: scheme.outline, width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide(color: scheme.primary, width: 1.5),
                  ),
                  hintStyle: textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurface.withOpacity(0.6),
                  ),
                ),
                style: textTheme.bodyMedium,
              ),
            ),
            // Grid
            Expanded(
              child: filteredProducts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_bag_outlined,
                            size: 64,
                            color: scheme.onSurface.withOpacity(0.6),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'No products found',
                            style: textTheme.titleMedium,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Try a different search term',
                            style: textTheme.bodySmall,
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.sm,
                        AppSpacing.md,
                        AppSpacing.md,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.75,
                          ),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        return _buildProductCard(context, product);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Map<String, dynamic> product) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final Color baseColor = product['color'] as Color;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border.all(color: scheme.outline, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image/Icon area
          Expanded(
            flex: 3,
            child: Container(
              color: baseColor.withOpacity(0.15),
              child: Center(
                child: Icon(product['image'], size: 48, color: baseColor),
              ),
            ),
          ),
          // Details area
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    product['name'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product['description'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall,
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        product['price'],
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            product['rating'].toString(),
                            style: textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
