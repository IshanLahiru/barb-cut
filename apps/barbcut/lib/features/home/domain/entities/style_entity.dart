enum StyleType { haircut, beard }

enum ImageAngle { front, leftSide, rightSide, back }

class StyleImages {
  final String front;
  final String leftSide;
  final String rightSide;
  final String back;

  const StyleImages({
    required this.front,
    required this.leftSide,
    required this.rightSide,
    required this.back,
  });

  List<String> toList() => [front, leftSide, rightSide, back];

  String getByAngle(ImageAngle angle) {
    switch (angle) {
      case ImageAngle.front:
        return front;
      case ImageAngle.leftSide:
        return leftSide;
      case ImageAngle.rightSide:
        return rightSide;
      case ImageAngle.back:
        return back;
    }
  }
}

class StyleEntity {
  final String id;
  final String name;
  final String? price;
  final String? duration;
  final String? tips;
  final StyleImages styleImages;
  final List<String> images; // Kept for backward compatibility
  final List<String> suitableFaceShapes;
  final List<String> maintenanceTips;
  final String description;
  final String imageUrl;
  final StyleType type;

  const StyleEntity({
    required this.id,
    required this.name,
    this.price,
    this.duration,
    this.tips,
    required this.styleImages,
    required this.images,
    required this.suitableFaceShapes,
    required this.maintenanceTips,
    required this.description,
    required this.imageUrl,
    required this.type,
  });
}
