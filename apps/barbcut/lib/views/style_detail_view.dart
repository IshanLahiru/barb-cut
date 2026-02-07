import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../features/home/domain/entities/style_entity.dart';
import '../controllers/style_selection_controller.dart';
import '../theme/theme.dart';
import '../widgets/multi_angle_carousel.dart';
import '../widgets/style_info_section.dart';

class StyleDetailView extends StatefulWidget {
  final StyleEntity style;

  const StyleDetailView({super.key, required this.style});

  @override
  State<StyleDetailView> createState() => _StyleDetailViewState();
}

class _StyleDetailViewState extends State<StyleDetailView> {
  late PanelController _panelController;
  late ScrollController _scrollController;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _panelController = PanelController();
    _scrollController = ScrollController();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    // As user scrolls down in the detail view, the bottom panel retracts
    if (_scrollController.hasClients) {
      final scrollPosition = _scrollController.offset;
      if (scrollPosition > 50 && !_isExpanded) {
        _panelController.close();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isExpanded) {
          _panelController.close();
          return false;
        }
        return true;
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              margin: EdgeInsets.all(AiSpacing.md),
              decoration: BoxDecoration(
                color: AiColors.backgroundDark.withValues(alpha: 0.8),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AiColors.borderLight.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Icon(Icons.arrow_back, color: AiColors.textPrimary),
            ),
          ),
        ),
        body: SlidingUpPanel(
          controller: _panelController,
          minHeight: 100,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AiSpacing.radiusLarge),
            topRight: Radius.circular(AiSpacing.radiusLarge),
          ),
          color: Theme.of(context).colorScheme.surface,
          panel: _buildDetailPanel(),
          collapsed: _buildCollapsedPanel(),
          onPanelSlide: (position) {
            // Handle panel slide
          },
          onPanelClosed: () {
            setState(() => _isExpanded = false);
          },
          onPanelOpened: () {
            setState(() => _isExpanded = true);
          },
          body: _buildCarouselBody(),
        ),
      ),
    );
  }

  Widget _buildCarouselBody() {
    return Container(
      color: AiColors.backgroundDark,
      child: SafeArea(
        bottom: false,
        child: Center(
          child: MultiAngleCarousel(
            style: widget.style,
            height: MediaQuery.of(context).size.height * 0.6,
            onAngleChanged: (index) {
              context.read<StyleSelectionController>().selectAngle(index);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCollapsedPanel() {
    return GestureDetector(
      onTap: () => _panelController.open(),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AiSpacing.radiusLarge),
            topRight: Radius.circular(AiSpacing.radiusLarge),
          ),
          border: Border(
            top: BorderSide(
              color: AiColors.borderLight.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AiColors.textTertiary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: AiSpacing.md),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AiSpacing.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.style.name,
                          style: TextStyle(
                            color: AiColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Text(
                          widget.style.description,
                          style: TextStyle(
                            color: AiColors.textSecondary,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_upward_rounded,
                    color: AiColors.textTertiary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailPanel() {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // Header with drag handle
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: AiSpacing.md),
            child: Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AiColors.textTertiary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ),

        // Style name header
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AiSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.style.name,
                  style: TextStyle(
                    color: AiColors.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: AiSpacing.sm),
                Text(
                  widget.style.description,
                  style: TextStyle(
                    color: AiColors.textSecondary,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Info section
        SliverToBoxAdapter(child: StyleInfoSection(style: widget.style)),

        // Bottom spacing
        SliverToBoxAdapter(child: SizedBox(height: AiSpacing.xl)),
      ],
    );
  }
}
