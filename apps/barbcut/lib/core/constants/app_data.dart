import 'package:flutter/material.dart';

/// Centralized data source for all application content
/// All static data used throughout the app should be defined here
class AppData {
  AppData._();

  // ========== HAIRCUT STYLES ==========
  static final List<Map<String, dynamic>> haircuts = [
    {
      'name': 'Classic Fade',
      'price': '\$25',
      'duration': '30 min',
      'description': 'A timeless fade that never goes out of style',
      'image':
          'https://images.unsplash.com/photo-1622286342621-4bd786c2447c?w=400&h=400&fit=crop',
    },
    {
      'name': 'Buzz Cut',
      'price': '\$15',
      'duration': '15 min',
      'description': 'Clean and simple, perfect for low maintenance',
      'image':
          'https://images.unsplash.com/photo-1621605815971-fbc98d665033?w=400&h=400&fit=crop',
    },
    {
      'name': 'Pompadour',
      'price': '\$35',
      'duration': '45 min',
      'description': 'Bold and stylish with volume on top',
      'image':
          'https://images.unsplash.com/photo-1605497788044-5a32c7078486?w=400&h=400&fit=crop',
    },
    {
      'name': 'Undercut',
      'price': '\$30',
      'duration': '35 min',
      'description': 'Modern and edgy with short sides',
      'image':
          'https://images.unsplash.com/photo-1622286342621-4bd786c2447c?w=400&h=400&fit=crop',
    },
    {
      'name': 'Crew Cut',
      'price': '\$20',
      'duration': '20 min',
      'description': 'Professional and neat for any occasion',
      'image':
          'https://images.unsplash.com/photo-1599351431202-1e0f0137899a?w=400&h=400&fit=crop',
    },
    {
      'name': 'Slicked Back',
      'price': '\$28',
      'duration': '32 min',
      'description': 'Sleek and polished for a sophisticated look',
      'image':
          'https://images.unsplash.com/photo-1622286342621-4bd786c2447c?w=400&h=400&fit=crop',
    },
    {
      'name': 'Textured Top',
      'price': '\$32',
      'duration': '38 min',
      'description': 'Messy texture with clean sides',
      'image':
          'https://images.unsplash.com/photo-1605497788044-5a32c7078486?w=400&h=400&fit=crop',
    },
    {
      'name': 'Quiff',
      'price': '\$30',
      'duration': '35 min',
      'description': 'Voluminous front with tapered sides',
      'image':
          'https://images.unsplash.com/photo-1621605815971-fbc98d665033?w=400&h=400&fit=crop',
    },
    {
      'name': 'Mohawk',
      'price': '\$35',
      'duration': '40 min',
      'description': 'Bold statement with tall center strip',
      'image':
          'https://images.unsplash.com/photo-1599351431202-1e0f0137899a?w=400&h=400&fit=crop',
    },
    {
      'name': 'Spiky',
      'price': '\$24',
      'duration': '28 min',
      'description': 'Sharp and edgy spikes throughout',
      'image':
          'https://images.unsplash.com/photo-1622286342621-4bd786c2447c?w=400&h=400&fit=crop',
    },
    {
      'name': 'French Crop',
      'price': '\$26',
      'duration': '31 min',
      'description': 'Short with textured fringe on top',
      'image':
          'https://images.unsplash.com/photo-1605497788044-5a32c7078486?w=400&h=400&fit=crop',
    },
    {
      'name': 'Taper Fade',
      'price': '\$27',
      'duration': '33 min',
      'description': 'Gradual fade from short to long',
      'image':
          'https://images.unsplash.com/photo-1621605815971-fbc98d665033?w=400&h=400&fit=crop',
    },
    {
      'name': 'Drop Fade',
      'price': '\$29',
      'duration': '34 min',
      'description': 'Fade that drops behind the ears',
      'image':
          'https://images.unsplash.com/photo-1599351431202-1e0f0137899a?w=400&h=400&fit=crop',
    },
    {
      'name': 'Bald Fade',
      'price': '\$25',
      'duration': '28 min',
      'description': 'Fades down to skin with length on top',
      'image':
          'https://images.unsplash.com/photo-1622286342621-4bd786c2447c?w=400&h=400&fit=crop',
    },
    {
      'name': 'Mid Fade',
      'price': '\$26',
      'duration': '30 min',
      'description': 'Fade starts at mid-head height',
      'image':
          'https://images.unsplash.com/photo-1605497788044-5a32c7078486?w=400&h=400&fit=crop',
    },
    {
      'name': 'High Fade',
      'price': '\$28',
      'duration': '32 min',
      'description': 'Fade starts higher for more contrast',
      'image':
          'https://images.unsplash.com/photo-1621605815971-fbc98d665033?w=400&h=400&fit=crop',
    },
    {
      'name': 'Skin Fade',
      'price': '\$30',
      'duration': '35 min',
      'description': 'Clean fade all the way to skin',
      'image':
          'https://images.unsplash.com/photo-1599351431202-1e0f0137899a?w=400&h=400&fit=crop',
    },
    {
      'name': 'Temple Fade',
      'price': '\$25',
      'duration': '28 min',
      'description': 'Fade concentrated around temples',
      'image':
          'https://images.unsplash.com/photo-1622286342621-4bd786c2447c?w=400&h=400&fit=crop',
    },
    {
      'name': 'Side Part',
      'price': '\$24',
      'duration': '27 min',
      'description': 'Classic side part with defined line',
      'image':
          'https://images.unsplash.com/photo-1605497788044-5a32c7078486?w=400&h=400&fit=crop',
    },
    {
      'name': 'Curly Top',
      'price': '\$32',
      'duration': '40 min',
      'description': 'Embraces natural curls with clean sides',
      'image':
          'https://images.unsplash.com/photo-1621605815971-fbc98d665033?w=400&h=400&fit=crop',
    },
    {
      'name': 'Afro',
      'price': '\$28',
      'duration': '35 min',
      'description': 'Full and voluminous natural afro',
      'image':
          'https://images.unsplash.com/photo-1599351431202-1e0f0137899a?w=400&h=400&fit=crop',
    },
    {
      'name': 'Box Braids',
      'price': '\$40',
      'duration': '90 min',
      'description': 'Intricate protective braided style',
      'image':
          'https://images.unsplash.com/photo-1622286342621-4bd786c2447c?w=400&h=400&fit=crop',
    },
    {
      'name': 'Cornrows',
      'price': '\$35',
      'duration': '60 min',
      'description': 'Neat rows of braids close to scalp',
      'image':
          'https://images.unsplash.com/photo-1605497788044-5a32c7078486?w=400&h=400&fit=crop',
    },
    {
      'name': 'Dreadlocks',
      'price': '\$50',
      'duration': '120 min',
      'description': 'Signature locked and twisted style',
      'image':
          'https://images.unsplash.com/photo-1621605815971-fbc98d665033?w=400&h=400&fit=crop',
    },
    {
      'name': 'Man Bun',
      'price': '\$22',
      'duration': '25 min',
      'description': 'Long hair styled into a top knot',
      'image':
          'https://images.unsplash.com/photo-1599351431202-1e0f0137899a?w=400&h=400&fit=crop',
    },
  ];

