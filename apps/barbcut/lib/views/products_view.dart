import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../theme/theme.dart';
import '../core/di/service_locator.dart';
import '../features/products/domain/entities/product_entity.dart';
import '../features/products/domain/usecases/get_products_usecase.dart';
import '../features/products/presentation/bloc/products_bloc.dart';
import '../features/products/presentation/bloc/products_event.dart';
import '../features/products/presentation/bloc/products_state.dart';

class ProductsView extends StatefulWidget {
  const ProductsView({super.key});

  @override
  State<ProductsView> createState() => _ProductsViewState();
}

class _ProductsViewState extends State<ProductsView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int? _selectedProductIndex;
  String _selectedCategory = 'All';

  late List<Map<String, dynamic>> _products;

  final List<String> _categories = ['All', 'Hair Care', 'Beard Care', 'Tools'];

  @override
  void initState() {
    super.initState();
    _products = [];
  }

  List<Map<String, dynamic>> _mapProducts(List<ProductEntity> products) {
    return products
        .map(
          (product) => {
            'name': product.name,
            'price': product.price,
            'rating': product.rating,
            'description': product.description,
            'icon': product.icon,
            'accentColor': product.accentColor,
          },
        )
        .toList();
  }

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

    return BlocProvider(
      create: (_) =>
          ProductsBloc(getProductsUseCase: getIt<GetProductsUseCase>())
            ..add(const ProductsLoadRequested()),
      child: BlocListener<ProductsBloc, ProductsState>(
        listener: (context, state) {
          if (state is ProductsLoaded) {
            setState(() {
              _products = _mapProducts(state.products);
            });
          }
        },
        child: Scaffold(
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
                // Modern search header
                Container(
                  padding: EdgeInsets.all(AiSpacing.lg),
                  decoration: BoxDecoration(
                    color: AdaptiveThemeColors.backgroundDark(context),
                    border: Border(
                      bottom: BorderSide(
                        color: AdaptiveThemeColors.borderLight(
                          context,
                        ).withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search field
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
                          hintText: 'Search products...',
                          hintStyle: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AdaptiveThemeColors.textTertiary(
                                  context,
                                ),
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
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: AiSpacing.md,
                            vertical: AiSpacing.md,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AiSpacing.radiusLarge,
                            ),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AiSpacing.radiusLarge,
                            ),
                            borderSide: BorderSide(
                              color: AdaptiveThemeColors.borderLight(
                                context,
                              ).withValues(alpha: 0.2),
                              width: 1,
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
                      SizedBox(height: AiSpacing.md),
                      // Category chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _categories.map((category) {
                            final isSelected = _selectedCategory == category;
                            final Color accentColor = category == 'Hair Care'
                                ? AdaptiveThemeColors.neonCyan(context)
                                : category == 'Beard Care'
                                ? AdaptiveThemeColors.sunsetCoral(context)
                                : category == 'Tools'
                                ? AdaptiveThemeColors.neonPurple(context)
                                : AdaptiveThemeColors.neonCyan(context);

                            return Padding(
                              padding: EdgeInsets.only(right: AiSpacing.sm),
                              child: _buildCategoryChip(
                                category,
                                isSelected,
                                accentColor,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                // Products list
                Expanded(
                  child: filteredProducts.isEmpty
                      ? _buildEmptyState(context)
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.all(AiSpacing.lg),
                          itemCount: filteredProducts.length,
                          itemBuilder: (context, index) {
                            final product = filteredProducts[index];
                            final isSelected = _selectedProductIndex == index;
                            return Padding(
                              padding: EdgeInsets.only(bottom: AiSpacing.md),
                              child: _buildProductCard(
                                context,
                                product,
                                isSelected,
                                index,
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected, Color accentColor) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = label;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: AiSpacing.md,
          vertical: AiSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
          border: Border.all(
            color: isSelected
                ? accentColor
                : AdaptiveThemeColors.borderLight(
                    context,
                  ).withValues(alpha: 0.3),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: isSelected
                ? accentColor
                : AdaptiveThemeColors.textSecondary(context),
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(AiSpacing.xl),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AdaptiveThemeColors.neonCyan(context).withValues(alpha: 0.2),
                  AdaptiveThemeColors.neonPurple(
                    context,
                  ).withValues(alpha: 0.2),
                ],
              ),
            ),
            child: Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: AdaptiveThemeColors.neonCyan(context),
            ),
          ),
          SizedBox(height: AiSpacing.xl),
          Text(
            'No products found',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AdaptiveThemeColors.textPrimary(context),
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: AiSpacing.sm),
          Text(
            'Try a different search term',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AdaptiveThemeColors.textTertiary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    Map<String, dynamic> product,
    bool isSelected,
    int index,
  ) {
    final Color accentColor =
        (product['accentColor'] as Color?) ??
        AdaptiveThemeColors.neonCyan(context);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedProductIndex = isSelected ? null : index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AdaptiveThemeColors.backgroundSecondary(context),
              AdaptiveThemeColors.surface(context),
            ],
          ),
          borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
          border: Border.all(
            color: isSelected
                ? accentColor.withValues(alpha: 0.5)
                : AdaptiveThemeColors.borderLight(
                    context,
                  ).withValues(alpha: 0.2),
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? accentColor.withValues(alpha: 0.2)
                  : Colors.transparent,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(AiSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      accentColor.withValues(alpha: 0.2),
                      accentColor.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AiSpacing.radiusMedium),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  product['icon'] as IconData? ?? Icons.shopping_bag,
                  color: accentColor,
                  size: 28,
                ),
              ),
              SizedBox(width: AiSpacing.md),
              // Product details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['name'] as String,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AdaptiveThemeColors.textPrimary(context),
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: AiSpacing.xs),
                    Text(
                      product['description'] as String,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AdaptiveThemeColors.textSecondary(context),
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: AiSpacing.sm),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AiSpacing.sm,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: accentColor.withValues(alpha: 0.4),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            '₹${product['price']}',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: accentColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                          ),
                        ),
                        SizedBox(width: AiSpacing.sm),
                        Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: AdaptiveThemeColors.sunsetCoral(context),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${product['rating']}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AdaptiveThemeColors.textSecondary(
                                  context,
                                ),
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                        ),
                      ],
                    ),
                    if (isSelected) ...[
                      SizedBox(height: AiSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                // View details
                              },
                              icon: Icon(Icons.visibility_outlined, size: 16),
                              label: Text(
                                'View',
                                style: TextStyle(fontSize: 12),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: accentColor,
                                side: BorderSide(
                                  color: accentColor.withValues(alpha: 0.5),
                                  width: 1.5,
                                ),
                                padding: EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AiSpacing.radiusMedium,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: AiSpacing.sm),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '${product['name']} added to cart!',
                                    ),
                                    backgroundColor:
                                        AdaptiveThemeColors.success(context),
                                    duration: const Duration(
                                      milliseconds: 1500,
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                setState(() {
                                  _selectedProductIndex = null;
                                });
                              },
                              icon: Icon(Icons.add_shopping_cart, size: 16),
                              label: Text(
                                'Add',
                                style: TextStyle(fontSize: 12),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accentColor,
                                foregroundColor:
                                    AdaptiveThemeColors.backgroundDeep(context),
                                padding: EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AiSpacing.radiusMedium,
                                  ),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
