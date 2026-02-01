import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
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

  String _formatDateTime(DateTime date) {
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
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${months[date.month - 1]} ${date.day}, ${date.year} · $hour:$minute';
  }

  String _formatDateTimeWithSeconds(DateTime date) {
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
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    final second = date.second.toString().padLeft(2, '0');
    return '${months[date.month - 1]} ${date.day}, ${date.year} · $hour:$minute:$second';
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
          Container(
            padding: EdgeInsets.all(AiSpacing.xl),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AdaptiveThemeColors.neonCyan(context).withValues(alpha: 0.2),
                  AdaptiveThemeColors.neonPurple(
                    context,
                  ).withValues(alpha: 0.2),
                ],
              ),
            ),
            child: Icon(
              Icons.history,
              size: 64,
              color: AdaptiveThemeColors.neonCyan(context),
            ),
          ),
          SizedBox(height: AiSpacing.xl),
          Text(
            'No generation history yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AdaptiveThemeColors.textPrimary(context),
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: AiSpacing.sm),
          Text(
            'Generate your first style to see it here',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AdaptiveThemeColors.textTertiary(context),
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
      onTap: () => _showImagePreview(context, item),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
          border: Border.all(
            color: AdaptiveThemeColors.borderLight(
              context,
            ).withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AiSpacing.radiusLarge - 1.5),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image background
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
              // Gradient overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.3),
                        Colors.black.withValues(alpha: 0.8),
                      ],
                      stops: const [0.4, 0.7, 1.0],
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
                            child: _buildMinimalBadge(
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
                            child: _buildMinimalBadge(
                              context,
                              item['beard'] as String,
                              AdaptiveThemeColors.neonPurple(context),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: AiSpacing.sm),
                    // Timestamp
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 12,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatTimestamp(item['timestamp'] as DateTime),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
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
    );
  }

  Widget _buildMinimalBadge(
    BuildContext context,
    String text,
    Color accentColor,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AiSpacing.sm, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: accentColor.withValues(alpha: 0.25),
        border: Border.all(color: accentColor.withValues(alpha: 0.5), width: 1),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 10,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  void _showImagePreview(BuildContext context, Map<String, dynamic> item) {
    final accentColor =
        (item['accentColor'] as Color?) ??
        AdaptiveThemeColors.neonCyan(context);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(AiSpacing.lg),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Image preview
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.2),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                    AiSpacing.radiusLarge - 2,
                  ),
                  child: Image.network(
                    item['image'] as String,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 300,
                        color: accentColor.withValues(alpha: 0.2),
                        child: Icon(
                          Icons.image_not_supported,
                          size: 80,
                          color: accentColor,
                        ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: AiSpacing.lg),
              // Details card
              Container(
                padding: EdgeInsets.all(AiSpacing.lg),
                decoration: BoxDecoration(
                  color: AdaptiveThemeColors.surface(context),
                  borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
                  border: Border.all(
                    color: AdaptiveThemeColors.borderLight(
                      context,
                    ).withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: accentColor.withValues(alpha: 0.2),
                          ),
                          child: Icon(
                            Icons.auto_awesome,
                            color: accentColor,
                            size: 16,
                          ),
                        ),
                        SizedBox(width: AiSpacing.sm),
                        Expanded(
                          child: Text(
                            'Generation Details',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: AdaptiveThemeColors.textPrimary(
                                    context,
                                  ),
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AiSpacing.md),
                    Divider(
                      color: AdaptiveThemeColors.borderLight(
                        context,
                      ).withValues(alpha: 0.2),
                      height: 1,
                    ),
                    SizedBox(height: AiSpacing.md),
                    if (item['haircut'] != null &&
                        (item['haircut'] as String).isNotEmpty) ...[
                      _buildDetailRow(
                        context,
                        'Haircut',
                        item['haircut'] as String,
                        accentColor,
                      ),
                      SizedBox(height: AiSpacing.sm),
                    ],
                    if (item['beard'] != null &&
                        (item['beard'] as String).isNotEmpty) ...[
                      _buildDetailRow(
                        context,
                        'Beard',
                        item['beard'] as String,
                        AdaptiveThemeColors.neonPurple(context),
                      ),
                      SizedBox(height: AiSpacing.sm),
                    ],
                    _buildDetailRow(
                      context,
                      'Generated',
                      _formatDateTimeWithSeconds(item['timestamp'] as DateTime),
                      AdaptiveThemeColors.neonCyan(context),
                    ),
                    SizedBox(height: AiSpacing.lg),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor: AdaptiveThemeColors.backgroundDeep(
                            context,
                          ),
                          padding: EdgeInsets.symmetric(vertical: AiSpacing.md),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AiSpacing.radiusMedium,
                            ),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Close',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: AdaptiveThemeColors.backgroundDeep(
                                  context,
                                ),
                                fontWeight: FontWeight.w700,
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
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    Color accentColor,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AdaptiveThemeColors.textTertiary(context),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
        SizedBox(width: AiSpacing.sm),
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AiSpacing.sm,
              vertical: AiSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: accentColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: accentColor,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
