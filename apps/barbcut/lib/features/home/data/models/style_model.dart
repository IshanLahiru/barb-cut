import '../../domain/entities/style_entity.dart';

class StyleModel extends StyleEntity {
  const StyleModel({
    required super.id,
    required super.name,
    super.price,
    super.duration,
    super.tips,
    required super.styleImages,
    required super.images,
    required super.suitableFaceShapes,
    required super.maintenanceTips,
    required super.description,
    required super.imageUrl,
    required super.type,
  });

  factory StyleModel.fromMap(Map<String, dynamic> map, StyleType type) {
    // Parse images - support both old array format and new map format
    StyleImages? styleImages;
    List<String> imagesList = [];

    final imagesData = map['images'];

    if (imagesData is Map<String, dynamic>) {
      // New format: map with front, left_side, right_side, back
      styleImages = StyleImages(
        front: imagesData['front'] as String? ?? '',
        leftSide: imagesData['left_side'] as String? ?? '',
        rightSide: imagesData['right_side'] as String? ?? '',
        back: imagesData['back'] as String? ?? '',
      );
      imagesList = styleImages.toList();
    } else if (imagesData is List) {
      // Old format: array of images
      imagesList = imagesData.map((value) => value as String).toList();
      // Convert to StyleImages using array indices
      styleImages = StyleImages(
        front: imagesList.isNotEmpty ? imagesList[0] : '',
        leftSide: imagesList.length > 1
            ? imagesList[1]
            : imagesList.isNotEmpty
            ? imagesList[0]
            : '',
        rightSide: imagesList.length > 2
            ? imagesList[2]
            : imagesList.isNotEmpty
            ? imagesList[0]
            : '',
        back: imagesList.length > 3
            ? imagesList[3]
            : imagesList.isNotEmpty
            ? imagesList[0]
            : '',
      );
    } else if (map['image'] != null) {
      // Fallback: single image field
      final singleImage = map['image'] as String;
      imagesList = [singleImage];
      styleImages = StyleImages(
        front: singleImage,
        leftSide: singleImage,
        rightSide: singleImage,
        back: singleImage,
      );
    } else {
      // Default empty
      styleImages = const StyleImages(
        front: '',
        leftSide: '',
        rightSide: '',
        back: '',
      );
    }

    // Parse maintenance tips - support both string and array
    List<String> maintenanceTipsList = [];
    final tipsData = map['maintenanceTips'];
    if (tipsData is List) {
      maintenanceTipsList = tipsData.map((value) => value as String).toList();
    } else if (tipsData is String) {
      maintenanceTipsList = [tipsData];
    }

    final imageUrl = map['image'] as String?;
    imagesList = imagesList.where((value) => value.trim().isNotEmpty).toList();
    final resolvedImageUrl =
        imageUrl ?? (imagesList.isNotEmpty ? imagesList.first : '');
    if (imagesList.isEmpty && resolvedImageUrl.isNotEmpty) {
      imagesList = [resolvedImageUrl];
    }

    return StyleModel(
      id:
          map['id'] as String? ??
          map['name'].toString().toLowerCase().replaceAll(' ', '-'),
      name: map['name'] as String,
      price: map['price'] as String?,
      duration: map['duration'] as String?,
      tips: map['tips'] as String?,
      styleImages: styleImages,
      images: imagesList,
      suitableFaceShapes:
          (map['suitableFaceShapes'] as List?)
              ?.map((value) => value as String)
              .toList() ??
          <String>[],
      maintenanceTips: maintenanceTipsList,
      description: map['description'] as String,
      imageUrl: resolvedImageUrl,
      type: type,
    );
  }
}
