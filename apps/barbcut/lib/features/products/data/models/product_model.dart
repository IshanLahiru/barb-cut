import 'package:flutter/material.dart';
import '../../domain/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.name,
    required super.price,
    required super.rating,
    required super.description,
    required super.imageUrl,
    required super.icon,
  });

  /// Convert icon name string to IconData
  static IconData _getIconData(String iconName) {
    final iconMap = {
      'palette': Icons.palette,
      'water_drop': Icons.water_drop,
      'shower': Icons.shower,
      'brush': Icons.brush,
      'content_cut': Icons.content_cut,
    };
    return iconMap[iconName] ?? Icons.shopping_bag;
  }

  /// Parses from Firestore/JSON. Tolerates price/rating as num and image/imageUrl.
  factory ProductModel.fromMap(Map<String, dynamic> map) {
    final name = map['name'];
    if (name == null || name is! String || name.isEmpty) {
      throw ArgumentError('Product map must have a non-empty "name" (String).');
    }

    final priceRaw = map['price'];
    final price = priceRaw is num
        ? priceRaw.toString()
        : priceRaw is String
            ? priceRaw
            : throw ArgumentError('Product "price" must be num or String.');

    final ratingRaw = map['rating'];
    final rating = ratingRaw is num
        ? ratingRaw.toDouble()
        : ratingRaw is String
            ? (double.tryParse(ratingRaw) ?? 0.0)
            : 0.0;

    final description = map['description'] is String
        ? map['description'] as String
        : (map['description']?.toString() ?? '');

    final imageUrl = map['image'] ?? map['imageUrl'];
    if (imageUrl == null || imageUrl is! String || imageUrl.isEmpty) {
      throw ArgumentError(
        'Product map must have "image" or "imageUrl" (non-empty String).',
      );
    }

    final iconName = map['icon'] is String ? map['icon'] as String : 'shopping_bag';

    return ProductModel(
      name: name,
      price: price,
      rating: rating,
      description: description,
      imageUrl: imageUrl,
      icon: _getIconData(iconName),
    );
  }
}
