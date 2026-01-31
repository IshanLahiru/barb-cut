import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../theme/adaptive_theme_colors.dart';
import '../theme/ai_spacing.dart';
import '../shared/widgets/atoms/category_chip.dart';
import '../shared/widgets/molecules/product_card.dart';
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

  late List<Map<String, dynamic>> _products;

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
      create: (_) => ProductsBloc(
        getProductsUseCase: getIt<GetProductsUseCase>(),
      )..add(const ProductsLoadRequested()),
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
                      CategoryChip(
                        label: 'Hair Care',
                        color: AdaptiveThemeColors.neonCyan(context),
                      ),
                      CategoryChip(
                        label: 'Beard Care',
                        color: AdaptiveThemeColors.sunsetCoral(context),
                      ),
                      CategoryChip(
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
                          child: ProductCard(
                            product: product,
                            isSelected: isSelected,
                            onTap: () {
                              setState(() {
                                _selectedProductIndex = isSelected
                                    ? null
                                    : index;
                              });
                            },
                            onView: () {},
                            onAdd: () {
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
}