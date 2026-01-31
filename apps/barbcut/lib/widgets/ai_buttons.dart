import 'package:flutter/material.dart';
import '../theme/ai_colors.dart';

/// AI Primary Button - Tactile "Squishy" 3D feel with gradient
/// Used for main CTAs like "Generate", "Create", "Submit"
class AiPrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final double height;
  final bool fullWidth;

  const AiPrimaryButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.height = 56,
    this.fullWidth = true,
  }) : super(key: key);

  @override
  State<AiPrimaryButton> createState() => _AiPrimaryButtonState();
}

class _AiPrimaryButtonState extends State<AiPrimaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onPressDown(PointerDownEvent event) {
    _animController.forward();
  }

  void _onPressUp(PointerUpEvent event) {
    _animController.reverse();
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _onPressDown,
      onPointerUp: _onPressUp,
      child: AnimatedBuilder(
        animation: _animController,
        builder: (context, child) {
          final squishFactor = 0.92 + (_animController.value * 0.08);
          final glowOpacity = 0.6 + (_animController.value * 0.4);

          return Container(
            height: widget.height,
            width: widget.fullWidth ? double.infinity : null,
            decoration: BoxDecoration(
              gradient: AiGradients.buttonPrimary,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AiColors.neonCyan.withOpacity(glowOpacity * 0.6),
                  blurRadius: 20 + (_animController.value * 10),
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: AiColors.sunsetCoral.withOpacity(glowOpacity * 0.4),
                  blurRadius: 15 + (_animController.value * 8),
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Transform.scale(
              scale: squishFactor,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.isLoading ? null : widget.onPressed,
                  borderRadius: BorderRadius.circular(16),
                  child: Center(
                    child: widget.isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AiColors.textPrimary,
                              ),
                            ),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (widget.icon != null) ...[
                                Icon(
                                  widget.icon,
                                  color: AiColors.textPrimary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                              ],
                              Text(
                                widget.label,
                                style: const TextStyle(
                                  color: AiColors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// AI Secondary Button - Outline style with glass effect
class AiSecondaryButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final double height;
  final bool fullWidth;
  final Color accentColor;

  const AiSecondaryButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.height = 48,
    this.fullWidth = true,
    this.accentColor = AiColors.neonCyan,
  }) : super(key: key);

  @override
  State<AiSecondaryButton> createState() => _AiSecondaryButtonState();
}

class _AiSecondaryButtonState extends State<AiSecondaryButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        height: widget.height,
        width: widget.fullWidth ? double.infinity : null,
        decoration: BoxDecoration(
          color: AiColors.surface.withOpacity(_isHovered ? 0.8 : 0.6),
          border: Border.all(
            color: widget.accentColor.withOpacity(_isHovered ? 1.0 : 0.5),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: widget.accentColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onPressed,
            borderRadius: BorderRadius.circular(14),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon, color: widget.accentColor, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    widget.label,
                    style: TextStyle(
                      color: widget.accentColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// AI Text Field - Modern input with glow effect, 16dp border radius
class AiTextField extends StatefulWidget {
  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final bool isMultiline;
  final int maxLines;
  final Color accentColor;
  final IconData? prefixIcon;
  final Widget? suffixWidget;
  final Function(String)? onChanged;

  const AiTextField({
    Key? key,
    required this.label,
    this.hintText,
    this.controller,
    this.isMultiline = false,
    this.maxLines = 1,
    this.accentColor = AiColors.neonCyan,
    this.prefixIcon,
    this.suffixWidget,
    this.onChanged,
  }) : super(key: key);

  @override
  State<AiTextField> createState() => _AiTextFieldState();
}

class _AiTextFieldState extends State<AiTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() => _isFocused = _focusNode.hasFocus);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            widget.label,
            style: TextStyle(
              color: AiColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
            ),
          ),
        ),
        // Input Field
        Container(
          decoration: BoxDecoration(
            color: AiColors.surface,
            border: Border.all(
              color: _isFocused ? widget.accentColor : AiColors.borderLight,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: widget.accentColor.withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 0),
                    ),
                  ]
                : [],
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            maxLines: widget.isMultiline ? widget.maxLines : 1,
            minLines: widget.isMultiline ? 3 : 1,
            onChanged: widget.onChanged,
            style: const TextStyle(
              color: AiColors.textPrimary,
              fontSize: 14,
              height: 1.6,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText ?? 'Enter text...',
              hintStyle: const TextStyle(
                color: AiColors.textTertiary,
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                      widget.prefixIcon,
                      color: _isFocused
                          ? widget.accentColor
                          : AiColors.textTertiary,
                      size: 18,
                    )
                  : null,
              prefixIconConstraints: const BoxConstraints(
                minWidth: 40,
                minHeight: 40,
              ),
              suffixIcon: widget.suffixWidget,
              suffixIconConstraints: const BoxConstraints(
                minWidth: 40,
                minHeight: 40,
              ),
            ),
            cursorColor: widget.accentColor,
            cursorHeight: 20,
          ),
        ),
      ],
    );
  }
}
