import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/lazy_network_image.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
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
            'image': product.imageUrl,
            'icon': product.icon,
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

    final width = MediaQuery.of(context).size.width;
    int crossAxisCount = 2;
    if (width >= 1100) {
      crossAxisCount = 4;
    } else if (width >= 820) {
      crossAxisCount = 3;
    }

    return BlocProvider(
      create: (_) =>
          ProductsBloc(getProductsUseCase: getIt<GetProductsUseCase>())
            ..add(const ProductsLoadRequested()),
      child: BlocConsumer<ProductsBloc, ProductsState>(
        listener: (context, state) {
          if (state is ProductsLoaded) {
            setState(() {
              _products = _mapProducts(state.products);
            });
          }
        },
        buildWhen: (previous, current) => true,
        builder: (context, state) {
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
                  // Products list: loading, error, or content
                  Expanded(
                    child: _buildProductsBody(
                      context,
                      state,
                      filteredProducts,
                      crossAxisCount,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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

  Widget _buildProductsBody(
    BuildContext context,
    ProductsState state,
    List<Map<String, dynamic>> filteredProducts,
    int crossAxisCount,
  ) {
    if (state is ProductsLoading || state is ProductsInitial) {
      return _buildProductsLoadingSkeleton(context, crossAxisCount);
    }
    if (state is ProductsFailure) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(AiSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: AdaptiveThemeColors.sunsetCoral(context),
              ),
              SizedBox(height: AiSpacing.md),
              Text(
                'Could not load products',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AdaptiveThemeColors.textPrimary(context),
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AiSpacing.sm),
              Text(
                state.message,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AdaptiveThemeColors.textTertiary(context),
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: AiSpacing.lg),
              FilledButton.icon(
                onPressed: () {
                  context.read<ProductsBloc>().add(const ProductsLoadRequested());
                },
                icon: const Icon(Icons.refresh_rounded, size: 20),
                label: const Text('Retry'),
                style: FilledButton.styleFrom(
                  backgroundColor: AdaptiveThemeColors.neonCyan(context),
                  foregroundColor: AdaptiveThemeColors.backgroundDeep(context),
                ),
              ),
            ],
          ),
        ),
      );
    }
    if (filteredProducts.isEmpty) {
      return _buildEmptyState(context);
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AiSpacing.md,
        AiSpacing.sm,
        AiSpacing.md,
        AiSpacing.md,
      ),
      child: MasonryGridView.builder(
        physics: const BouncingScrollPhysics(),
        gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
        ),
        itemCount: filteredProducts.length,
        mainAxisSpacing: AiSpacing.md,
        crossAxisSpacing: AiSpacing.md,
        itemBuilder: (context, index) {
          final product = filteredProducts[index];
          return _buildProductTile(context, product, index);
        },
      ),
    );
  }

  /// Skeleton grid matching the shop product layout (same as home page style).
  Widget _buildProductsLoadingSkeleton(
    BuildContext context,
    int crossAxisCount,
  ) {
    final baseColor = Colors.white.withValues(alpha: 0.06);
    final highlightColor = Colors.white.withValues(alpha: 0.14);
    const skeletonItemCount = 6;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AiSpacing.md,
        AiSpacing.sm,
        AiSpacing.md,
        AiSpacing.md,
      ),
      child: MasonryGridView.builder(
        physics: const BouncingScrollPhysics(),
        gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
        ),
        itemCount: skeletonItemCount,
        mainAxisSpacing: AiSpacing.md,
        crossAxisSpacing: AiSpacing.md,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
              color: AdaptiveThemeColors.backgroundDark(context),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final w = constraints.maxWidth;
                  final imageHeight = w * 1.5; // 2/3 aspect ratio
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerPlaceholder(
                        width: w,
                        height: imageHeight,
                        baseColor: baseColor,
                        highlightColor: highlightColor,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(AiSpacing.md),
                        child: Row(
                          children: [
                            ShimmerPlaceholder(
                              width: 56,
                              height: 14,
                              baseColor: baseColor,
                              highlightColor: highlightColor,
                            ),
                            const Spacer(),
                            ShimmerPlaceholder(
                              width: 28,
                              height: 14,
                              baseColor: baseColor,
                              highlightColor: highlightColor,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
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

  Widget _buildProductTile(
    BuildContext context,
    Map<String, dynamic> product,
    int index,
  ) {
    final Color accentColor =
        // Using general color:
        AdaptiveThemeColors.neonCyan(context);

    return GestureDetector(
      onTap: () {
        _showProductDetailsDialog(context, product);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
          color: AdaptiveThemeColors.backgroundDark(context),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 2 / 3,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    GridLazyImage(
                      imageUrl: product['image'] as String,
                      fit: BoxFit.cover,
                      customErrorWidget: Container(
                        color: accentColor.withValues(alpha: 0.2),
                        child: Icon(
                          Icons.image_not_supported,
                          size: 48,
                          color: accentColor.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.5),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: AiSpacing.md,
                      right: AiSpacing.md,
                      bottom: AiSpacing.sm,
                      child: Text(
                        product['name'] as String,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AiSpacing.md),
                child: Row(
                  children: [
                    Text(
                      '₹${product['price']}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AdaptiveThemeColors.textPrimary(context),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.star_rounded,
                      size: 14,
                      color: AdaptiveThemeColors.sunsetCoral(context),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${product['rating']}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AdaptiveThemeColors.textSecondary(context),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showProductDetailsDialog(
    BuildContext context,
    Map<String, dynamic> product,
  ) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        final Color accentColor =
            // Using general color:
            AdaptiveThemeColors.neonCyan(dialogContext);
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(AiSpacing.lg),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 520),
            decoration: BoxDecoration(
              color: AdaptiveThemeColors.backgroundDark(
                dialogContext,
              ).withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(AiSpacing.radiusLarge),
                    ),
                    child: AspectRatio(
                      aspectRatio: 2 / 3,
                      child: GridLazyImage(
                        imageUrl: product['image'] as String,
                        fit: BoxFit.cover,
                        customErrorWidget: Container(
                          color: accentColor.withValues(alpha: 0.2),
                          child: Icon(
                            Icons.image_not_supported,
                            size: 64,
                            color: accentColor.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AiSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product['name'] as String,
                          style: Theme.of(dialogContext).textTheme.titleLarge
                              ?.copyWith(
                                color: AdaptiveThemeColors.textPrimary(
                                  dialogContext,
                                ),
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        SizedBox(height: AiSpacing.xs),
                        Row(
                          children: [
                            Text(
                              '₹${product['price']}',
                              style: Theme.of(dialogContext)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: accentColor,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.star_rounded,
                              size: 16,
                              color: AdaptiveThemeColors.sunsetCoral(
                                dialogContext,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${product['rating']}',
                              style: Theme.of(dialogContext).textTheme.bodySmall
                                  ?.copyWith(
                                    color: AdaptiveThemeColors.textSecondary(
                                      dialogContext,
                                    ),
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                        SizedBox(height: AiSpacing.md),
                        Text(
                          product['description'] as String,
                          style: Theme.of(dialogContext).textTheme.bodyMedium
                              ?.copyWith(
                                color: AdaptiveThemeColors.textSecondary(
                                  dialogContext,
                                ),
                              ),
                        ),
                        SizedBox(height: AiSpacing.lg),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(dialogContext),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor:
                                      AdaptiveThemeColors.textSecondary(
                                        dialogContext,
                                      ),
                                  side: BorderSide(
                                    color: AdaptiveThemeColors.borderLight(
                                      dialogContext,
                                    ).withValues(alpha: 0.4),
                                    width: 1.5,
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    vertical: AiSpacing.md,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AiSpacing.radiusMedium,
                                    ),
                                  ),
                                ),
                                child: Text('Close'),
                              ),
                            ),
                            SizedBox(width: AiSpacing.md),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(dialogContext);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${product['name']} ready to buy now!',
                                      ),
                                      backgroundColor:
                                          AdaptiveThemeColors.success(context),
                                      duration: const Duration(
                                        milliseconds: 1500,
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: accentColor,
                                  foregroundColor:
                                      AdaptiveThemeColors.backgroundDeep(
                                        dialogContext,
                                      ),
                                  padding: EdgeInsets.symmetric(
                                    vertical: AiSpacing.md,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AiSpacing.radiusMedium,
                                    ),
                                  ),
                                ),
                                child: Text('Buy Now'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
