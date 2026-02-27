import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math';
import 'dart:async';
import '../theme/theme.dart';
import '../core/di/service_locator.dart';
import '../features/home/domain/entities/style_entity.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/favourites/domain/usecases/add_favourite_usecase.dart';
import '../features/favourites/domain/usecases/get_favourites_usecase.dart';
import '../features/favourites/domain/usecases/remove_favourite_usecase.dart';
import '../features/home/domain/usecases/get_beard_styles_usecase.dart';
import '../features/home/data/datasources/tab_categories_remote_data_source.dart';
import '../features/home/domain/entities/tab_category_entity.dart';
import '../features/home/domain/usecases/get_haircuts_usecase.dart';
import '../features/ai_generation/presentation/cubit/generation_status_cubit.dart';
import '../features/home/presentation/bloc/home_bloc.dart';
import '../features/home/presentation/bloc/home_event.dart';
import '../features/home/presentation/bloc/home_state.dart';
import '../features/home/presentation/widgets/home_favourites_empty.dart';
import '../shared/widgets/molecules/style_preview_card_inline.dart';
import '../controllers/style_selection_controller.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../services/ai_generation_service.dart';
import '../services/user_photo_service.dart';
import '../widgets/generation_error_card.dart';
import '../widgets/lazy_network_image.dart';
import '../widgets/firebase_image.dart';
import 'face_photo_upload_view.dart';

class HomeView extends StatefulWidget {
  final VoidCallback? onNavigateToHistory;

  const HomeView({super.key, this.onNavigateToHistory});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  // Fields
  Set<String> _favouriteIds = {};
  bool _favouritesLoading = false;
  String? _favouritesError;
  final PanelController _panelController = PanelController();
  final ScrollController _mainScrollController = ScrollController();
  final ScrollController _panelScrollController = ScrollController();
  final TextEditingController _panelSearchController = TextEditingController();
  final FocusNode _panelSearchFocus = FocusNode();
  int _selectedHaircutIndex = 0;
  int _selectedBeardIndex = 0;
  int _selectedAngleIndex = 0;
  final ValueNotifier<String> _panelSearchQueryNotifier = ValueNotifier<String>(
    '',
  );
  double _panelSlidePosition = 0.0;
  final ValueNotifier<double> _panelSlidePositionNotifier =
      ValueNotifier<double>(0.0);
  TabController? _tabController;
  late AnimationController _arrowAnimationController;
  late AnimationController _generationPulseController;
  final Random _random = Random();
  late List<double> _beardHeights;
  bool _isGenerating = false;
  int? _confirmedHaircutIndex;
  int? _confirmedBeardIndex;
  Timer? _carouselTimer;
  final String _activeJobStatus = 'queued';
  String? _activeJobError;
  late List<StyleEntity> _haircutEntities = [];
  late List<StyleEntity> _beardEntities = [];
  late List<Map<String, dynamic>> _haircuts = [];
  late List<Map<String, dynamic>> _beardStyles = [];

  // Methods
  Widget _buildRecentGrid(ScrollController? scrollController) {
    // TODO: Backend-backed recents can be implemented here by
    // loading a user-specific recent list and rendering it similarly
    // to the favourites grid. For now, show a friendly placeholder.
    return Center(
      child: Text(
        'Recently used haircuts and beard styles will appear here.',
        style: Theme.of(context).textTheme.titleMedium,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildFavouritesGrid(ScrollController? scrollController) {
    final width = MediaQuery.of(context).size.width;
    int crossAxisCount = 2;
    if (width >= 1100) {
      crossAxisCount = 4;
    } else if (width >= 820) {
      crossAxisCount = 3;
    }

    // Only show loading spinner when actively fetching favorites
    if (_favouritesLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    // Show error if occurred
    if (_favouritesError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
            SizedBox(height: AiSpacing.md),
            Text(
              'Failed to load favourites:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AdaptiveThemeColors.textSecondary(context),
              ),
            ),
            SizedBox(height: AiSpacing.sm),
            Text(
              _favouritesError!,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.redAccent),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    // If styles haven't loaded yet, show a message
    if (_haircuts.isEmpty && _beardStyles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.style_outlined,
              size: 64,
              color: AdaptiveThemeColors.textTertiary(context),
            ),
            SizedBox(height: AiSpacing.md),
            Text(
              'Styles are loading...',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AdaptiveThemeColors.textSecondary(context),
              ),
            ),
          ],
        ),
      );
    }

