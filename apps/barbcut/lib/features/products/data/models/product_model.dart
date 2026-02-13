import 'package:flutter/material.dart';
import '../../domain/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  final String iconName;

  const ProductModel({
    required super.name,
    required super.price,
    required super.rating,
    required super.description,
    required super.imageUrl,
    required super.icon,
    required this.iconName,
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

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    final iconName = map['icon'] as String;
    return ProductModel(
      name: map['name'] as String,
      price: map['price'] as String,
      rating: (map['rating'] as num).toDouble(),
      description: map['description'] as String,
      imageUrl: map['image'] as String,
      icon: _getIconData(iconName),
      iconName: iconName,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'rating': rating,
      'description': description,
      'image': imageUrl,
      'icon': iconName,
    };
  }
}
