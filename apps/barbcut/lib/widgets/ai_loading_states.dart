import 'package:flutter/material.dart';
import '../theme/ai_colors.dart';

/// AI Loading State - Shimmer/Pulse effect instead of spinner
/// Creates a dreamy "image being generated" effect
class AiLoadingState extends StatefulWidget {
  final String message;

  const AiLoadingState({Key? key, this.message = 'Dreaming up your image...'})
    : super(key: key);

  @override
  State<AiLoadingState> createState() => _AiLoadingStateState();
}

class _AiLoadingStateState extends State<AiLoadingState>
    with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Shimmer Grid Animation
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: AiGradients.backgroundGradient(),
              ),
              child: Stack(
                children: [
                  // Base grid
                  GridView.count(
                    crossAxisCount: 3,
                    physics: const NeverScrollableScrollPhysics(),
                    children: List.generate(
                      9,
                      (index) => _ShimmerGridCell(
                        delayFactor: index / 9,
                        animation: _shimmerController,
                      ),
                    ),
                  ),
                  // Glow Pulse Overlay
                  ScaleTransition(
                    scale: Tween<double>(begin: 0.8, end: 1.2).animate(
                      CurvedAnimation(
                        parent: _pulseController,
                        curve: Curves.easeInOut,
                      ),
                    ),
                    child: Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AiColors.neonCyan.withOpacity(0.5),
                              AiColors.neonCyan.withOpacity(0),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AiColors.neonCyan,
                                  AiColors.sunsetCoral,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          // Loading Message
          Text(
            widget.message,
            style: const TextStyle(
              color: AiColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          // Progress Dots
          _DotProgress(controller: _pulseController),
        ],
      ),
    );
  }
}

class _ShimmerGridCell extends StatelessWidget {
  final double delayFactor;
  final AnimationController animation;

  const _ShimmerGridCell({required this.delayFactor, required this.animation});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final shimmerValue =
              (animation.value + delayFactor) % 1.0; // Staggered effect
          final opacity = (shimmerValue < 0.5)
              ? shimmerValue *
                    2 // 0 to 1
              : (1 - shimmerValue) * 2; // 1 to 0

          return Container(
            decoration: BoxDecoration(
              color: AiColors.shimmerLight.withOpacity(opacity),
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: AiColors.neonCyan.withOpacity(opacity * 0.3),
                  blurRadius: 8,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DotProgress extends StatelessWidget {
  final AnimationController controller;

  const _DotProgress({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        3,
        (index) => AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            final delay = index * 0.15;
            final animValue = (controller.value + delay) % 1.0;
            final scale = 0.6 + (sin(animValue * 3.14) * 0.4);

            return ScaleTransition(
              scale: AlwaysStoppedAnimation(scale),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AiColors.neonCyan, AiColors.sunsetCoral],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

double sin(double x) => (x - (x.toStringAsFixed(0).length) * 3.14159 / 2).sin();

/// AI Success State - Celebrate successful generation
class AiSuccessState extends StatefulWidget {
  final VoidCallback onContinue;

  const AiSuccessState({Key? key, required this.onContinue}) : super(key: key);

  @override
  State<AiSuccessState> createState() => _AiSuccessStateState();
}

class _AiSuccessStateState extends State<AiSuccessState>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.5, end: 1.0).animate(
          CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AiGradients.buttonPrimary,
                boxShadow: [
                  BoxShadow(
                    color: AiColors.neonCyan.withOpacity(0.4),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.check_rounded,
                  color: AiColors.textPrimary,
                  size: 56,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Image Generated!',
              style: TextStyle(
                color: AiColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your masterpiece is ready',
              style: TextStyle(
                color: AiColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: widget.onContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AiColors.neonCyan,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Continue Creating',
                  style: TextStyle(
                    color: AiColors.backgroundDeep,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
