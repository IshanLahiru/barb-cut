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
    {
      'name': 'Pompadour',
      'price': '\$35',
      'duration': '45 min',
      'description': 'Bold and stylish with volume on top',
      'image':
          'https://images.unsplash.com/photo-1605497788044-5a32c7078486?w=400&h=400&fit=crop',
      'accentColor': AiColors.neonPurple,
    },
    {
      'name': 'Undercut',
      'price': '\$30',
      'duration': '35 min',
      'description': 'Modern and edgy with short sides',
      'image':
          'https://images.unsplash.com/photo-1622286342621-4bd786c2447c?w=400&h=400&fit=crop',
      'accentColor': AiColors.neonCyan,
    },
    {
      'name': 'Crew Cut',
      'price': '\$20',
      'duration': '20 min',
      'description': 'Professional and neat for any occasion',
      'image':
          'https://images.unsplash.com/photo-1599351431202-1e0f0137899a?w=400&h=400&fit=crop',
      'accentColor': AiColors.sunsetCoral,
    },
    {
      'name': 'Slicked Back',
      'price': '\$28',
      'duration': '32 min',
      'description': 'Sleek and polished for a sophisticated look',
      'image':
          'https://images.unsplash.com/photo-1622286342621-4bd786c2447c?w=400&h=400&fit=crop',
      'accentColor': AiColors.neonPurple,
    },
    {
      'name': 'Textured Top',
      'price': '\$32',
      'duration': '38 min',
      'description': 'Messy texture with clean sides',
      'image':
          'https://images.unsplash.com/photo-1605497788044-5a32c7078486?w=400&h=400&fit=crop',
      'accentColor': AiColors.neonCyan,
    },
    {
      'name': 'Quiff',
      'price': '\$30',
      'duration': '35 min',
      'description': 'Voluminous front with tapered sides',
      'image':
          'https://images.unsplash.com/photo-1621605815971-fbc98d665033?w=400&h=400&fit=crop',
      'accentColor': AiColors.sunsetCoral,
    },
    {
      'name': 'Mohawk',
      'price': '\$35',
      'duration': '40 min',
      'description': 'Bold statement with tall center strip',
      'image':
          'https://images.unsplash.com/photo-1599351431202-1e0f0137899a?w=400&h=400&fit=crop',
      'accentColor': AiColors.neonPurple,
    },
    {
      'name': 'Spiky',
      'price': '\$24',
      'duration': '28 min',
      'description': 'Sharp and edgy spikes throughout',
      'image':
          'https://images.unsplash.com/photo-1622286342621-4bd786c2447c?w=400&h=400&fit=crop',
      'accentColor': AiColors.neonCyan,
    },
    {
      'name': 'French Crop',
      'price': '\$26',
      'duration': '31 min',
      'description': 'Short with textured fringe on top',
      'image':
          'https://images.unsplash.com/photo-1605497788044-5a32c7078486?w=400&h=400&fit=crop',
      'accentColor': AiColors.sunsetCoral,
    },
    {
      'name': 'Taper Fade',
      'price': '\$27',
      'duration': '33 min',
      'description': 'Gradual fade from short to long',
      'image':
          'https://images.unsplash.com/photo-1621605815971-fbc98d665033?w=400&h=400&fit=crop',
      'accentColor': AiColors.neonPurple,
    },
    {
      'name': 'Drop Fade',
      'price': '\$29',
      'duration': '34 min',
      'description': 'Fade that drops behind the ears',
      'image':
          'https://images.unsplash.com/photo-1599351431202-1e0f0137899a?w=400&h=400&fit=crop',
      'accentColor': AiColors.neonCyan,
    },
    {
      'name': 'Bald Fade',
      'price': '\$25',
      'duration': '28 min',
      'description': 'Fades down to skin with length on top',
      'image':
          'https://images.unsplash.com/photo-1622286342621-4bd786c2447c?w=400&h=400&fit=crop',
      'accentColor': AiColors.sunsetCoral,
    },
    {
      'name': 'Mid Fade',
      'price': '\$26',
      'duration': '30 min',
      'description': 'Fade starts at mid-head height',
      'image':
          'https://images.unsplash.com/photo-1605497788044-5a32c7078486?w=400&h=400&fit=crop',
      'accentColor': AiColors.neonPurple,
    },
    {
      'name': 'High Fade',
      'price': '\$28',
      'duration': '32 min',
      'description': 'Fade starts higher for more contrast',
      'image':
          'https://images.unsplash.com/photo-1621605815971-fbc98d665033?w=400&h=400&fit=crop',
      'accentColor': AiColors.neonCyan,
    },
    {
      'name': 'Skin Fade',
      'price': '\$30',
      'duration': '35 min',
      'description': 'Clean fade all the way to skin',
      'image':
          'https://images.unsplash.com/photo-1599351431202-1e0f0137899a?w=400&h=400&fit=crop',
      'accentColor': AiColors.sunsetCoral,
    },
    {
      'name': 'Temple Fade',
      'price': '\$25',
      'duration': '28 min',
      'description': 'Fade concentrated around temples',
      'image':
          'https://images.unsplash.com/photo-1622286342621-4bd786c2447c?w=400&h=400&fit=crop',
      'accentColor': AiColors.neonPurple,
    },
    {
      'name': 'Side Part',
      'price': '\$24',
      'duration': '27 min',
      'description': 'Classic side part with defined line',
      'image':
          'https://images.unsplash.com/photo-1605497788044-5a32c7078486?w=400&h=400&fit=crop',
      'accentColor': AiColors.neonCyan,
    },
    {
      'name': 'Curly Top',
      'price': '\$32',
      'duration': '40 min',
      'description': 'Embraces natural curls with clean sides',
      'image':
          'https://images.unsplash.com/photo-1621605815971-fbc98d665033?w=400&h=400&fit=crop',
      'accentColor': AiColors.sunsetCoral,
    },
    {
      'name': 'Afro',
      'price': '\$28',
      'duration': '35 min',
      'description': 'Full and voluminous natural afro',
      'image':
          'https://images.unsplash.com/photo-1599351431202-1e0f0137899a?w=400&h=400&fit=crop',
      'accentColor': AiColors.neonPurple,
    },
    {
      'name': 'Box Braids',
      'price': '\$40',
      'duration': '90 min',
      'description': 'Intricate protective braided style',
      'image':
          'https://images.unsplash.com/photo-1622286342621-4bd786c2447c?w=400&h=400&fit=crop',
      'accentColor': AiColors.neonCyan,
    },
    {
      'name': 'Cornrows',
      'price': '\$35',
      'duration': '60 min',
      'description': 'Neat rows of braids close to scalp',
      'image':
          'https://images.unsplash.com/photo-1605497788044-5a32c7078486?w=400&h=400&fit=crop',
      'accentColor': AiColors.sunsetCoral,
    },
    {
      'name': 'Dreadlocks',
      'price': '\$50',
      'duration': '120 min',
      'description': 'Signature locked and twisted style',
      'image':
          'https://images.unsplash.com/photo-1621605815971-fbc98d665033?w=400&h=400&fit=crop',
      'accentColor': AiColors.neonPurple,
    },
    {
      'name': 'Man Bun',
      'price': '\$22',
      'duration': '25 min',
      'description': 'Long hair styled into a top knot',
      'image':
          'https://images.unsplash.com/photo-1599351431202-1e0f0137899a?w=400&h=400&fit=crop',
      'accentColor': AiColors.neonCyan,
    },
  ];

  static final List<Map<String, dynamic>> _beardData = [
    {
      'name': 'Full Beard',
      'price': '\$20',
      'duration': '25 min',
      'description': 'A classic full beard, well-groomed.',
      'image':
          'https://images.unsplash.com/photo-1564564321837-a57b7070ac4f?w=400&h=400&fit=crop',
      'accentColor': AiColors.neonPurple,
    },
    {
      'name': 'Goatee',
      'price': '\$15',
      'duration': '20 min',
      'description': 'A stylish goatee, precisely trimmed.',
      'image':
          'https://images.unsplash.com/photo-1595152452543-e5c9d2e39c2d?w=400&h=400&fit=crop',
      'accentColor': AiColors.neonCyan,
    },
    {
      'name': 'Stubble',
      'price': '\$10',
      'duration': '10 min',
      'description': 'A short, rugged stubble.',
      'image':
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop',
      'accentColor': AiColors.sunsetCoral,
    },
    {
      'name': 'Van Dyke',
      'price': '\$25',
      'duration': '30 min',
      'description': 'Curled mustache with soul patch',
      'image':
          'https://images.unsplash.com/photo-1564564321837-a57b7070ac4f?w=400&h=400&fit=crop',
      'accentColor': AiColors.neonPurple,
    },
    {
      'name': 'Ducktail',
      'price': '\$22',
      'duration': '27 min',
      'description': 'Pointed beard shaped like a duck tail',
      'image':
          'https://images.unsplash.com/photo-1595152452543-e5c9d2e39c2d?w=400&h=400&fit=crop',
      'accentColor': AiColors.neonCyan,
    },
    {
      'name': 'Verdi',
      'price': '\$20',
      'duration': '25 min',
      'description': 'Pointed full beard with clean lines',
      'image':
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop',
      'accentColor': AiColors.sunsetCoral,
    },
    {
      'name': 'Balbo',
      'price': '\$18',
      'duration': '22 min',
      'description': 'Disconnected mustache with goatee',
      'image':
          'https://images.unsplash.com/photo-1564564321837-a57b7070ac4f?w=400&h=400&fit=crop',
      'accentColor': AiColors.neonPurple,
    },
    {
      'name': 'Anchor',
      'price': '\$19',
      'duration': '23 min',
      'description': 'Goatee with soul patch extension',
      'image':
          'https://images.unsplash.com/photo-1595152452543-e5c9d2e39c2d?w=400&h=400&fit=crop',
      'accentColor': AiColors.neonCyan,
    },
    {
      'name': 'Chevron',
      'price': '\$16',
      'duration': '20 min',
      'description': 'Full mustache covering upper lip',
      'image':
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop',
      'accentColor': AiColors.sunsetCoral,
    },
    {
      'name': 'Handlebar',
      'price': '\$17',
      'duration': '21 min',
      'description': 'Distinctive curled upturned mustache',
      'image':
          'https://images.unsplash.com/photo-1564564321837-a57b7070ac4f?w=400&h=400&fit=crop',
      'accentColor': AiColors.neonPurple,
    },
    {
      'name': 'Pencil Stache',
      'price': '\$12',
      'duration': '15 min',
      'description': 'Thin, refined mustache line',
      'image':
          'https://images.unsplash.com/photo-1595152452543-e5c9d2e39c2d?w=400&h=400&fit=crop',
      'accentColor': AiColors.neonCyan,
    },
    {
      'name': 'Hipster',
      'price': '\$20',
      'duration': '25 min',
      'description': 'Full beard with styled mustache',
      'image':
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop',
      'accentColor': AiColors.sunsetCoral,
    },
    {
      'name': 'Friendly Mutton Chops',
      'price': '\$23',
      'duration': '28 min',
      'description': 'Full cheek whiskers with clean chin',
      'image':
          'https://images.unsplash.com/photo-1564564321837-a57b7070ac4f?w=400&h=400&fit=crop',
      'accentColor': AiColors.neonPurple,
    },
    {
      'name': 'Circle Beard',
      'price': '\$21',
      'duration': '26 min',
      'description': 'Mustache connected to chin beard',
      'image':
          'https://images.unsplash.com/photo-1595152452543-e5c9d2e39c2d?w=400&h=400&fit=crop',
      'accentColor': AiColors.neonCyan,
    },
    {
      'name': 'French Fork',
      'price': '\$24',
      'duration': '29 min',
      'description': 'Long beard split into two points',
      'image':
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop',
      'accentColor': AiColors.sunsetCoral,
    },
    {
      'name': 'Garibaldi',
      'price': '\$26',
      'duration': '32 min',
      'description': 'Large, rounded, fully grown beard',
      'image':
          'https://images.unsplash.com/photo-1564564321837-a57b7070ac4f?w=400&h=400&fit=crop',
      'accentColor': AiColors.neonPurple,
    },
    {
      'name': 'Beardstache',
      'price': '\$18',
      'duration': '22 min',
      'description': 'Full mustache with clean shaved chin',
      'image':
          'https://images.unsplash.com/photo-1595152452543-e5c9d2e39c2d?w=400&h=400&fit=crop',
      'accentColor': AiColors.neonCyan,
    },
    {
      'name': 'Extended Goatee',
      'price': '\$19',
      'duration': '24 min',
      'description': 'Long goatee with extended length',
      'image':
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop',
      'accentColor': AiColors.sunsetCoral,
    },
    {
      'name': 'Short Beard',
      'price': '\$14',
      'duration': '18 min',
      'description': 'Light, maintained short facial hair',
      'image':
          'https://images.unsplash.com/photo-1564564321837-a57b7070ac4f?w=400&h=400&fit=crop',
      'accentColor': AiColors.neonPurple,
    },
    {
      'name': 'Designer Stubble',
      'price': '\$11',
      'duration': '12 min',
      'description': 'Carefully maintained three-day growth',
      'image':
          'https://images.unsplash.com/photo-1595152452543-e5c9d2e39c2d?w=400&h=400&fit=crop',
      'accentColor': AiColors.neonCyan,
    },
    {
      'name': 'Ducktail Goatee',
      'price': '\$23',
      'duration': '28 min',
      'description': 'Pointed goatee shaped like duck tail',
      'image':
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop',
      'accentColor': AiColors.sunsetCoral,
    },
    {
      'name': 'Styled Beard',
      'price': '\$25',
      'duration': '30 min',
      'description': 'Full beard with beard oil and styling',
      'image':
          'https://images.unsplash.com/photo-1564564321837-a57b7070ac4f?w=400&h=400&fit=crop',
      'accentColor': AiColors.neonPurple,
    },
    {
      'name': 'Trimmed & Shaped',
      'price': '\$17',
      'duration': '21 min',
      'description': 'Neatly trimmed beard with sharp lines',
      'image':
          'https://images.unsplash.com/photo-1595152452543-e5c9d2e39c2d?w=400&h=400&fit=crop',
      'accentColor': AiColors.neonCyan,
    },
  ];
}
