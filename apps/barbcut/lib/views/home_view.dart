import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  final PanelController _panelController = PanelController();
  final TextEditingController _panelSearchController = TextEditingController();
  int _selectedHaircutIndex = 0;
  int _selectedBeardIndex = 0;
  String _panelSearchQuery = '';
  double _panelSlidePosition = 0.0;
  late TabController _tabController;
  final Random _random = Random();
  late List<double> _haircutHeights;
  late List<double> _beardHeights;
  bool _isGenerating = false;
  int? _confirmedHaircutIndex;
  int? _confirmedBeardIndex;
  Timer? _carouselTimer;

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
            'description': style.description,
            'image': style.imageUrl,
            'accentColor': style.accentColor,
          },
        )
        .toList();
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
    _haircuts = List<Map<String, dynamic>>.from(_defaultHaircuts);
    _beardStyles = List<Map<String, dynamic>>.from(_defaultBeardStyles);
    _regenerateHeights();
  }

  void _onTryThisPressed() async {
    if (_haircuts.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Styles are still loading. Please try again.'),
          backgroundColor: AdaptiveThemeColors.error(context),
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
          backgroundColor: AdaptiveThemeColors.error(context),
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
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Stack(
                children: [
                  Image.network(
                    style['image'] as String,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
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
    _panelSearchController.dispose();
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
    final media = MediaQuery.of(context);
    final availableHeight =
        media.size.height - media.padding.top - kBottomNavigationBarHeight - 22;
    final minPanelHeight = availableHeight * 0.28;
    final maxPanelHeight = availableHeight * 0.9;

    return BlocProvider(
      create: (_) => HomeBloc(
        getHaircutsUseCase: getIt<GetHaircutsUseCase>(),
        getBeardStylesUseCase: getIt<GetBeardStylesUseCase>(),
      )..add(const HomeLoadRequested()),
      child: BlocListener<HomeBloc, HomeState>(
        listener: (context, state) {
          if (state is HomeLoaded) {
            setState(() {
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
        child: Scaffold(
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
            },
            panelBuilder: (scrollController) => _buildPanel(scrollController),
            body: _buildMainContent(),
          ),
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

        return Container(
          decoration: BoxDecoration(
            color: AdaptiveThemeColors.backgroundDeep(context),
          ),
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
                        items: _haircuts.take(4).toList().asMap().entries.map((
                          entry,
                        ) {
                          final int itemIndex = entry.key;
                          final Map<String, dynamic> haircut = entry.value;
                          final Color accentColor =
                              (haircut['accentColor'] as Color?) ??
                              AdaptiveThemeColors.neonCyan(context);

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
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AiSpacing.none),
                // Carousel indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    4,
                    (index) => Container(
                      width: 6,
                      height: 6,
                      margin: EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _selectedHaircutIndex == index
                            ? AdaptiveThemeColors.neonCyan(context)
                            : AiColors.borderLight.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: AiSpacing.md),
              ],
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
          // Draggable area (drag handle + padding makes it easy to grab)
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AdaptiveThemeColors.borderLight(
                    context,
                  ).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Hair'),
              Tab(text: 'Beard'),
            ],
            labelColor: AdaptiveThemeColors.neonCyan(context),
            unselectedLabelColor: AdaptiveThemeColors.textTertiary(context),
            labelStyle: Theme.of(context).textTheme.titleMedium,
            unselectedLabelStyle: Theme.of(context).textTheme.titleMedium,
            indicatorSize: TabBarIndicatorSize.label,
            indicatorColor: AdaptiveThemeColors.neonCyan(context),
            dividerColor: AdaptiveThemeColors.borderLight(context),
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
          final isSelected = _selectedHaircutIndex == itemIndex;
          return _buildStyleCard(
            item: haircut,
            itemIndex: itemIndex,
            isSelected: isSelected,
            height: _haircutHeights[itemIndex],
            onTap: () {
              setState(() {
                _selectedHaircutIndex = itemIndex;
              });
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
          final isSelected = _selectedBeardIndex == itemIndex;
          return _buildStyleCard(
            item: beard,
            itemIndex: itemIndex,
            isSelected: isSelected,
            height: _beardHeights[itemIndex],
            onTap: () {
              setState(() {
                _selectedBeardIndex = itemIndex;
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
        (item['accentColor'] as Color?) ??
        AdaptiveThemeColors.neonCyan(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          border: isSelected
              ? Border.all(
                  color: AdaptiveThemeColors.neonCyan(context),
                  width: 3,
                )
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
                        // If haircut is already confirmed, go directly to confirmation dialog
                        if (_confirmedHaircutIndex != null) {
                          _showConfirmationDialog();
                        } else {
                          _showBeardSelectionPrompt();
                        }
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdaptiveThemeColors.neonCyan(context),
                    foregroundColor: AdaptiveThemeColors.backgroundDeep(
                      context,
                    ),
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
