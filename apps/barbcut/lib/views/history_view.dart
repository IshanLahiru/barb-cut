import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import '../theme/theme.dart';
import '../core/di/service_locator.dart';
import '../features/history/domain/entities/history_entity.dart';
import '../features/history/domain/usecases/get_history_usecase.dart';
import '../features/history/presentation/bloc/history_bloc.dart';
import '../features/history/presentation/bloc/history_event.dart';
import '../features/history/presentation/bloc/history_state.dart';
import 'dart:math';

class HistoryView extends StatefulWidget {
  const HistoryView({super.key});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  late List<Map<String, dynamic>> _generationHistory;
  final Random _random = Random();
  late List<double> _cardHeights;

  @override
  void initState() {
    super.initState();
    _generationHistory = [];
    _cardHeights = [];
  }

  void _regenerateHeights() {
    _cardHeights = List.generate(
      _generationHistory.length,
      (_) => 220.0 + _random.nextDouble() * 100,
    );
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
            'accentColor': item.accentColor,
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

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    int crossAxisCount = 2;
    if (width >= 1100) {
      crossAxisCount = 4;
    } else if (width >= 820) {
      crossAxisCount = 3;
    }

    return BlocProvider(
      create: (_) =>
          HistoryBloc(getHistoryUseCase: getIt<GetHistoryUseCase>())
            ..add(const HistoryLoadRequested()),
      child: BlocListener<HistoryBloc, HistoryState>(
        listener: (context, state) {
          if (state is HistoryLoaded) {
            setState(() {
              _generationHistory = _mapHistory(state.history);
              _regenerateHeights();
            });
          }
        },
        child: Scaffold(
          backgroundColor: AdaptiveThemeColors.backgroundDeep(context),
          appBar: AppBar(
            backgroundColor: AdaptiveThemeColors.backgroundDark(context),
            elevation: 0,
            toolbarHeight: 48,
            title: Text(
              'History',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AdaptiveThemeColors.textPrimary(context),
                fontWeight: FontWeight.w800,
              ),
            ),
            centerTitle: true,
            surfaceTintColor: Colors.transparent,
          ),
          body: SafeArea(
            child: _generationHistory.isEmpty
                ? _buildEmptyState(context)
                : Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AiSpacing.md,
                      AiSpacing.sm,
                      AiSpacing.md,
                      AiSpacing.md,
                    ),
                    child: MasonryGridView.builder(
                      physics: const BouncingScrollPhysics(),
                      gridDelegate:
                          SliverSimpleGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                          ),
                      itemCount: _generationHistory.length,
                      mainAxisSpacing: AiSpacing.md,
                      crossAxisSpacing: AiSpacing.md,
                      itemBuilder: (context, index) {
                        final item = _generationHistory[index];
                        final height = _cardHeights[index];
                        return _buildHistoryCard(context, item, height);
                      },
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.8 + (value * 0.2),
                child: Opacity(opacity: value, child: child),
              );
            },
            child: Container(
              padding: EdgeInsets.all(AiSpacing.xl),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AdaptiveThemeColors.neonCyan(
                      context,
                    ).withValues(alpha: 0.15),
                    AdaptiveThemeColors.neonPurple(
                      context,
                    ).withValues(alpha: 0.15),
                  ],
                ),
                border: Border.all(
                  color: AdaptiveThemeColors.neonCyan(
                    context,
                  ).withValues(alpha: 0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AdaptiveThemeColors.neonCyan(
                      context,
                    ).withValues(alpha: 0.1),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Icon(
                Icons.history_rounded,
                size: 64,
                color: AdaptiveThemeColors.neonCyan(context),
              ),
            ),
          ),
          SizedBox(height: AiSpacing.xl),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 900),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 10 * (1 - value)),
                child: Opacity(opacity: value, child: child),
              );
            },
            child: Column(
              children: [
                Text(
                  'No generation history yet',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AdaptiveThemeColors.textPrimary(context),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),
                SizedBox(height: AiSpacing.md),
                Text(
                  'Generate your first style to see it here',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AdaptiveThemeColors.textTertiary(context),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(
    BuildContext context,
    Map<String, dynamic> item,
    double height,
  ) {
    final accentColor =
        (item['accentColor'] as Color?) ??
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
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.2),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Image background with fade
                Image.network(
                  item['image'] as String,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: accentColor.withValues(alpha: 0.2),
                      child: Icon(
                        Icons.image_not_supported,
                        size: 80,
                        color: accentColor.withValues(alpha: 0.6),
                      ),
                    );
                  },
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
                (activeItem['accentColor'] as Color?) ??
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
                            child: Container(
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
                                      (carouselItem['accentColor'] as Color?) ??
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
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.2),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
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
                      (item['accentColor'] as Color?) ??
                      AdaptiveThemeColors.neonCyan(context);

                  return Center(
                    child: InteractiveViewer(
                      minScale: 1,
                      maxScale: 3,
                      child: Image.network(
                        item['image'] as String,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
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
                          );
                        },
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
