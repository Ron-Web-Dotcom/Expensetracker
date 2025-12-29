import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedBackgroundWidget extends StatefulWidget {
  const AnimatedBackgroundWidget({super.key});

  @override
  State<AnimatedBackgroundWidget> createState() =>
      _AnimatedBackgroundWidgetState();
}

class _AnimatedBackgroundWidgetState extends State<AnimatedBackgroundWidget>
    with TickerProviderStateMixin {
  late AnimationController _gradientController;
  late AnimationController _particleController;
  late List<Particle> _particles;

  @override
  void initState() {
    super.initState();

    // Gradient animation controller
    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    // Particle animation controller
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // Initialize particles
    _particles = List.generate(
      15,
      (index) => Particle(
        x: Random().nextDouble(),
        y: Random().nextDouble(),
        size: Random().nextDouble() * 80 + 40,
        speed: Random().nextDouble() * 0.5 + 0.2,
        opacity: Random().nextDouble() * 0.3 + 0.1,
      ),
    );
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Stack(
      children: [
        // Animated gradient background
        AnimatedBuilder(
          animation: _gradientController,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          Color.lerp(
                            const Color(0xFF6BCF36),
                            const Color(0xFF5AB82E),
                            _gradientController.value,
                          )!,
                          Color.lerp(
                            const Color(0xFF4A9E26),
                            const Color(0xFF6BCF36),
                            _gradientController.value,
                          )!,
                        ]
                      : [
                          Color.lerp(
                            const Color(0xFF9AE269),
                            const Color(0xFF8AD95A),
                            _gradientController.value,
                          )!,
                          Color.lerp(
                            const Color(0xFF6BCF36),
                            const Color(0xFF9AE269),
                            _gradientController.value,
                          )!,
                        ],
                ),
              ),
            );
          },
        ),

        // Floating particles
        AnimatedBuilder(
          animation: _particleController,
          builder: (context, child) {
            return CustomPaint(
              painter: ParticlePainter(
                particles: _particles,
                animation: _particleController.value,
                isDark: isDark,
              ),
              size: Size.infinite,
            );
          },
        ),
      ],
    );
  }
}

class Particle {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double opacity;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animation;
  final bool isDark;

  ParticlePainter({
    required this.particles,
    required this.animation,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()
        ..color = (isDark ? const Color(0xFF8AD95A) : const Color(0xFF7DD14D))
            .withValues(alpha: particle.opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);

      final yOffset = ((animation * particle.speed) % 1.0);
      final currentY = (particle.y + yOffset) % 1.0;

      canvas.drawCircle(
        Offset(particle.x * size.width, currentY * size.height),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}
