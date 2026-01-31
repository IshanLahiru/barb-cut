import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../theme/ai_spacing.dart';
import '../theme/adaptive_theme_colors.dart';
import '../core/di/service_locator.dart';
import '../features/history/domain/entities/history_entity.dart';
import '../features/history/domain/usecases/get_history_usecase.dart';
import '../features/history/presentation/bloc/history_bloc.dart';
import '../features/history/presentation/bloc/history_event.dart';
import '../features/history/presentation/bloc/history_state.dart';

class HistoryView extends StatefulWidget {
  const HistoryView({super.key});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  late List<Map<String, dynamic>> _generationHistory;

  @override
  void initState() {
    super.initState();
    _generationHistory = [];
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
    return BlocProvider(
      create: (_) =>
          HistoryBloc(getHistoryUseCase: getIt<GetHistoryUseCase>())
            ..add(const HistoryLoadRequested()),
      child: BlocListener<HistoryBloc, HistoryState>(
        listener: (context, state) {
          if (state is HistoryLoaded) {
            setState(() {
              _generationHistory = _mapHistory(state.history);
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
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history,
                          size: 64,
                          color: AdaptiveThemeColors.textTertiary(context),
                        ),
                        const SizedBox(height: AiSpacing.md),
                        Text(
                          'No generation history yet',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: AdaptiveThemeColors.textPrimary(context),
                              ),
                        ),
                        const SizedBox(height: AiSpacing.sm),
                        Text(
                          'Generate your first style to see it here',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AdaptiveThemeColors.textTertiary(
                                  context,
                                ),
                              ),
                        ),
                      ],
                    ),
                  )
                : CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.all(AiSpacing.lg),
                        sliver: SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: AiSpacing.md,
                                mainAxisSpacing: AiSpacing.lg,
                                childAspectRatio: 0.8,
                              ),
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final item = _generationHistory[index];
                            return _buildHistoryCard(context, item);
                          }, childCount: _generationHistory.length),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () {
        // Show full preview dialog
        _showImagePreview(context, item);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
          border: Border.all(
            color: AdaptiveThemeColors.borderLight(context),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: (item['accentColor'] as Color).withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Image background
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
                image: DecorationImage(
                  image: NetworkImage(item['image'] as String),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
            // Content
            Positioned(
              left: AiSpacing.md,
              right: AiSpacing.md,
              bottom: AiSpacing.md,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Haircut and Beard badges
                  Wrap(
                    spacing: AiSpacing.sm,
                    runSpacing: AiSpacing.sm,
                    children: [
                      _buildBadge(context, item['haircut'] as String),
                      _buildBadge(context, item['beard'] as String),
                    ],
                  ),
                  const SizedBox(height: AiSpacing.sm),
                  // Timestamp
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatTimestamp(item['timestamp'] as DateTime),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AiSpacing.sm),
                  // Full date and time
                  Text(
                    _formatDateTime(item['timestamp'] as DateTime),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AiSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: AdaptiveThemeColors.neonCyan(context).withValues(alpha: 0.2),
        border: Border.all(
          color: AdaptiveThemeColors.neonCyan(context).withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AdaptiveThemeColors.neonCyan(context),
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }

  void _showImagePreview(BuildContext context, Map<String, dynamic> item) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(AiSpacing.md),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
                border: Border.all(
                  color: AdaptiveThemeColors.borderLight(context),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
                child: Image.network(
                  item['image'] as String,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: AiSpacing.lg),
            Container(
              padding: const EdgeInsets.all(AiSpacing.lg),
              decoration: BoxDecoration(
                color: AdaptiveThemeColors.backgroundDark(context),
                borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
                border: Border.all(
                  color: AdaptiveThemeColors.borderLight(context),
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Generation Details',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AdaptiveThemeColors.textPrimary(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AiSpacing.md),
                  _buildDetailRow(
                    context,
                    'Haircut',
                    item['haircut'] as String,
                  ),
                  const SizedBox(height: AiSpacing.sm),
                  _buildDetailRow(context, 'Beard', item['beard'] as String),
                  const SizedBox(height: AiSpacing.sm),
                  _buildDetailRow(
                    context,
                    'Generated',
                    _formatDateTimeWithSeconds(item['timestamp'] as DateTime),
                  ),
                  const SizedBox(height: AiSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AdaptiveThemeColors.neonCyan(context),
                        padding: const EdgeInsets.symmetric(
                          vertical: AiSpacing.md,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AiSpacing.radiusLarge,
                          ),
                        ),
                      ),
                      child: Text(
                        'Close',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AdaptiveThemeColors.backgroundDark(context),
                          fontWeight: FontWeight.w600,
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
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AdaptiveThemeColors.textSecondary(context),
            fontWeight: FontWeight.w500,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AiSpacing.md,
            vertical: AiSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: AdaptiveThemeColors.backgroundSecondary(context),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: AdaptiveThemeColors.borderLight(context),
              width: 1,
            ),
          ),
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AdaptiveThemeColors.neonCyan(context),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
