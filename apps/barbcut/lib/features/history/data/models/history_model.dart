import 'package:cloud_firestore/cloud_firestore.dart';
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
    final rawTimestamp = map['timestamp'];
    final timestamp = rawTimestamp is Timestamp
        ? rawTimestamp.toDate()
        : rawTimestamp as DateTime;

    return HistoryModel(
      id: map['id'] as String,
      imageUrl: (map['imageUrl'] ?? map['image']) as String,
      haircut: map['haircut'] as String,
      beard: map['beard'] as String,
      timestamp: timestamp,
    );
  }
}