  // ========== BEARD STYLES ==========
  static final List<Map<String, dynamic>> beardStyles = [
    {
      'name': 'Full Beard',
      'price': '\$20',
      'duration': '25 min',
      'description': 'A classic full beard, well-groomed.',
      'image':
          'https://images.unsplash.com/photo-1564564321837-a57b7070ac4f?w=400&h=400&fit=crop',
    },
    {
      'name': 'Goatee',
      'price': '\$15',
      'duration': '20 min',
      'description': 'A stylish goatee, precisely trimmed.',
      'image':
          'https://images.unsplash.com/photo-1595152452543-e5c9d2e39c2d?w=400&h=400&fit=crop',
    },
    {
      'name': 'Stubble',
      'price': '\$10',
      'duration': '10 min',
      'description': 'A short, rugged stubble.',
      'image':
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop',
    },
    {
      'name': 'Van Dyke',
      'price': '\$25',
      'duration': '30 min',
      'description': 'Curled mustache with soul patch',
      'image':
          'https://images.unsplash.com/photo-1564564321837-a57b7070ac4f?w=400&h=400&fit=crop',
    },
    {
      'name': 'Ducktail',
      'price': '\$22',
      'duration': '27 min',
      'description': 'Pointed beard shaped like a duck tail',
      'image':
          'https://images.unsplash.com/photo-1595152452543-e5c9d2e39c2d?w=400&h=400&fit=crop',
    },
    {
      'name': 'Verdi',
      'price': '\$20',
      'duration': '25 min',
      'description': 'Pointed full beard with clean lines',
      'image':
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop',
    },
    {
      'name': 'Balbo',
      'price': '\$18',
      'duration': '22 min',
      'description': 'Disconnected mustache with goatee',
      'image':
          'https://images.unsplash.com/photo-1564564321837-a57b7070ac4f?w=400&h=400&fit=crop',
    },
    {
      'name': 'Anchor',
      'price': '\$19',
      'duration': '23 min',
      'description': 'Goatee with soul patch extension',
      'image':
          'https://images.unsplash.com/photo-1595152452543-e5c9d2e39c2d?w=400&h=400&fit=crop',
    },
    {
      'name': 'Chevron',
      'price': '\$16',
      'duration': '20 min',
      'description': 'Full mustache covering upper lip',
      'image':
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop',
    },
    {
      'name': 'Handlebar',
      'price': '\$17',
      'duration': '21 min',
      'description': 'Distinctive curled upturned mustache',
      'image':
          'https://images.unsplash.com/photo-1564564321837-a57b7070ac4f?w=400&h=400&fit=crop',
    },
    {
      'name': 'Pencil Stache',
      'price': '\$12',
      'duration': '15 min',
      'description': 'Thin, refined mustache line',
      'image':
          'https://images.unsplash.com/photo-1595152452543-e5c9d2e39c2d?w=400&h=400&fit=crop',
    },
    {
      'name': 'Hipster',
      'price': '\$20',
      'duration': '25 min',
      'description': 'Full beard with styled mustache',
      'image':
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop',
    },
    {
      'name': 'Friendly Mutton Chops',
      'price': '\$23',
      'duration': '28 min',
      'description': 'Full cheek whiskers with clean chin',
      'image':
          'https://images.unsplash.com/photo-1564564321837-a57b7070ac4f?w=400&h=400&fit=crop',
    },
    {
      'name': 'Circle Beard',
      'price': '\$21',
      'duration': '26 min',
      'description': 'Mustache connected to chin beard',
      'image':
          'https://images.unsplash.com/photo-1595152452543-e5c9d2e39c2d?w=400&h=400&fit=crop',
    },
    {
      'name': 'French Fork',
      'price': '\$24',
      'duration': '29 min',
      'description': 'Long beard split into two points',
      'image':
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop',
    },
    {
      'name': 'Garibaldi',
      'price': '\$26',
      'duration': '32 min',
      'description': 'Large, rounded, fully grown beard',
      'image':
          'https://images.unsplash.com/photo-1564564321837-a57b7070ac4f?w=400&h=400&fit=crop',
    },
    {
      'name': 'Beardstache',
      'price': '\$18',
      'duration': '22 min',
      'description': 'Full mustache with clean shaved chin',
      'image':
          'https://images.unsplash.com/photo-1595152452543-e5c9d2e39c2d?w=400&h=400&fit=crop',
    },
    {
      'name': 'Extended Goatee',
      'price': '\$19',
      'duration': '24 min',
      'description': 'Long goatee with extended length',
      'image':
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop',
    },
    {
      'name': 'Short Beard',
      'price': '\$14',
      'duration': '18 min',
      'description': 'Light, maintained short facial hair',
      'image':
          'https://images.unsplash.com/photo-1564564321837-a57b7070ac4f?w=400&h=400&fit=crop',
    },
    {
      'name': 'Designer Stubble',
      'price': '\$11',
      'duration': '12 min',
      'description': 'Carefully maintained three-day growth',
      'image':
          'https://images.unsplash.com/photo-1595152452543-e5c9d2e39c2d?w=400&h=400&fit=crop',
    },
    {
      'name': 'Ducktail Goatee',
      'price': '\$23',
      'duration': '28 min',
      'description': 'Pointed goatee shaped like duck tail',
      'image':
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop',
    },
    {
      'name': 'Styled Beard',
      'price': '\$25',
      'duration': '30 min',
      'description': 'Full beard with beard oil and styling',
      'image':
          'https://images.unsplash.com/photo-1564564321837-a57b7070ac4f?w=400&h=400&fit=crop',
    },
    {
      'name': 'Trimmed & Shaped',
      'price': '\$17',
      'duration': '21 min',
      'description': 'Neatly trimmed beard with sharp lines',
      'image':
          'https://images.unsplash.com/photo-1595152452543-e5c9d2e39c2d?w=400&h=400&fit=crop',
    },
  ];

