import 'package:flutter/material.dart';
import '../../../../views/products_view.dart';

class ProductsPage extends StatelessWidget {
  final int currentIndex;
  final int tabIndex;

  const ProductsPage({
    super.key,
    required this.currentIndex,
    required this.tabIndex,
  });

  @override
  Widget build(BuildContext context) {
    return ProductsView(
      currentIndex: currentIndex,
      tabIndex: tabIndex,
    );
  }
}
