import 'package:flutter/material.dart';

class ProductEntity {
  final String name;
  final String price;
  final double rating;
  final String description;
  final String imageUrl;
  final IconData icon;

  const ProductEntity({
    required this.name,
    required this.price,
    required this.rating,
    required this.description,
    required this.imageUrl,
    required this.icon,
  });
}
