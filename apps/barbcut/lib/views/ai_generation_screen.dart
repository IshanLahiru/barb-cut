import 'package:flutter/material.dart';
import '../theme/ai_colors.dart';
import '../theme/ai_spacing.dart';
import '../shared/widgets/atoms/ai_buttons.dart';
import '../shared/widgets/atoms/ai_input_components.dart';
import '../shared/widgets/organisms/ai_loading_states.dart';

/// Example AI Image Generation Screen
/// Demonstrates all custom widgets in a real-world scenario
class AiGenerationScreen extends StatefulWidget {
  const AiGenerationScreen({Key? key}) : super(key: key);

  @override
  State<AiGenerationScreen> createState() => _AiGenerationScreenState();
}

class _AiGenerationScreenState extends State<AiGenerationScreen> {
  final TextEditingController _promptController = TextEditingController();
  String _selectedAspectRatio = '1:1';
  int _generationStep = 0; // 0: idle, 1: loading, 2: success

  final List<String> suggestedPrompts = [
    '🌌 Cosmic nebula abstract art',
    '🎨 Surreal landscape with floating islands',
    '🚀 Futuristic city in neon glow',
    '🌊 Underwater bioluminescent creatures',
    '🎭 Cyberpunk character portrait',
    '✨ Magical forest with glowing trees',
  ];

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  void _startGeneration() {
    setState(() {
      _generationStep = 1; // Loading state
    });

    // Simulate generation time
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _generationStep = 2); // Success state

        // Auto-reset after showing success
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _generationStep = 0;
              _promptController.clear();
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AiColors.backgroundDeep,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AiSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Text(
                  'Imagine',
                  style: TextStyle(
                    color: AiColors.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: AiSpacing.sm),
                const Text(
                  'Create stunning visuals with AI',
                  style: TextStyle(
                    color: AiColors.textTertiary,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: AiSpacing.xl),

                // Show appropriate state
                if (_generationStep == 1)
                  _buildLoadingState()
                else if (_generationStep == 2)
                  _buildSuccessState()
                else
                  _buildIdleState(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIdleState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Prompt Input Section
        const Text(
          'DESCRIBE YOUR IMAGE',
          style: TextStyle(
            color: AiColors.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: AiSpacing.md),
        AiTextField(
          label: 'Prompt',
          hintText: 'A serene landscape with golden sunset...',
          controller: _promptController,
          isMultiline: true,
          maxLines: 4,
          accentColor: AiColors.neonCyan,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: AiSpacing.lg),

        // Suggested Prompts
        const Text(
          'SUGGESTED PROMPTS',
          style: TextStyle(
            color: AiColors.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: AiSpacing.md),
        Wrap(
          spacing: AiSpacing.sm,
          runSpacing: AiSpacing.sm,
          children: suggestedPrompts.asMap().entries.map((entry) {
            final colors = [
              AiColors.neonCyan,
              AiColors.sunsetCoral,
              AiColors.neonPurple,
            ];
            return AiPromptChip(
              prompt: entry.value,
              accentColor: colors[entry.key % colors.length],
              onTap: () {
                _promptController.text = entry.value;
                setState(() {});
              },
            );
          }).toList(),
        ),
        const SizedBox(height: AiSpacing.xxl),

        // Aspect Ratio Section
        AiAspectRatioSelector(
          selectedRatio: _selectedAspectRatio,
          onRatioChanged: (ratio) {
            setState(() => _selectedAspectRatio = ratio);
          },
        ),
        const SizedBox(height: AiSpacing.xxl),

        // Advanced Options (Glassmorphic Card)
        AiGlassCard(
          accentBorder: AiColors.neonPurple,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Advanced Options',
                style: TextStyle(
                  color: AiColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: AiSpacing.md),
              _buildOptionRow('Quality', 'Ultra High'),
              const SizedBox(height: AiSpacing.md),
              _buildOptionRow('Speed', 'Balanced'),
              const SizedBox(height: AiSpacing.md),
              _buildOptionRow('Style', 'Cinematic'),
            ],
          ),
        ),
        const SizedBox(height: AiSpacing.xxl),

        // Generate Button
        AiPrimaryButton(
          label: 'Generate Image',
          icon: Icons.flash_on_rounded,
          fullWidth: true,
          height: AiSpacing.buttonHeightXL,
          onPressed: _promptController.text.isNotEmpty
              ? _startGeneration
              : null,
        ),
        const SizedBox(height: AiSpacing.xl),

        // Recent Gallery
        const Text(
          'RECENT GENERATIONS',
          style: TextStyle(
            color: AiColors.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: AiSpacing.md),
        GridView.count(
          crossAxisCount: 2,
          childAspectRatio: 1,
          mainAxisSpacing: AiSpacing.md,
          crossAxisSpacing: AiSpacing.md,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: List.generate(4, (index) {
            final colors = [
              AiColors.neonCyan,
              AiColors.sunsetCoral,
              AiColors.neonPurple,
              AiColors.neonCyan,
            ];
            return Container(
              decoration: BoxDecoration(
                color: AiColors.surface,
                border: Border.all(
                  color: colors[index].withOpacity(0.3),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
              ),
              child: Center(
                child: Icon(
                  Icons.image_outlined,
                  color: AiColors.textTertiary.withOpacity(0.5),
                  size: 40,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildOptionRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AiColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AiColors.neonCyan,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const AiLoadingState(message: 'Creating your masterpiece...');
  }

  Widget _buildSuccessState() {
    return AiSuccessState(
      onContinue: () {
        setState(() {
          _generationStep = 0;
          _promptController.clear();
        });
      },
    );
  }
}
