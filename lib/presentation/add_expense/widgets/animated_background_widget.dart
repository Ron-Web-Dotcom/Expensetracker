import 'package:flutter/material.dart';

class AnimatedBackgroundWidget extends StatefulWidget {
  final Color? color;

  const AnimatedBackgroundWidget({super.key, this.color});

  @override
  State<AnimatedBackgroundWidget> createState() =>
      _AnimatedBackgroundWidgetState();
}

class _AnimatedBackgroundWidgetState extends State<AnimatedBackgroundWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = widget.color ?? theme.colorScheme.primary;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                baseColor.withValues(alpha: 0.1),
                baseColor.withValues(alpha: 0.05),
                theme.colorScheme.surface,
              ],
              stops: [
                0.0 + (_controller.value * 0.3),
                0.5 + (_controller.value * 0.2),
                1.0,
              ],
            ),
          ),
        );
      },
    );
  }
}
