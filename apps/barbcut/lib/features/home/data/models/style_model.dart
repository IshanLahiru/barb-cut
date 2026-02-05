import '../../domain/entities/style_entity.dart';

class StyleModel extends StyleEntity {
  const StyleModel({
    required super.name,
    required super.price,
    required super.duration,
    required super.description,
    required super.imageUrl,
    required super.type,
  });

  factory StyleModel.fromMap(Map<String, dynamic> map, StyleType type) {
    return StyleModel(
      name: map['name'] as String,
      price: map['price'] as String,
      duration: map['duration'] as String,
      description: map['description'] as String,
      imageUrl: map['image'] as String,
      type: type,
    );
  }
}
