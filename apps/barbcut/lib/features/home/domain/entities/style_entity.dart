enum StyleType { haircut, beard }

class StyleEntity {
  final String name;
  final String? price;
  final String? duration;
  final String? tips;
  final List<String> images;
  final List<String> suitableFaceShapes;
  final String maintenanceTips;
  final String description;
  final String imageUrl;
  final StyleType type;

  const StyleEntity({
    required this.name,
    this.price,
    this.duration,
    this.tips,
    required this.images,
    required this.suitableFaceShapes,
    required this.maintenanceTips,
    required this.description,
    required this.imageUrl,
    required this.type,
  });
}
