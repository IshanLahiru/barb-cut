import 'package:flutter/material.dart';
import '../theme/ai_colors.dart';
import '../theme/ai_spacing.dart';

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
      'icon': Icons.content_cut,
      'accentColor': AiColors.neonCyan,
    },
    {
      'name': 'Buzz Cut',
      'price': '\$15',
      'duration': '15 min',
      'description': 'Clean and simple, perfect for low maintenance',
      'icon': Icons.face_retouching_natural,
      'accentColor': AiColors.sunsetCoral,
    },
    {
      'name': 'Pompadour',
      'price': '\$35',
      'duration': '45 min',
      'description': 'Bold and stylish with volume on top',
      'icon': Icons.style,
      'accentColor': AiColors.neonPurple,
    },
    {
      'name': 'Undercut',
      'price': '\$30',
      'duration': '35 min',
      'description': 'Modern and edgy with short sides',
      'icon': Icons.face,
      'accentColor': AiColors.neonCyan,
    },
    {
      'name': 'Crew Cut',
      'price': '\$20',
      'duration': '20 min',
      'description': 'Professional and neat for any occasion',
      'icon': Icons.person,
      'accentColor': AiColors.sunsetCoral,
    },
    {
      'name': 'Full Beard',
      'price': '\$20',
      'duration': '25 min',
      'description': 'A classic full beard, well-groomed.',
      'icon': Icons.face_retouching_natural,
      'accentColor': AiColors.neonPurple,
    },
    {
      'name': 'Goatee',
      'price': '\$15',
      'duration': '20 min',
      'description': 'A stylish goatee, precisely trimmed.',
      'icon': Icons.face,
      'accentColor': AiColors.neonCyan,
    },
    {
      'name': 'Stubble',
      'price': '\$10',
      'duration': '10 min',
      'description': 'A short, rugged stubble.',
      'icon': Icons.face,
      'accentColor': AiColors.sunsetCoral,
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
              padding: const EdgeInsets.symmetric(
                horizontal: AiSpacing.lg,
                vertical: AiSpacing.md,
              ),
              decoration: BoxDecoration(
                color: AiColors.backgroundDark,
                border: Border(
                  bottom: BorderSide(
                    color: AiColors.borderGlass,
                    width: 1,
                  ),
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
                  const SizedBox(height: AiSpacing.sm),
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
                      hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AiColors.textTertiary,
                          ),
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
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AiSpacing.md,
                        vertical: AiSpacing.md,
                      ),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AiSpacing.radiusLarge),
                        borderSide: const BorderSide(
                          color: AiColors.borderLight,
                          width: 1.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AiSpacing.radiusLarge),
                        borderSide: const BorderSide(
                          color: AiColors.borderLight,
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AiSpacing.radiusLarge),
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
                          const SizedBox(height: AiSpacing.md),
                          Text(
                            'No styles found',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: AiColors.textPrimary,
                                ),
                          ),
                          const SizedBox(height: AiSpacing.sm),
                          Text(
                            'Try a different search term',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: AiColors.textTertiary,
                                ),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.symmetric(
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

  Widget _buildStyleCard(BuildContext context, Map<String, dynamic> style, int index) {
    final accentColor = style['accentColor'] as Color;

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
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(
              style['icon'],
              size: 110,
              color: accentColor.withValues(alpha: 0.5),
            ),
          ),
          Positioned(
            left: AiSpacing.md,
            right: AiSpacing.md,
            bottom: AiSpacing.md,
            child: Container(
              padding: const EdgeInsets.all(AiSpacing.sm),
              decoration: BoxDecoration(
                color: AiColors.backgroundDeep,
                borderRadius: BorderRadius.circular(AiSpacing.radiusMedium),
                border: Border.all(
                  color: accentColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    style['name'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: accentColor,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: AiSpacing.xs),
                  Text(
                    style['description'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                          color: AiColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: AiSpacing.sm),
                  Row(
                    children: [
                      _chip(style['price'], accentColor),
                      const SizedBox(width: AiSpacing.xs),
                      _chip(style['duration'], accentColor),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: AiSpacing.md,
            right: AiSpacing.md,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AiSpacing.sm,
                vertical: AiSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(AiSpacing.radiusSmall),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
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

  Widget _chip(String text, Color accentColor) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AiSpacing.sm,
        vertical: AiSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AiSpacing.radiusSmall),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontSize: 10,
              color: accentColor,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