    final favHaircuts = _haircuts
        .where((h) => _favouriteIds.contains(h['id'].toString()))
        .toList();
    final favBeards = _beardStyles
        .where((b) => _favouriteIds.contains(b['id'].toString()))
        .toList();
    final allFavourites = [...favHaircuts, ...favBeards];
    if (allFavourites.isEmpty) {
      return const HomeFavouritesEmpty();
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AiSpacing.md,
        AiSpacing.sm,
        AiSpacing.md,
        AiSpacing.md,
      ),
      child: RepaintBoundary(
        child: MasonryGridView.builder(
          controller: scrollController ?? ScrollController(),
          physics: const BouncingScrollPhysics(),
          gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
          ),
          itemCount: allFavourites.length,
          mainAxisSpacing: AiSpacing.md,
          crossAxisSpacing: AiSpacing.md,
          itemBuilder: (context, index) {
            final item = allFavourites[index];
            final isSelected = false;
            // Determine style type for correct toggle logic
            final isHaircut = _haircuts.any((h) => h['id'] == item['id']);
            final styleType = isHaircut ? 'haircut' : 'beard';
            return _buildStyleCard(
              item: item,
              itemIndex: index,
              isSelected: isSelected,
              height: 220,
              onTap: () {},
              showFavouriteIcon: true,
              onFavouriteToggle: () {
                context.read<HomeBloc>().add(
                  FavouriteToggled(item: item, styleType: styleType),
                );
              },
              styleType: styleType,
            );
          },
        ),
      ),
    );
  }

  /// Current panel tab type from HomeBloc (e.g. 'recent', 'favourites', 'hair', 'beard').
  String _getCurrentTabType(BuildContext context) {
    final state = context.read<HomeBloc>().state;
    final categories = state is HomeLoaded && state.tabCategories.isNotEmpty
        ? state.tabCategories
        : TabCategoryEntity.defaultPanelTabs;
    final index = _tabController?.index ?? 0;
    if (index < 0 || index >= categories.length) return 'recent';
    return categories[index].type;
  }

  /// Selected style for the hero area: only set when current tab is 'hair' or 'beard'.
  Map<String, dynamic>? _getSelectedStyleForMainContent(BuildContext context) {
    final tabType = _getCurrentTabType(context);
    if (tabType == 'hair') {
      return _haircuts.isNotEmpty ? _haircuts[_selectedHaircutIndex] : null;
    }
    if (tabType == 'beard') {
      return _beardStyles.isNotEmpty ? _beardStyles[_selectedBeardIndex] : null;
    }
    return null;
  }

  /// Extract images for the hero / swipe-up view.
  /// Only returns the *primary* (front) image so we don't
  /// eagerly load all angles when the user opens a style.
  List<String> _extractImages(Map<String, dynamic>? style) {
    final images = style?['images'];
    if (images is List && images.isNotEmpty) {
      // Use only the first image in the list (front/primary).
      final primary = images.first.toString();
      final largePrimary = _buildSizedImageUrl(primary, 'large');
      return <String>[largePrimary];
    }
    if (images is Map) {
      // Prefer explicit front image if available.
      final front = images['front']?.toString();
      if (front != null && front.isNotEmpty) {
        final largeFront = _buildSizedImageUrl(front, 'large');
        return <String>[largeFront];
      }
      // Fallback to any of the side images if front is missing.
      final left = images['left'] ?? images['left_side'] ?? images['leftSide'];
      if (left != null && left.toString().isNotEmpty) {
        final largeLeft = _buildSizedImageUrl(left.toString(), 'large');
        return <String>[largeLeft];
      }
      final right =
          images['right'] ?? images['right_side'] ?? images['rightSide'];
      if (right != null && right.toString().isNotEmpty) {
        final largeRight = _buildSizedImageUrl(right.toString(), 'large');
        return <String>[largeRight];
      }
      final back = images['back']?.toString();
      if (back != null && back.isNotEmpty) {
        final largeBack = _buildSizedImageUrl(back, 'large');
        return <String>[largeBack];
      }
    }
    final image = style?['image'];
    if (image != null && image.toString().isNotEmpty) {
      final largeImage = _buildSizedImageUrl(image.toString(), 'large');
      return <String>[largeImage];
    }
    return <String>[];
  }

  /// Build a sized variant of a storage path or download URL.
  /// Example: 'haircuts/afro_front.png' -> 'haircuts/afro_front_small.png'.
  String _buildSizedImageUrl(String urlOrPath, String sizeSuffix) {
    if (urlOrPath.isEmpty) return urlOrPath;

    // If this looks like a full URL, rewrite only the path segment.
    try {
      final uri = Uri.parse(urlOrPath);
      if (uri.scheme.isNotEmpty && uri.host.isNotEmpty) {
        final path = uri.path;
        final dotIndex = path.lastIndexOf('.');
        final newPath = dotIndex == -1
            ? '$path\_$sizeSuffix'
            : '${path.substring(0, dotIndex)}\_$sizeSuffix${path.substring(dotIndex)}';
        return uri.replace(path: newPath).toString();
      }
    } catch (_) {
      // Fall through to plain string handling if parsing fails.
    }

    final dotIndex = urlOrPath.lastIndexOf('.');
    if (dotIndex == -1) {
      return '${urlOrPath}_$sizeSuffix';
    }
    return '${urlOrPath.substring(0, dotIndex)}_$sizeSuffix${urlOrPath.substring(dotIndex)}';
  }

  void _regenerateHeights() {
    _beardHeights = List.generate(
      _beardStyles.length,
      (_) => 200.0 + _random.nextDouble() * 80,
    );
  }

  @override
  void initState() {
    super.initState();
    _arrowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 380),
      vsync: this,
    );
    _generationPulseController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    )..repeat();
    _mainScrollController.addListener(_handleMainScroll);
    _panelSearchFocus.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    _regenerateHeights();
  }

  double _lastScrollOffset = 0.0;
  final double _scrollThresholdToRetractPanel = 40.0;
  final double _scrollDeltaMin = 24.0;
  final double _scrollOffsetDescriptionVisible = 280.0;
  final double _scrollOffsetRevealPanel = 260.0;

  // Panel levels: 1 = minimal (reading description), 2 = peek, 4 = full screen
  final double _panelLevel1 = 0.0;
  final double _panelLevel2 = 0.20; // middle stage — a bit lower
  final double _panelLevel4 = 1.0;

  final Duration _panelRevealDuration = const Duration(milliseconds: 520);
  final Duration _panelSnapDuration = const Duration(milliseconds: 320);
  final Curve _panelCurve = Curves.fastOutSlowIn;

  Future<void> _setPanelLevel(double level, {Duration? duration}) async {
    if (!_panelController.isAttached) return;
    await _panelController.animatePanelToPosition(
      level.clamp(0.0, 1.0),
      duration: duration ?? _panelSnapDuration,
      curve: _panelCurve,
    );
  }

  void _handleMainScroll() {
    if (!_mainScrollController.hasClients) return;
    _handleScrollOffset(_mainScrollController.offset);
  }

  void _handleScrollOffset(double offset) {
    if (!_panelController.isAttached) return;
    final delta = offset - _lastScrollOffset;

    // When viewing description: collapse panel to minimum (no hide/show — avoid stuck state)
    if (offset >= _scrollOffsetDescriptionVisible) {
      if (_panelSlidePosition > 0) {
        _setPanelLevel(_panelLevel1);
      }
      _lastScrollOffset = offset;
      return;
    }

    // Back in top area: bring panel back to peek when user scrolls up
    if (offset < _scrollOffsetRevealPanel &&
        _panelSlidePosition < _panelLevel2) {
      _setPanelLevel(_panelLevel2, duration: _panelRevealDuration);
      _lastScrollOffset = offset;
      return;
    }

    // Scrolling down: go to level 2 (peek)
    if (delta > _scrollDeltaMin &&
        offset > _scrollThresholdToRetractPanel &&
        _panelSlidePosition > _panelLevel2) {
      _setPanelLevel(_panelLevel2);
    }

    // Scrolling up (panel visible): animate to full
    if (delta < -_scrollDeltaMin &&
        offset < _scrollOffsetDescriptionVisible &&
        _panelSlidePosition < _panelLevel4) {
      _setPanelLevel(_panelLevel4, duration: _panelRevealDuration);
    }

    _lastScrollOffset = offset;
  }

  void _onTryThisPressed() async {
    if (_haircuts.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Styles are still loading. Please try again.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }
    final haircut = _haircuts[_confirmedHaircutIndex ?? _selectedHaircutIndex];
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        final bg = AdaptiveThemeColors.backgroundDark(dialogContext);
        final border = AdaptiveThemeColors.borderLight(dialogContext);
        final textP = AdaptiveThemeColors.textPrimary(dialogContext);
        final textS = AdaptiveThemeColors.textSecondary(dialogContext);
        final textT = AdaptiveThemeColors.textTertiary(dialogContext);
        final accent = AdaptiveThemeColors.neonCyan(dialogContext);
        final onAccent = AdaptiveThemeColors.backgroundDeep(dialogContext);
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: AiSpacing.lg),
          child: Container(
            constraints: BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
              border: Border.all(
                color: border.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    AiSpacing.lg,
                    AiSpacing.lg,
                    AiSpacing.sm,
                    AiSpacing.md,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accent.withValues(alpha: 0.15),
                        ),
                        child: Icon(
                          Icons.face_retouching_natural,
                          color: accent,
                          size: 22,
                        ),
                      ),
                      SizedBox(width: AiSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Complete Your Look',
                              style: TextStyle(
                                color: textP,
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Add a beard style to complete your transformation',
                              style: TextStyle(color: textT, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: textS, size: 22),
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          if (mounted) {
                            setState(() {
                              _confirmedHaircutIndex = null;
                              _confirmedBeardIndex = null;
                            });
                          }
                        },
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(
                          minWidth: 44,
                          minHeight: 44,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: border.withValues(alpha: 0.3)),
                Padding(
                  padding: EdgeInsets.all(AiSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your selection',
                        style: TextStyle(
                          color: textT,
                          letterSpacing: 0.3,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: AiSpacing.sm),
                      StylePreviewCardInline(style: haircut),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    AiSpacing.lg,
                    0,
                    AiSpacing.lg,
                    AiSpacing.lg,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                            setState(
                              () => _confirmedHaircutIndex =
                                  _selectedHaircutIndex,
                            );
                            _tabController?.animateTo(1);
                            _setPanelLevel(_panelLevel4);
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: accent,
                            foregroundColor: onAccent,
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
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
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

  void _showBeardSelectionPrompt() async {
    if (_beardStyles.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Beard styles are still loading.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }
    final beard = _beardStyles[_confirmedBeardIndex ?? _selectedBeardIndex];
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        final bg = AdaptiveThemeColors.backgroundDark(dialogContext);
        final border = AdaptiveThemeColors.borderLight(dialogContext);
        final textP = AdaptiveThemeColors.textPrimary(dialogContext);
        final textS = AdaptiveThemeColors.textSecondary(dialogContext);
        final textT = AdaptiveThemeColors.textTertiary(dialogContext);
        final accent = AdaptiveThemeColors.neonCyan(dialogContext);
        final onAccent = AdaptiveThemeColors.backgroundDeep(dialogContext);
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: AiSpacing.lg),
          child: Container(
            constraints: BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
              border: Border.all(
                color: border.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    AiSpacing.lg,
                    AiSpacing.lg,
                    AiSpacing.sm,
                    AiSpacing.md,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accent.withValues(alpha: 0.15),
                        ),
                        child: Icon(
                          Icons.face_retouching_natural,
                          color: accent,
                          size: 22,
                        ),
                      ),
                      SizedBox(width: AiSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Complete Your Look',
                              style: TextStyle(
                                color: textP,
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Add a haircut style to complete your transformation',
                              style: TextStyle(color: textT, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: textS, size: 22),
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          if (mounted) {
                            setState(() {
                              _confirmedHaircutIndex = null;
                              _confirmedBeardIndex = null;
                            });
                          }
                        },
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(
                          minWidth: 44,
                          minHeight: 44,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: border.withValues(alpha: 0.3)),
                Padding(
                  padding: EdgeInsets.all(AiSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your selection',
                        style: TextStyle(
                          color: textT,
                          letterSpacing: 0.3,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: AiSpacing.sm),
                      StylePreviewCardInline(style: beard),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    AiSpacing.lg,
                    0,
                    AiSpacing.lg,
                    AiSpacing.lg,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                            setState(
                              () => _confirmedBeardIndex = _selectedBeardIndex,
                            );
                            _showConfirmationDialog();
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: textS,
                            side: BorderSide(color: border, width: 1.5),
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AiSpacing.radiusMedium,
                              ),
                            ),
                          ),
                          child: Text(
                            'Just Beard',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: AiSpacing.md),
                      Expanded(
                        flex: 2,
                        child: FilledButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                            setState(
                              () => _confirmedBeardIndex = _selectedBeardIndex,
                            );
                            _tabController?.animateTo(0);
                            _setPanelLevel(_panelLevel4);
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: accent,
                            foregroundColor: onAccent,
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AiSpacing.radiusMedium,
                              ),
                            ),
                          ),
                          child: Text(
                            'Add Haircut Style',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
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
    final haircut = _confirmedHaircutIndex != null
        ? _haircuts[_confirmedHaircutIndex!]
        : null;
    final beard = _confirmedBeardIndex != null
        ? _beardStyles[_confirmedBeardIndex!]
        : null;

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        if (!mounted) return const SizedBox.shrink();
        final bg = AdaptiveThemeColors.backgroundDark(dialogContext);
        final border = AdaptiveThemeColors.borderLight(dialogContext);
        final textP = AdaptiveThemeColors.textPrimary(dialogContext);
        final textS = AdaptiveThemeColors.textSecondary(dialogContext);
        final textT = AdaptiveThemeColors.textTertiary(dialogContext);
        final accent = AdaptiveThemeColors.neonCyan(dialogContext);
        final onAccent = AdaptiveThemeColors.backgroundDeep(dialogContext);
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: AiSpacing.lg),
          child: Container(
            constraints: BoxConstraints(maxWidth: 420),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
              border: Border.all(
                color: border.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    AiSpacing.lg,
                    AiSpacing.lg,
                    AiSpacing.sm,
                    AiSpacing.md,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accent.withValues(alpha: 0.15),
                        ),
                        child: Icon(
                          Icons.check_circle_outline,
                          color: accent,
                          size: 22,
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
                                color: textP,
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Review your selections',
                              style: TextStyle(color: textT, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: textS, size: 22),
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          if (mounted) {
                            setState(() {
                              _confirmedHaircutIndex = null;
                              _confirmedBeardIndex = null;
                            });
                          }
                        },
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(
                          minWidth: 44,
                          minHeight: 44,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: border.withValues(alpha: 0.3)),

                // Selection cards with small image preview
                Padding(
                  padding: EdgeInsets.all(AiSpacing.lg),
                  child: Column(
                    children: [
                      haircut != null
                          ? _buildInlineStyleCard(
                              style: haircut,
                              label: 'Haircut',
                              accentColor: AdaptiveThemeColors.neonCyan(
                                dialogContext,
                              ),
                              onChangePressed: () {
                                Navigator.of(dialogContext).pop();
                                if (mounted) {
                                  setState(() {
                                    _selectedHaircutIndex =
                                        _confirmedHaircutIndex ??
                                        _selectedHaircutIndex;
                                  });
                                  _tabController?.animateTo(0);
                                  _setPanelLevel(_panelLevel4);
                                }
                              },
                              onRemovePressed: () {
                                Navigator.of(dialogContext).pop();
                                if (mounted) {
                                  setState(() => _confirmedHaircutIndex = null);
                                  _showConfirmationDialog();
                                }
                              },
                            )
                          : _buildInlineAddStyleCard(
                              title: 'Add Haircut Style',
                              subtitle: 'Complete your look',
                              accentColor: accent,
                              onPressed: () {
                                Navigator.of(dialogContext).pop();
                                if (mounted) {
                                  _tabController?.animateTo(0);
                                  _setPanelLevel(_panelLevel4);
                                }
                              },
                            ),
                      SizedBox(height: AiSpacing.md),
                      beard != null
                          ? _buildInlineStyleCard(
                              style: beard,
                              label: 'Beard',
                              accentColor: AdaptiveThemeColors.neonCyan(
                                dialogContext,
                              ),
                              onChangePressed: () {
                                Navigator.of(dialogContext).pop();
                                if (mounted) {
                                  setState(() {
                                    _selectedBeardIndex =
                                        _confirmedBeardIndex ??
                                        _selectedBeardIndex;
                                  });
                                  _tabController?.animateTo(1);
                                  _setPanelLevel(_panelLevel4);
                                }
                              },
                              onRemovePressed: () {
                                Navigator.of(dialogContext).pop();
                                if (mounted) {
                                  setState(() => _confirmedBeardIndex = null);
                                  _showConfirmationDialog();
                                }
                              },
                            )
                          : _buildInlineAddStyleCard(
                              title: 'Add Beard Style',
                              subtitle: 'Complete your look',
                              accentColor: AdaptiveThemeColors.neonPurple(
                                dialogContext,
                              ),
                              onPressed: () {
                                Navigator.of(dialogContext).pop();
                                if (mounted) {
                                  _tabController?.animateTo(1);
                                  _setPanelLevel(_panelLevel4);
                                }
                              },
                            ),
                    ],
                  ),
                ),

                Divider(height: 1, color: border.withValues(alpha: 0.3)),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    AiSpacing.lg,
                    AiSpacing.md,
                    AiSpacing.lg,
                    AiSpacing.lg,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                            if (mounted) {
                              setState(() {
                                _confirmedHaircutIndex = null;
                                _confirmedBeardIndex = null;
                              });
                              _setPanelLevel(_panelLevel2);
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: textS,
                            side: BorderSide(color: border, width: 1.5),
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AiSpacing.radiusMedium,
                              ),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: AiSpacing.md),
                      Expanded(
                        flex: 2,
                        child: FilledButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                            if (mounted) _startGeneration();
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: accent,
                            foregroundColor: onAccent,
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

  Widget _buildInlineStyleCard({
    required Map<String, dynamic> style,
    required String label,
    required Color accentColor,
    required VoidCallback onChangePressed,
    required VoidCallback onRemovePressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AiSpacing.radiusMedium),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
        color: accentColor.withValues(alpha: 0.03),
      ),
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
          SizedBox(height: 10),
          StylePreviewCardInline(style: style),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
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
              SizedBox(width: 8),
              Expanded(
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
        ],
      ),
    );
  }

  Widget _buildInlineAddStyleCard({
    required String title,
    required String subtitle,
    required Color accentColor,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AiSpacing.radiusMedium),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
        color: accentColor.withValues(alpha: 0.03),
      ),
      padding: EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accentColor.withValues(alpha: 0.15),
            ),
            child: Icon(Icons.add_circle_outline, color: accentColor, size: 24),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AiColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: AiColors.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
          SizedBox(width: 12),
          OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: accentColor,
              side: BorderSide(
                color: accentColor.withValues(alpha: 0.4),
                width: 1,
              ),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: Text('Add', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Future<void> _startGeneration() async {
    // Check if user has uploaded face photos
    final hasPhotos = await UserPhotoService.hasPhotoUploaded();
    if (!hasPhotos) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Upload Face Photos First'),
            content: const Text(
              'Please upload face photos from different angles (front, left, right, back) before generating styles.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (ctx) => const FacePhotoUploadView(),
                    ),
                  );
                },
                child: const Text('Upload Photos'),
              ),
            ],
          ),
        );
      }
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    _setPanelLevel(_panelLevel2);

    final String tabType = _getCurrentTabType(context);
    final Map<String, dynamic>? selectedStyle = _getSelectedStyleForMainContent(
      context,
    );

    if (selectedStyle != null) {
      final List<String> images = _extractImages(selectedStyle);
      final String styleImage = images.isNotEmpty ? images[0] : '';

      final bool hasHaircut =
          _confirmedHaircutIndex != null ||
          (tabType == 'hair' && _haircuts.isNotEmpty);
      final bool hasBeard =
          _confirmedBeardIndex != null ||
          (tabType == 'beard' && _beardStyles.isNotEmpty);
      String jobId = '';
      try {
        jobId = await AiGenerationService.createGenerationJob(
          haircutId: hasHaircut
              ? _haircuts[_confirmedHaircutIndex ?? _selectedHaircutIndex]['id']
                    ?.toString()
              : null,
          beardId: hasBeard
              ? _beardStyles[_confirmedBeardIndex ?? _selectedBeardIndex]['id']
                    ?.toString()
              : null,
        );
      } catch (e) {
        debugPrint('Failed to create generation job: $e');
        if (mounted) {
          setState(() => _isGenerating = false);
          if (e is FirebaseFunctionsException &&
              e.code == 'failed-precondition' &&
              (e.message?.toLowerCase().contains('insufficient') ?? false)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Insufficient credits. Get more in Settings or purchase more.',
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: $e')));
          }
        }
        return;
      }

      final String haircutName = _confirmedHaircutIndex != null
          ? _haircuts[_confirmedHaircutIndex!]['name']?.toString() ?? 'N/A'
          : (tabType == 'hair'
                ? selectedStyle['name']?.toString() ?? 'Haircut'
                : 'N/A');
      final String beardName = _confirmedBeardIndex != null
          ? _beardStyles[_confirmedBeardIndex!]['name']?.toString() ?? 'N/A'
          : (tabType == 'beard'
                ? selectedStyle['name']?.toString() ?? 'Beard'
                : 'N/A');
      final styleData = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'image': styleImage,
        'haircut': haircutName,
        'beard': beardName,
        'timestamp': DateTime.now(),
        'jobId': jobId,
        'status': jobId.isEmpty ? 'error' : 'queued',
      };

      if (jobId.isNotEmpty) {
        context.read<GenerationStatusCubit>().startWatchingJob(
          jobId,
          styleData,
        );
      } else {
        setState(() => _isGenerating = false);
        _markGenerationFailedSnackbar('Unable to create generation job.');
      }
    }

    widget.onNavigateToHistory?.call();
  }

  void _markGenerationFailedSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _arrowAnimationController.dispose();
    _generationPulseController.dispose();
    _carouselTimer?.cancel();
    _panelSearchQueryNotifier.dispose();
    _panelSearchController.dispose();
    _panelSearchFocus.dispose();
    _mainScrollController.dispose();
    _panelScrollController.dispose();
    _panelSlidePositionNotifier.dispose();
    super.dispose();
  }

  bool _matchesPanelSearch(Map<String, dynamic> item) {
    final raw = _panelSearchQueryNotifier.value;
    if (raw.trim().isEmpty) {
      return true;
    }
    final query = raw.toLowerCase();
    final name = item['name']?.toString().toLowerCase() ?? '';
    final description = item['description']?.toString().toLowerCase() ?? '';
    return name.contains(query) || description.contains(query);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GenerationStatusCubit, GenerationStatusState>(
      listener: (context, state) {
        if (!state.isGenerating && state.generatedStyleData != null) {
          final status = state.generatedStyleData!['status']?.toString();
          if (status == 'completed') {
            if (mounted) {
              setState(() {
                _isGenerating = false;
                _confirmedHaircutIndex = null;
                _confirmedBeardIndex = null;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    'Your look is ready. Check History to view it.',
                  ),
                  action: SnackBarAction(
                    label: 'History',
                    onPressed: widget.onNavigateToHistory ?? () {},
                  ),
                ),
              );
            }
          } else if (status == 'error') {
            if (mounted) {
              setState(() {
                _isGenerating = false;
                _confirmedHaircutIndex = null;
                _confirmedBeardIndex = null;
              });
              final msg =
                  state.generatedStyleData!['errorMessage']?.toString() ??
                  'Generation failed.';
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(msg)));
            }
          }
        }
      },
      child: BlocProvider<HomeBloc>(
        create: (_) => HomeBloc(
          getHaircutsUseCase: getIt<GetHaircutsUseCase>(),
          getBeardStylesUseCase: getIt<GetBeardStylesUseCase>(),
          getFavouritesUseCase: getIt<GetFavouritesUseCase>(),
          addFavouriteUseCase: getIt<AddFavouriteUseCase>(),
          removeFavouriteUseCase: getIt<RemoveFavouriteUseCase>(),
          authRepository: getIt<AuthRepository>(),
          tabCategoriesDataSource: getIt<TabCategoriesRemoteDataSource>(),
        )..add(const HomeLoadRequested()),
        child: BlocListener<HomeBloc, HomeState>(
          listener: (context, state) {
            if (state is HomeLoaded) {
              final haircuts = state.haircutMaps;
              final beardStyles = state.beardStyleMaps;
              setState(() {
                _haircutEntities = state.haircuts;
                _beardEntities = state.beardStyles;
                _haircuts = haircuts;
                _beardStyles = beardStyles;
                _favouriteIds = state.favouriteIds;
                _favouritesLoading = state.favouritesLoading;
                _favouritesError = state.favouritesError;
                _selectedHaircutIndex = _haircuts.isNotEmpty
                    ? _selectedHaircutIndex.clamp(0, _haircuts.length - 1)
                    : 0;
                _selectedBeardIndex = _beardStyles.isNotEmpty
                    ? _selectedBeardIndex.clamp(0, _beardStyles.length - 1)
                    : 0;
                if (_confirmedHaircutIndex != null &&
                    _confirmedHaircutIndex! >= _haircuts.length) {
                  _confirmedHaircutIndex = null;
                }
                if (_confirmedBeardIndex != null &&
                    _confirmedBeardIndex! >= _beardStyles.length) {
                  _confirmedBeardIndex = null;
                }
                _selectedAngleIndex = 0;
                _regenerateHeights();
              });
            }
            if (state is HomeFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AdaptiveThemeColors.error(context),
                ),
              );
            }
          },
          child: BlocBuilder<HomeBloc, HomeState>(
            buildWhen: (prev, curr) =>
                prev.runtimeType != curr.runtimeType ||
                curr is HomeLoading ||
                curr is HomeInitial,
            builder: (context, state) {
              if (state is HomeLoading || state is HomeInitial) {
                return _buildScaffoldWithLoadingBody();
              }
              return _buildScaffoldDynamicTabs();
            },
          ),
        ),
      ),
    );
  }

  /// Scaffold with same app bar but body is the loading animation (no panel).
  Widget _buildScaffoldWithLoadingBody() {
    return Scaffold(
      backgroundColor: AdaptiveThemeColors.backgroundDeep(context),
      appBar: AppBar(
        backgroundColor: AdaptiveThemeColors.backgroundDark(context),
        elevation: 0,
        toolbarHeight: 48,
        title: Text(
          'Barbcut',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AdaptiveThemeColors.textPrimary(context),
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
      ),
      body: _buildHomeLoadingAnimation(),
    );
  }

  /// Skeleton screen while home data (styles, favourites) is loading.
  /// Matches real layout: viewportFraction, slide width, and visible peek of adjacent slides.
  Widget _buildHomeLoadingAnimation() {
    final media = MediaQuery.of(context);
    final contentWidth = media.size.width - 2 * AiSpacing.lg;
    final carouselHeight =
        (media.size.height -
            media.padding.top -
            kBottomNavigationBarHeight -
            22) *
        0.52;
    final cardHeight = carouselHeight.clamp(260.0, 520.0);

    // Match real carousel: viewportFraction, slide/peek widths, and card margin (AiSpacing.sm each side)
    final double viewportFraction = (media.size.width < 360)
        ? 0.88
        : (media.size.width < 600 ? 0.8 : 0.7);
    final double slideWidth = contentWidth * viewportFraction;
    final double peekWidth = (contentWidth - slideWidth) / 2;
    final double slideHorizontalPadding = peekWidth;
    const double slideGap =
        AiSpacing.sm * 2; // margin left + margin right between adjacent cards
    final double peekCardWidth =
        peekWidth - slideGap; // peek minus one gap so total = contentWidth
    final double peekCardHeight =
        cardHeight *
        0.88; // side slides slightly shorter (enlargeCenterPage effect)

    // Dark skeleton colors: subtle grey so shimmer reads clearly
    final baseColor = Colors.white.withValues(alpha: 0.06);
    final highlightColor = Colors.white.withValues(alpha: 0.14);

    Widget skeletonCard({
      required double width,
      required double height,
      required BorderRadius borderRadius,
    }) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: ShimmerPlaceholder(
          width: width,
          height: height,
          baseColor: baseColor,
          highlightColor: highlightColor,
        ),
      );
    }

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        AiSpacing.lg,
        AiSpacing.md,
        AiSpacing.lg,
        AiSpacing.xl + 80,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Skeleton: style name (aligned with left edge of center slide)
          Padding(
            padding: EdgeInsets.fromLTRB(slideHorizontalPadding, 0, 0, 6),
            child: ShimmerPlaceholder(
              width: slideWidth * 0.5,
              height: 22,
              baseColor: baseColor,
              highlightColor: highlightColor,
            ),
          ),
          // Skeleton: carousel = left peek + gap + center + gap + right peek (side slides slightly shorter)
          SizedBox(
            height: cardHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                skeletonCard(
                  width: peekCardWidth,
                  height: peekCardHeight,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(AiSpacing.radiusLarge),
                  ),
                ),
                SizedBox(width: slideGap),
                skeletonCard(
                  width: slideWidth,
                  height: cardHeight,
                  borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
                ),
                SizedBox(width: slideGap),
                skeletonCard(
                  width: peekCardWidth,
                  height: peekCardHeight,
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(AiSpacing.radiusLarge),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12),
          // Skeleton: carousel indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (_) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: ShimmerPlaceholder(
                  width: 8,
                  height: 8,
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                ),
              );
            }),
          ),
          SizedBox(height: AiSpacing.xl),
          // Skeleton: "About this style" block (same horizontal padding as real)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: slideHorizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerPlaceholder(
                  width: slideWidth * 0.45,
                  height: 16,
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                ),
                SizedBox(height: AiSpacing.sm),
                ShimmerPlaceholder(
                  width: slideWidth,
                  height: 12,
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                ),
                SizedBox(height: 6),
                ShimmerPlaceholder(
                  width: slideWidth * 0.92,
                  height: 12,
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                ),
                SizedBox(height: 6),
                ShimmerPlaceholder(
                  width: slideWidth * 0.7,
                  height: 12,
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                ),
                SizedBox(height: AiSpacing.lg),
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(
                        AiSpacing.radiusMedium,
                      ),
                      child: ShimmerPlaceholder(
                        width: 72,
                        height: 28,
                        baseColor: baseColor,
                        highlightColor: highlightColor,
                      ),
                    ),
                    SizedBox(width: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(
                        AiSpacing.radiusMedium,
                      ),
                      child: ShimmerPlaceholder(
                        width: 64,
                        height: 28,
                        baseColor: baseColor,
                        highlightColor: highlightColor,
                      ),
                    ),
                    SizedBox(width: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(
                        AiSpacing.radiusMedium,
                      ),
                      child: ShimmerPlaceholder(
                        width: 80,
                        height: 28,
                        baseColor: baseColor,
                        highlightColor: highlightColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AiSpacing.xl),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AiSpacing.radiusMedium),
                  child: ShimmerPlaceholder(
                    width: slideWidth,
                    height: 48,
                    baseColor: baseColor,
                    highlightColor: highlightColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScaffoldDynamicTabs() {
    final media = MediaQuery.of(context);
    final availableHeight =
        media.size.height - media.padding.top - kBottomNavigationBarHeight - 22;
    final minPanelHeight = (availableHeight * 0.04).clamp(32.0, 48.0);
    final maxPanelHeight = availableHeight * 0.9;

    return Scaffold(
      backgroundColor: AdaptiveThemeColors.backgroundDeep(context),
      appBar: AppBar(
        backgroundColor: AdaptiveThemeColors.backgroundDark(context),
        elevation: 0,
        toolbarHeight: 48,
        title: Text(
          'Barbcut',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AdaptiveThemeColors.textPrimary(context),
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
        renderPanelSheet: false,
        boxShadow: const [],
        backdropEnabled: false,
        isDraggable: true,
        parallaxEnabled: true,
        parallaxOffset: 0.5,
        onPanelSlide: (position) {
          _panelSlidePosition = position;
          _panelSlidePositionNotifier.value = position;
          final arrowTarget = position >= 0.5 ? 1.0 : 0.0;
          if (_arrowAnimationController.value != arrowTarget) {
            _arrowAnimationController.animateTo(
              arrowTarget,
              curve: Curves.fastOutSlowIn,
            );
          }
        },
        panelBuilder: (scrollController) => ValueListenableBuilder<double>(
          valueListenable: _panelSlidePositionNotifier,
          builder: (context, _, __) => _buildDynamicPanel(scrollController),
        ),
        body: ValueListenableBuilder<double>(
          valueListenable: _panelSlidePositionNotifier,
          builder: (context, _, __) => _buildMainContent(),
        ),
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
        final String currentTabType = _getCurrentTabType(context);
        final Map<String, dynamic>? selectedStyle =
            _getSelectedStyleForMainContent(context);
        final bool isStyleTab =
            currentTabType == 'hair' || currentTabType == 'beard';
        final List<String> carouselImages = _extractImages(selectedStyle);
        final List<String> activeImages = carouselImages.isNotEmpty
            ? carouselImages
            : <String>[''];

        // Match carousel viewportFraction so title aligns with slide
        final double viewportFraction = (constraints.maxWidth < 360)
            ? 0.88
            : (constraints.maxWidth < 600 ? 0.8 : 0.7);
        final double contentWidth = constraints.maxWidth - 2 * AiSpacing.lg;
        final double slideHorizontalPadding =
            (contentWidth * (1 - viewportFraction)) / 2;

        // Space for name; reduced top/bottom spacing
        const double nameTopPadding = 6.0;
        const double nameBottomPadding = 0.0;
        const double headerAreaHeight = 36.0;

        // Match SlidingUpPanel parallax: body shifts up by position * (max - min) * 0.5
        final media = MediaQuery.of(context);
        final availableHeight =
            media.size.height -
            media.padding.top -
            kBottomNavigationBarHeight -
            22;
        final minPanelH = (availableHeight * 0.04).clamp(32.0, 48.0);
        final maxPanelH = availableHeight * 0.9;
        final parallaxShift =
            _panelSlidePosition * (maxPanelH - minPanelH) * 0.5;

        return NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification notification) {
            if (notification is ScrollUpdateNotification ||
                notification is ScrollEndNotification) {
              final pixels = notification.metrics.pixels;
              _handleScrollOffset(pixels);
            }
            return false;
          },
          child: Container(
            decoration: BoxDecoration(
              color: AdaptiveThemeColors.backgroundDeep(context),
            ),
            child: SingleChildScrollView(
              controller: _mainScrollController,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                AiSpacing.lg,
                // Compensate for parallax so name and carousel stay visible in middle/top stage
                parallaxShift,
                AiSpacing.lg,
                AiSpacing.lg +
                    80 +
                    (MediaQuery.of(context).size.height -
                            MediaQuery.of(context).padding.top -
                            kBottomNavigationBarHeight -
                            22) *
                        0.20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // When no style tab is selected, show prompt to swipe up
                  if (selectedStyle == null) ...[
                    SizedBox(height: carouselHeight * 0.35),
                    _buildHomeEmptyState(carouselHeight),
                  ] else ...[
                    // Style name: starts at left edge of slide, similar spacing above and below
                    SizedBox(
                      height: headerAreaHeight,
                      width: double.infinity,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          slideHorizontalPadding,
                          nameTopPadding,
                          slideHorizontalPadding,
                          nameBottomPadding,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            selectedStyle['name']?.toString() ?? '',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  color: AdaptiveThemeColors.textPrimary(
                                    context,
                                  ),
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: carouselHeight,
                      child: RepaintBoundary(
                        child: Stack(
                          children: [
                            FlutterCarousel(
                              key: ValueKey(
                                'style-carousel-$currentTabType-${isStyleTab && currentTabType == 'hair' ? _selectedHaircutIndex : _selectedBeardIndex}',
                              ),
                              options: CarouselOptions(
                                height: carouselHeight,
                                viewportFraction: (constraints.maxWidth < 360)
                                    ? 0.88
                                    : (constraints.maxWidth < 600 ? 0.8 : 0.7),
                                enlargeCenterPage: true,
                                enableInfiniteScroll: false,
                                autoPlay: false,
                                showIndicator: false,
                                onPageChanged: (index, reason) {
                                  setState(() {
                                    _selectedAngleIndex = index;
                                  });
                                },
                              ),
                              items: [
                                // Image slides (n)
                                ...activeImages.asMap().entries.map((entry) {
                                  final int itemIndex = entry.key;
                                  final String imageUrl = entry.value;
                                  final Color accentColor =
                                      AdaptiveThemeColors.neonCyan(context);

                                  return Align(
                                    alignment: Alignment.center,
                                    child: _buildCarouselCard(
                                      imageUrl: imageUrl,
                                      title: '',
                                      accentColor: accentColor,
                                      itemIndex: itemIndex,
                                      iconSize: iconSize,
                                      allImages: activeImages,
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 2),
                    // Carousel indicators — smooth transition when changing angle
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(activeImages.length, (index) {
                          final isActive = _selectedAngleIndex == index;
                          final accent = AdaptiveThemeColors.neonCyan(context);
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeOutCubic,
                              width: isActive ? 10 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isActive
                                    ? accent
                                    : Colors.white.withValues(alpha: 0.4),
                                boxShadow: isActive
                                    ? [
                                        BoxShadow(
                                          color: accent.withValues(alpha: 0.5),
                                          blurRadius: 4,
                                          spreadRadius: 0,
                                        ),
                                      ]
                                    : null,
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    if (_isGenerating) ...[
                      SizedBox(height: AiSpacing.md),
                      if (_activeJobStatus == 'error')
                        GenerationErrorCard(
                          errorMessage: _activeJobError,
                          onRetry: _startGeneration,
                        )
                      else
                        _buildGenerationScheduledCard(selectedStyle),
                    ],
                    SizedBox(height: AiSpacing.md),
                    // Main section: details, face shapes, maintenance tips (scrolls into view; panel retracts on scroll)
                    _buildMainSection(
                      selectedStyle,
                      slideHorizontalPadding,
                      isHaircut: currentTabType == 'hair',
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHomeEmptyState(double carouselHeight) {
    final accent = AdaptiveThemeColors.neonCyan(context);
    final textPrimary = AdaptiveThemeColors.textPrimary(context);
    final textSecondary = AdaptiveThemeColors.textSecondary(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AiSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(AiSpacing.xl),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent.withValues(alpha: 0.12),
              ),
              child: Icon(
                Icons.swipe_up_rounded,
                size: 56,
                color: accent.withValues(alpha: 0.9),
              ),
            ),
            SizedBox(height: AiSpacing.lg),
            Text(
              'Swipe up to choose a style',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: textPrimary,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AiSpacing.sm),
            Text(
              'Pick a haircut or beard style from the panel to preview it here',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainSection(
    Map<String, dynamic> style,
    double horizontalPadding, {
    required bool isHaircut,
  }) {
    final description = style['description']?.toString();
    final maintenanceTips = style['maintenanceTips'];
    final tipsList = maintenanceTips is List
        ? (maintenanceTips).map((e) => e.toString()).toList()
        : maintenanceTips is String
        ? [maintenanceTips]
        : <String>[];
    final faceShapes =
        (style['suitableFaceShapes'] as List?)
            ?.map((e) => e.toString())
            .toList() ??
        <String>[];
    final accentColor = AdaptiveThemeColors.neonCyan(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (description != null && description.isNotEmpty) ...[
            Text(
              'About this style',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AdaptiveThemeColors.textSecondary(context),
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
            SizedBox(height: AiSpacing.xs),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AdaptiveThemeColors.textPrimary(context),
                height: 1.45,
              ),
            ),
            SizedBox(height: AiSpacing.lg),
          ],
          if (faceShapes.isNotEmpty) ...[
            Text(
              'Suitable face shapes',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AdaptiveThemeColors.textSecondary(context),
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
            SizedBox(height: AiSpacing.sm),
            Wrap(
              spacing: AiSpacing.sm,
              runSpacing: AiSpacing.xs,
              children: faceShapes
                  .map(
                    (shape) => Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AiSpacing.md,
                        vertical: AiSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(
                          AiSpacing.radiusMedium,
                        ),
                        border: Border.all(
                          color: accentColor.withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        shape,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AdaptiveThemeColors.textPrimary(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            SizedBox(height: AiSpacing.lg),
          ],
          if (tipsList.isNotEmpty) ...[
            Text(
              'Maintenance tips',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AdaptiveThemeColors.textSecondary(context),
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
            SizedBox(height: AiSpacing.sm),
            ...tipsList.map(
              (tip) => Padding(
                padding: EdgeInsets.only(bottom: AiSpacing.sm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accentColor,
                        ),
                      ),
                    ),
                    SizedBox(width: AiSpacing.sm),
                    Expanded(
                      child: Text(
                        tip,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AdaptiveThemeColors.textSecondary(context),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (isHaircut && _haircutEntities.length > _selectedHaircutIndex) ...[
            SizedBox(height: AiSpacing.md),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  setState(() {
                    _confirmedHaircutIndex = _selectedHaircutIndex;
                  });
                  if (_confirmedBeardIndex != null) {
                    _showConfirmationDialog();
                  } else {
                    _onTryThisPressed();
                  }
                },
                icon: Icon(
                  Icons.check_circle_outline,
                  size: 20,
                  color: Colors.black,
                ),
                label: Text(
                  'Try this',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(vertical: AiSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AiSpacing.radiusMedium),
                  ),
                ),
              ),
            ),
          ],
          if (!isHaircut && _beardEntities.length > _selectedBeardIndex) ...[
            SizedBox(height: AiSpacing.md),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  setState(() {
                    _confirmedBeardIndex = _selectedBeardIndex;
                  });
                  if (_confirmedHaircutIndex != null) {
                    _showConfirmationDialog();
                  } else {
                    _showBeardSelectionPrompt();
                  }
                },
                icon: Icon(
                  Icons.check_circle_outline,
                  size: 20,
                  color: Colors.black,
                ),
                label: Text(
                  'Try this',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(vertical: AiSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AiSpacing.radiusMedium),
                  ),
                ),
              ),
            ),
          ],
          SizedBox(height: AiSpacing.xl),
          // Extra bottom space so "Try this" stays visible when panel is hidden
          SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildCarouselCard({
    required String imageUrl,
    required String title,
    required Color accentColor,
    required int itemIndex,
    required double iconSize,
    List<String>? allImages,
  }) {
    Widget cardContent = GestureDetector(
      onTap: allImages != null
          ? () => _showFullScreenGallery(
              context,
              allImages,
              initialIndex: itemIndex,
            )
          : null,
      child: Container(
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
        child: AspectRatio(
          aspectRatio: 2 / 3,
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
                  child: FirebaseImage(
                    imageUrl,
                    fit: BoxFit.cover,
                    enableLazyLoading: true,
                    loadingWidget: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        AiSpacing.radiusLarge,
                      ),
                      child: ShimmerPlaceholder(
                        baseColor: accentColor.withValues(alpha: 0.12),
                        highlightColor: accentColor.withValues(alpha: 0.28),
                      ),
                    ),
                    errorWidget: Container(
                      color: accentColor.withValues(alpha: 0.2),
                      child: Icon(
                        Icons.image_not_supported,
                        size: iconSize,
                        color: accentColor.withValues(alpha: 0.6),
                      ),
                    ),
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
            ],
          ),
        ),
      ),
    );

    return cardContent;
  }

  Widget _buildGenerationScheduledCard(Map<String, dynamic> style) {
    final accent = AdaptiveThemeColors.neonCyan(context);
    final imageUrl = style['image']?.toString() ?? '';
    final status = _activeJobStatus;
    final isError = status == 'error';
    final statusText = switch (status) {
      'processing' => 'Generating now',
      'completed' => 'Ready',
      'error' => 'Failed',
      _ => 'In queue',
    };
    final headlineText = isError
        ? 'We hit a snag'
        : 'AI is generating your look';
    final subText = isError
        ? (_activeJobError ?? 'Try again when you are ready.')
        : 'Hang tight, this can take a few minutes.';

    return Container(
      decoration: BoxDecoration(
        color: AdaptiveThemeColors.backgroundDark(context),
        borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
        border: Border.all(color: accent.withValues(alpha: 0.35), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: EdgeInsets.all(AiSpacing.md),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AiSpacing.radiusMedium),
            child: SizedBox(
              width: 72,
              height: 72,
              child: FirebaseImage(
                imageUrl,
                fit: BoxFit.cover,
                width: 72,
                height: 72,
                loadingWidget: ShimmerPlaceholder(
                  width: 72,
                  height: 72,
                  baseColor: accent.withValues(alpha: 0.12),
                  highlightColor: accent.withValues(alpha: 0.28),
                ),
                errorWidget: Container(
                  width: 72,
                  height: 72,
                  color: accent.withValues(alpha: 0.15),
                  child: Icon(
                    Icons.image_not_supported,
                    color: accent.withValues(alpha: 0.6),
                    size: 28,
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
                Row(
                  children: [
                    Icon(
                      isError ? Icons.error_outline : Icons.schedule_rounded,
                      size: 14,
                      color: isError
                          ? Theme.of(context).colorScheme.error
                          : AdaptiveThemeColors.textTertiary(context),
                    ),
                    SizedBox(width: 6),
                    Text(
                      status == 'completed'
                          ? 'Completed'
                          : 'Scheduled • $statusText',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isError
                            ? Theme.of(context).colorScheme.error
                            : AdaptiveThemeColors.textTertiary(context),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Text(
                  headlineText,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AdaptiveThemeColors.textPrimary(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  subText,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AdaptiveThemeColors.textSecondary(context),
                  ),
                ),
                SizedBox(height: 10),
                if (!isError) _buildGeneratingDots(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneratingDots() {
    return AnimatedBuilder(
      animation: _generationPulseController,
      builder: (context, child) {
        return Row(
          children: List.generate(3, (index) {
            final phase =
                (_generationPulseController.value + index * 0.18) % 1.0;
            final scale = 0.7 + (0.4 * (1 - (phase - 0.5).abs() * 2));
            final opacity = 0.4 + (0.6 * (1 - (phase - 0.5).abs() * 2));

            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AdaptiveThemeColors.neonCyan(
                      context,
                    ).withValues(alpha: opacity),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildPanelFailureContent(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AiSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 64,
              color: AdaptiveThemeColors.textTertiary(context),
            ),
            const SizedBox(height: AiSpacing.lg),
            Text(
              'Styles didn\'t load',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AdaptiveThemeColors.textPrimary(context),
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AiSpacing.sm),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AdaptiveThemeColors.textSecondary(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AiSpacing.xl),
            FilledButton.icon(
              onPressed: () {
                context.read<HomeBloc>().add(const HomeLoadRequested());
              },
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: const Text('Retry'),
              style: FilledButton.styleFrom(
                backgroundColor: AdaptiveThemeColors.neonCyan(context),
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the swipe-up panel shell (arrow, tabs, search, content) with a single widget in every tab.
  Widget _buildPanelWithTabs({
    required List<TabCategoryEntity> categories,
    required Widget Function() contentBuilder,
  }) {
    final tabs = categories.map((c) => Tab(text: c.title)).toList();
    if (_tabController == null || _tabController!.length != tabs.length) {
      _tabController?.dispose();
      _tabController = TabController(length: tabs.length, vsync: this);
      _tabController!.addListener(() {
        if (!_tabController!.indexIsChanging && mounted) {
          setState(() => _selectedAngleIndex = 0);
        }
      });
    }
    return Container(
      color: AdaptiveThemeColors.backgroundDeep(context),
      child: Container(
        margin: const EdgeInsets.only(top: 1),
        color: AdaptiveThemeColors.backgroundDark(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                if (_panelController.isAttached) {
                  if (_panelSlidePosition > 0.3) {
                    _setPanelLevel(_panelLevel2);
                  } else {
                    _setPanelLevel(_panelLevel4);
                  }
                }
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 2),
                child: Center(
                  child: AnimatedBuilder(
                    animation: _arrowAnimationController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _arrowAnimationController.value * pi,
                        child: Icon(
                          Icons.expand_less,
                          size: 32,
                          weight: 900,
                          color: Colors.grey[400],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AdaptiveThemeColors.borderLight(context),
                    width: 1,
                  ),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: tabs,
                labelColor: AdaptiveThemeColors.neonCyan(context),
                unselectedLabelColor: AdaptiveThemeColors.textSecondary(
                  context,
                ),
                labelStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
                unselectedLabelStyle: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
                indicatorSize: TabBarIndicatorSize.label,
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(
                    color: AdaptiveThemeColors.neonCyan(context),
                    width: 4,
                  ),
                  insets: EdgeInsets.symmetric(horizontal: 16),
                ),
                dividerColor: Colors.transparent,
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const BouncingScrollPhysics(),
                children: List.generate(
                  categories.length,
                  (_) => contentBuilder(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicPanel(ScrollController scrollController) {
    return BlocBuilder<HomeBloc, HomeState>(
      buildWhen: (prev, curr) {
        if (curr is! HomeLoaded) return prev.runtimeType != curr.runtimeType;
        if (prev is! HomeLoaded) return true;
        return prev.tabCategories != curr.tabCategories;
      },
      builder: (context, state) {
        // When load failed: show full panel (tabs + error + Retry) so swipe-up view is visible.
        if (state is HomeFailure) {
          return _buildPanelWithTabs(
            categories: TabCategoryEntity.defaultPanelTabs,
            contentBuilder: () =>
                _buildPanelFailureContent(context, state.message),
          );
        }
        if (state is! HomeLoaded) {
          return const Center(child: CircularProgressIndicator());
        }
        // Use Firestore tab categories when available; otherwise default tabs so
        // the swipe-up panel (Recent, Favourites, Hair, Beard) is always visible.
        final categories = state.tabCategories.isNotEmpty
            ? state.tabCategories
            : TabCategoryEntity.defaultPanelTabs;

        final tabs = categories.map((c) => Tab(text: c.title)).toList();
        final tabTypes = categories.map((c) => c.type).toList();

        // (Re)create TabController if needed
        if (_tabController == null || _tabController!.length != tabs.length) {
          _tabController?.dispose();
          _tabController = TabController(length: tabs.length, vsync: this);
          _tabController!.addListener(() {
            if (!_tabController!.indexIsChanging && mounted) {
              setState(() => _selectedAngleIndex = 0);
            }
          });
        }

        return Container(
          color: AdaptiveThemeColors.backgroundDeep(context),
          child: Container(
            margin: const EdgeInsets.only(top: 1),
            color: AdaptiveThemeColors.backgroundDark(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Animated draggable arrow indicator
                GestureDetector(
                  onTap: () {
                    if (_panelController.isAttached) {
                      if (_panelSlidePosition > 0.3) {
                        _setPanelLevel(_panelLevel2);
                      } else {
                        _setPanelLevel(_panelLevel4);
                      }
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 2),
                    child: Center(
                      child: AnimatedBuilder(
                        animation: _arrowAnimationController,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _arrowAnimationController.value * pi,
                            child: Icon(
                              Icons.expand_less,
                              size: 32,
                              weight: 900,
                              color: Colors.grey[400],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: AdaptiveThemeColors.borderLight(context),
                        width: 1,
                      ),
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabs: tabs,
                    labelColor: AdaptiveThemeColors.neonCyan(context),
                    unselectedLabelColor: AdaptiveThemeColors.textSecondary(
                      context,
                    ),
                    labelStyle: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800, fontSize: 16),
                    unselectedLabelStyle: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w500),
                    indicatorSize: TabBarIndicatorSize.label,
                    indicator: UnderlineTabIndicator(
                      borderSide: BorderSide(
                        color: AdaptiveThemeColors.neonCyan(context),
                        width: 4,
                      ),
                      insets: EdgeInsets.symmetric(horizontal: 16),
                    ),
                    dividerColor: Colors.transparent,
                  ),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 450),
                  curve: Curves.fastOutSlowIn,
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    height: _panelSlidePosition * 70,
                    child: Transform.translate(
                      offset: Offset(0, 30 * (1 - _panelSlidePosition)),
                      child: Opacity(
                        opacity: _panelSlidePosition,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AiSpacing.lg,
                            AiSpacing.md,
                            AiSpacing.lg,
                            AiSpacing.sm,
                          ),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOutCubic,
                            decoration: BoxDecoration(
                              color: AdaptiveThemeColors.backgroundSecondary(
                                context,
                              ).withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(
                                AiSpacing.radiusLarge,
                              ),
                              border: Border.all(
                                color: _panelSearchFocus.hasFocus
                                    ? AdaptiveThemeColors.neonCyan(
                                        context,
                                      ).withValues(alpha: 0.9)
                                    : AdaptiveThemeColors.borderLight(
                                        context,
                                      ).withValues(alpha: 0.5),
                                width: _panelSearchFocus.hasFocus ? 1.6 : 1.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 10,
                                  offset: Offset(0, 6),
                                ),
                                if (_panelSearchFocus.hasFocus)
                                  BoxShadow(
                                    color: AdaptiveThemeColors.neonCyan(
                                      context,
                                    ).withValues(alpha: 0.2),
                                    blurRadius: 16,
                                    offset: Offset(0, 8),
                                  ),
                              ],
                            ),
                            child: ValueListenableBuilder<String>(
                              valueListenable: _panelSearchQueryNotifier,
                              builder: (context, query, _) {
                                return TextField(
                                  focusNode: _panelSearchFocus,
                                  controller: _panelSearchController,
                                  onChanged: (value) {
                                    _panelSearchQueryNotifier.value = value;
                                  },
                                  textInputAction: TextInputAction.search,
                                  keyboardAppearance: Brightness.dark,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: AdaptiveThemeColors.textPrimary(
                                          context,
                                        ),
                                      ),
                                  decoration: InputDecoration(
                                    hintText: 'Search styles...',
                                    hintStyle: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color:
                                              AdaptiveThemeColors.textTertiary(
                                                context,
                                              ),
                                        ),
                                    prefixIcon: Icon(
                                      Icons.search,
                                      color: AdaptiveThemeColors.textTertiary(
                                        context,
                                      ),
                                      size: 20,
                                    ),
                                    suffixIcon: query.isNotEmpty
                                        ? IconButton(
                                            icon: Icon(
                                              Icons.close_rounded,
                                              color:
                                                  AdaptiveThemeColors.textSecondary(
                                                    context,
                                                  ),
                                              size: 18,
                                            ),
                                            onPressed: () {
                                              _panelSearchController.clear();
                                              _panelSearchQueryNotifier.value =
                                                  '';
                                            },
                                          )
                                        : null,
                                    filled: false,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: AiSpacing.md,
                                      vertical: AiSpacing.md,
                                    ),
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                  ),
                                  cursorColor: AdaptiveThemeColors.neonCyan(
                                    context,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    physics: const BouncingScrollPhysics(),
                    children: tabTypes.map((type) {
                      switch (type) {
                        case 'recent':
                          return _buildRecentGrid(null);
                        case 'favourites':
                          return _buildFavouritesGrid(null);
                        case 'hair':
                          return ValueListenableBuilder<String>(
                            valueListenable: _panelSearchQueryNotifier,
                            builder: (context, _, __) =>
                                _buildHaircutGrid(null),
                          );
                        case 'beard':
                          return ValueListenableBuilder<String>(
                            valueListenable: _panelSearchQueryNotifier,
                            builder: (context, _, __) => _buildBeardGrid(null),
                          );
                        default:
                          return const Center(child: Text('Unknown tab'));
                      }
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHaircutGrid(ScrollController? scrollController) {
    if (_haircuts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    final width = MediaQuery.of(context).size.width;
    int crossAxisCount = 2;
    if (width >= 1100) {
      crossAxisCount = 4;
    } else if (width >= 820) {
      crossAxisCount = 3;
    }

    final filteredIndices = _haircuts
        .asMap()
        .entries
        .where((entry) => _matchesPanelSearch(entry.value))
        .map((entry) => entry.key)
        .toList();

    if (filteredIndices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: AdaptiveThemeColors.textTertiary(context),
            ),
            SizedBox(height: AiSpacing.md),
            Text(
              'No styles found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AdaptiveThemeColors.textPrimary(context),
              ),
            ),
            SizedBox(height: AiSpacing.sm),
            Text(
              'Try a different search term',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AdaptiveThemeColors.textTertiary(context),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AiSpacing.md,
        AiSpacing.sm,
        AiSpacing.md,
        AiSpacing.md,
      ),
      child: RepaintBoundary(
        child: MasonryGridView.builder(
          controller: scrollController ?? ScrollController(),
          key: const PageStorageKey('haircut_grid'),
          physics: const BouncingScrollPhysics(),
          gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
          ),
          itemCount: filteredIndices.length,
          mainAxisSpacing: AiSpacing.md,
          crossAxisSpacing: AiSpacing.md,
          itemBuilder: (context, index) {
            final haircutIndex = filteredIndices[index];
            final item = _haircuts[haircutIndex];
            final isSelected = haircutIndex == _selectedHaircutIndex;
            return _buildStyleCard(
              key: ValueKey(item['id']),
              item: item,
              itemIndex: haircutIndex,
              isSelected: isSelected,
              height: 220,
              onTap: () {
                setState(() {
                  _selectedHaircutIndex = haircutIndex;
                });
              },
              showFavouriteIcon: true,
              onFavouriteToggle: () {
                context.read<HomeBloc>().add(
                  FavouriteToggled(item: item, styleType: 'haircut'),
                );
              },
              styleType: 'haircut',
            );
          },
        ),
      ),
    );
  }

  Widget _buildBeardGrid(ScrollController? scrollController) {
    final width = MediaQuery.of(context).size.width;
    int crossAxisCount = 2;
    if (width >= 1100) {
      crossAxisCount = 4;
    } else if (width >= 820) {
      crossAxisCount = 3;
    }

    final filteredIndices = _beardStyles
        .asMap()
        .entries
        .where((entry) => _matchesPanelSearch(entry.value))
        .map((entry) => entry.key)
        .toList();

    if (filteredIndices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: AdaptiveThemeColors.textTertiary(context),
            ),
            SizedBox(height: AiSpacing.md),
            Text(
              'No styles found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AdaptiveThemeColors.textPrimary(context),
              ),
            ),
            SizedBox(height: AiSpacing.sm),
            Text(
              'Try a different search term',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AdaptiveThemeColors.textTertiary(context),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AiSpacing.md,
        AiSpacing.sm,
        AiSpacing.md,
        AiSpacing.md,
      ),
      child: RepaintBoundary(
        child: MasonryGridView.builder(
          controller: scrollController ?? ScrollController(),
          physics: const BouncingScrollPhysics(),
          gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
          ),
          itemCount: filteredIndices.length,
          mainAxisSpacing: AiSpacing.md,
          crossAxisSpacing: AiSpacing.md,
          itemBuilder: (context, index) {
            final itemIndex = filteredIndices[index];
            final beard = _beardStyles[itemIndex];
            final beardEntity = _beardEntities[itemIndex];
            final isSelected = _selectedBeardIndex == itemIndex;
            return _buildStyleCard(
              item: beard,
              itemIndex: itemIndex,
              isSelected: isSelected,
              height: _beardHeights[itemIndex],
              onTap: () {
                // Select beard style and close panel
                context.read<StyleSelectionController>().selectBeardStyle(
                  beardEntity,
                );
                setState(() {
                  _selectedBeardIndex = itemIndex;
                  _selectedAngleIndex = 0;
                });
                _setPanelLevel(_panelLevel2);
              },
              showFavouriteIcon: true,
              onFavouriteToggle: () {
                context.read<HomeBloc>().add(
                  FavouriteToggled(item: beard, styleType: 'beard'),
                );
              },
              styleType: 'beard',
            );
          },
        ),
      ),
    );
  }

  Widget _buildStyleCard({
    Key? key,
    required Map<String, dynamic> item,
    required int itemIndex,
    required bool isSelected,
    required VoidCallback onTap,
    required double height,
    bool showFavouriteIcon = false,
    VoidCallback? onFavouriteToggle,
    String? styleType,
  }) {
    final Color accentColor = AdaptiveThemeColors.neonCyan(context);

    final isFavourite = _favouriteIds.contains(item['id']);
    final String baseImageUrl = item['image']?.toString() ?? '';
    final String smallImageUrl = _buildSizedImageUrl(baseImageUrl, 'small');
    final String thumbnailUrl = smallImageUrl.isNotEmpty
        ? smallImageUrl
        : baseImageUrl;
    return GestureDetector(
      key: key,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
        height: height,
        decoration: BoxDecoration(
          border: isSelected
              ? Border.all(color: Colors.white.withValues(alpha: 0.3), width: 3)
              : Border.all(color: Colors.transparent, width: 3),
          borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AiSpacing.radiusLarge - 3),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image (FirebaseImage resolves Storage paths to download URLs)
              FirebaseImage(
                thumbnailUrl,
                fit: BoxFit.cover,
                loadingWidget: ShimmerPlaceholder(
                  baseColor: accentColor.withValues(alpha: 0.12),
                  highlightColor: accentColor.withValues(alpha: 0.28),
                ),
                errorWidget: Container(
                  color: accentColor.withValues(alpha: 0.2),
                  child: Icon(
                    Icons.image_not_supported,
                    size: 80,
                    color: accentColor.withValues(alpha: 0.6),
                  ),
                ),
              ),
              // Favourite icon (always show in Favourites tab)
              if (showFavouriteIcon || isSelected)
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () {
                      if (onFavouriteToggle != null) {
                        onFavouriteToggle();
                      } else if (styleType != null) {
                        context.read<HomeBloc>().add(
                          FavouriteToggled(item: item, styleType: styleType),
                        );
                      }
                    },
                    child: Icon(
                      isFavourite ? Icons.star : Icons.star_border,
                      color: isFavourite ? Colors.amber : Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              // Bottom gradient with name
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.8),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item['name'] as String? ?? 'Style',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (isSelected) ...[
                        SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                if (styleType == 'haircut') {
                                  _confirmedHaircutIndex = itemIndex;
                                  if (_confirmedBeardIndex != null) {
                                    _showConfirmationDialog();
                                  } else {
                                    _onTryThisPressed();
                                  }
                                } else if (styleType == 'beard') {
                                  _confirmedBeardIndex = itemIndex;
                                  if (_confirmedHaircutIndex != null) {
                                    _showConfirmationDialog();
                                  } else {
                                    _showBeardSelectionPrompt();
                                  }
                                }
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AdaptiveThemeColors.neonCyan(
                                context,
                              ),
                              foregroundColor: Colors.black,
                              padding: EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'Try This',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
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

  void _showFullScreenGallery(
    BuildContext context,
    List<String> images, {
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
                itemCount: images.length,
                itemBuilder: (context, index) {
                  final Color accentColor =
                      // Using general color:
                      AdaptiveThemeColors.neonCyan(context);

                  return Center(
                    child: InteractiveViewer(
                      minScale: 1,
                      maxScale: 3,
                      child: SizedBox(
                        width: 240,
                        height: 320,
                        child: FirebaseImage(
                          images[index],
                          fit: BoxFit.contain,
                          width: 240,
                          height: 320,
                          loadingWidget: ShimmerPlaceholder(
                            width: 240,
                            height: 320,
                            baseColor: accentColor.withValues(alpha: 0.12),
                            highlightColor: accentColor.withValues(alpha: 0.28),
                          ),
                          errorWidget: Container(
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
                    ),
                  );
                },
              ),
              Positioned(
                top: 24,
                right: 24,
                child: IconButton(
                  icon: Icon(Icons.close_rounded, color: Colors.white),
                  onPressed: () => Navigator.pop(dialogContext),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
