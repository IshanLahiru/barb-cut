import 'package:flutter/material.dart';
import '../../../theme/ai_spacing.dart';
import '../atoms/category_chip.dart';

class CategoryChipGroup extends StatelessWidget {
  final List<CategoryChip> chips;

  const CategoryChipGroup({
    super.key,
    required this.chips,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AiSpacing.sm,
      runSpacing: AiSpacing.sm,
      children: chips,
    );
  }
}
