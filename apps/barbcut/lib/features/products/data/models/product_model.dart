import 'package:flutter/material.dart';
import '../../domain/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.name,
    required super.price,
    required super.rating,
    required super.description,
    required super.icon,
    required super.accentColor,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      name: map['name'] as String,
      price: map['price'] as String,
      rating: map['rating'] as double,
      description: map['description'] as String,
      icon: map['icon'] as IconData,
      accentColor: map['accentColor'] as Color,
    );
  }
}
