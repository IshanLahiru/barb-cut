class HistoryEntity {
  final String id;
  final String imageUrl;
  final String haircut;
  final String beard;
  final DateTime timestamp;

  const HistoryEntity({
    required this.id,
    required this.imageUrl,
    required this.haircut,
    required this.beard,
    required this.timestamp,
  });
}
