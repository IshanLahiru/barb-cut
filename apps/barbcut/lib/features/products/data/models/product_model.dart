import 'package:flutter/material.dart';
import '../../domain/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required String name,
    required String price,
    required double rating,
    required String description,
    required IconData icon,
    required Color accentColor,
  }) : super(
         name: name,
         price: price,
         rating: rating,
         description: description,
         icon: icon,
         accentColor: accentColor,
       );

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