  // ========== PRODUCTS ==========
  static final List<Map<String, dynamic>> products = [
    {
      'name': 'Hair Gel Premium',
      'price': '\$15.99',
      'rating': 4.5,
      'description': 'Premium styling gel for powerful hold',
      'image':
          'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?w=800&h=1200&fit=crop',
      'icon': Icons.palette,
    },
    {
      'name': 'Beard Oil Deluxe',
      'price': '\$12.99',
      'rating': 4.7,
      'description': 'Natural beard conditioning oil',
      'image':
          'https://images.unsplash.com/photo-1512436991641-6745cdb1723f?w=800&h=1200&fit=crop',
      'icon': Icons.face_retouching_natural,
    },
    {
      'name': 'Pro Clippers',
      'price': '\$89.99',
      'rating': 4.9,
      'description': 'Professional hair clippers',
      'image':
          'https://images.unsplash.com/photo-1512499617640-c2f999098cbe?w=800&h=1200&fit=crop',
      'icon': Icons.content_cut,
    },
    {
      'name': 'Premium Shampoo',
      'price': '\$9.99',
      'rating': 4.4,
      'description': 'Gentle hair shampoo',
      'image':
          'https://images.unsplash.com/photo-1522337094846-8a818192de1d?w=800&h=1200&fit=crop',
      'icon': Icons.water_drop,
    },
    {
      'name': 'Straight Razor',
      'price': '\$24.99',
      'rating': 4.8,
      'description': 'Precision straight razor',
      'image':
          'https://images.unsplash.com/photo-1501004318641-b39e6451bec6?w=800&h=1200&fit=crop',
      'icon': Icons.content_cut,
    },
    {
      'name': 'Styling Wax',
      'price': '\$11.99',
      'rating': 4.6,
      'description': 'Professional hair styling wax',
      'image':
          'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?w=800&h=1200&fit=crop',
      'icon': Icons.brush,
    },
  ];

