import 'package:flutter/material.dart';
import '../../../theme/ai_colors.dart';
import '../../../theme/ai_spacing.dart';

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final Color? accentColor;
  final Color? focusColor;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.accentColor,
    this.focusColor,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = accentColor ?? AiColors.neonCyan;
    final activeColor = focusColor ?? AiColors.neonCyan;

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: AiColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AiColors.textTertiary,
        ),
        prefixIcon: Icon(
          prefixIcon,
          color: iconColor,
          size: 20,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AiColors.backgroundDeep,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AiSpacing.md,
          vertical: AiSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AiSpacing.radiusMedium,
          ),
          borderSide: const BorderSide(
            color: AiColors.borderLight,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AiSpacing.radiusMedium,
          ),
          borderSide: const BorderSide(
            color: AiColors.borderLight,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AiSpacing.radiusMedium,
          ),
          borderSide: BorderSide(
            color: activeColor,
            width: 2,
          ),
        ),
      ),
      cursorColor: activeColor,
    );
  }
}
