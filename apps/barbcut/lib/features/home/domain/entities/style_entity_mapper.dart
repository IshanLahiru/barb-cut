import 'style_entity.dart';

/// Extension methods to convert StyleEntity to UI-friendly Map format.
///
/// This keeps the domain entities clean and lightweight while providing
/// the UI with the data format it expects.
extension StyleEntityMapperX on StyleEntity {
  /// Converts this StyleEntity to a `Map<String, dynamic>` format for UI consumption.
  ///
  /// This map includes all the fields the UI needs, including:
  /// - Basic fields: id, name, description, image (imageUrl)
  /// - Images: images list (from styleImages.toList()), imagesMap (keyed by angle)
  /// - Metadata: suitableFaceShapes, maintenanceTips
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image': imageUrl,
      // Full ordered list from styleImages so carousel gets all angles
      'images': styleImages.toList(),
      'imagesMap': {
        'front': styleImages.front,
        'left_side': styleImages.leftSide,
        'right_side': styleImages.rightSide,
        'back': styleImages.back,
      },
      'suitableFaceShapes': suitableFaceShapes,
      'maintenanceTips': maintenanceTips,
      // Include additional metadata that might be useful
      'price': price,
      'duration': duration,
      'tips': tips,
      'type': type.name,
    };
  }
}

/// Extension on `List<StyleEntity>` to efficiently convert to maps.
extension StyleEntityListMapperX on List<StyleEntity> {
  /// Converts all entities to maps in one operation.
  ///
  /// Useful for converting entire lists when needed, though consider
  /// lazy conversion (entity by entity) for better performance.
  List<Map<String, dynamic>> toMaps() {
    return map((entity) => entity.toMap()).toList();
  }
}
