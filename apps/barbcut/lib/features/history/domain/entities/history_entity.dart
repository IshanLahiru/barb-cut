import 'package:flutter/material.dart';

class HistoryEntity {
  final String id;
  final String imageUrl;
  final String haircut;
  final String beard;
  final DateTime timestamp;
  final Color accentColor;

  const HistoryEntity({
    required this.id,
    required this.imageUrl,
    required this.haircut,
    required this.beard,
    required this.timestamp,
    required this.accentColor,
  });
}
