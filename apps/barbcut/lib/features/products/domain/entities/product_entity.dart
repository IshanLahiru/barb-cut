import 'package:flutter/material.dart';

class ProductEntity {
  final String name;
  final String price;
  final double rating;
  final String description;
  final IconData icon;
  final Color accentColor;

  const ProductEntity({
    required this.name,
    required this.price,
    required this.rating,
    required this.description,
    required this.icon,
    required this.accentColor,
  });
}
