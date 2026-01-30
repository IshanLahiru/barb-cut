import 'package:flutter/material.dart';
import '../theme/ai_colors.dart';
import '../theme/ai_spacing.dart';
import '../theme/adaptive_theme_colors.dart';

class HistoryView extends StatefulWidget {
  const HistoryView({super.key});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  // Sample history data with generated images
  final List<Map<String, dynamic>> _generationHistory = [
    {
      'id': '1',
      'image': 'https://images.unsplash.com/photo-1622286342621-4bd786c2447c?w=400&h=400&fit=crop',
      'haircut': 'Classic Fade',
      'beard': 'Full Beard',
      'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
      'accentColor': AiColors.neonCyan,
    },
    {
      'id': '2',
      'image': 'https://images.unsplash.com/photo-1621605815971-fbc98d665033?w=400&h=400&fit=crop',
      'haircut': 'Buzz Cut',
      'beard': 'Stubble',
      'timestamp': DateTime.now().subtract(const Duration(hours: 5)),
      'accentColor': AiColors.sunsetCoral,
    },
    {
      'id': '3',
      'image': 'https://images.unsplash.com/photo-1605497788044-5a32c7078486?w=400&h=400&fit=crop',
      'haircut': 'Pompadour',
      'beard': 'Goatee',
      'timestamp': DateTime.now().subtract(const Duration(hours: 12)),
      'accentColor': AiColors.neonPurple,
    },
    {
      'id': '4',
      'image': 'https://images.unsplash.com/photo-1599351431202-1e0f0137899a?w=400&h=400&fit=crop',
      'haircut': 'Undercut',
      'beard': 'Full Beard',
      'timestamp': DateTime.now().subtract(const Duration(days: 1)),
      'accentColor': AiColors.neonCyan,
    },
    {
      'id': '5',
      'image': 'https://images.unsplash.com/photo-1564564321837-a57b7070ac4f?w=400&h=400&fit=crop',
      'haircut': 'Crew Cut',
      'beard': 'Clean Shaven',
      'timestamp': DateTime.now().subtract(const Duration(days: 2)),
      'accentColor': AiColors.sunsetCoral,
    },
    {
      'id': '6',
      'image': 'https://images.unsplash.com/photo-1595152452543-e5c9d2e39c2d?w=400&h=400&fit=crop',
      'haircut': 'Textured Top',
      'beard': 'Stubble',
      'timestamp': DateTime.now().subtract(const Duration(days: 3)),
      'accentColor': AiColors.neonPurple,
    },
  ];

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
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatDateTime(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${months[date.month - 1]} ${date.day}, ${date.year} · $hour:$minute';
  }

  String _formatDateTimeWithSeconds(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    final second = date.second.toString().padLeft(2, '0');
    return '${months[date.month - 1]} ${date.day}, ${date.year} · $hour:$minute:$second';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdaptiveThemeColors.backgroundDeep(context),
      appBar: AppBar(
        backgroundColor: AdaptiveThemeColors.backgroundDark(context),
        elevation: 0,
        title: Text(
          'History',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AdaptiveThemeColors.textPrimary(context),
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
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
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AdaptiveThemeColors.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: AiSpacing.sm),
                    Text(
                      'Generate your first style to see it here',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AdaptiveThemeColors.textTertiary(context),
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
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: AiSpacing.md,
                        mainAxisSpacing: AiSpacing.lg,
                        childAspectRatio: 0.8,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final item = _generationHistory[index];
                          return _buildHistoryCard(context, item);
                        },
                        childCount: _generationHistory.length,
                      ),
                    ),
                  ),
                ],
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
            // Accent color accent line
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AiSpacing.radiusLarge),
                    topRight: Radius.circular(AiSpacing.radiusLarge),
                  ),
                  color: item['accentColor'] as Color,
                ),
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
                  _buildDetailRow(context, 'Haircut', item['haircut'] as String),
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
                        padding: const EdgeInsets.symmetric(vertical: AiSpacing.md),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
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
