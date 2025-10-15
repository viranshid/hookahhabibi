import 'package:flutter/material.dart';

// Slide from left animation
class CustomPageRouteBuilder extends PageRouteBuilder {
  final Widget Function(BuildContext) builder;

  CustomPageRouteBuilder({required this.builder})
      : super(
    pageBuilder: (context, animation, secondaryAnimation) =>
        builder(context),
    transitionDuration: const Duration(milliseconds: 400),
    reverseTransitionDuration: const Duration(milliseconds: 350),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = const Offset(-1.0, 0.0);
      var end = Offset.zero;
      var curve = Curves.easeInOutCubic;

      var tween = Tween(begin: begin, end: end).chain(
        CurveTween(curve: curve),
      );

      var offsetAnimation = animation.drive(tween);

      // Add fade animation
      var fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
        ),
      );

      return SlideTransition(
        position: offsetAnimation,
        child: FadeTransition(
          opacity: fadeAnimation,
          child: child,
        ),
      );
    },
  );
}

// Fade animation
class FadePageRouteBuilder extends PageRouteBuilder {
  final Widget Function(BuildContext) builder;

  FadePageRouteBuilder({required this.builder})
      : super(
    pageBuilder: (context, animation, secondaryAnimation) =>
        builder(context),
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 250),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
  );
}

// Scale and fade animation
class ScalePageRouteBuilder extends PageRouteBuilder {
  final Widget Function(BuildContext) builder;

  ScalePageRouteBuilder({required this.builder})
      : super(
    pageBuilder: (context, animation, secondaryAnimation) =>
        builder(context),
    transitionDuration: const Duration(milliseconds: 400),
    reverseTransitionDuration: const Duration(milliseconds: 350),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var curve = Curves.easeInOutCubic;

      var scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
        CurvedAnimation(parent: animation, curve: curve),
      );

      var fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: animation, curve: curve),
      );

      return ScaleTransition(
        scale: scaleAnimation,
        child: FadeTransition(
          opacity: fadeAnimation,
          child: child,
        ),
      );
    },
  );
}