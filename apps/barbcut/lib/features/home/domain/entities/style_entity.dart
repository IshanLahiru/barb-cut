enum StyleType { haircut, beard }

class StyleEntity {
  final String name;
  final String price;
  final String duration;
  final String description;
  final String imageUrl;
  final StyleType type;

  const StyleEntity({
    required this.name,
    required this.price,
    required this.duration,
    required this.description,
    required this.imageUrl,
    required this.type,
  });
}
