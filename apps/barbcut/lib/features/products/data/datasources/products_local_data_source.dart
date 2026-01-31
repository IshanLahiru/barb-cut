import 'package:flutter/material.dart';
import '../../domain/entities/product_entity.dart';
import '../models/product_model.dart';
import '../../../../theme/ai_colors.dart';

class ProductsLocalDataSource {
  List<ProductEntity> getProducts() {
    return _buildProductsData()
        .map((item) => ProductModel.fromMap(item))
        .toList();
  }

  static List<Map<String, dynamic>> _buildProductsData() {
    return [
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
  }
}
