import 'package:flutter/material.dart';
import '../../domain/entities/history_entity.dart';

class HistoryModel extends HistoryEntity {
  const HistoryModel({
    required String id,
    required String imageUrl,
    required String haircut,
    required String beard,
    required DateTime timestamp,
    required Color accentColor,
  }) : super(
    id: id,
    imageUrl: imageUrl,
    haircut: haircut,
    beard: beard,
    timestamp: timestamp,
    accentColor: accentColor,
  );

  factory HistoryModel.fromMap(Map<String, dynamic> map, Color accentColor) {
    return HistoryModel(
      id: map['id'] as String,
      imageUrl: map['imageUrl'] as String,
      haircut: map['haircut'] as String,
      beard: map['beard'] as String,
      timestamp: map['timestamp'] as DateTime,
      accentColor: accentColor,
    );
  }
}
