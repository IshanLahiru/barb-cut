import 'package:flutter/material.dart';
import 'dart:ui';
import '../theme/ai_colors.dart';

/// Suggested Prompts Chips - Beautiful idle state suggestions
/// Tap to populate the prompt field
class AiPromptChip extends StatefulWidget {
  final String prompt;
  final VoidCallback onTap;
  final Color? accentColor;

  const AiPromptChip({
    Key? key,
    required this.prompt,
    required this.onTap,
    this.accentColor,
  }) : super(key: key);

  @override
  State<AiPromptChip> createState() => _AiPromptChipState();
}

class _AiPromptChipState extends State<AiPromptChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final accent = widget.accentColor ?? AiColors.neonCyan;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AiColors.surface.withOpacity(_isHovered ? 1.0 : 0.7),
            border: Border.all(
              color: accent.withOpacity(_isHovered ? 1.0 : 0.4),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: accent.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Text(
            widget.prompt,
            style: TextStyle(
              color: _isHovered ? accent : AiColors.textSecondary,
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
    Key? key,
    required this.selectedRatio,
    required this.onRatioChanged,
  }) : super(key: key);

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
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AiColors.surface
                : AiColors.surface.withOpacity(0.5),
            border: Border.all(
              color: widget.isSelected
                  ? AiColors.neonCyan
                  : AiColors.borderLight,
              width: widget.isSelected ? 2.0 : 1.5,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: AiColors.neonCyan.withOpacity(0.3),
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
                        ? AiColors.neonCyan
                        : AiColors.textTertiary,
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
                      ? AiColors.neonCyan
                      : AiColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
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
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.accentBorder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: AiColors.glassLight,
            border: Border.all(
              color: accentBorder ?? AiColors.borderGlass,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AiColors.neonCyan.withOpacity(0.1),
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
