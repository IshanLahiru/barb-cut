import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';

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
      'image': Icons.content_cut,
      'color': Colors.blue,
    },
    {
      'name': 'Buzz Cut',
      'price': '\$15',
      'duration': '15 min',
      'description': 'Clean and simple, perfect for low maintenance',
      'image': Icons.face_retouching_natural,
      'color': Colors.green,
    },
    {
      'name': 'Pompadour',
      'price': '\$35',
      'duration': '45 min',
      'description': 'Bold and stylish with volume on top',
      'image': Icons.style,
      'color': Colors.purple,
    },
    {
      'name': 'Undercut',
      'price': '\$30',
      'duration': '35 min',
      'description': 'Modern and edgy with short sides',
      'image': Icons.face,
      'color': Colors.orange,
    },
    {
      'name': 'Crew Cut',
      'price': '\$20',
      'duration': '20 min',
      'description': 'Professional and neat for any occasion',
      'image': Icons.person,
      'color': Colors.teal,
    },
  ];

  final List<Map<String, dynamic>> _beardStyles = [
    {
      'name': 'Full Beard',
      'price': '\$20',
      'duration': '25 min',
      'description': 'A classic full beard, well-groomed.',
      'image': Icons.face_retouching_natural,
      'color': Colors.brown,
    },
    {
      'name': 'Goatee',
      'price': '\$15',
      'duration': '20 min',
      'description': 'A stylish goatee, precisely trimmed.',
      'image': Icons.face,
      'color': Colors.blueGrey,
    },
    {
      'name': 'Stubble',
      'price': '\$10',
      'duration': '10 min',
      'description': 'A short, rugged stubble.',
      'image': Icons.face,
      'color': Colors.grey,
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
      appBar: AppBar(
        title: Text(
          'Barbcut',
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: false,
        toolbarHeight: 22,
        elevation: 0,
        backgroundColor: AppColors.background,
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
    final double carouselHeight = MediaQuery.of(context).size.height * 0.52;

    return GestureDetector(
      onVerticalDragUpdate: (details) {
        // If dragging up (negative delta), open the panel
        if (details.delta.dy < -5) {
          _panelController.open();
        }
      },
      child: Container(
        decoration: const BoxDecoration(color: AppColors.background),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 8),
                SizedBox(
                  height: carouselHeight,
                  child: FlutterCarousel(
                    options: CarouselOptions(
                      height: carouselHeight,
                      viewportFraction: 0.75,
                      enlargeCenterPage: true,
                      enableInfiniteScroll: true,
                      autoPlay: false,

                      onPageChanged: (index, reason) {
                        setState(() {
                          _selectedHaircutIndex = index;
                        });
                      },
                    ),
                    items: _haircuts.asMap().entries.map((entry) {
                      final int itemIndex = entry.key;
                      final Map<String, dynamic> haircut = entry.value;
                      final Color baseColor = haircut['color'] as Color;
                      final List<Color> colors = [
                        baseColor.withOpacity(0.7),
                        baseColor.withOpacity(0.5),
                        baseColor.withOpacity(0.6),
                        baseColor.withOpacity(0.8),
                      ];

                      return Align(
                        alignment: Alignment.center,
                        child: _buildCarouselCard(
                          haircut: haircut,
                          colors: colors,
                          itemIndex: itemIndex,
                          iconSize: 210,
                          titleSize: 16,
                          descriptionSize: 12,
                          chipSize: 12,
                          overlayOpacity: 0.25,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCarouselCard({
    required Map<String, dynamic> haircut,
    required List<Color> colors,
    required int itemIndex,
    required double iconSize,
    required double titleSize,
    required double descriptionSize,
    required double chipSize,
    required double overlayOpacity,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors[itemIndex % colors.length],
            colors[itemIndex % colors.length].withOpacity(0.3),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: colors[itemIndex % colors.length].withOpacity(0.2),
            blurRadius: 16,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(
              haircut['image'],
              size: iconSize,
              color: Colors.white.withOpacity(0.95),
            ),
          ),
          Positioned(
            left: 14,
            right: 14,
            bottom: 14,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: AppSpacing.paddingMD,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        haircut['name'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.titleMedium.copyWith(
                          fontSize: titleSize,
                          color: AppColors.surface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        haircut['description'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: descriptionSize,
                          color: AppColors.surface.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusSM,
                                ),
                              ),
                              child: Text(
                                haircut['price'],
                                style: AppTextStyles.labelSmall.copyWith(
                                  fontSize: chipSize,
                                  color: AppColors.surface,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusSM,
                                ),
                              ),
                              child: Text(
                                haircut['duration'],
                                style: AppTextStyles.labelSmall.copyWith(
                                  fontSize: chipSize,
                                  color: AppColors.surface,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                '${itemIndex + 1}',
                style: AppTextStyles.labelMedium.copyWith(
                  color: haircut['color'],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // const Padding(
        //   padding: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0),
        //   child: Text(
        //     "Choose a Style",
        //     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        //   ),
        // ),
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Hair'),
            Tab(text: 'Beard'),
          ],
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textTertiary,
          labelStyle: AppTextStyles.titleMedium,
          unselectedLabelStyle: AppTextStyles.titleMedium,
          indicatorSize: TabBarIndicatorSize.label,
          indicatorColor: AppColors.accent,
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [_buildHaircutGrid(), _buildBeardGrid()],
          ),
        ),
      ],
    );
  }

  Widget _buildHaircutGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 3 / 4,
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
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 3 / 4,
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
              // Note: We are closing the panel, but the main carousel
              // currently only shows haircuts. A further enhancement
              // would be to show the selected beard style as well.
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
    final Color baseColor = item['color'] as Color;
    final List<Color> colors = [
      baseColor.withOpacity(0.7),
      baseColor.withOpacity(0.5),
      baseColor.withOpacity(0.6),
      baseColor.withOpacity(0.8),
    ];

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? baseColor : Colors.transparent,
            width: 2.5,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: baseColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: _buildCarouselCard(
            haircut: item,
            colors: colors,
            itemIndex: itemIndex,
            iconSize: 120,
            titleSize: 12,
            descriptionSize: 10,
            chipSize: 10,
            overlayOpacity: 0.25,
          ),
        ),
      ),
    );
  }
}