  // ========== HISTORY / GENERATION DATA ==========
  static List<Map<String, dynamic>> generateHistory() {
    return [
      {
        'id': '1',
        'imageUrl':
            'https://images.unsplash.com/photo-1622286342621-4bd786c2447c?w=400&h=400&fit=crop',
        'haircut': 'Classic Fade',
        'beard': 'Full Beard',
        'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
      },
      {
        'id': '2',
        'imageUrl':
            'https://images.unsplash.com/photo-1621605815971-fbc98d665033?w=400&h=400&fit=crop',
        'haircut': 'Buzz Cut',
        'beard': 'Stubble',
        'timestamp': DateTime.now().subtract(const Duration(hours: 5)),
      },
      {
        'id': '3',
        'imageUrl':
            'https://images.unsplash.com/photo-1605497788044-5a32c7078486?w=400&h=400&fit=crop',
        'haircut': 'Pompadour',
        'beard': 'Goatee',
        'timestamp': DateTime.now().subtract(const Duration(hours: 12)),
      },
      {
        'id': '4',
        'imageUrl':
            'https://images.unsplash.com/photo-1599351431202-1e0f0137899a?w=400&h=400&fit=crop',
        'haircut': 'Undercut',
        'beard': 'Full Beard',
        'timestamp': DateTime.now().subtract(const Duration(days: 1)),
      },
      {
        'id': '5',
        'imageUrl':
            'https://images.unsplash.com/photo-1564564321837-a57b7070ac4f?w=400&h=400&fit=crop',
        'haircut': 'Crew Cut',
        'beard': 'Clean Shaven',
        'timestamp': DateTime.now().subtract(const Duration(days: 2)),
      },
      {
        'id': '6',
        'imageUrl':
            'https://images.unsplash.com/photo-1599351431202-1e0f0137899a?w=400&h=400&fit=crop',
        'haircut': 'Textured Top',
        'beard': 'Stubble',
        'timestamp': DateTime.now().subtract(const Duration(days: 3)),
      },
    ];
  }

  // ========== PROFILE DATA ==========
  static final Map<String, dynamic> defaultProfile = {
    'userId': 'user_123',
    'username': 'alexporter',
    'email': 'alex@example.com',
    'bio': 'Barber enthusiast & AI style explorer',
    'appointmentsCount': 24,
    'favoritesCount': 12,
    'averageRating': 4.8,
  };
}
