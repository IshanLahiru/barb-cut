import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/rendering.dart';
import 'dart:math';
import 'dart:async';
import 'dart:ui';
import '../theme/theme.dart';
import '../core/di/service_locator.dart';
import '../features/home/domain/entities/style_entity.dart';
import '../features/home/domain/usecases/get_beard_styles_usecase.dart';
import '../features/home/domain/usecases/get_haircuts_usecase.dart';
import '../features/home/presentation/bloc/home_bloc.dart';
import '../features/home/presentation/bloc/home_event.dart';
import '../features/home/presentation/bloc/home_state.dart';
import '../shared/widgets/molecules/add_style_card.dart';
import '../shared/widgets/molecules/style_preview_card_inline.dart';
import '../controllers/style_selection_controller.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  final PanelController _panelController = PanelController();
  final ScrollController _mainScrollController = ScrollController();
  final TextEditingController _panelSearchController = TextEditingController();
  int _selectedHaircutIndex = 0;
  int _selectedBeardIndex = 0;
  int _selectedAngleIndex = 0;
  String _panelSearchQuery = '';
  double _panelSlidePosition = 0.0;
  late TabController _tabController;
  late AnimationController _arrowAnimationController;
  final Random _random = Random();
  late List<double> _haircutHeights;
  late List<double> _beardHeights;
  bool _isGenerating = false;
  int? _confirmedHaircutIndex;
  int? _confirmedBeardIndex;
  Timer? _carouselTimer;

  // NEW: Store StyleEntity objects from the bloc
  late List<StyleEntity> _haircutEntities = [];
  late List<StyleEntity> _beardEntities = [];

  final List<Map<String, dynamic>> _defaultHaircuts = const [];

  final List<Map<String, dynamic>> _defaultBeardStyles = const [];

  late List<Map<String, dynamic>> _haircuts;
  late List<Map<String, dynamic>> _beardStyles;

  List<Map<String, dynamic>> _mapStyles(List<StyleEntity> styles) {
    return styles
        .map(
          (style) => {
            'name': style.name,
            'price': style.price,
            'duration': style.duration,
            'tips': style.tips,
            'description': style.description,
            'maintenanceTips': style.maintenanceTips,
            'suitableFaceShapes': style.suitableFaceShapes,
            'images': style.images,
            'image': style.images.isNotEmpty
                ? style.images.first
                : style.imageUrl,
          },
        )
        .toList();
  }

  List<String> _extractImages(Map<String, dynamic>? style) {
    final images = style?['images'];
    if (images is List) {
      return images.map((value) => value.toString()).toList();
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
    _tabController = TabController(length: 2, vsync: this);
    _arrowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _mainScrollController.addListener(_handleMainScroll);
    _haircuts = List<Map<String, dynamic>>.from(_defaultHaircuts);
    _beardStyles = List<Map<String, dynamic>>.from(_defaultBeardStyles);
    _regenerateHeights();
  }

  double _lastScrollOffset = 0.0;
  static const double _scrollThresholdToRetractPanel = 40.0;
  static const double _scrollDeltaMin = 18.0;
  static const double _scrollOffsetDescriptionVisible = 280.0;
  static const double _scrollOffsetRevealPanel = 260.0;

  // Panel levels: 1 = minimal (reading description), 2 = peek, 4 = full screen
  static const double _panelLevel1 = 0.0;
  static const double _panelLevel2 = 0.20; // middle stage — a bit lower
  static const double _panelLevel4 = 1.0;

  static const Duration _panelRevealDuration = Duration(milliseconds: 480);

  Future<void> _setPanelLevel(double level, {Duration? duration}) async {
    if (!_panelController.isAttached) return;
    await _panelController.animatePanelToPosition(
      level.clamp(0.0, 1.0),
      duration: duration ?? const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  void _handleMainScroll() {
    if (!_mainScrollController.hasClients) return;
    _handleScrollOffset(_mainScrollController.offset);
  }

  void _handleScrollOffset(double offset) {
    if (!_panelController.isAttached) return;
    final delta = offset - _lastScrollOffset;

    // When viewing description: collapse panel to minimum (no hide/show — avoids stuck state)
    if (offset >= _scrollOffsetDescriptionVisible) {
      if (_panelSlidePosition > 0) {
        _setPanelLevel(_panelLevel1);
      }
      _lastScrollOffset = offset;
      return;
    }

    // Back in top area: bring panel back to peek when user scrolls up
    if (offset < _scrollOffsetRevealPanel && _panelSlidePosition < _panelLevel2) {
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
                  padding: EdgeInsets.all(AiSpacing.lg),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AdaptiveThemeColors.neonCyan(
                            dialogContext,
                          ).withValues(alpha: 0.2),
                        ),
                        child: Icon(
                          Icons.add,
                          color: AdaptiveThemeColors.neonCyan(dialogContext),
                          size: 18,
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
                                color: AiColors.textPrimary,
                                fontWeight: FontWeight.w800,
                                fontSize: 20,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Add a beard style to complete your transformation',
                              style: TextStyle(
                                color: AiColors.textTertiary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: AiColors.textSecondary,
                          size: 20,
                        ),
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
                          minWidth: 40,
                          minHeight: 40,
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
                  padding: EdgeInsets.all(AiSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Selection',
                        style: TextStyle(
                          color: AiColors.textTertiary,
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: AiSpacing.md),
                      StylePreviewCardInline(style: haircut),
                    ],
                  ),
                ),
                Divider(
                  color: AiColors.borderLight.withValues(alpha: 0.2),
                  height: 1,
                  thickness: 1,
                ),
                Padding(
                  padding: EdgeInsets.all(AiSpacing.lg),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
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
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: AiSpacing.md),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                            setState(
                              () => _confirmedHaircutIndex =
                                  _selectedHaircutIndex,
                            );
                            _tabController.animateTo(1);
                            _panelController.open();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AdaptiveThemeColors.neonCyan(
                              dialogContext,
                            ),
                            foregroundColor: AdaptiveThemeColors.backgroundDeep(
                              dialogContext,
                            ),
                            padding: EdgeInsets.symmetric(vertical: 12),
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
                              fontSize: 13,
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
                  padding: EdgeInsets.all(AiSpacing.lg),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AdaptiveThemeColors.neonCyan(
                            dialogContext,
                          ).withValues(alpha: 0.2),
                        ),
                        child: Icon(
                          Icons.add,
                          color: AdaptiveThemeColors.neonCyan(dialogContext),
                          size: 18,
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
                                color: AiColors.textPrimary,
                                fontWeight: FontWeight.w800,
                                fontSize: 20,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Add a haircut style to complete your transformation',
                              style: TextStyle(
                                color: AiColors.textTertiary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: AiColors.textSecondary,
                          size: 20,
                        ),
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
                          minWidth: 40,
                          minHeight: 40,
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
                  padding: EdgeInsets.all(AiSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Selection',
                        style: TextStyle(
                          color: AiColors.textTertiary,
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: AiSpacing.md),
                      StylePreviewCardInline(style: beard),
                    ],
                  ),
                ),
                Divider(
                  color: AiColors.borderLight.withValues(alpha: 0.2),
                  height: 1,
                  thickness: 1,
                ),
                Padding(
                  padding: EdgeInsets.all(AiSpacing.lg),
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
                            'Just Beard',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      SizedBox(width: AiSpacing.md),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                            setState(
                              () => _confirmedBeardIndex = _selectedBeardIndex,
                            );
                            _tabController.animateTo(0);
                            _panelController.open();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AdaptiveThemeColors.neonCyan(
                              dialogContext,
                            ),
                            foregroundColor: AdaptiveThemeColors.backgroundDeep(
                              dialogContext,
                            ),
                            padding: EdgeInsets.symmetric(vertical: 12),
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
                              fontSize: 13,
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
                  padding: EdgeInsets.all(AiSpacing.lg),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AdaptiveThemeColors.neonCyan(
                            dialogContext,
                          ).withValues(alpha: 0.2),
                        ),
                        child: Icon(
                          Icons.check,
                          color: AdaptiveThemeColors.neonCyan(dialogContext),
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
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: AiColors.textSecondary,
                          size: 20,
                        ),
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
                          minWidth: 40,
                          minHeight: 40,
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
                  padding: EdgeInsets.all(AiSpacing.lg),
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Haircut Card or Add CTA
                      if (haircut != null)
                        _buildCompactStyleCard(
                          style: haircut,
                          label: 'Haircut',
                          accentColor: AdaptiveThemeColors.neonCyan(
                            dialogContext,
                          ),
                          onChangePressed: () {
                            Navigator.of(dialogContext).pop();
                            setState(() {
                              _selectedHaircutIndex =
                                  _confirmedHaircutIndex ??
                                  _selectedHaircutIndex;
                            });
                            _tabController.animateTo(0);
                            _panelController.open();
                          },
                          onRemovePressed: () {
                            Navigator.of(dialogContext).pop();
                            setState(() => _confirmedHaircutIndex = null);
                            _showConfirmationDialog();
                          },
                        )
                      else
                        AddStyleCard(
                          title: 'Add Haircut Style',
                          subtitle: 'Complete your look',
                          accentColor: AiColors.neonCyan,
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                            _tabController.animateTo(0);
                            _panelController.open();
                          },
                        ),
                      SizedBox(width: AiSpacing.md),

                      // Beard Card or Add CTA
                      if (beard != null)
                        _buildCompactStyleCard(
                          style: beard,
                          label: 'Beard',
                          accentColor: AdaptiveThemeColors.neonCyan(
                            dialogContext,
                          ),
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
                        AddStyleCard(
                          title: 'Add Beard Style',
                          subtitle: 'Complete your look',
                          accentColor: AiColors.neonPurple,
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                            _tabController.animateTo(1);
                            _panelController.open();
                          },
                        ),
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
                  padding: EdgeInsets.all(AiSpacing.lg),
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
                            _setPanelLevel(_panelLevel2);
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
                            'Cancel',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
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
                            backgroundColor: AdaptiveThemeColors.neonCyan(
                              context,
                            ),
                            foregroundColor: AdaptiveThemeColors.backgroundDeep(
                              context,
                            ),
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
    final tips = (style['tips'] as String?)?.trim();
    final hasTips = tips != null && tips.isNotEmpty;

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
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: AspectRatio(
              aspectRatio: 2 / 3,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  children: [
                    Image.network(
                      style['image'] as String,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
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
                if (hasTips)
                  Text(
                    tips,
                    style: TextStyle(
                      color: AiColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  )
                else
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
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

  void _startGeneration() {
    setState(() {
      _isGenerating = true;
    });

    _setPanelLevel(_panelLevel2);

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
    _arrowAnimationController.dispose();
    _carouselTimer?.cancel();
    _panelSearchController.dispose();
    _mainScrollController.dispose();
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
              // Store both StyleEntity objects and Maps
              _haircutEntities = state.haircuts;
              _beardEntities = state.beardStyles;
              _haircuts = _mapStyles(state.haircuts);
              _beardStyles = _mapStyles(state.beardStyles);

              if (_haircuts.isNotEmpty) {
                _selectedHaircutIndex = _selectedHaircutIndex.clamp(
                  0,
                  _haircuts.length - 1,
                );
              } else {
                _selectedHaircutIndex = 0;
              }

              if (_beardStyles.isNotEmpty) {
                _selectedBeardIndex = _selectedBeardIndex.clamp(
                  0,
                  _beardStyles.length - 1,
                );
              } else {
                _selectedBeardIndex = 0;
              }

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
        child: _buildScaffold(),
      ),
    );
  }

  Widget _buildScaffold() {
    final media = MediaQuery.of(context);
    final availableHeight =
        media.size.height - media.padding.top - kBottomNavigationBarHeight - 22;
    // Level 1 = minimal strip (4%), Level 2 = 28% via position, Level 4 = 90%
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
        backdropEnabled: false,
        isDraggable: true,
        parallaxEnabled: true,
        parallaxOffset: 0.5,
        onPanelSlide: (position) {
          setState(() {
            _panelSlidePosition = position;
          });
          // Arrow: up when bottom/middle (position < 0.5), down when top (position >= 0.5)
          final arrowTarget = position >= 0.5 ? 1.0 : 0.0;
          if (_arrowAnimationController.value != arrowTarget) {
            _arrowAnimationController.animateTo(arrowTarget);
          }
        },
        panelBuilder: (scrollController) => _buildPanel(scrollController),
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
        final Map<String, dynamic>? selectedHaircut = _haircuts.isNotEmpty
            ? _haircuts[_selectedHaircutIndex]
            : null;
        final List<String> carouselImages = _extractImages(selectedHaircut);
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
        final availableHeight = media.size.height -
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
                // Haircut name: starts at left edge of slide, similar spacing above and below
                if (selectedHaircut != null) ...[
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
                          selectedHaircut['name']?.toString() ?? '',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: AdaptiveThemeColors.textPrimary(context),
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
                          'haircut-carousel-$_selectedHaircutIndex',
                        ),
                        options: CarouselOptions(
                          height: carouselHeight,
                          viewportFraction: (constraints.maxWidth < 360)
                              ? 0.88
                              : (constraints.maxWidth < 600 ? 0.8 : 0.7),
                          enlargeCenterPage: true,
                          enableInfiniteScroll: false,
                          autoPlay: _isGenerating,
                          autoPlayInterval: Duration(milliseconds: 1500),
                          autoPlayAnimationDuration: Duration(
                            milliseconds: 800,
                          ),
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
                                isGenerating: _isGenerating,
                                allImages: activeImages,
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 2),
                // Carousel indicators (one per angle) — larger and higher contrast so they stay visible
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      activeImages.length,
                      (index) => Container(
                        width: 8,
                        height: 8,
                        margin: EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _selectedAngleIndex == index
                              ? AdaptiveThemeColors.neonCyan(context)
                              : Colors.white.withValues(alpha: 0.4),
                          boxShadow: _selectedAngleIndex == index
                              ? [
                                  BoxShadow(
                                    color: AdaptiveThemeColors.neonCyan(context)
                                        .withValues(alpha: 0.5),
                                    blurRadius: 4,
                                    spreadRadius: 0,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: AiSpacing.md),
                // Main section: details, face shapes, maintenance tips (scrolls into view; panel retracts on scroll)
                if (selectedHaircut != null)
                  _buildMainSection(
                    selectedHaircut,
                    slideHorizontalPadding,
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
    double horizontalPadding,
  ) {
    final description = style['description']?.toString();
    final maintenanceTips = style['maintenanceTips'];
    final tipsList = maintenanceTips is List
        ? (maintenanceTips as List).map((e) => e.toString()).toList()
        : maintenanceTips is String
            ? [maintenanceTips]
            : <String>[];
    final faceShapes = (style['suitableFaceShapes'] as List?)
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
                        borderRadius:
                            BorderRadius.circular(AiSpacing.radiusMedium),
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
          if (_haircutEntities.length > _selectedHaircutIndex) ...[
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
                  color: AdaptiveThemeColors.backgroundDeep(context),
                ),
                label: Text(
                  'Try this',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AdaptiveThemeColors.backgroundDeep(context),
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor:
                      AdaptiveThemeColors.backgroundDeep(context),
                  padding: EdgeInsets.symmetric(vertical: AiSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AiSpacing.radiusMedium),
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
    bool isGenerating = false,
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
                  child: Image.network(
                    imageUrl,
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
            ],
          ),
        ),
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
                      AdaptiveThemeColors.neonCyan(context),
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

  Widget _buildPanel(ScrollController scrollController) {
    return Container(
      color: AdaptiveThemeColors.backgroundDark(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Animated draggable arrow indicator
          GestureDetector(
            onTap: () {
              // Toggle between level 2 (peek) and level 4 (full)
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
              tabs: const [
                Tab(text: 'Hair'),
                Tab(text: 'Beard'),
              ],
              labelColor: AdaptiveThemeColors.neonCyan(context),
              unselectedLabelColor: AdaptiveThemeColors.textSecondary(context),
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
          AnimatedSize(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
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
                    child: TextField(
                      controller: _panelSearchController,
                      onChanged: (value) {
                        setState(() {
                          _panelSearchQuery = value;
                        });
                      },
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AdaptiveThemeColors.textPrimary(context),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Fade, buzz cut, pompadour...',
                        hintStyle: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(
                              color: AdaptiveThemeColors.textTertiary(context),
                            ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: AdaptiveThemeColors.textTertiary(context),
                          size: 20,
                        ),
                        suffixIcon: _panelSearchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  color: AdaptiveThemeColors.textTertiary(
                                    context,
                                  ),
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _panelSearchController.clear();
                                    _panelSearchQuery = '';
                                  });
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: AdaptiveThemeColors.backgroundSecondary(
                          context,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: AiSpacing.md,
                          vertical: AiSpacing.md,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AiSpacing.radiusLarge,
                          ),
                          borderSide: BorderSide(
                            color: AdaptiveThemeColors.borderLight(context),
                            width: 1.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AiSpacing.radiusLarge,
                          ),
                          borderSide: BorderSide(
                            color: AdaptiveThemeColors.borderLight(context),
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AiSpacing.radiusLarge,
                          ),
                          borderSide: BorderSide(
                            color: AdaptiveThemeColors.neonCyan(context),
                            width: 2,
                          ),
                        ),
                      ),
                      cursorColor: AdaptiveThemeColors.neonCyan(context),
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
              children: [
                _buildHaircutGrid(scrollController),
                _buildBeardGrid(scrollController),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHaircutGrid(ScrollController scrollController) {
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
        controller: scrollController,
        physics: const BouncingScrollPhysics(),
        gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
        ),
        itemCount: filteredIndices.length,
        mainAxisSpacing: AiSpacing.md,
        crossAxisSpacing: AiSpacing.md,
        itemBuilder: (context, index) {
          final itemIndex = filteredIndices[index];
          final haircut = _haircuts[itemIndex];
          final haircutEntity = _haircutEntities[itemIndex];
          final isSelected = _selectedHaircutIndex == itemIndex;
          return _buildStyleCard(
            item: haircut,
            itemIndex: itemIndex,
            isSelected: isSelected,
            height: _haircutHeights[itemIndex],
            onTap: () {
              // Select haircut and show its images in the main view
              context.read<StyleSelectionController>().selectHaircutStyle(
                haircutEntity,
              );
              setState(() {
                _selectedHaircutIndex = itemIndex;
                _selectedAngleIndex = 0;
              });
              _setPanelLevel(_panelLevel2);
            },
          );
        },
      ),
    );
  }

  Widget _buildBeardGrid(ScrollController scrollController) {
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
        controller: scrollController,
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
              setState(() => _selectedBeardIndex = itemIndex);
              _setPanelLevel(_panelLevel2);
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
        // Using general color:
        AdaptiveThemeColors.neonCyan(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
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
              Image.network(
                item['image'],
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
                      if (isSelected) ...[
                        SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                if (_tabController.index == 0) {
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
                              foregroundColor: Colors.white,
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
                      child: Image.network(
                        images[index],
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
