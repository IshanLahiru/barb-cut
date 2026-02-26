import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math';
import 'dart:async';
import '../theme/theme.dart';
import '../core/di/service_locator.dart';
import '../features/home/domain/entities/style_entity.dart';
import '../features/home/domain/usecases/get_beard_styles_usecase.dart';
import '../features/home/domain/usecases/get_haircuts_usecase.dart';
import '../features/home/presentation/bloc/home_bloc.dart';
import '../features/home/presentation/bloc/home_event.dart';
import '../features/home/presentation/bloc/home_state.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../shared/widgets/molecules/style_preview_card_inline.dart';
import '../controllers/style_selection_controller.dart';
import '../services/ai_generation_service.dart';
import '../services/user_photo_service.dart';
import '../widgets/generation_error_card.dart';
import '../widgets/lazy_network_image.dart';
import '../widgets/firebase_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_data_service.dart';
import 'face_photo_upload_view.dart';

class HomeView extends StatefulWidget {
  final VoidCallback? onNavigateToHistory;

  const HomeView({super.key, this.onNavigateToHistory});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  // Firestore tab categories stream
  final Stream<QuerySnapshot<Map<String, dynamic>>> _tabCategoriesStream =
      FirebaseFirestore.instance
          .collection('tabCategories')
          .orderBy('order')
          .snapshots();
  // Fetch favourites from a data source (stub implementation)
  String? _favouritesError;
  void _fetchFavourites() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _favouritesLoading = false;
        _favouritesError = 'User not authenticated.';
      });
      return;
    }
    setState(() {
      _favouritesLoading = true;
      _favouritesError = null;
    });
    try {
      await FirebaseDataService.initializeUser(userId: user.uid);
      final favs = await FirebaseDataService.getFavourites(userId: user.uid);
      if (!mounted) return;
      setState(() {
        _favouriteIds = favs.map((f) => f['id'].toString()).toSet();
        _favouritesLoading = false;
        _favouritesError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _favouritesLoading = false;
        _favouritesError = e.toString();
      });
    }
  }

  // Helper to map StyleEntity list to List<Map<String, dynamic>>
  List<Map<String, dynamic>> _mapStyles(List<StyleEntity> styles) {
    return styles
        .map(
          (e) => {
            'id': e.id,
            'name': e.name,
            'description': e.description,
            'image': e.imageUrl,
            'images': e.images,
            'suitableFaceShapes': e.suitableFaceShapes,
            'maintenanceTips': e.maintenanceTips,
          },
        )
        .toList();
  }

  // Toggle favourite for a style (stub implementation)
  void _toggleFavourite(Map<String, dynamic> item, String styleType) {
    final id = item['id']?.toString();
    if (id == null) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final userId = user.uid;
    setState(() {
      if (_favouriteIds.contains(id)) {
        _favouriteIds.remove(id);
        FirebaseDataService.removeFavourite(userId: userId, styleId: id);
      } else {
        _favouriteIds.add(id);
        FirebaseDataService.addFavourite(
          userId: userId,
          style: item,
          styleType: styleType,
        );
      }
    });
  }

  // Fields
  Set<String> _favouriteIds = {};
  bool _favouritesLoading = false;
  final PanelController _panelController = PanelController();
  final ScrollController _mainScrollController = ScrollController();
  final ScrollController _panelScrollController = ScrollController();
  final TextEditingController _panelSearchController = TextEditingController();
  final FocusNode _panelSearchFocus = FocusNode();
  int _selectedHaircutIndex = 0;
  int _selectedBeardIndex = 0;
  int _selectedAngleIndex = 0;
  String _panelSearchQuery = '';
  double _panelSlidePosition = 0.0;
  TabController? _tabController;
  late AnimationController _arrowAnimationController;
  late AnimationController _generationPulseController;
  final Random _random = Random();
  // Removed unused _haircutHeights field
  late List<double> _beardHeights;
  bool _isGenerating = false;
  int? _confirmedHaircutIndex;
  int? _confirmedBeardIndex;
  Timer? _carouselTimer;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _jobSubscription;
  String _activeJobStatus = 'queued';
  String? _activeJobError;
  late List<StyleEntity> _haircutEntities = [];
  late List<StyleEntity> _beardEntities = [];
  late List<Map<String, dynamic>> _haircuts = [];
  late List<Map<String, dynamic>> _beardStyles = [];

  // Methods
  Widget _buildRecentGrid(ScrollController? scrollController) {
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
      return Center(
        child: Text(
          'No favourites yet. Tap the star on a style to add it!',
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
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
            onFavouriteToggle: () => _toggleFavourite(item, styleType),
          );
        },
      ),
    );
  }

  List<String> _extractImages(Map<String, dynamic>? style) {
    final images = style?['images'];
    if (images is List) {
      return images.map((value) => value.toString()).toList();
    }
    if (images is Map) {
      final List<String> imageList = [];
      final front = images['front']?.toString();
      final left = images['left'] ?? images['left_side'] ?? images['leftSide'];
      final right =
          images['right'] ?? images['right_side'] ?? images['rightSide'];
      final back = images['back']?.toString();
      if (front != null && front.isNotEmpty) imageList.add(front);
      if (left != null && left.toString().isNotEmpty) {
        imageList.add(left.toString());
      }
      if (right != null && right.toString().isNotEmpty) {
        imageList.add(right.toString());
      }
      if (back != null && back.isNotEmpty) imageList.add(back);
      if (imageList.isNotEmpty) return imageList;
    }
    final image = style?['image'];
    return image != null ? [image.toString()] : <String>[];
  }

  void _regenerateHeights() {
    _haircutHeights = List.generate(
      _haircuts.length,
      (_) => 200.0 + _random.nextDouble() * 80,
    );
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
    _fetchFavourites();
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

    HomePage.isGenerating = true;
    HomePage.generationNotifier.value = true;

    _setPanelLevel(_panelLevel2);

    // Capture the selected style data for history
    final int currentTab = _tabController?.index ?? 0;
    final Map<String, dynamic>? selectedStyle = currentTab == 0
        ? (_haircuts.isNotEmpty ? _haircuts[_selectedHaircutIndex] : null)
        : (_beardStyles.isNotEmpty ? _beardStyles[_selectedBeardIndex] : null);

    if (selectedStyle != null) {
      // Get the first image from the style
      final List<String> images = _extractImages(selectedStyle);
      final String styleImage = images.isNotEmpty ? images[0] : '';

      String jobId = '';
      try {
        jobId = await AiGenerationService.createGenerationJob(
          haircutId: _haircuts.isNotEmpty
              ? _haircuts[_selectedHaircutIndex]['id']?.toString()
              : null,
          beardId: _beardStyles.isNotEmpty
              ? _beardStyles[_selectedBeardIndex]['id']?.toString()
              : null,
        );
      } catch (e) {
        debugPrint('Failed to create generation job: $e');
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }

      // Prepare style data for history
      HomePage.generatedStyleData = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'image': styleImage,
        'haircut': currentTab == 0 ? selectedStyle['name'] ?? 'Haircut' : 'N/A',
        'beard': currentTab == 1 ? selectedStyle['name'] ?? 'Beard' : 'N/A',
        'timestamp': DateTime.now(),
        'jobId': jobId,
        'status': jobId.isEmpty ? 'error' : 'queued',
      };
      HomePage.generatedStyleNotifier.value = HomePage.generatedStyleData;

      if (jobId.isNotEmpty) {
        _listenToGenerationJob(jobId);
      } else {
        _markGenerationFailed('Unable to create generation job.');
      }
    }

    widget.onNavigateToHistory?.call();
  }

  void _listenToGenerationJob(String jobId) {
    _jobSubscription?.cancel();
    _activeJobStatus = 'queued';
    _activeJobError = null;

    _jobSubscription = FirebaseFirestore.instance
        .collection('aiJobs')
        .doc(jobId)
        .snapshots()
        .listen((snapshot) {
          if (!snapshot.exists) {
            return;
          }
          final data = snapshot.data();
          final status = data?['status']?.toString() ?? 'queued';
          final errorMessage = data?['errorMessage']?.toString();

          if (!mounted) {
            return;
          }

          setState(() {
            _activeJobStatus = status;
            _activeJobError = errorMessage;
          });

          HomePage.generatedStyleData = {
            ...(HomePage.generatedStyleData ?? {}),
            'jobId': jobId,
            'status': status,
            'errorMessage': ?errorMessage,
          };
          HomePage.generatedStyleNotifier.value = HomePage.generatedStyleData;

          if (status == 'completed') {
            _markGenerationComplete();
          } else if (status == 'error') {
            _markGenerationFailed(
              errorMessage ?? 'Generation failed. Please try again.',
            );
          }
        });
  }

  void _markGenerationComplete() {
    if (!mounted) {
      return;
    }
    setState(() {
      _isGenerating = false;
      _confirmedHaircutIndex = null;
      _confirmedBeardIndex = null;
    });
    HomePage.isGenerating = false;
    HomePage.generationNotifier.value = false;
    HomePage.generatedStyleData = {
      ...(HomePage.generatedStyleData ?? {}),
      'status': 'completed',
    };
    HomePage.generatedStyleNotifier.value = HomePage.generatedStyleData;
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Your look is ready. Check History to view it.'),
          action: SnackBarAction(
            label: 'History',
            onPressed: widget.onNavigateToHistory ?? () {},
          ),
        ),
      );
    }
  }

  void _markGenerationFailed(String message) {
    if (!mounted) {
      return;
    }
    setState(() {
      _isGenerating = false;
      _confirmedHaircutIndex = null;
      _confirmedBeardIndex = null;
    });
    HomePage.isGenerating = false;
    HomePage.generationNotifier.value = false;
    HomePage.generatedStyleData = {
      ...(HomePage.generatedStyleData ?? {}),
      'status': 'error',
      'errorMessage': message,
    };
    HomePage.generatedStyleNotifier.value = HomePage.generatedStyleData;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _arrowAnimationController.dispose();
    _generationPulseController.dispose();
    _carouselTimer?.cancel();
    _jobSubscription?.cancel();
    _panelSearchController.dispose();
    _panelSearchFocus.dispose();
    _mainScrollController.dispose();
    _panelScrollController.dispose();
    super.dispose();
  }

  bool _matchesPanelSearch(Map<String, dynamic> item) {
    if (_panelSearchQuery.trim().isEmpty) {
      return true;
    }
    final query = _panelSearchQuery.toLowerCase();
    final name = item['name']?.toString().toLowerCase() ?? '';
    final description = item['description']?.toString().toLowerCase() ?? '';
    return name.contains(query) || description.contains(query);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeBloc>(
      create: (_) => HomeBloc(
        getHaircutsUseCase: getIt<GetHaircutsUseCase>(),
        getBeardStylesUseCase: getIt<GetBeardStylesUseCase>(),
      )..add(const HomeLoadRequested()),
      child: BlocListener<HomeBloc, HomeState>(
        listener: (context, state) {
          if (state is HomeLoaded) {
            setState(() {
              _haircutEntities = state.haircuts;
              _beardEntities = state.beardStyles;
              _haircuts = _mapStyles(state.haircuts);
              _beardStyles = _mapStyles(state.beardStyles);
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
        child: Builder(
          builder: (context) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _fetchFavourites();
            });
            return _buildScaffoldDynamicTabs();
          },
        ),
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
          setState(() {
            _panelSlidePosition = position;
          });
          final arrowTarget = position >= 0.5 ? 1.0 : 0.0;
          if (_arrowAnimationController.value != arrowTarget) {
            _arrowAnimationController.animateTo(
              arrowTarget,
              curve: Curves.fastOutSlowIn,
            );
          }
        },
        panelBuilder: (scrollController) =>
            _buildDynamicPanel(scrollController),
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
        final int currentTab = _tabController?.index ?? 0;
        final Map<String, dynamic>? selectedStyle = currentTab == 0
            ? (_haircuts.isNotEmpty ? _haircuts[_selectedHaircutIndex] : null)
            : (_beardStyles.isNotEmpty
                  ? _beardStyles[_selectedBeardIndex]
                  : null);
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
                  // Style name: starts at left edge of slide, similar spacing above and below
                  if (selectedStyle != null) ...[
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
                  ],
                  SizedBox(
                    height: carouselHeight,
                    child: Stack(
                      children: [
                        FlutterCarousel(
                          key: ValueKey(
                            'style-carousel-$currentTab-${currentTab == 0 ? _selectedHaircutIndex : _selectedBeardIndex}',
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
                  if (_isGenerating && selectedStyle != null) ...[
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
                  if (selectedStyle != null)
                    _buildMainSection(
                      selectedStyle,
                      slideHorizontalPadding,
                      isHaircut: currentTab == 0,
                    ),
                ],
              ),
            ),
          ),
        );
      },
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
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              width: 72,
              height: 72,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 72,
                  height: 72,
                  color: accent.withValues(alpha: 0.15),
                  child: Icon(
                    Icons.image_not_supported,
                    color: accent.withValues(alpha: 0.6),
                    size: 28,
                  ),
                );
              },
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

  Widget _buildDynamicPanel(ScrollController scrollController) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _tabCategoriesStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Failed to load categories'));
        }
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return Center(child: Text('No categories available'));
        }

        final tabs = docs
            .map((doc) => Tab(text: doc['title'] ?? 'Tab'))
            .toList();
        final tabTypes = docs
            .map((doc) => doc['type'] as String? ?? '')
            .toList();

        // (Re)create TabController if needed
        if (_tabController == null || _tabController!.length != tabs.length) {
          _tabController?.dispose();
          _tabController = TabController(length: tabs.length, vsync: this);
          _tabController!.addListener(() {
            if (!_tabController!.indexIsChanging && mounted) {
              setState(() => _selectedAngleIndex = 0);
              // Favourites tab type check
              if (tabTypes[_tabController!.index] == 'favourites') {
                _fetchFavourites();
              }
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
                            child: TextField(
                              focusNode: _panelSearchFocus,
                              controller: _panelSearchController,
                              onChanged: (value) {
                                setState(() {
                                  _panelSearchQuery = value;
                                });
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
                                      color: AdaptiveThemeColors.textTertiary(
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
                                suffixIcon: _panelSearchQuery.isNotEmpty
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
                                          setState(() {
                                            _panelSearchController.clear();
                                            _panelSearchQuery = '';
                                          });
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
                          return _buildHaircutGrid(null);
                        case 'beard':
                          return _buildBeardGrid(null);
                        default:
                          return Center(child: Text('Unknown tab'));
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
      child: MasonryGridView.builder(
        controller: scrollController ?? ScrollController(),
        key: PageStorageKey('haircut_grid'),
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
            onFavouriteToggle: () => _toggleFavourite(item, 'haircut'),
          );
        },
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
          );
        },
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
  }) {
    final Color accentColor = AdaptiveThemeColors.neonCyan(context);

    final isFavourite = _favouriteIds.contains(item['id']);
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
              // Image
              GridLazyImage(
                imageUrl: item['image'],
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
              // Favourite icon (always show in Favourites tab)
              if (showFavouriteIcon || isSelected)
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap:
                        onFavouriteToggle ??
                        () {
                          final styleType = _tabController?.index == 1
                              ? 'haircut'
                              : 'beard';
                          _toggleFavourite(item, styleType);
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
                                if ((_tabController?.index ?? 0) == 0) {
                                  _confirmedHaircutIndex = itemIndex;
                                  if (_confirmedBeardIndex != null) {
                                    _showConfirmationDialog();
                                  } else {
                                    _onTryThisPressed();
                                  }
                                } else {
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
                      child: LazyNetworkImage(
                        imageUrl: images[index],
                        fit: BoxFit.contain,
                        width: 240,
                        height: 320,
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
