import '../../domain/entities/style_entity.dart';

class StyleModel extends StyleEntity {
  const StyleModel({
    required super.name,
    super.price,
    super.duration,
    super.tips,
    required super.images,
    required super.suitableFaceShapes,
    required super.maintenanceTips,
    required super.description,
    required super.imageUrl,
    required super.type,
  });

  factory StyleModel.fromMap(Map<String, dynamic> map, StyleType type) {
    final images =
        (map['images'] as List?)?.map((value) => value as String).toList() ??
        (map['image'] != null ? [map['image'] as String] : <String>[]);
    final imageUrl = map['image'] as String?;
    return StyleModel(
      name: map['name'] as String,
      price: map['price'] as String?,
      duration: map['duration'] as String?,
      tips: map['tips'] as String?,
      images: images,
      suitableFaceShapes:
          (map['suitableFaceShapes'] as List?)
              ?.map((value) => value as String)
              .toList() ??
          <String>[],
      maintenanceTips: map['maintenanceTips'] as String? ?? '',
      description: map['description'] as String,
      imageUrl: imageUrl ?? (images.isNotEmpty ? images.first : ''),
      type: type,
    );
  }
}
