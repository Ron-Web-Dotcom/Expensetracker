import 'package:flutter/material.dart';

/// Custom page route with combined fade, slide, and scale animations
class CustomPageRoute extends PageRouteBuilder {
  final WidgetBuilder builder;
  final RouteSettings settings;

  CustomPageRoute({required this.builder, required this.settings})
    : super(
        settings: settings,
        pageBuilder: (context, animation, secondaryAnimation) =>
            builder(context),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Curved animation for smooth feel
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutCubic,
          );

          // Fade animation (0.0 to 1.0)
          final fadeAnimation = Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(curvedAnimation);

          // Slide animation (from right to center)
          final slideAnimation = Tween<Offset>(
            begin: const Offset(0.3, 0.0),
            end: Offset.zero,
          ).animate(curvedAnimation);

          // Scale animation (0.9 to 1.0 for subtle zoom)
          final scaleAnimation = Tween<double>(
            begin: 0.92,
            end: 1.0,
          ).animate(curvedAnimation);

          // Exit animation for previous screen (fade out slightly)
          final exitFadeAnimation = Tween<double>(
            begin: 1.0,
            end: 0.95,
          ).animate(secondaryAnimation);

          return FadeTransition(
            opacity: exitFadeAnimation,
            child: FadeTransition(
              opacity: fadeAnimation,
              child: SlideTransition(
                position: slideAnimation,
                child: ScaleTransition(scale: scaleAnimation, child: child),
              ),
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
        reverseTransitionDuration: const Duration(milliseconds: 350),
      );
}
