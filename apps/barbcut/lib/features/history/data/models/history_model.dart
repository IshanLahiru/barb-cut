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
    return HistoryModel(
      id: map['id'] as String,
      imageUrl: map['imageUrl'] as String,
      haircut: map['haircut'] as String,
      beard: map['beard'] as String,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'haircut': haircut,
      'beard': beard,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
