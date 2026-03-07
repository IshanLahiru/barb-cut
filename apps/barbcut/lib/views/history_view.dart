import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../features/history/domain/entities/history_entity.dart';
import '../features/history/presentation/bloc/history_bloc.dart';
import '../features/history/presentation/bloc/history_event.dart';
import '../features/ai_generation/presentation/cubit/generation_status_cubit.dart';
import '../features/history/presentation/bloc/history_state.dart';
import '../features/history/presentation/widgets/history_empty_state.dart';
import '../theme/theme.dart';
import '../widgets/lazy_network_image.dart';

class HistoryView extends StatefulWidget {
  final int currentIndex;
  final int tabIndex;

  const HistoryView({
    super.key,
    required this.currentIndex,
    required this.tabIndex,
  });

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView>
    with TickerProviderStateMixin {
  final Random _random = Random();
  late List<double> _cardHeights;
  late AnimationController _generationPulseController;
  bool _hasRequestedLoad = false;
  bool _isGridView = true; // Toggle between grid and list view

  // Getter that reads _generationHistory from BLoC state (avoid local copy)
  List<Map<String, dynamic>> get _generationHistory {
    final state = context.read<HistoryBloc>().state;
    if (state is HistoryLoaded) {
      return _mapHistory(state.history);
    }
    return [];
  }

  @override
  void initState() {
    super.initState();
    _cardHeights = [];
    _generationPulseController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    )..repeat();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _maybeRequestInitialLoad();
      }
    });
  }

  @override
  void didUpdateWidget(HistoryView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != oldWidget.currentIndex) {
      _maybeRequestInitialLoad();
    }
  }

  @override
  void dispose() {
    _generationPulseController.dispose();
    super.dispose();
  }

  void _regenerateHeights() {
    _cardHeights = List.generate(
      _generationHistory.length,
      (_) => 220.0 + _random.nextDouble() * 100,
    );
  }

  Future<void> _refreshHistory(BuildContext context) async {
    context.read<HistoryBloc>().add(const HistoryLoadRequested());
  }

  void _maybeRequestInitialLoad() {
    if (_hasRequestedLoad) return;
    if (widget.currentIndex != widget.tabIndex) return;
    final state = context.read<HistoryBloc>().state;
    if (state is HistoryInitial) {
      context.read<HistoryBloc>().add(const HistoryLoadRequested());
      _hasRequestedLoad = true;
    }
  }

  List<Map<String, dynamic>> _mapHistory(List<HistoryEntity> history) {
    return history
        .map(
          (item) => {
            'id': item.id,
            'image': item.imageUrl,
            'haircut': item.haircut,
            'beard': item.beard,
            'timestamp': item.timestamp,
          },
        )
        .toList();
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return _formatDate(timestamp);
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Widget _buildViewToggleButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: AiSpacing.sm,
            vertical: AiSpacing.xs,
          ),
          child: Icon(
            icon,
            size: 20,
            color: isActive
                ? AdaptiveThemeColors.neonCyan(context)
                : AdaptiveThemeColors.textTertiary(context),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    int crossAxisCount = 2;
    if (width >= 1100) {
      crossAxisCount = 4;
    } else if (width >= 820) {
      crossAxisCount = 3;
    }

    return BlocListener<HistoryBloc, HistoryState>(
      listener: (context, state) {
        // Side effects only - no setState for data updates
        if (state is HistoryLoaded) {
          // Data changes are handled through BlocBuilder via _mappedHistory getter
        }
      },
      child: Scaffold(
        backgroundColor: AdaptiveThemeColors.backgroundDeep(context),
        appBar: AppBar(
          backgroundColor: AdaptiveThemeColors.backgroundDark(context),
          elevation: 0,
          toolbarHeight: 56,
          title: Text(
            'History',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AdaptiveThemeColors.textPrimary(context),
              fontWeight: FontWeight.w800,
            ),
          ),
          centerTitle: true,
          surfaceTintColor: Colors.transparent,
          actions: [
            // View toggle button
            Container(
              margin: EdgeInsets.only(right: AiSpacing.md),
              decoration: BoxDecoration(
                color: AdaptiveThemeColors.backgroundDeep(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AdaptiveThemeColors.borderLight(
                    context,
                  ).withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildViewToggleButton(
                    icon: Icons.grid_view_rounded,
                    isActive: _isGridView,
                    onTap: () => setState(() => _isGridView = true),
                  ),
                  Container(
                    width: 1,
                    height: 24,
                    color: AdaptiveThemeColors.borderLight(
                      context,
                    ).withValues(alpha: 0.2),
                  ),
                  _buildViewToggleButton(
                    icon: Icons.view_list_rounded,
                    isActive: !_isGridView,
                    onTap: () => setState(() => _isGridView = false),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: BlocBuilder<HistoryBloc, HistoryState>(
            buildWhen: (prev, curr) {
              // Rebuild on state type changes
              if (prev.runtimeType != curr.runtimeType) return true;
              // For HistoryLoaded states, only rebuild if history data changed
              if (prev is HistoryLoaded && curr is HistoryLoaded) {
                return prev.history != curr.history;
              }
              return true;
            },
            builder: (context, historyState) {
              // Regenerate heights whenever history state changes
              if (historyState is HistoryLoaded) {
                _regenerateHeights();
              }
              return BlocBuilder<GenerationStatusCubit, GenerationStatusState>(
                buildWhen: (prev, curr) =>
                    prev.isGenerating != curr.isGenerating ||
                    prev.generatedStyleData != curr.generatedStyleData,
                builder: (context, genState) {
                  final isGenerating = genState.isGenerating;
                  final generatedStyle = genState.generatedStyleData;
                  return RefreshIndicator(
                    onRefresh: () => _refreshHistory(context),
                    child: _generationHistory.isEmpty && !isGenerating
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(height: 80),
                              const HistoryEmptyState(),
                            ],
                          )
                        : _isGridView
                        ? Padding(
                            padding: const EdgeInsets.fromLTRB(
                              AiSpacing.md,
                              AiSpacing.sm,
                              AiSpacing.md,
                              AiSpacing.md,
                            ),
                            child: MasonryGridView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                  ),
                              itemCount:
                                  _generationHistory.length +
                                  (isGenerating ? 1 : 0),
                              mainAxisSpacing: AiSpacing.md,
                              crossAxisSpacing: AiSpacing.md,
                              itemBuilder: (context, index) {
                                if (isGenerating && index == 0) {
                                  return _buildGeneratingTile(
                                    generatedStyle ?? {},
                                  );
                                }
                                final historyIndex = isGenerating
                                    ? index - 1
                                    : index;
                                final item = _generationHistory[historyIndex];
                                final height = _cardHeights[historyIndex];
                                return _buildHistoryCard(context, item, height);
                              },
                            ),
                          )
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(
                              AiSpacing.md,
                              AiSpacing.sm,
                              AiSpacing.md,
                              AiSpacing.md,
                            ),
                            itemCount:
                                _generationHistory.length +
                                (isGenerating ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (isGenerating && index == 0) {
                                return _buildGeneratingListTile(
                                  generatedStyle ?? {},
                                );
                              }
                              final historyIndex = isGenerating
                                  ? index - 1
                                  : index;
                              final item = _generationHistory[historyIndex];
                              return _buildHistoryListItem(context, item);
                            },
                          ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryCard(
    BuildContext context,
    Map<String, dynamic> item,
    double height,
  ) {
    final accentColor =
        // Using general color:
        AdaptiveThemeColors.neonCyan(context);

    return GestureDetector(
      onTap: () => _showHistoryPreviewDialog(context, item),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Image background with fade
                GridLazyImage(
                  imageUrl: item['image'] as String,
                  fit: BoxFit.cover,
                  customErrorWidget: Container(
                    color: accentColor.withValues(alpha: 0.2),
                    child: Icon(
                      Icons.image_not_supported,
                      size: 80,
                      color: accentColor.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                // Enhanced gradient overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.2),
                          Colors.black.withValues(alpha: 0.85),
                        ],
                        stops: const [0.3, 0.65, 1.0],
                      ),
                    ),
                  ),
                ),
                // Accent border glow
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.2),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(
                        AiSpacing.radiusLarge,
                      ),
                    ),
                  ),
                ),
                // Content at bottom
                Positioned(
                  left: AiSpacing.md,
                  right: AiSpacing.md,
                  bottom: AiSpacing.md,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Style badges
                      Row(
                        children: [
                          if (item['haircut'] != null &&
                              (item['haircut'] as String).isNotEmpty)
                            Flexible(
                              child: _buildModernBadge(
                                context,
                                item['haircut'] as String,
                                accentColor,
                              ),
                            ),
                          if (item['haircut'] != null &&
                              (item['haircut'] as String).isNotEmpty &&
                              item['beard'] != null &&
                              (item['beard'] as String).isNotEmpty)
                            SizedBox(width: AiSpacing.xs),
                          if (item['beard'] != null &&
                              (item['beard'] as String).isNotEmpty)
                            Flexible(
                              child: _buildModernBadge(
                                context,
                                item['beard'] as String,
                                AdaptiveThemeColors.neonPurple(context),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: AiSpacing.sm),
                      // Timestamp with modern styling
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 13,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            _formatTimestamp(item['timestamp'] as DateTime),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.95),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  letterSpacing: 0.2,
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
        ),
      ),
    );
  }

  Widget _buildModernBadge(
    BuildContext context,
    String text,
    Color accentColor,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AiSpacing.sm, vertical: 6),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 11,
          letterSpacing: 0.3,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildGeneratingTile(Map<String, dynamic>? styleData) {
    final accent = AdaptiveThemeColors.neonCyan(context);
    final previewImage = styleData?['image'] as String?;
    final haircutName = styleData?['haircut'] as String?;
    final beardName = styleData?['beard'] as String?;
    final status = styleData?['status']?.toString() ?? 'queued';
    final statusLine = switch (status) {
      'processing' ||
      'generating' => 'Generating now. This can take a few minutes.',
      'completed' => 'Finalizing your result in history.',
      'error' => 'Generation failed. You can retry from Home.',
      _ => 'Queued up. We will start shortly.',
    };

    return GestureDetector(
      onTap: null,
      child: Container(
        height: 280,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
          border: Border.all(color: accent.withValues(alpha: 0.4), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
          child: Stack(
            children: [
              // Preview image in background
              if (previewImage != null && previewImage.isNotEmpty)
                GridLazyImage(
                  imageUrl: previewImage,
                  fit: BoxFit.cover,
                  customErrorWidget: Container(
                    color: AdaptiveThemeColors.backgroundDark(context),
                    child: Icon(
                      Icons.image_not_supported,
                      size: 60,
                      color: accent.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              // Animated shimmer overlay
              AnimatedBuilder(
                animation: _generationPulseController,
                builder: (context, child) {
                  final shimmerOpacity =
                      ((_generationPulseController.value * 2 - 1).abs() - 1)
                          .abs();
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          accent.withValues(alpha: 0.0),
                          accent.withValues(
                            alpha: shimmerOpacity.clamp(0.0, 0.2),
                          ),
                          accent.withValues(alpha: 0.0),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  );
                },
              ),
              // Dark overlay for content readability
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.3),
                        Colors.black.withValues(alpha: 0.5),
                        Colors.black.withValues(alpha: 0.7),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),
              // Content
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.all(AiSpacing.lg),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Animated generating icon
                      AnimatedBuilder(
                        animation: _generationPulseController,
                        builder: (context, child) {
                          final pulse =
                              ((_generationPulseController.value * 2 - 1)
                                  .abs());
                          final scale = 0.85 + (pulse * 0.25);
                          final opacity = (0.6 + (pulse * 0.4)).clamp(0.0, 1.0);

                          return Transform.scale(
                            scale: scale,
                            child: Opacity(
                              opacity: opacity,
                              child: Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: accent.withValues(alpha: 0.4),
                                    width: 2.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: accent.withValues(alpha: 0.3),
                                      blurRadius: 12,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.auto_awesome_rounded,
                                  size: 40,
                                  color: accent,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: AiSpacing.md),
                      Text(
                        'Creating your style',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                              fontSize: 16,
                            ),
                      ),
                      SizedBox(height: AiSpacing.xs),
                      // Show selected styles
                      if (haircutName != null || beardName != null)
                        Text(
                          '${haircutName ?? ''} ${beardName ?? ''}'.trim(),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: accent.withValues(alpha: 0.9),
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (haircutName == null && beardName == null)
                        Text(
                          statusLine,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      SizedBox(height: AiSpacing.lg),
                      // Animated dots
                      _buildGeneratingStatusDots(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGeneratingStatusDots() {
    final accent = AdaptiveThemeColors.neonCyan(context);
    return AnimatedBuilder(
      animation: _generationPulseController,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (index) {
            final phase =
                (_generationPulseController.value + index * 0.15) % 1.0;
            // Smooth wave animation
            final distance = (phase - 0.5).abs() * 2;
            final scale = (0.5 + (0.6 * (1 - distance))).clamp(0.0, 2.0);
            final opacity = (0.4 + (0.8 * (1 - distance))).clamp(0.0, 1.0);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Opacity(
                opacity: opacity,
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accent,
                      boxShadow: [
                        BoxShadow(
                          color: accent.withValues(alpha: opacity * 0.6),
                          blurRadius: 8,
                          spreadRadius: 1.5,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  void _showHistoryPreviewDialog(
    BuildContext context,
    Map<String, dynamic> item,
  ) {
    final int tappedIndex = _generationHistory.indexOf(item);
    if (tappedIndex == -1) return;

    final List<int> previewIndices = [tappedIndex];
    for (int i = 0; i < _generationHistory.length; i++) {
      if (previewIndices.length >= 4) break;
      if (i != tappedIndex) previewIndices.add(i);
    }
    final List<Map<String, dynamic>> previewItems = previewIndices
        .map((index) => _generationHistory[index])
        .toList();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        int activeIndex = 0;
        return StatefulBuilder(
          builder: (context, setState) {
            final Map<String, dynamic> activeItem = previewItems[activeIndex];
            final accentColor =
                // Using general color:
                AdaptiveThemeColors.neonCyan(context);
            final double screenHeight = MediaQuery.of(context).size.height;
            final double screenWidth = MediaQuery.of(context).size.width;
            final double carouselHeight = (screenWidth * (2 / 3)).clamp(
              300.0,
              550.0,
            );

            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: EdgeInsets.all(AiSpacing.lg),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: 480,
                  maxHeight: screenHeight * 0.95,
                ),
                decoration: BoxDecoration(
                  color: AdaptiveThemeColors.backgroundDark(
                    context,
                  ).withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
                ),
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header
                          Padding(
                            padding: EdgeInsets.all(AiSpacing.lg),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.image,
                                    color: accentColor,
                                    size: 16,
                                  ),
                                ),
                                SizedBox(width: AiSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Generated Style',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              color:
                                                  AdaptiveThemeColors.textPrimary(
                                                    context,
                                                  ),
                                              fontWeight: FontWeight.w800,
                                            ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        _formatTimestamp(
                                          activeItem['timestamp'] as DateTime,
                                        ),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color:
                                                  AdaptiveThemeColors.textTertiary(
                                                    context,
                                                  ),
                                              fontSize: 12,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Image carousel - larger
                          Padding(
                            padding: EdgeInsets.all(AiSpacing.md),
                            child: SizedBox(
                              height: carouselHeight,
                              child: FlutterCarousel(
                                options: CarouselOptions(
                                  height: carouselHeight,
                                  viewportFraction: 0.95,
                                  enlargeCenterPage: true,
                                  enableInfiniteScroll: previewItems.length > 1,
                                  showIndicator: false,
                                  onPageChanged: (index, reason) {
                                    setState(() {
                                      activeIndex = index;
                                    });
                                  },
                                ),
                                items: previewItems.asMap().entries.map((
                                  entry,
                                ) {
                                  final int itemIndex = entry.key;
                                  final Map<String, dynamic> carouselItem =
                                      entry.value;
                                  final Color itemAccentColor =
                                      // Using general color:
                                      AdaptiveThemeColors.neonCyan(context);

                                  return GestureDetector(
                                    onTap: () => _showFullScreenGallery(
                                      context,
                                      previewItems,
                                      initialIndex: itemIndex,
                                    ),
                                    child: _buildPreviewImageCard(
                                      context,
                                      carouselItem,
                                      itemAccentColor,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          // Indicators
                          if (previewItems.length > 1)
                            Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: AiSpacing.sm,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  previewItems.length,
                                  (index) => AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: activeIndex == index ? 24 : 6,
                                    height: 6,
                                    margin: EdgeInsets.symmetric(
                                      horizontal: AiSpacing.xs,
                                    ),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: activeIndex == index
                                          ? accentColor
                                          : AiColors.borderLight.withValues(
                                              alpha: 0.4,
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          // Details - minimal space
                          Padding(
                            padding: EdgeInsets.all(AiSpacing.md),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (activeItem['haircut'] != null &&
                                    (activeItem['haircut'] as String)
                                        .isNotEmpty) ...[
                                  _buildDetailRowCompact(
                                    context,
                                    'Haircut',
                                    activeItem['haircut'] as String,
                                    accentColor,
                                  ),
                                  SizedBox(height: AiSpacing.sm),
                                ],
                                if (activeItem['beard'] != null &&
                                    (activeItem['beard'] as String)
                                        .isNotEmpty) ...[
                                  _buildDetailRowCompact(
                                    context,
                                    'Beard',
                                    activeItem['beard'] as String,
                                    AdaptiveThemeColors.neonPurple(context),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // X close button - top right
                    Positioned(
                      top: AiSpacing.md,
                      right: AiSpacing.md,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(dialogContext),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AdaptiveThemeColors.backgroundDeep(
                              context,
                            ).withValues(alpha: 0.6),
                            border: Border.all(
                              color: AdaptiveThemeColors.borderLight(
                                context,
                              ).withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            Icons.close,
                            color: AdaptiveThemeColors.textPrimary(context),
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPreviewImageCard(
    BuildContext context,
    Map<String, dynamic> item,
    Color accentColor,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AiSpacing.sm),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
        border: Border.all(color: accentColor.withValues(alpha: 0.3), width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AiSpacing.radiusLarge - 2),
        child: AspectRatio(
          aspectRatio: 2 / 3,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                item['image'] as String,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: accentColor.withValues(alpha: 0.2),
                    child: Icon(
                      Icons.image_not_supported,
                      size: 80,
                      color: accentColor,
                    ),
                  );
                },
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.25),
                        Colors.black.withValues(alpha: 0.7),
                      ],
                      stops: const [0.4, 0.7, 1.0],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFullScreenGallery(
    BuildContext context,
    List<Map<String, dynamic>> items, {
    int initialIndex = 0,
  }) {
    final PageController controller = PageController(initialPage: initialIndex);

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Stack(
            children: [
              PageView.builder(
                controller: controller,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final Map<String, dynamic> item = items[index];
                  final Color accentColor =
                      // Using general color:
                      AdaptiveThemeColors.neonCyan(context);

                  return Center(
                    child: InteractiveViewer(
                      minScale: 1,
                      maxScale: 3,
                      child: GridLazyImage(
                        imageUrl: item['image'] as String,
                        fit: BoxFit.contain,
                        customErrorWidget: Container(
                          height: 320,
                          width: 240,
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(
                              AiSpacing.radiusLarge,
                            ),
                          ),
                          child: Icon(
                            Icons.image_not_supported,
                            size: 80,
                            color: accentColor,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              Positioned(
                top: 24,
                right: 24,
                child: Container(
                  decoration: BoxDecoration(
                    color: AdaptiveThemeColors.backgroundDark(
                      context,
                    ).withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AdaptiveThemeColors.borderLight(
                        context,
                      ).withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: AdaptiveThemeColors.textPrimary(context),
                    ),
                    onPressed: () => Navigator.pop(dialogContext),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHistoryListItem(
    BuildContext context,
    Map<String, dynamic> item,
  ) {
    final accentColor = AdaptiveThemeColors.neonCyan(context);

    return GestureDetector(
      onTap: () => _showHistoryPreviewDialog(context, item),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          margin: EdgeInsets.only(bottom: AiSpacing.md),
          decoration: BoxDecoration(
            color: AdaptiveThemeColors.backgroundDark(context),
            borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.15),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Image thumbnail
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AiSpacing.radiusLarge),
                  bottomLeft: Radius.circular(AiSpacing.radiusLarge),
                ),
                child: Container(
                  width: 100,
                  height: 140,
                  child: GridLazyImage(
                    imageUrl: item['image'] as String,
                    fit: BoxFit.cover,
                    customErrorWidget: Container(
                      color: accentColor.withValues(alpha: 0.2),
                      child: Icon(
                        Icons.image_not_supported,
                        size: 40,
                        color: accentColor.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ),
              ),
              // Details
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(AiSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (item['haircut'] != null &&
                          (item['haircut'] as String).isNotEmpty)
                        _buildListDetailRow(
                          context,
                          Icons.content_cut_rounded,
                          'Haircut',
                          item['haircut'] as String,
                          accentColor,
                        ),
                      if (item['haircut'] != null &&
                          (item['haircut'] as String).isNotEmpty)
                        SizedBox(height: AiSpacing.sm),
                      if (item['beard'] != null &&
                          (item['beard'] as String).isNotEmpty)
                        _buildListDetailRow(
                          context,
                          Icons.face_rounded,
                          'Beard',
                          item['beard'] as String,
                          AdaptiveThemeColors.neonPurple(context),
                        ),
                      if (item['beard'] != null &&
                          (item['beard'] as String).isNotEmpty)
                        SizedBox(height: AiSpacing.sm),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: AdaptiveThemeColors.textTertiary(context),
                          ),
                          SizedBox(width: AiSpacing.xs),
                          Text(
                            _formatTimestamp(item['timestamp'] as DateTime),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AdaptiveThemeColors.textSecondary(
                                    context,
                                  ),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Arrow indicator
              Padding(
                padding: EdgeInsets.only(right: AiSpacing.md),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: AdaptiveThemeColors.textTertiary(context),
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color accentColor,
  ) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: accentColor),
        ),
        SizedBox(width: AiSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AdaptiveThemeColors.textTertiary(context),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AdaptiveThemeColors.textPrimary(context),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGeneratingListTile(Map<String, dynamic>? styleData) {
    final accent = AdaptiveThemeColors.neonCyan(context);
    final previewImage = styleData?['image'] as String?;
    final haircutName = styleData?['haircut'] as String?;
    final beardName = styleData?['beard'] as String?;
    final status = styleData?['status']?.toString() ?? 'queued';
    final statusLine = switch (status) {
      'processing' ||
      'generating' => 'Generating now. This can take a few minutes.',
      'completed' => 'Finalizing your result in history.',
      'error' => 'Generation failed. You can retry from Home.',
      _ => 'Queued up. We will start shortly.',
    };

    return Container(
      margin: EdgeInsets.only(bottom: AiSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
        border: Border.all(color: accent.withValues(alpha: 0.4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
        child: Row(
          children: [
            // Preview image thumbnail
            Container(
              width: 100,
              height: 140,
              child: Stack(
                children: [
                  if (previewImage != null && previewImage.isNotEmpty)
                    GridLazyImage(
                      imageUrl: previewImage,
                      fit: BoxFit.cover,
                      customErrorWidget: Container(
                        color: AdaptiveThemeColors.backgroundDark(context),
                        child: Icon(
                          Icons.image_not_supported,
                          size: 40,
                          color: accent.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                  // Shimmer overlay
                  AnimatedBuilder(
                    animation: _generationPulseController,
                    builder: (context, child) {
                      final shimmerOpacity =
                          ((_generationPulseController.value * 2 - 1).abs() - 1)
                              .abs();
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              accent.withValues(alpha: 0.0),
                              accent.withValues(
                                alpha: shimmerOpacity.clamp(0.0, 0.2),
                              ),
                              accent.withValues(alpha: 0.0),
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            // Details
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(AiSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        AnimatedBuilder(
                          animation: _generationPulseController,
                          builder: (context, child) {
                            final pulse =
                                ((_generationPulseController.value * 2 - 1)
                                    .abs());
                            final scale = 0.85 + (pulse * 0.15);
                            return Transform.scale(
                              scale: scale,
                              child: Icon(
                                Icons.auto_awesome_rounded,
                                size: 20,
                                color: accent,
                              ),
                            );
                          },
                        ),
                        SizedBox(width: AiSpacing.sm),
                        Text(
                          'Creating your style',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: AdaptiveThemeColors.textPrimary(context),
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                    SizedBox(height: AiSpacing.sm),
                    if (haircutName != null || beardName != null)
                      Text(
                        '${haircutName ?? ''} ${beardName ?? ''}'.trim(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: accent,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    SizedBox(height: AiSpacing.xs),
                    Text(
                      statusLine,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AdaptiveThemeColors.textSecondary(context),
                        fontSize: 11,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: AiSpacing.sm),
                    _buildGeneratingStatusDots(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRowCompact(
    BuildContext context,
    String label,
    String value,
    Color accentColor,
  ) {
    return Row(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AdaptiveThemeColors.textTertiary(context),
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),
        SizedBox(width: AiSpacing.xs),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AdaptiveThemeColors.textPrimary(context),
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
