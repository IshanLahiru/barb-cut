import 'package:flutter/material.dart';
import '../../domain/entities/history_entity.dart';
import '../models/history_model.dart';
import '../../../../theme/ai_colors.dart';

class HistoryLocalDataSource {
  List<HistoryEntity> getHistory() {
    return _buildHistoryData()
        .map((item) => HistoryModel.fromMap(item, item['accentColor'] as Color))
        .toList();
  }

  static List<Map<String, dynamic>> _buildHistoryData() {
    return [
      {
        'id': '1',
        'imageUrl':
            'https://images.unsplash.com/photo-1622286342621-4bd786c2447c?w=400&h=400&fit=crop',
        'haircut': 'Classic Fade',
        'beard': 'Full Beard',
        'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
        'accentColor': AiColors.neonCyan,
      },
      {
        'id': '2',
        'imageUrl':
            'https://images.unsplash.com/photo-1621605815971-fbc98d665033?w=400&h=400&fit=crop',
        'haircut': 'Buzz Cut',
        'beard': 'Stubble',
        'timestamp': DateTime.now().subtract(const Duration(hours: 5)),
        'accentColor': AiColors.sunsetCoral,
      },
      {
        'id': '3',
        'imageUrl':
            'https://images.unsplash.com/photo-1605497788044-5a32c7078486?w=400&h=400&fit=crop',
        'haircut': 'Pompadour',
        'beard': 'Goatee',
        'timestamp': DateTime.now().subtract(const Duration(hours: 12)),
        'accentColor': AiColors.neonPurple,
      },
      {
        'id': '4',
        'imageUrl':
            'https://images.unsplash.com/photo-1599351431202-1e0f0137899a?w=400&h=400&fit=crop',
        'haircut': 'Undercut',
        'beard': 'Full Beard',
        'timestamp': DateTime.now().subtract(const Duration(days: 1)),
        'accentColor': AiColors.neonCyan,
      },
      {
        'id': '5',
        'imageUrl':
            'https://images.unsplash.com/photo-1564564321837-a57b7070ac4f?w=400&h=400&fit=crop',
        'haircut': 'Crew Cut',
        'beard': 'Clean Shaven',
        'timestamp': DateTime.now().subtract(const Duration(days: 2)),
        'accentColor': AiColors.sunsetCoral,
      },
      {
        'id': '6',
        'imageUrl':
            'https://images.unsplash.com/photo-1599351431202-1e0f0137899a?w=400&h=400&fit=crop',
        'haircut': 'Textured Top',
        'beard': 'Stubble',
        'timestamp': DateTime.now().subtract(const Duration(days: 3)),
        'accentColor': AiColors.neonPurple,
      },
    ];
  }
}
