import 'package:barbcut/theme/ai_colors.dart';
import '../../domain/entities/style_entity.dart';
import '../models/style_model.dart';

abstract class HomeLocalDataSource {
  Future<List<StyleModel>> getHaircuts();
  Future<List<StyleModel>> getBeardStyles();
}

class HomeLocalDataSourceImpl implements HomeLocalDataSource {
  @override
  Future<List<StyleModel>> getHaircuts() async {
    return _haircutData
        .map((item) => StyleModel.fromMap(item, StyleType.haircut))
        .toList();
  }

  @override
  Future<List<StyleModel>> getBeardStyles() async {
    return _beardData
        .map((item) => StyleModel.fromMap(item, StyleType.beard))
        .toList();
  }

  // TODO: Replace with full dataset from HomeView during migration.
  static final List<Map<String, dynamic>> _haircutData = [
    {
      'name': 'Classic Fade',
      'price': '\$25',
      'duration': '30 min',
      'description': 'A timeless fade that never goes out of style',
      'image':
          'https://images.unsplash.com/photo-1622286342621-4bd786c2447c?w=400&h=400&fit=crop',
      'accentColor': AiColors.neonCyan,
    },
    {
      'name': 'Buzz Cut',
      'price': '\$15',
      'duration': '15 min',
      'description': 'Clean and simple, perfect for low maintenance',
      'image':
          'https://images.unsplash.com/photo-1621605815971-fbc98d665033?w=400&h=400&fit=crop',
      'accentColor': AiColors.sunsetCoral,
    },
  ];

  static final List<Map<String, dynamic>> _beardData = [
    {
      'name': 'Short Boxed',
      'price': '\$18',
      'duration': '20 min',
      'description': 'Neat boxed beard with clean lines',
      'image':
          'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400&h=400&fit=crop',
      'accentColor': AiColors.neonCyan,
    },
    {
      'name': 'Full Beard',
      'price': '\$25',
      'duration': '30 min',
      'description': 'Full beard with shape and detail',
      'image':
          'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=400&h=400&fit=crop',
      'accentColor': AiColors.neonPurple,
    },
  ];
}
