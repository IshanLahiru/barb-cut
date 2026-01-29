import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'dart:math';
import 'dart:async';
import 'dart:ui';
import '../theme/ai_colors.dart';
import '../theme/ai_spacing.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  final PanelController _panelController = PanelController();
  int _selectedHaircutIndex = 0;
  int _selectedBeardIndex = 0;
  late TabController _tabController;
  final Random _random = Random();
  late List<double> _haircutHeights;
  late List<double> _beardHeights;
  bool _isGenerating = false;
  int? _confirmedHaircutIndex;
  int? _confirmedBeardIndex;
  Timer? _carouselTimer;

  final List<Map<String, dynamic>> _haircuts = [
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

  final List<Map<String, dynamic>> _beardStyles = [
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Generate random heights once for all haircuts
    _haircutHeights = List.generate(
      _haircuts.length,
      (_) => 200.0 + _random.nextDouble() * 80,
    );
    // Generate random heights once for all beard styles
    _beardHeights = List.generate(
      _beardStyles.length,
      (_) => 200.0 + _random.nextDouble() * 80,
    );
  }

  void _onTryThisPressed() async {
    final haircut = _haircuts[_confirmedHaircutIndex ?? _selectedHaircutIndex];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: BoxConstraints(maxWidth: 420),
            decoration: BoxDecoration(
              color: AiColors.backgroundDark.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
              border: Border.all(
                color: AiColors.borderLight.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AiSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Complete Your Look',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: AiColors.textPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      SizedBox(height: AiSpacing.xs),
                      Text(
                        'Add a beard style to complete your transformation',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AiColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: AiColors.borderLight.withValues(alpha: 0.2),
                  height: 1,
                  thickness: 1,
                ),
                Padding(
                  padding: const EdgeInsets.all(AiSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Selection',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AiColors.textTertiary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: AiSpacing.md),
                      _buildStylePreviewCardInline(haircut),
                    ],
                  ),
                ),
                Divider(
                  color: AiColors.borderLight.withValues(alpha: 0.2),
                  height: 1,
                  thickness: 1,
                ),
                Padding(
                  padding: const EdgeInsets.all(AiSpacing.lg),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            setState(
                              () => _confirmedHaircutIndex =
                                  _selectedHaircutIndex,
                            );
                            _tabController.animateTo(1);
                            _panelController.open();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AiColors.neonPurple.withValues(
                              alpha: 0.8,
                            ),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AiSpacing.radiusMedium,
                              ),
                            ),
                          ),
                          child: Text(
                            'Add Beard Style',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: AiSpacing.md),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            setState(
                              () => _confirmedHaircutIndex =
                                  _selectedHaircutIndex,
                            );
                            _showConfirmationDialog();
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AiColors.textSecondary,
                            side: BorderSide(
                              color: AiColors.borderLight.withValues(
                                alpha: 0.4,
                              ),
                              width: 1.5,
                            ),
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AiSpacing.radiusMedium,
                              ),
                            ),
                          ),
                          child: Text(
                            'Just Haircut',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showConfirmationDialog() async {
    final haircut = _haircuts[_confirmedHaircutIndex ?? _selectedHaircutIndex];
    final beard = _confirmedBeardIndex != null
        ? _beardStyles[_confirmedBeardIndex!]
        : null;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: BoxConstraints(maxWidth: 500),
            decoration: BoxDecoration(
              color: AiColors.backgroundDark.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
              border: Border.all(
                color: AiColors.borderLight.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(AiSpacing.lg),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AiColors.neonCyan.withValues(alpha: 0.2),
                        ),
                        child: Icon(
                          Icons.check,
                          color: AiColors.neonCyan,
                          size: 18,
                        ),
                      ),
                      SizedBox(width: AiSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ready to Generate',
                              style: TextStyle(
                                color: AiColors.textPrimary,
                                fontWeight: FontWeight.w800,
                                fontSize: 20,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Review your selections',
                              style: TextStyle(
                                color: AiColors.textTertiary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: AiColors.borderLight.withValues(alpha: 0.2),
                  height: 1,
                  thickness: 1,
                ),

                // Cards in horizontal layout
                SingleChildScrollView(
                  padding: const EdgeInsets.all(AiSpacing.lg),
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Haircut Card
                      _buildCompactStyleCard(
                        style: haircut,
                        label: 'Haircut',
                        accentColor: AiColors.neonCyan,
                        onChangePressed: () {
                          Navigator.of(dialogContext).pop();
                          setState(() {
                            _selectedHaircutIndex =
                                _confirmedHaircutIndex ?? _selectedHaircutIndex;
                          });
                          _tabController.animateTo(0);
                          _panelController.open();
                        },
                        onRemovePressed: () {
                          Navigator.of(dialogContext).pop();
                          setState(() {
                            _confirmedHaircutIndex = null;
                            _confirmedBeardIndex = null;
                            _selectedHaircutIndex = 0;
                            _selectedBeardIndex = 0;
                          });
                          _panelController.open();
                        },
                      ),
                      SizedBox(width: AiSpacing.md),

                      // Beard Card or Add CTA
                      if (beard != null)
                        _buildCompactStyleCard(
                          style: beard,
                          label: 'Beard',
                          accentColor: AiColors.neonCyan,
                          onChangePressed: () {
                            Navigator.of(dialogContext).pop();
                            setState(() {
                              _selectedBeardIndex =
                                  _confirmedBeardIndex ?? _selectedBeardIndex;
                            });
                            _tabController.animateTo(1);
                            _panelController.open();
                          },
                          onRemovePressed: () {
                            Navigator.of(dialogContext).pop();
                            setState(() => _confirmedBeardIndex = null);
                            _showConfirmationDialog();
                          },
                        )
                      else
                        _buildAddBeardCard(dialogContext),
                    ],
                  ),
                ),

                Divider(
                  color: AiColors.borderLight.withValues(alpha: 0.2),
                  height: 1,
                  thickness: 1,
                ),

                // Action Buttons
                Padding(
                  padding: const EdgeInsets.all(AiSpacing.lg),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                            setState(() {
                              _confirmedHaircutIndex = null;
                              _confirmedBeardIndex = null;
                            });
                            _panelController.close();
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AiColors.textSecondary,
                            side: BorderSide(
                              color: AiColors.borderLight.withValues(
                                alpha: 0.4,
                              ),
                              width: 1.5,
                            ),
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AiSpacing.radiusMedium,
                              ),
                            ),
                          ),
                          child: Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ),
                      SizedBox(width: AiSpacing.md),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                            _startGeneration();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AiColors.neonCyan,
                            foregroundColor: AiColors.backgroundDeep,
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AiSpacing.radiusMedium,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.auto_awesome, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Generate Style',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompactStyleCard({
    required Map<String, dynamic> style,
    required String label,
    required Color accentColor,
    required VoidCallback onChangePressed,
    required VoidCallback onRemovePressed,
  }) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AiSpacing.radiusMedium),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
        color: accentColor.withValues(alpha: 0.03),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Label
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accentColor,
                  ),
                ),
                SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: AiColors.textTertiary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Stack(
                children: [
                  Image.network(
                    style['image'] as String,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 120,
                      color: AiColors.backgroundSecondary.withValues(
                        alpha: 0.5,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.image_not_supported,
                          color: AiColors.textTertiary,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            accentColor.withValues(alpha: 0.15),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  style['name'] as String,
                  style: TextStyle(
                    color: AiColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: accentColor.withValues(alpha: 0.15),
                      ),
                      child: Text(
                        '₹${style['price']}',
                        style: TextStyle(
                          color: accentColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    SizedBox(width: 6),
                    Text(
                      '${style['duration'] ?? 45}min',
                      style: TextStyle(
                        color: AiColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),

                // Buttons stacked vertically
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onChangePressed,
                    icon: Icon(Icons.edit_outlined, size: 14),
                    label: Text('Change', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: accentColor,
                      side: BorderSide(
                        color: accentColor.withValues(alpha: 0.4),
                        width: 1,
                      ),
                      padding: EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 6),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onRemovePressed,
                    icon: Icon(Icons.close_outlined, size: 14),
                    label: Text('Remove', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AiColors.textSecondary,
                      side: BorderSide(
                        color: AiColors.borderLight.withValues(alpha: 0.3),
                        width: 1,
                      ),
                      padding: EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddBeardCard(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        _tabController.animateTo(1);
        _panelController.open();
      },
      child: Container(
        width: 200,
        height: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AiSpacing.radiusMedium),
          border: Border.all(
            color: AiColors.neonPurple.withValues(alpha: 0.3),
            width: 2,
          ),
          color: AiColors.neonPurple.withValues(alpha: 0.05),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AiColors.neonPurple.withValues(alpha: 0.15),
              ),
              child: Icon(
                Icons.add_circle_outline,
                color: AiColors.neonPurple,
                size: 32,
              ),
            ),
            SizedBox(height: AiSpacing.md),
            Text(
              'Add Beard Style',
              style: TextStyle(
                color: AiColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Complete your look',
                style: TextStyle(color: AiColors.textSecondary, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStylePreviewCardInline(Map<String, dynamic> style) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AiSpacing.radiusMedium),
          child: Image.network(
            style['image'] as String,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 100,
              height: 100,
              color: AiColors.backgroundSecondary.withValues(alpha: 0.5),
              child: Center(
                child: Icon(
                  Icons.image_not_supported,
                  color: AiColors.textTertiary,
                  size: 32,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: AiSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                style['name'] as String,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AiColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '₹${style['price']}',
                style: TextStyle(
                  color: AiColors.neonCyan,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              SizedBox(height: 2),
              Text(
                '${style['duration'] ?? 45} mins',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AiColors.textTertiary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _startGeneration() {
    setState(() {
      _isGenerating = true;
    });

    _panelController.close();

    // After 5 seconds, reset
    Future.delayed(Duration(seconds: 5), () {
      _carouselTimer?.cancel();
      if (mounted) {
        setState(() {
          _isGenerating = false;
          _confirmedHaircutIndex = null;
          _confirmedBeardIndex = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _carouselTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final availableHeight =
        media.size.height - media.padding.top - kBottomNavigationBarHeight - 22;
    final minPanelHeight = availableHeight * 0.28;
    final maxPanelHeight = availableHeight * 0.9;

    return Scaffold(
      backgroundColor: AiColors.backgroundDeep,
      appBar: AppBar(
        backgroundColor: AiColors.backgroundDark,
        elevation: 0,
        toolbarHeight: 48,
        title: Text(
          'Barbcut',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AiColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
      ),
      body: SlidingUpPanel(
        controller: _panelController,
        minHeight: minPanelHeight,
        maxHeight: maxPanelHeight,
        borderRadius: BorderRadius.zero,
        backdropEnabled: false,
        isDraggable: true,
        panelBuilder: (scrollController) => _buildPanel(),
        body: _buildMainContent(),
      ),
    );
  }

  Widget _buildMainContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double carouselHeight = (constraints.maxHeight * 0.52).clamp(
          260,
          520,
        );
        final double iconSize = (carouselHeight * 0.55).clamp(140, 260);

        return GestureDetector(
          onVerticalDragUpdate: (details) {
            if (details.delta.dy < -5) {
              _panelController.open();
            }
          },
          child: Container(
            decoration: BoxDecoration(color: AiColors.backgroundDeep),
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  AiSpacing.lg,
                  0,
                  AiSpacing.lg,
                  AiSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: AiSpacing.xs),
                    SizedBox(
                      height: carouselHeight,
                      child: Stack(
                        children: [
                          FlutterCarousel(
                            options: CarouselOptions(
                              height: carouselHeight,
                              viewportFraction: (constraints.maxWidth < 360)
                                  ? 0.88
                                  : (constraints.maxWidth < 600 ? 0.8 : 0.7),
                              enlargeCenterPage: true,
                              enableInfiniteScroll: true,
                              autoPlay: _isGenerating,
                              autoPlayInterval: Duration(milliseconds: 1500),
                              autoPlayAnimationDuration: Duration(
                                milliseconds: 800,
                              ),
                              showIndicator: false,
                              onPageChanged: (index, reason) {
                                setState(() {
                                  _selectedHaircutIndex = index;
                                });
                              },
                            ),
                            items: _haircuts
                                .take(4)
                                .toList()
                                .asMap()
                                .entries
                                .map((entry) {
                                  final int itemIndex = entry.key;
                                  final Map<String, dynamic> haircut =
                                      entry.value;
                                  final Color accentColor =
                                      (haircut['accentColor'] as Color?) ??
                                      AiColors.neonCyan;

                                  return Align(
                                    alignment: Alignment.center,
                                    child: _buildCarouselCard(
                                      haircut: haircut,
                                      accentColor: accentColor,
                                      itemIndex: itemIndex,
                                      iconSize: iconSize,
                                      isGenerating: _isGenerating,
                                    ),
                                  );
                                })
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AiSpacing.none),
                    // Carousel indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        4,
                        (index) => Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _selectedHaircutIndex == index
                                ? AiColors.neonCyan
                                : AiColors.borderLight.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AiSpacing.md),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCarouselCard({
    required Map<String, dynamic> haircut,
    required Color accentColor,
    required int itemIndex,
    required double iconSize,
    bool isGenerating = false,
  }) {
    Widget cardContent = Container(
      margin: EdgeInsets.symmetric(
        horizontal: AiSpacing.sm,
        vertical: AiSpacing.sm,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor.withValues(alpha: 0.2),
            accentColor.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
              child: Image.network(
                haircut['image'],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: accentColor.withValues(alpha: 0.2),
                    child: Icon(
                      Icons.image_not_supported,
                      size: iconSize,
                      color: accentColor.withValues(alpha: 0.6),
                    ),
                  );
                },
              ),
            ),
          ),
          // Gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.3),
                    Colors.black.withValues(alpha: 0.7),
                  ],
                  stops: const [0.4, 0.7, 1.0],
                ),
              ),
            ),
          ),
          // Minimal text overlay
          Positioned(
            left: AiSpacing.md,
            right: AiSpacing.md,
            bottom: AiSpacing.sm,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  haircut['name'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    // Apply blur and spinner overlay if generating
    if (isGenerating) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
        child: Stack(
          children: [
            // Blurred card content
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: cardContent,
            ),
            // Spinner overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AiColors.neonCyan,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return cardContent;
  }

  Widget _buildPanel() {
    return Container(
      color: AiColors.backgroundDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Hair'),
              Tab(text: 'Beard'),
            ],
            labelColor: AiColors.neonCyan,
            unselectedLabelColor: AiColors.textTertiary,
            labelStyle: Theme.of(context).textTheme.titleMedium,
            unselectedLabelStyle: Theme.of(context).textTheme.titleMedium,
            indicatorSize: TabBarIndicatorSize.label,
            indicatorColor: AiColors.neonCyan,
            dividerColor: AiColors.borderLight,
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildHaircutGrid(), _buildBeardGrid()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHaircutGrid() {
    final width = MediaQuery.of(context).size.width;
    int crossAxisCount = 2;
    if (width >= 1100)
      crossAxisCount = 4;
    else if (width >= 820)
      crossAxisCount = 3;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AiSpacing.md,
        AiSpacing.sm,
        AiSpacing.md,
        AiSpacing.md,
      ),
      child: MasonryGridView.builder(
        gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
        ),
        itemCount: _haircuts.length,
        mainAxisSpacing: AiSpacing.md,
        crossAxisSpacing: AiSpacing.md,
        itemBuilder: (context, index) {
          final haircut = _haircuts[index];
          final isSelected = _selectedHaircutIndex == index;
          return _buildStyleCard(
            item: haircut,
            itemIndex: index,
            isSelected: isSelected,
            height: _haircutHeights[index],
            onTap: () {
              setState(() {
                _selectedHaircutIndex = index;
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildBeardGrid() {
    final width = MediaQuery.of(context).size.width;
    int crossAxisCount = 2;
    if (width >= 1100)
      crossAxisCount = 4;
    else if (width >= 820)
      crossAxisCount = 3;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AiSpacing.md,
        AiSpacing.sm,
        AiSpacing.md,
        AiSpacing.md,
      ),
      child: MasonryGridView.builder(
        gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
        ),
        itemCount: _beardStyles.length,
        mainAxisSpacing: AiSpacing.md,
        crossAxisSpacing: AiSpacing.md,
        itemBuilder: (context, index) {
          final beard = _beardStyles[index];
          final isSelected = _selectedBeardIndex == index;
          return _buildStyleCard(
            item: beard,
            itemIndex: index,
            isSelected: isSelected,
            height: _beardHeights[index],
            onTap: () {
              setState(() {
                _selectedBeardIndex = index;
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildStyleCard({
    required Map<String, dynamic> item,
    required int itemIndex,
    required bool isSelected,
    required VoidCallback onTap,
    required double height,
  }) {
    final Color accentColor =
        (item['accentColor'] as Color?) ?? AiColors.neonCyan;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          border: isSelected
              ? Border.all(color: AiColors.neonCyan, width: 3)
              : null,
          borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
        ),
        child: Stack(
          children: [
            SizedBox(
              height: height,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
                child: _buildCarouselCard(
                  haircut: item,
                  accentColor: accentColor,
                  itemIndex: itemIndex,
                  iconSize: 120,
                ),
              ),
            ),
            if (isSelected)
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      if (_tabController.index == 0) {
                        _confirmedHaircutIndex = itemIndex;
                        // If beard is already confirmed, go directly to confirmation dialog
                        if (_confirmedBeardIndex != null) {
                          _showConfirmationDialog();
                        } else {
                          _onTryThisPressed();
                        }
                      } else {
                        _confirmedBeardIndex = itemIndex;
                        _showConfirmationDialog();
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AiColors.neonCyan,
                    foregroundColor: AiColors.backgroundDeep,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AiSpacing.radiusMedium,
                      ),
                    ),
                  ),
                  child: Text(
                    'Try This',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
