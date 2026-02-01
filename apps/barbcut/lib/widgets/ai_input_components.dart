import 'package:flutter/material.dart';
import 'dart:ui';
import '../theme/theme.dart';

/// Suggested Prompts Chips - Beautiful idle state suggestions
/// Tap to populate the prompt field
class AiPromptChip extends StatefulWidget {
  final String prompt;
  final VoidCallback onTap;
  final Color? accentColor;

  const AiPromptChip({
    super.key,
    required this.prompt,
    required this.onTap,
    this.accentColor,
  });

  @override
  State<AiPromptChip> createState() => _AiPromptChipState();
}

class _AiPromptChipState extends State<AiPromptChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final accent = widget.accentColor ?? Theme.of(context).colorScheme.primary;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: ThemeAdapter.getSurface(context).withValues(alpha: _isHovered ? 1.0 : 0.7),
            border: Border.all(
              color: accent.withValues(alpha: _isHovered ? 1.0 : 0.4),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Text(
            widget.prompt,
            style: TextStyle(
              color: _isHovered ? accent : ThemeAdapter.getTextSecondary(context),
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}

/// Aspect Ratio Selector - Grid-based 2x2 layout
class AiAspectRatioSelector extends StatefulWidget {
  final String selectedRatio;
  final Function(String) onRatioChanged;

  const AiAspectRatioSelector({
    super.key,
    required this.selectedRatio,
    required this.onRatioChanged,
  });

  @override
  State<AiAspectRatioSelector> createState() => _AiAspectRatioSelectorState();
}

class _AiAspectRatioSelectorState extends State<AiAspectRatioSelector> {
  static const ratios = ['1:1', '16:9', '9:16', '4:3'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Text(
            'ASPECT RATIO',
            style: TextStyle(
              color: AiColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
            ),
          ),
        ),
        GridView.count(
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: ratios
              .map(
                (ratio) => _AiAspectRatioButton(
                  ratio: ratio,
                  isSelected: widget.selectedRatio == ratio,
                  onTap: () => widget.onRatioChanged(ratio),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _AiAspectRatioButton extends StatefulWidget {
  final String ratio;
  final bool isSelected;
  final VoidCallback onTap;

  const _AiAspectRatioButton({
    required this.ratio,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_AiAspectRatioButton> createState() => _AiAspectRatioButtonState();
}

class _AiAspectRatioButtonState extends State<_AiAspectRatioButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: widget.isSelected
              ? ThemeAdapter.getSurface(context)
              : ThemeAdapter.getSurface(context).withValues(alpha: 0.5),
          border: Border.all(
            color: widget.isSelected ? Theme.of(context).colorScheme.primary : ThemeAdapter.getBorderLight(context),
            width: widget.isSelected ? 2.0 : 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: widget.isSelected
              ? [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Aspect ratio preview
            Container(
              width: 40,
              height: widget.ratio == '1:1'
                  ? 40
                  : widget.ratio == '16:9'
                  ? 22
                  : widget.ratio == '9:16'
                  ? 60
                  : 30,
              decoration: BoxDecoration(
                border: Border.all(
                  color: widget.isSelected
                      ? Theme.of(context).colorScheme.primary
                      : ThemeAdapter.getTextTertiary(context),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.ratio,
              style: TextStyle(
                color: widget.isSelected
                    ? Theme.of(context).colorScheme.primary
                    : ThemeAdapter.getTextSecondary(context),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Glassmorphic Card - For dashboard sections
class AiGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color? accentBorder;

  const AiGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.accentBorder,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: ThemeAdapter.getSurface(context).withValues(alpha: 0.7),
            border: Border.all(
              color: accentBorder ?? ThemeAdapter.getBorderColor(context),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
