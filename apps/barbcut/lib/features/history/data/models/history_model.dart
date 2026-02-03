import '../../domain/entities/history_entity.dart';

class HistoryModel extends HistoryEntity {
  const HistoryModel({
    required super.id,
    required super.imageUrl,
    required super.haircut,
    required super.beard,
    required super.timestamp,
  });

  factory HistoryModel.fromMap(Map<String, dynamic> map) {
    return HistoryModel(
      id: map['id'] as String,
      imageUrl: map['imageUrl'] as String,
      haircut: map['haircut'] as String,
      beard: map['beard'] as String,
      timestamp: map['timestamp'] as DateTime,
    );
  }
}
