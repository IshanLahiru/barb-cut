import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class ProductEntity extends Equatable {
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

  @override
  List<Object?> get props => [name, price, rating, description, imageUrl, icon];
}
