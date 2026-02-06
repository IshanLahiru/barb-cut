import 'package:flutter/material.dart';
import '../theme/theme.dart';

class ExploreView extends StatefulWidget {
  const ExploreView({super.key});

  @override
  State<ExploreView> createState() => _ExploreViewState();
}

class _ExploreViewState extends State<ExploreView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  static final List<Map<String, dynamic>> _styles = [
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
      'name': 'Full Beard',
      'description': 'A classic full beard, well-groomed.',
      'tips':
          'Let it grow evenly for 3-4 weeks; ask for a clean neckline two fingers above the Adam\'s apple.',
      'image':
          'https://images.unsplash.com/photo-1564564321837-a57b7070ac4f?w=400&h=400&fit=crop',
    },
    {
      'name': 'Goatee',
      'description': 'A stylish goatee, precisely trimmed.',
      'tips':
          'Keep the cheeks clean; define the chin outline with a sharp edge.',
      'image':
          'https://images.unsplash.com/photo-1595152452543-e5c9d2e39c2d?w=400&h=400&fit=crop',
    },
    {
      'name': 'Stubble',
      'description': 'A short, rugged stubble.',
      'tips':
          'Agree on a guard length; keep the neckline tidy and follow the jawline.',
      'image':
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredStyles = _styles.where((style) {
      if (_searchQuery.isEmpty) return true;
      final name = style['name'].toString().toLowerCase();
      final description = style['description'].toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || description.contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: AiColors.backgroundDeep,
      appBar: AppBar(
        backgroundColor: AiColors.backgroundDark,
        elevation: 0,
        title: Text(
          'Explore',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AiColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header with gradient
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AiSpacing.lg,
                vertical: AiSpacing.md,
              ),
              decoration: BoxDecoration(
                color: AiColors.backgroundDark,
                border: Border(
                  bottom: BorderSide(color: AiColors.borderGlass, width: 1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Discover Styles',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AiColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: AiSpacing.sm),
                  // Search field with neon cyan focus
                  TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AiColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Fade, buzz cut, pompadour...',
                      hintStyle: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(color: AiColors.textTertiary),
                      prefixIcon: Icon(
                        Icons.search,
                        color: AiColors.textTertiary,
                        size: 20,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.clear,
                                color: AiColors.textTertiary,
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: AiColors.backgroundSecondary,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: AiSpacing.md,
                        vertical: AiSpacing.md,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AiSpacing.radiusLarge,
                        ),
                        borderSide: const BorderSide(
                          color: AiColors.borderLight,
                          width: 1.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AiSpacing.radiusLarge,
                        ),
                        borderSide: const BorderSide(
                          color: AiColors.borderLight,
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AiSpacing.radiusLarge,
                        ),
                        borderSide: const BorderSide(
                          color: AiColors.neonCyan,
                          width: 2,
                        ),
                      ),
                    ),
                    cursorColor: AiColors.neonCyan,
                  ),
                ],
              ),
            ),
            // Styles Grid
            Expanded(
              child: filteredStyles.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: AiColors.textTertiary,
                          ),
                          SizedBox(height: AiSpacing.md),
                          Text(
                            'No styles found',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(color: AiColors.textPrimary),
                          ),
                          SizedBox(height: AiSpacing.sm),
                          Text(
                            'Try a different search term',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AiColors.textTertiary),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: AiSpacing.lg,
                        vertical: AiSpacing.md,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: AiSpacing.md,
                            mainAxisSpacing: AiSpacing.md,
                            childAspectRatio: 0.78,
                          ),
                      itemCount: filteredStyles.length,
                      itemBuilder: (context, index) {
                        final style = filteredStyles[index];
                        return _buildStyleCard(context, style, index);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStyleCard(
    BuildContext context,
    Map<String, dynamic> style,
    int index,
  ) {
    final accentColor = AdaptiveThemeColors.neonCyan(context);
    final tips = (style['tips'] as String?)?.trim();
    final hasTips = tips != null && tips.isNotEmpty;

    return Container(
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
        border: Border.all(
          color: accentColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
              child: Image.network(
                style['image'],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: accentColor.withValues(alpha: 0.2),
                    child: Icon(
                      Icons.image_not_supported,
                      size: 110,
                      color: accentColor.withValues(alpha: 0.5),
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
            bottom: AiSpacing.md,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  style['name'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                if (hasTips) ...[
                  SizedBox(height: 4),
                  Text(
                    tips,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Positioned(
            top: AiSpacing.md,
            right: AiSpacing.md,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AiSpacing.sm,
                vertical: AiSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(AiSpacing.radiusSmall),
              ),
              child: Text(
                '${index + 1}',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AiColors.backgroundDeep,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
