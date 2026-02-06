enum StyleType { haircut, beard }

class StyleEntity {
  final String name;
  final String? price;
  final String? duration;
  final String? tips;
  final String description;
  final String imageUrl;
  final StyleType type;

  const StyleEntity({
    required this.name,
    this.price,
    this.duration,
    this.tips,
    required this.description,
    required this.imageUrl,
    required this.type,
  });
}
