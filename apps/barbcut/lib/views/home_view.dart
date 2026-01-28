import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
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
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
                      child: FlutterCarousel(
                        options: CarouselOptions(
                          height: carouselHeight,
                          viewportFraction: (constraints.maxWidth < 360)
                              ? 0.88
                              : (constraints.maxWidth < 600 ? 0.8 : 0.7),
                          enlargeCenterPage: true,
                          enableInfiniteScroll: true,
                          autoPlay: false,
                          showIndicator: false,
                          onPageChanged: (index, reason) {
                            setState(() {
                              _selectedHaircutIndex = index;
                            });
                          },
                        ),
                        items: _haircuts.asMap().entries.map((entry) {
                          final int itemIndex = entry.key;
                          final Map<String, dynamic> haircut = entry.value;
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
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: AiSpacing.sm),
                    // Carousel indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _haircuts.length,
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
  }) {
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

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(
        AiSpacing.md,
        AiSpacing.sm,
        AiSpacing.md,
        AiSpacing.md,
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: AiSpacing.md,
        mainAxisSpacing: AiSpacing.md,
        childAspectRatio: width < 360 ? 0.72 : 0.78,
      ),
      itemCount: _haircuts.length,
      itemBuilder: (context, index) {
        final haircut = _haircuts[index];
        final isSelected = _selectedHaircutIndex == index;
        return _buildStyleCard(
          item: haircut,
          itemIndex: index,
          isSelected: isSelected,
          onTap: () {
            setState(() {
              _selectedHaircutIndex = index;
            });
            _panelController.close();
          },
        );
      },
    );
  }

  Widget _buildBeardGrid() {
    final width = MediaQuery.of(context).size.width;
    int crossAxisCount = 2;
    if (width >= 1100)
      crossAxisCount = 4;
    else if (width >= 820)
      crossAxisCount = 3;

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(
        AiSpacing.md,
        AiSpacing.sm,
        AiSpacing.md,
        AiSpacing.md,
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: AiSpacing.md,
        mainAxisSpacing: AiSpacing.md,
        childAspectRatio: width < 360 ? 0.72 : 0.78,
      ),
      itemCount: _beardStyles.length,
      itemBuilder: (context, index) {
        final beard = _beardStyles[index];
        final isSelected = _selectedBeardIndex == index;
        return _buildStyleCard(
          item: beard,
          itemIndex: index,
          isSelected: isSelected,
          onTap: () {
            setState(() {
              _selectedBeardIndex = index;
            });
            _panelController.close();
          },
        );
      },
    );
  }

  Widget _buildStyleCard({
    required Map<String, dynamic> item,
    required int itemIndex,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final Color accentColor =
        (item['accentColor'] as Color?) ?? AiColors.neonCyan;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? accentColor : AiColors.borderLight,
            width: isSelected ? 2 : 1.5,
          ),
          borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
        ),
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
    );
  }
}
